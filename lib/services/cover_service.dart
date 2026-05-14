import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_cropper/image_cropper.dart';

/// Service for managing book covers and imprint images locally.
class CoverService {
  /// Downloads an image from a URL and saves it to the app's local documents directory.
  static Future<String?> saveCoverFromUrl(String url, {String? cropTitle, bool shouldCrop = true}) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final tempFileName = 'temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final tempPath = p.join(directory.path, tempFileName);
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(response.bodyBytes);

        if (shouldCrop) {
          final cropped = await cropCover(tempPath, title: cropTitle ?? 'Crop Cover');
          if (cropped != null) {
            final finalPath = await saveCover(cropped);
            await tempFile.delete();
            return finalPath;
          }
        }
        
        final finalPath = await saveCover(tempPath);
        return finalPath;
      }
    } catch (e) {
      debugPrint('Error saving cover from URL: $e');
    }
    return null;
  }

  /// Downloads an image to a temporary location for preview purposes.
  static Future<String?> downloadForPreview(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final fileName = 'preview_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = p.join(directory.path, fileName);
        await File(filePath).writeAsBytes(response.bodyBytes);
        return filePath;
      }
    } catch (e) {
      debugPrint('Error downloading preview: $e');
    }
    return null;
  }

  /// Checks if the image at the given path matches the target aspect ratio.
  static Future<bool> isRatioCorrect(String path, double targetRatio) async {
    // Simplified: always return false to trigger crop for now, 
    // or we could use image package to check dimensions.
    return false;
  }

  /// Saves a cover image to the permanent storage.
  static Future<String> saveCover(String path) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}${p.extension(path)}';
    final finalPath = p.join(directory.path, fileName);
    await File(path).copy(finalPath);
    return finalPath;
  }

  /// Provides a standard UI for cropping book covers (usually 2:3 ratio).
  static Future<String?> cropCover(String path, {required String title}) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      ],
    );
    return croppedFile?.path;
  }

  /// Copies a local file to the app's permanent storage directory.
  static Future<String?> saveLocalCover(String tempPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(tempPath)}';
      final filePath = p.join(directory.path, fileName);
      final file = File(tempPath);
      await file.copy(filePath);
      return filePath;
    } catch (e) {
      debugPrint('Error saving local cover: $e');
    }
    return null;
  }

  /// Deletes a local cover image file.
  static Future<void> deleteCover(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting cover: $e');
    }
  }

  /// Provides a standard UI for cropping imprint/publisher logos.
  static Future<String?> cropImprint(String path, {required String title}) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
      ],
    );
    return croppedFile?.path;
  }

  /// Saves an imprint image and returns the local path.
  static Future<String?> saveImprintImage(String tempPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imprintDir = Directory(p.join(directory.path, 'imprints'));
      if (!await imprintDir.exists()) await imprintDir.create(recursive: true);

      final fileName = 'imprint_${ p.basename(tempPath) }';
      final filePath = p.join(imprintDir.path, fileName);
      await File(tempPath).copy(filePath);
      return filePath;
    } catch (e) {
      debugPrint('Error saving imprint image: $e');
      return null;
    }
  }

  /// Downloads and crops an imprint image from a URL.
  static Future<String?> saveImprintFromUrl(String url, {required String cropTitle}) async {
    final temp = await downloadForPreview(url);
    if (temp == null) return null;
    final cropped = await cropImprint(temp, title: cropTitle);
    if (cropped == null) return null;
    return saveImprintImage(cropped);
  }

  /// Deletes an imprint image.
  static Future<void> deleteImprintImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('Error deleting imprint image: $e');
    }
  }
}
