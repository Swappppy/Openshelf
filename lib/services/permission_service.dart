import 'package:permission_handler/permission_handler.dart';

/// Centralized service for handling Android/iOS runtime permissions.
class PermissionService {
  /// Requests access to the device photo gallery.
  static Future<bool> requestGallery() async {
    final status = await Permission.photos.request();
    if (status.isGranted) return true;
    
    // Fallback for older Android versions where 'photos' might not be the right key.
    if (await Permission.storage.request().isGranted) return true;
    
    return false;
  }

  /// Requests access to the device camera.
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
}
