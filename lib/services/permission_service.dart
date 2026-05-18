import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {

  static int? _sdk;

  static Future<int> _getAndroidSdk() async {
    if (_sdk != null) return _sdk!;
    if (!Platform.isAndroid) return 0;
    try {
      _sdk = await const MethodChannel('dev.flutter.pigeon/platform_info')
          .invokeMethod<int>('getAndroidSdkInt') ?? 21;    } catch (_) {
      _sdk = 21; // fallback conservador, no 33
    }
    return _sdk!;
  }

  static Future<bool> requestGallery() async {
    if (Platform.isIOS) {
      final s = await Permission.photos.request();
      return s.isGranted || s.isLimited;
    }

    if (Platform.isAndroid) {
      final sdk = await _getAndroidSdk();

      if (sdk >= 34) {
        // Android 14+: pedir ambos para activar el selector parcial
        final results = await [
          Permission.photos,
          Permission.mediaLibrary,
        ].request();
        return (results[Permission.photos]?.isGranted ?? false) ||
            (results[Permission.photos]?.isLimited ?? false) ||
            (results[Permission.mediaLibrary]?.isGranted ?? false) ||
            (results[Permission.mediaLibrary]?.isLimited ?? false);
      }

      if (sdk >= 33) {
        // Android 13: solo READ_MEDIA_IMAGES
        final s = await Permission.photos.request();
        return s.isGranted || s.isLimited;
      }

      // Android 6–12: READ_EXTERNAL_STORAGE
      return (await Permission.storage.request()).isGranted;
    }

    return true;
  }

  static Future<bool> requestCamera() async {
    return (await Permission.camera.request()).isGranted;
  }

  static Future<bool> requestStorage() async {
    if (!Platform.isAndroid) return true;
    final sdk = await _getAndroidSdk();
    if (sdk >= 33) return true; // el almacenamiento interno no necesita permiso
    return (await Permission.storage.request()).isGranted;
  }

  static Future<bool> isPermanentlyDenied(Permission permission) =>
      permission.isPermanentlyDenied;

  static Future<void> openSettings() => openAppSettings();
}