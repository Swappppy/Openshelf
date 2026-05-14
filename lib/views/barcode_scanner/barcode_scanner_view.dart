import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:camera/camera.dart';
import '../../services/permission_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/app_settings_controller.dart';
import '../../services/book_search_service.dart';
import '../../controllers/database_provider.dart';
import '../../l10n/l10n_extension.dart';
import 'dart:async';
import 'dart:io';

/// A unified scanner view that combines standard barcode scanning with OCR text recognition.
/// This allows capturing both traditional barcodes and printed ISBN text.
class BarcodeScannerView extends ConsumerStatefulWidget {
  final bool batchMode;
  const BarcodeScannerView({super.key, this.batchMode = false});

  @override
  ConsumerState<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends ConsumerState<BarcodeScannerView> {
  // MobileScanner - used for high-performance barcode detection.
  late MobileScannerController _scannerController;

  // Standard Camera package - used for periodic OCR snapshots.
  CameraController? _cameraController;

  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _hasPermission = false;
  bool _isChecking = true;
  bool _isPopped = false;
  bool _isProcessingOcr = false;
  Timer? _ocrTimer;

  // Batch mode feedback state
  bool _isBatchProcessing = false;
  String? _lastAddedTitle;
  String? _lastAddedAuthor;
  String? _warningMessage;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await PermissionService.requestCamera();
    if (mounted) {
      if (granted) {
        _scannerController = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          autoStart: true,
          returnImage: false,
        );
        await _initCameraForOcr();
        // Periodically run OCR on camera snapshots.
        _ocrTimer = Timer.periodic(
          const Duration(milliseconds: 1500),
              (_) => _runOcr(),
        );
      }
      setState(() {
        _hasPermission = granted;
        _isChecking = false;
      });
    }
  }

  /// Initializes the secondary camera controller for OCR snapshots.
  Future<void> _initCameraForOcr() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final back = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _ocrTimer?.cancel();
    _feedbackTimer?.cancel();
    _scannerController.dispose();
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  /// Callback when the MobileScanner detects a valid barcode.
  Future<void> _processBarcode(BarcodeCapture capture) async {
    if (_isPopped || _isBatchProcessing) return;
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue ?? barcode.displayValue;
      if (code != null && code.trim().length >= 10) {
        _onFound(code.trim());
        return;
      }
    }
  }

  /// Captures a frame and runs ML Kit Text Recognition to find printed ISBNs.
  Future<void> _runOcr() async {
    if (_isPopped || _isProcessingOcr) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    _isProcessingOcr = true;
    try {
      final xFile = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(xFile.path);
      final result = await _textRecognizer.processImage(inputImage);

      // Clean up temporary image immediately.
      await File(xFile.path).delete();

      final isbn = _extractIsbn(result.text);
      if (isbn != null) _onFound(isbn);
    } catch (e) {
      debugPrint('OCR Error: $e');
    } finally {
      _isProcessingOcr = false;
    }
  }

  /// Heuristically extracts a valid ISBN from recognized text lines.
  String? _extractIsbn(String text) {
    final lines = text.split('\n');
    for (final line in lines) {
      // Remove common separators
      final clean = line.replaceAll(RegExp(r'[-\s]'), '');

      // Check for ISBN-13
      final isbn13Match = RegExp(r'(97[89]\d{10})').firstMatch(clean);
      if (isbn13Match != null) {
        final candidate = isbn13Match.group(1)!;
        if (_validateIsbn13(candidate)) return candidate;
      }

      // Check for ISBN-10
      final isbn10Match = RegExp(r'(\d{9}[\dX])').firstMatch(clean);
      if (isbn10Match != null) {
        final candidate = isbn10Match.group(1)!;
        if (_validateIsbn10(candidate)) return candidate;
      }
    }
    return null;
  }

  /// ISBN-13 Checksum validation.
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

  /// ISBN-10 Checksum validation.
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
      debugPrint('Scanner found valid code: $code');
      _isPopped = true;
      _ocrTimer?.cancel();
      HapticFeedback.mediumImpact();
      Navigator.pop(context, code);
      return;
    }

    // Batch mode logic
    setState(() {
      _isBatchProcessing = true;
      _warningMessage = null;
    });
    HapticFeedback.lightImpact();

    try {
      final settings = ref.read(appSettingsProvider);
      final db = ref.read(databaseProvider);

      // Check if already in DB
      final existing = await db.getBookByIsbn(code);
      if (existing != null) {
        if (mounted) _showFeedback(warning: context.l10n.errorDuplicateIsbn);
        return;
      }

      // Search for recommended result
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

      // The first result is the Recommended one
      final book = results.first;
      await db.insertBook(book.toCompanion());

      if (mounted) _showFeedback(title: book.title, author: book.authors.join(', '));
    } catch (e) {
      debugPrint('Batch scan error: $e');
      if (mounted) _showFeedback(warning: context.l10n.bookSearchErrorNetwork);
    }
  }

  void _showFeedback({String? title, String? author, String? warning}) {
    if (!mounted) return;
    setState(() {
      _lastAddedTitle = title;
      _lastAddedAuthor = author;
      _warningMessage = warning;
      _isBatchProcessing = false;
    });

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _lastAddedTitle = null;
          _lastAddedAuthor = null;
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
      appBar: AppBar(
        title: Text(widget.batchMode ? context.l10n.scanBatch : context.l10n.scanBarcode),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  default:
                    return const Icon(Icons.flash_auto, color: Colors.grey);
                }
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_outlined),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            fit: BoxFit.cover,
            onDetect: _processBarcode,
          ),
          // Visual scanning guide frame
          Center(
            child: Container(
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
          ),
          
          // Feedback notification area
          if (_lastAddedTitle != null || _warningMessage != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _warningMessage != null 
                        ? Colors.orange.withValues(alpha: 0.9)
                        : Colors.green.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _warningMessage != null ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _warningMessage ?? context.l10n.addedToLibrary,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (_lastAddedTitle != null)
                              Text(
                                '$_lastAddedTitle${_lastAddedAuthor != null ? " · $_lastAddedAuthor" : ""}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black45,
                child: Text(
                  widget.batchMode ? context.l10n.scanBatchSubtitle : context.l10n.scanBarcodeSubtitle,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
