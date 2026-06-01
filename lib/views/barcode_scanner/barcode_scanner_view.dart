import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:camera/camera.dart';
import '../../services/permission_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/app_settings_controller.dart';
import '../../services/book_search_service.dart';
import '../../services/database.dart';
import '../../controllers/database_provider.dart';
import '../../l10n/l10n_extension.dart';
import 'dart:async';
import 'dart:io';
import 'ocr_processor.dart';

enum ScannerMode { barcode, ocr }

/// A unified scanner view that switches between standard barcode scanning and OCR text recognition.
class BarcodeScannerView extends ConsumerStatefulWidget {
  final bool batchMode;
  const BarcodeScannerView({super.key, this.batchMode = false});

  @override
  ConsumerState<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends ConsumerState<BarcodeScannerView> {
  ScannerMode _mode = ScannerMode.barcode;
  
  // MobileScanner - for barcodes
  MobileScannerController? _scannerController;

  // Camera package - for OCR
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];

  bool _hasPermission = false;
  bool _isChecking = true;
  bool _isPopped = false;
  bool _isProcessingOcr = false;
  Timer? _ocrTimer;

  // Batch mode feedback state
  bool _isBatchProcessing = false;
  final List<Book> _recentlyScanned = [];
  String? _warningMessage;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    _preFetchCameras();
    _checkPermission();
  }

  Future<void> _preFetchCameras() async {
    try {
      _availableCameras = await availableCameras();
    } catch (e) {
      debugPrint('Error pre-fetching cameras: $e');
    }
  }

  Future<void> _checkPermission() async {
    final granted = await PermissionService.requestCamera();
    if (mounted) {
      setState(() {
        _hasPermission = granted;
        _isChecking = false;
      });
      if (granted) {
        // Start in default mode
        _startBarcodeMode();
      }
    }
  }

  Future<void> _startBarcodeMode() async {
    await _stopOcrMode();
    if (_isPopped) return;

    setState(() {
      _mode = ScannerMode.barcode;
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        autoStart: true,
        returnImage: false,
      );
    });
  }

  Future<void> _stopBarcodeMode() async {
    if (_scannerController != null) {
      await _scannerController!.dispose();
      _scannerController = null;
    }
  }

  Future<void> _startOcrMode() async {
    await _stopBarcodeMode();
    if (_isPopped) return;

    setState(() {
      _mode = ScannerMode.ocr;
    });

    try {
      if (_availableCameras.isEmpty) {
        _availableCameras = await availableCameras();
      }
      if (_availableCameras.isEmpty) return;

      final back = _availableCameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _availableCameras.first,
      );

      _cameraController = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await _cameraController!.initialize();

      if (mounted && !_isPopped && _mode == ScannerMode.ocr) {
        setState(() {}); // Refresh to show camera preview
        _ocrTimer = Timer.periodic(
          const Duration(milliseconds: 2000),
          (_) => _runOcr(),
        );
      }
    } catch (e) {
      debugPrint('OCR Camera init error: $e');
    }
  }

  Future<void> _stopOcrMode() async {
    _ocrTimer?.cancel();
    _ocrTimer = null;
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
  }

  Future<void> _toggleMode(ScannerMode? newMode) async {
    if (newMode == null || newMode == _mode) return;
    
    if (newMode == ScannerMode.barcode) {
      await _startBarcodeMode();
    } else {
      await _startOcrMode();
    }
  }

  @override
  void dispose() {
    _isPopped = true;
    _ocrTimer?.cancel();
    _feedbackTimer?.cancel();
    _scannerController?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  /// Callback when the MobileScanner detects a valid barcode.
  Future<void> _processBarcode(BarcodeCapture capture) async {
    if (_isPopped || _isBatchProcessing || _mode != ScannerMode.barcode) return;
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue ?? barcode.displayValue;
      if (code != null && code.trim().length >= 10) {
        _onFound(code.trim());
        return;
      }
    }
  }

  /// Captures a frame and runs Tesseract OCR to find printed ISBNs.
  Future<void> _runOcr() async {
    if (_isPopped || _isProcessingOcr || _mode != ScannerMode.ocr) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    _isProcessingOcr = true;
    try {
      final xFile = await _cameraController!.takePicture();
      final String originalPath = xFile.path;
      final String croppedPath = '${Directory.systemTemp.path}/ocr_crop_${DateTime.now().millisecondsSinceEpoch}.png';

      // Background Isolate processing
      final bool success = await compute(OcrProcessor.processAndCrop, OcrCropParams(
        inputPath: originalPath,
        outputPath: croppedPath,
        widthPercent: 0.8,
        heightPercent: 0.4,
      ));

      if (success && mounted && _mode == ScannerMode.ocr) {
        final text = await FlutterTesseractOcr.extractText(
          croppedPath,
          language: 'eng',
          args: {
            "tessedit_char_whitelist": "0123456789X",
            "tessedit_pageseg_mode": "7",
          },
        );

        final croppedFile = File(croppedPath);
        if (await croppedFile.exists()) await croppedFile.delete();
        
        final isbn = _extractIsbn(text);
        if (isbn != null) _onFound(isbn);
      }
      
      final originalFile = File(originalPath);
      if (await originalFile.exists()) await originalFile.delete();

    } catch (e) {
      debugPrint('OCR Error: $e');
    } finally {
      _isProcessingOcr = false;
    }
  }

  String? _extractIsbn(String text) {
    final lines = text.split('\n');
    for (final line in lines) {
      final clean = line.replaceAll(RegExp(r'[^0123456789X]'), '');
      final isbn13Match = RegExp(r'(97[89]\d{10})').firstMatch(clean);
      if (isbn13Match != null) {
        final candidate = isbn13Match.group(1)!;
        if (_validateIsbn13(candidate)) return candidate;
      }
      final isbn10Match = RegExp(r'(\d{9}[\dX])').firstMatch(clean);
      if (isbn10Match != null) {
        final candidate = isbn10Match.group(1)!;
        if (_validateIsbn10(candidate)) return candidate;
      }
    }
    return null;
  }

  bool _validateIsbn13(String isbn) {
    if (isbn.length != 13) return false;
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final d = int.tryParse(isbn[i]) ?? -1;
      if (d < 0) return false;
      sum += i.isEven ? d : d * 3;
    }
    final check = (10 - (sum % 10)) % 10;
    return check == int.tryParse(isbn[12]);
  }

  bool _validateIsbn10(String isbn) {
    if (isbn.length != 10) return false;
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      final d = int.tryParse(isbn[i]) ?? -1;
      if (d < 0) return false;
      sum += d * (10 - i);
    }
    final lastChar = isbn[9].toUpperCase();
    final last = lastChar == 'X' ? 10 : (int.tryParse(lastChar) ?? -1);
    if (last < 0) return false;
    sum += last;
    return sum % 11 == 0;
  }

  void _onFound(String code) async {
    if (_isPopped || _isBatchProcessing) return;

    if (!widget.batchMode) {
      _isPopped = true;
      _ocrTimer?.cancel();
      HapticFeedback.mediumImpact();
      Navigator.pop(context, code);
      return;
    }

    if (mounted) {
      setState(() {
        _isBatchProcessing = true;
        _warningMessage = null;
      });
    }
    HapticFeedback.lightImpact();

    try {
      final settings = ref.read(appSettingsProvider);
      final db = ref.read(databaseProvider);

      final existing = await db.bookDao.getBookByIsbn(code);
      if (existing != null) {
        if (mounted) _showFeedback(warning: context.l10n.errorDuplicateIsbn);
        return;
      }

      final results = await BookSearchService.searchByIsbn(
        code,
        servers: settings.searchServers,
        googleApiKey: settings.googleBooksApiKey,
        preferredLanguage: settings.locale?.languageCode,
      );

      if (results.isEmpty) {
        if (mounted) _showFeedback(warning: context.l10n.bookSearchNoResults(code));
        return;
      }

      final book = results.first;
      final insertedBook = book.toCompanion();
      final id = await db.bookDao.insertBook(insertedBook);
      final fullBook = await db.bookDao.getBook(id);

      if (mounted && fullBook != null) {
        _showFeedback(book: fullBook);
      }
    } catch (e) {
      if (mounted) _showFeedback(warning: context.l10n.bookSearchErrorNetwork);
    }
  }

  void _showFeedback({Book? book, String? warning}) {
    if (!mounted) return;
    setState(() {
      if (book != null) _recentlyScanned.insert(0, book);
      _warningMessage = warning;
      _isBatchProcessing = false;
    });

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _warningMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.scanBarcode)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.no_photography_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  context.l10n.scanBarcodePermission,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _checkPermission,
                  child: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.batchMode ? context.l10n.scanBatch : context.l10n.scanBarcode),
        actions: [
          if (_mode == ScannerMode.barcode && _scannerController != null)
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: _scannerController!,
                builder: (context, state, child) {
                  switch (state.torchState) {
                    case TorchState.off: return const Icon(Icons.flash_off, color: Colors.grey);
                    case TorchState.on: return const Icon(Icons.flash_on, color: Colors.yellow);
                    default: return const Icon(Icons.flash_auto, color: Colors.grey);
                  }
                },
              ),
              onPressed: () => _scannerController?.toggleTorch(),
            ),
          if (_mode == ScannerMode.barcode && _scannerController != null)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios_outlined),
              onPressed: () => _scannerController?.switchCamera(),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Previews
          if (_mode == ScannerMode.barcode && _scannerController != null)
            MobileScanner(
              controller: _scannerController!,
              fit: BoxFit.cover,
              onDetect: _processBarcode,
            )
          else if (_mode == ScannerMode.ocr && _cameraController != null && _cameraController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize!.height,
                  height: _cameraController!.value.previewSize!.width,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),

          // Visual scanning guide frame + Instructions
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 280,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isBatchProcessing 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.white, 
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isBatchProcessing 
                    ? const Center(child: CircularProgressIndicator()) 
                    : null,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _mode == ScannerMode.barcode 
                      ? context.l10n.scanBarcodeSubtitle 
                      : context.l10n.scanIsbnTextSubtitle,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          
          // Mode Selector
          Positioned(
            bottom: widget.batchMode && _recentlyScanned.isNotEmpty ? 190 : 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SegmentedButton<ScannerMode>(
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  segments: [
                    ButtonSegment(
                      value: ScannerMode.barcode,
                      label: Text(context.l10n.scanModeBarcode, style: const TextStyle(fontSize: 12)),
                      icon: const Icon(Icons.qr_code_scanner, size: 18),
                    ),
                    ButtonSegment(
                      value: ScannerMode.ocr,
                      label: Text(context.l10n.scanModeIsbn, style: const TextStyle(fontSize: 12)),
                      icon: const Icon(Icons.text_fields, size: 18),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (set) => _toggleMode(set.first),
                  showSelectedIcon: false,
                ),
              ),
            ),
          ),

          // Batch List
          if (widget.batchMode && _recentlyScanned.isNotEmpty)
            _buildBatchList(),

          // Error/Warning Feedback
          if (_warningMessage != null)
            _buildWarningFeedback(),
        ],
      ),
    );
  }

  Widget _buildBatchList() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECIÉN AÑADIDOS (${_recentlyScanned.length})',
                    style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.done, style: const TextStyle(color: Colors.blue, fontSize: 12)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _recentlyScanned.length,
                itemBuilder: (context, index) {
                  final book = _recentlyScanned[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        if (book.coverPath != null && File(book.coverPath!).existsSync())
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(File(book.coverPath!), width: 30, height: 45, fit: BoxFit.cover),
                          )
                        else
                          Container(width: 30, height: 45, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.book, size: 16, color: Colors.white24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(book.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(book.author, style: const TextStyle(color: Colors.white54, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningFeedback() {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _warningMessage!,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
