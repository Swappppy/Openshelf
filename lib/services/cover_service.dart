import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'database.dart';
import 'http_utils.dart';

/// Service for managing book covers and imprint images locally.
class CoverService {
  /// SharedPreferences key holding the user-selected covers folder.
  static const coversPathPrefKey = 'app_covers_path';

  /// Images above this many pixels are never decoded (decompression-bomb guard).
  static const _maxPixels = 40 * 1000 * 1000;

  static final _random = Random();

  /// File names produced by this service. Only files matching this pattern are
  /// ever deleted automatically, so a stray path can never remove user files.
  static final managedCoverName = RegExp(r'^(cover_[\w-]+|\d+(_\d+)?)\.jpg$');

  static String _uniqueName(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32)}.jpg';

  /// Downloads an image from a URL and saves it to the covers directory.
  static Future<String?> saveCoverFromUrl(
    String url, {
    String? cropTitle,
    String? doneButtonTitle,
    String? cancelButtonTitle,
    bool shouldCrop = true,
    void Function(String?)? onStatusChanged,
  }) async {
    final tempPath = await downloadForPreview(url);
    if (tempPath == null) return null;
    String? cropped;
    try {
      if (shouldCrop && !await isCoverRatio(tempPath)) {
        cropped = await cropCover(
          tempPath,
          title: cropTitle ?? 'Crop Cover',
          doneButtonTitle: doneButtonTitle,
          cancelButtonTitle: cancelButtonTitle,
          onStatusChanged: onStatusChanged,
        );
      }
      onStatusChanged?.call('optimizing');
      return await saveCover(cropped ?? tempPath);
    } catch (e) {
      debugPrint('Error saving cover from URL: $e');
      return null;
    } finally {
      await _deleteQuietly(tempPath);
      if (cropped != null) await _deleteQuietly(cropped);
    }
  }

  /// Downloads an image to a temporary location for preview purposes.
  static Future<String?> downloadForPreview(String url) async {
    try {
      final bytes = await downloadBytes(url);
      if (bytes == null || bytes.isEmpty) return null;
      final directory = await getTemporaryDirectory();
      final filePath = p.join(directory.path, _uniqueName('preview'));
      await File(filePath).writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      debugPrint('Error downloading preview: $e');
    }
    return null;
  }

  /// Reads image dimensions from the header only, without decoding pixels.
  static (int, int)? _dimensions(Uint8List bytes) {
    final info = img.findDecoderForData(bytes)?.startDecode(bytes);
    if (info == null || info.width <= 0 || info.height <= 0) return null;
    return (info.width, info.height);
  }

  /// Accepted cover proportions: 2:3 (most books) and 1:1 (audiobooks and
  /// some square print editions). Anything else is offered for cropping.
  static Future<bool> isCoverRatio(String path) async =>
      await isRatioCorrect(path, 2 / 3) || await isRatioCorrect(path, 1.0);

  /// Checks if the image at the given path matches the target aspect ratio.
  static Future<bool> isRatioCorrect(String path, double targetRatio, {double tolerance = 0.1}) async {
    try {
      final bytes = await File(path).readAsBytes();
      final dims = await Isolate.run(() => _dimensions(bytes));
      if (dims == null) return false;
      final diff = (dims.$1 / dims.$2 - targetRatio).abs();
      return diff <= targetRatio * tolerance;
    } catch (e) {
      debugPrint('Error checking image ratio: $e');
      return false;
    }
  }

  /// Saves a cover image to the permanent storage with automatic compression if enabled.
  static Future<String> saveCover(String path, {bool forceCompress = false}) async {
    final directory = await getCoverDirectory();
    final finalPath = p.join(directory.path, _uniqueName('cover'));

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
    final paths = <String>{
      for (final b in await db.select(db.books).get())
        if (b.coverPath != null) b.coverPath!,
      for (final t in await db.tagDao.getTagsByType(TagType.imprint))
        if (t.imagePath != null) t.imagePath!,
    };
    for (final path in paths) {
      if (await shouldCompress(path)) {
        final tempPath = '$path.tmp';
        await compressImage(path, tempPath);
        await _safeReplaceFile(tempPath, path);
        optimized++;
      }
    }
    return optimized;
  }

  /// Verifies that a temporary file is valid before replacing the original.
  static Future<void> _safeReplaceFile(String tempPath, String originalPath) async {
    final tempFile = File(tempPath);
    try {
      if (await tempFile.exists() && await tempFile.length() > 0) {
        await tempFile.rename(originalPath);
      } else {
        await _deleteQuietly(tempPath);
        debugPrint('CoverService: Compression produced invalid or empty file for $originalPath. Aborting replacement.');
      }
    } catch (e) {
      debugPrint('CoverService: Error during safe file replacement for $originalPath: $e');
      await _deleteQuietly(tempPath);
    }
  }

  /// Checks if an image should be compressed based on its size and dimensions.
  static Future<bool> shouldCompress(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      if (await file.length() < 150 * 1024) return false;
      final bytes = await file.readAsBytes();
      final dims = await Isolate.run(() => _dimensions(bytes));
      if (dims == null || dims.$1 * dims.$2 > _maxPixels) return false;
      return dims.$2 > 1000;
    } catch (_) {
      return false;
    }
  }

  /// Compresses an image to a maximum height and reduced JPEG quality.
  static Future<void> compressImage(String sourcePath, String targetPath, {int maxHeight = 1000, int quality = 75}) async {
    try {
      final bytes = await File(sourcePath).readAsBytes();

      final compressedBytes = await Isolate.run(() {
        final dims = _dimensions(bytes);
        if (dims == null || dims.$1 * dims.$2 > _maxPixels) return null;
        img.Image? image = img.decodeImage(bytes);
        if (image == null) return null;
        if (image.height > maxHeight) {
          image = img.copyResize(image, height: maxHeight, interpolation: img.Interpolation.linear);
        }
        return img.encodeJpg(image, quality: quality);
      });

      if (compressedBytes == null) {
        await File(sourcePath).copy(targetPath);
        return;
      }
      await File(targetPath).writeAsBytes(compressedBytes);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      await File(sourcePath).copy(targetPath);
    }
  }

  /// Provides a standard UI for cropping book covers (usually 2:3 ratio).
  static Future<String?> cropCover(String path, {
    required String title,
    String? doneButtonTitle,
    String? cancelButtonTitle,
    void Function(String?)? onStatusChanged,
  }) async {
    try {
      final preparedPath = await _prepareImageForCropper(path);
      
      // Hide dialog before opening cropper activity to avoid conflicts
      onStatusChanged?.call(null);

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: preparedPath,
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

      // Cleanup temp file if it was created
      if (preparedPath != path) {
        try { await File(preparedPath).delete(); } catch (_) {}
      }

      return croppedFile?.path;
    } catch (e) {
      debugPrint('CoverService: Error during cropCover: $e');
      return null;
    }
  }

  /// Helper to re-encode image to baseline JPEG on Android to avoid UCrop crashes with progressive JPEGs.
  static Future<String> _prepareImageForCropper(String sourcePath) async {
    if (!Platform.isAndroid) return sourcePath;

    try {
      final bytes = await File(sourcePath).readAsBytes();
      
      final encoded = await Isolate.run(() {
        final dims = _dimensions(bytes);
        if (dims == null || dims.$1 * dims.$2 > _maxPixels) return null;
        final image = img.decodeImage(bytes);
        if (image == null) return null;
        // package:image encodeJpg produces baseline JPEGs which BitmapRegionDecoder can handle.
        return img.encodeJpg(image);
      });

      if (encoded == null) return sourcePath;

      final directory = await getTemporaryDirectory();
      final tempPath = p.join(directory.path, _uniqueName('crop_prep'));
      await File(tempPath).writeAsBytes(encoded);
      
      debugPrint('CoverService: Pre-processed image for Android cropper: $tempPath');
      return tempPath;
    } catch (e) {
      debugPrint('CoverService: Failed to pre-process image for cropper: $e');
      return sourcePath;
    }
  }

  /// Copies a local file to the covers directory with compression.
  static Future<String?> saveLocalCover(String tempPath, {void Function(String?)? onStatusChanged}) async {
    try {
      final directory = await getCoverDirectory();
      final filePath = p.join(directory.path, _uniqueName('cover'));
      onStatusChanged?.call('optimizing');
      await compressImage(tempPath, filePath);
      return filePath;
    } catch (e) {
      debugPrint('Error saving local cover: $e');
    } finally {
      // Cropper output lives in the cache; it is no longer needed.
      final tmp = await getTemporaryDirectory();
      if (p.isWithin(tmp.path, tempPath)) await _deleteQuietly(tempPath);
    }
    return null;
  }

  /// Deletes a local cover image file.
  static Future<void> deleteCover(String filePath) => _deleteQuietly(filePath);

  /// Deletes the given cover files unless another book still references them
  /// (duplicated books share the same file). Only files created by this
  /// service are touched.
  static Future<void> deleteUnreferencedCovers(AppDatabase db, Iterable<String?> paths) async {
    for (final path in paths.whereType<String>().toSet()) {
      if (!managedCoverName.hasMatch(p.basename(path))) continue;
      final stillUsed = await (db.select(db.books)
            ..where((b) => b.coverPath.equals(path))
            ..limit(1))
          .getSingleOrNull();
      if (stillUsed == null) await _deleteQuietly(path);
    }
  }

  static Future<void> _deleteQuietly(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('CoverService: could not delete $path: $e');
    }
  }

  /// Returns the directory where new covers are stored: the user-selected
  /// folder if configured and usable, otherwise the app documents directory.
  static Future<Directory> getCoverDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    try {
      final prefs = await SharedPreferences.getInstance();
      final custom = prefs.getString(coversPathPrefKey);
      if (custom != null && custom.isNotEmpty) {
        final dir = Directory(custom);
        if (!await dir.exists()) await dir.create(recursive: true);
        return dir;
      }
    } catch (e) {
      debugPrint('CoverService: custom covers folder unavailable, using default: $e');
    }
    return docDir;
  }

  /// Moves every cover referenced by a book into [newDir] and updates the
  /// database. Only referenced cover files are moved; nothing else in the old
  /// folder is touched. Returns the number of covers moved.
  static Future<int> relocateCovers(AppDatabase db, String newDir) async {
    final dest = Directory(newDir);
    if (!await dest.exists()) await dest.create(recursive: true);

    final moved = <String, String>{}; // old path -> new path (shared covers)
    for (final book in await db.select(db.books).get()) {
      final old = book.coverPath;
      if (old == null) continue;
      if (p.equals(p.dirname(old), dest.path)) continue;

      var target = moved[old];
      if (target == null) {
        final src = File(old);
        if (!await src.exists()) continue;
        target = p.join(dest.path, p.basename(old));
        if (await File(target).exists()) target = p.join(dest.path, _uniqueName('cover'));
        await src.copy(target);
        moved[old] = target;
      }
      await (db.update(db.books)..where((b) => b.id.equals(book.id)))
          .write(BooksCompanion(coverPath: Value(target)));
    }
    for (final old in moved.keys) {
      if (managedCoverName.hasMatch(p.basename(old))) await _deleteQuietly(old);
    }
    return moved.length;
  }

  /// Provides a standard UI for cropping imprint/publisher logos.
  static Future<String?> cropImprint(String path, {
    required String title,
    String? doneButtonTitle,
    String? cancelButtonTitle,
    void Function(String?)? onStatusChanged,
  }) async {
    try {
      final preparedPath = await _prepareImageForCropper(path);

      onStatusChanged?.call(null);

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: preparedPath,
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

      // Cleanup temp file if it was created
      if (preparedPath != path) {
        try { await File(preparedPath).delete(); } catch (_) {}
      }

      return croppedFile?.path;
    } catch (e) {
      debugPrint('CoverService: Error during cropImprint: $e');
      return null;
    }
  }

  /// Saves an imprint image and returns the local path.
  static Future<String?> saveImprintImage(String tempPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imprintDir = Directory(p.join(directory.path, 'imprints'));
      if (!await imprintDir.exists()) await imprintDir.create(recursive: true);

      final fileName = _uniqueName('imprint');
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
    void Function(String?)? onStatusChanged,
  }) async {
    final temp = await downloadForPreview(url);
    if (temp == null) return null;
    final cropped = await cropImprint(
      temp,
      title: cropTitle,
      doneButtonTitle: doneButtonTitle,
      cancelButtonTitle: cancelButtonTitle,
      onStatusChanged: onStatusChanged,
    );
    await _deleteQuietly(temp);
    if (cropped == null) return null;
    onStatusChanged?.call('optimizing');
    final saved = await saveImprintImage(cropped);
    await _deleteQuietly(cropped);
    return saved;
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
