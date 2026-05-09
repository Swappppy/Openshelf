import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request Camera permission. Returns true if granted.
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request Gallery/Photos permission. Returns true if granted.
  static Future<bool> requestGallery() async {
    if (Platform.isAndroid) {
      // Android 13+ uses READ_MEDIA_IMAGES
      final status = await Permission.photos.request();
      if (status.isGranted) return true;

      // Fallback for older Android versions
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else {
      // iOS
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }
}
