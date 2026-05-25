import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'database.dart';

/// Service for managing book covers and imprint images locally.
class CoverService {
  /// Downloads an image from a URL and saves it to the app's local documents directory.
  static Future<String?> saveCoverFromUrl(
    String url, {
    String? cropTitle,
    String? doneButtonTitle,
    String? cancelButtonTitle,
    bool shouldCrop = true,
  }) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final tempFileName = 'temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final tempPath = p.join(directory.path, tempFileName);
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(response.bodyBytes);

        if (shouldCrop) {
          final isGood = await isRatioCorrect(tempPath, 2 / 3);
          if (isGood) {
            final finalPath = await saveCover(tempPath);
            await tempFile.delete();
            return finalPath;
          }

          final cropped = await cropCover(
            tempPath, 
            title: cropTitle ?? 'Crop Cover',
            doneButtonTitle: doneButtonTitle,
            cancelButtonTitle: cancelButtonTitle,
          );
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
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'Openshelf/1.0.0 (https://github.com/ftena/openshelf)',
      });
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
  static Future<bool> isRatioCorrect(String path, double targetRatio, {double tolerance = 0.1}) async {
    try {
      final bytes = await File(path).readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return false;
      
      final currentRatio = image.width / image.height;
      final diff = (currentRatio - targetRatio).abs();
      final threshold = targetRatio * tolerance;
      
      final isCorrect = diff <= threshold;
      debugPrint('CoverService: SmartCrop check - current=$currentRatio, target=$targetRatio, diff=$diff, threshold=$threshold, result=$isCorrect');
      return isCorrect;
    } catch (e) {
      debugPrint('Error checking image ratio: $e');
      return false;
    }
  }

  /// Saves a cover image to the permanent storage with automatic compression if enabled.
  static Future<String> saveCover(String path, {bool forceCompress = false}) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final finalPath = p.join(directory.path, fileName);
    
    // Apply compression if forced or if would benefit from it
    if (forceCompress || await shouldCompress(path)) {
      await compressImage(path, finalPath);
    } else {
      await File(path).copy(finalPath);
    }
    
    return finalPath;
  }

  /// Iterates over all books and imprints and compresses images that benefit from it.
  static Future<int> batchCompressAll(AppDatabase db) async {
    int optimized = 0;

    // 1. Books
    final allBooks = await db.select(db.books).get();
    for (final book in allBooks) {
      if (book.coverPath != null) {
        if (await shouldCompress(book.coverPath!)) {
          // We compress in-place by using a temp file
          final tempPath = '${book.coverPath!}.tmp';
          await compressImage(book.coverPath!, tempPath);
          await File(tempPath).rename(book.coverPath!);
          optimized++;
        }
      }
    }

    // 2. Imprints
    final allImprints = await db.getTagsByType('imprint');
    for (final imp in allImprints) {
      if (imp.imagePath != null) {
        if (await shouldCompress(imp.imagePath!)) {
          final tempPath = '${imp.imagePath!}.tmp';
          await compressImage(imp.imagePath!, tempPath);
          await File(tempPath).rename(imp.imagePath!);
          optimized++;
        }
      }
    }

    return optimized;
  }

  /// Checks if an image should be compressed based on its size and dimensions.
  static Future<bool> shouldCompress(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      
      // If file is very small (< 150KB), don't bother compressing again
      final size = await file.length();
      if (size < 150 * 1024) return false;

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return false;

      // If height is large (> 1000px), it should be compressed/resized
      if (image.height > 1000) return true;
      
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Compresses an image to a maximum height and reduced JPEG quality.
  static Future<void> compressImage(String sourcePath, String targetPath, {int maxHeight = 1000, int quality = 75}) async {
    try {
      final bytes = await File(sourcePath).readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) {
        // Fallback to simple copy if decoding fails
        await File(sourcePath).copy(targetPath);
        return;
      }

      // Resize if height exceeds limit
      if (image.height > maxHeight) {
        image = img.copyResize(image, height: maxHeight, interpolation: img.Interpolation.linear);
      }

      // Encode as compressed JPEG
      final compressedBytes = img.encodeJpg(image, quality: quality);
      await File(targetPath).writeAsBytes(compressedBytes);
      debugPrint('CoverService: Compressed image saved to $targetPath (Quality: $quality, Height: ${image.height})');
    } catch (e) {
      debugPrint('Error compressing image: $e');
      // Final fallback
      await File(sourcePath).copy(targetPath);
    }
  }

  /// Provides a standard UI for cropping book covers (usually 2:3 ratio).
  static Future<String?> cropCover(String path, {
    required String title,
    String? doneButtonTitle,
    String? cancelButtonTitle,
  }) async {
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
        IOSUiSettings(
          title: title,
          doneButtonTitle: doneButtonTitle,
          cancelButtonTitle: cancelButtonTitle,
        ),
      ],
    );
    return croppedFile?.path;
  }

  /// Copies a local file to the app's permanent storage directory with compression.
  static Future<String?> saveLocalCover(String tempPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = p.join(directory.path, fileName);
      
      await compressImage(tempPath, filePath);
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

  /// Returns the directory where covers are stored.
  static Future<Directory> getCoverDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    return docDir; // Currently stored in root documents
  }

  /// Provides a standard UI for cropping imprint/publisher logos.
  static Future<String?> cropImprint(String path, {
    required String title,
    String? doneButtonTitle,
    String? cancelButtonTitle,
  }) async {
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
        IOSUiSettings(
          title: title,
          doneButtonTitle: doneButtonTitle,
          cancelButtonTitle: cancelButtonTitle,
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
  static Future<String?> saveImprintFromUrl(
    String url, {
    required String cropTitle,
    String? doneButtonTitle,
    String? cancelButtonTitle,
  }) async {
    final temp = await downloadForPreview(url);
    if (temp == null) return null;
    final cropped = await cropImprint(
      temp, 
      title: cropTitle,
      doneButtonTitle: doneButtonTitle,
      cancelButtonTitle: cancelButtonTitle,
    );
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
