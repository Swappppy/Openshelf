import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:camera/camera.dart';
import '../../services/permission_service.dart';
import '../../l10n/l10n_extension.dart';
import 'dart:async';
import 'dart:io';

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({super.key});

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  // MobileScanner - solo para barcodes
  late MobileScannerController _scannerController;

  // Camera - solo para OCR
  CameraController? _cameraController;

  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _hasPermission = false;
  bool _isChecking = true;
  bool _isPopped = false;
  bool _isProcessingOcr = false;
  Timer? _ocrTimer;

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
    _scannerController.dispose();
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  // Solo barcodes
  Future<void> _processBarcode(BarcodeCapture capture) async {
    if (_isPopped) return;
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue ?? barcode.displayValue;
      if (code != null && code.trim().length >= 8) {
        _onFound(code.trim());
        return;
      }
    }
  }

  // OCR via camera package
  Future<void> _runOcr() async {
    if (_isPopped || _isProcessingOcr) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    _isProcessingOcr = true;
    try {
      final xFile = await _cameraController!.takePicture();
      debugPrint('OCR: captured image at ${xFile.path}');

      final inputImage = InputImage.fromFilePath(xFile.path);
      final result = await _textRecognizer.processImage(inputImage);

      // Limpiar archivo temporal
      await File(xFile.path).delete();

      debugPrint('OCR text: "${result.text}"');
      final isbn = _extractIsbn(result.text);
      if (isbn != null) _onFound(isbn);
    } catch (e) {
      debugPrint('OCR Error: $e');
    } finally {
      _isProcessingOcr = false;
    }
  }

  String? _extractIsbn(String text) {
    final lines = text.split('\n');
    for (final line in lines) {
      final clean = line.replaceAll(RegExp(r'[-\s]'), '');

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

  void _onFound(String code) {
    if (_isPopped) return;
    debugPrint('Scanner SUCCESS: $code');
    _isPopped = true;
    _ocrTimer?.cancel();
    HapticFeedback.mediumImpact();
    Navigator.pop(context, code);
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
        title: Text(context.l10n.scanBarcode),
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
          Center(
            child: Container(
              width: 280,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
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
                  context.l10n.scanBarcodeSubtitle,
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