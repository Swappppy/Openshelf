import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

enum GalleryPermissionResult { granted, denied, permanentlyDenied }

class PermissionService {

  static Future<GalleryPermissionResult> requestGallery() async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt >= 33) {
        final photos = await Permission.photos.request();
        debugPrint('>>> photos status: $photos');
        if (photos.isGranted || photos.isLimited) {
          return GalleryPermissionResult.granted;
        }
        if (photos.isPermanentlyDenied) return GalleryPermissionResult.permanentlyDenied;
        return GalleryPermissionResult.denied;
      }

      final storage = await Permission.storage.request();
      debugPrint('>>> storage status: $storage');

      if (storage.isGranted) return GalleryPermissionResult.granted;
      if (storage.isPermanentlyDenied) return GalleryPermissionResult.permanentlyDenied;
      return GalleryPermissionResult.denied;
    }

    if (Platform.isIOS) {
      final s = await Permission.photos.request();
      if (s.isGranted || s.isLimited) return GalleryPermissionResult.granted;
      if (s.isPermanentlyDenied) return GalleryPermissionResult.permanentlyDenied;
      return GalleryPermissionResult.denied;
    }

    return GalleryPermissionResult.granted;
  }

  static Future<bool> requestCamera() async {
    final s = await Permission.camera.request();
    return s.isGranted;
  }

  static Future<bool> requestStorage() async {
    if (!Platform.isAndroid) return true;

    final info = await DeviceInfoPlugin().androidInfo;
    
    // On Android 11+ (API 30), standard Permission.storage.request() 
    // often returns 'denied' immediately without showing a popup 
    // due to Scoped Storage, unless we use MANAGE_EXTERNAL_STORAGE.
    // However, for CSV/ZIP import/export, FilePicker (SAF) works 
    // WITHOUT manual permission gating.
    if (info.version.sdkInt >= 30) {
      return true;
    }

    final s = await Permission.storage.request();
    return s.isGranted;
  }

  static Future<bool> isPermanentlyDenied(Permission permission) =>
      permission.isPermanentlyDenied;

  static Future<void> openSettings() => openAppSettings();
}
