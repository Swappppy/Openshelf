import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CoverService {
  // -------------------------------------------------------
  // Directorios
  // -------------------------------------------------------
  static Future<Directory> _coversDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'covers'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> _imprintsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'imprints'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  // -------------------------------------------------------
  // Recorte
  // -------------------------------------------------------
  static Future<String?> cropCover(String sourcePath) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar portada',
          toolbarColor: const Color(0xFF6B4E3D),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Recortar portada',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    return cropped?.path;
  }

  static Future<String?> cropImprint(String sourcePath) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar sello',
          toolbarColor: const Color(0xFF6B4E3D),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Recortar sello',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    return cropped?.path;
  }

  // -------------------------------------------------------
  // Guardar desde path local
  // -------------------------------------------------------
  static Future<String> saveCover(String sourcePath) async {
    final dir = await _coversDir();
    final ext = p.extension(sourcePath);
    final filename = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final dest = File(p.join(dir.path, filename));
    await File(sourcePath).copy(dest.path);
    return dest.path;
  }

  static Future<String> saveImprintImage(String sourcePath) async {
    final dir = await _imprintsDir();
    final ext = p.extension(sourcePath);
    final filename = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final dest = File(p.join(dir.path, filename));
    await File(sourcePath).copy(dest.path);
    return dest.path;
  }

  // -------------------------------------------------------
  // Guardar desde URL
  // -------------------------------------------------------
  static Future<String?> saveCoverFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final tempDir = await getTemporaryDirectory();
      final ext = _extensionFromUrl(url);
      final tempFile = File(p.join(tempDir.path, 'temp_cover_${DateTime.now().millisecondsSinceEpoch}$ext'));
      await tempFile.writeAsBytes(response.bodyBytes);

      final croppedPath = await cropCover(tempFile.path);
      await tempFile.delete();

      if (croppedPath == null) return null;
      return await saveCover(croppedPath);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> saveImprintFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final tempDir = await getTemporaryDirectory();
      final ext = _extensionFromUrl(url);
      final tempFile = File(p.join(tempDir.path, 'temp_imprint_${DateTime.now().millisecondsSinceEpoch}$ext'));
      await tempFile.writeAsBytes(response.bodyBytes);

      final croppedPath = await cropImprint(tempFile.path);
      await tempFile.delete();

      if (croppedPath == null) return null;
      return await saveImprintImage(croppedPath);
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------------
  // Eliminar
  // -------------------------------------------------------
  static Future<void> deleteCover(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  static Future<void> deleteImprintImage(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  // -------------------------------------------------------
  // Utilidades
  // -------------------------------------------------------
  static String _extensionFromUrl(String url) {
    final uri = Uri.parse(url);
    final ext = p.extension(uri.path);
    if (ext.isNotEmpty) return ext;
    return '.jpg';
  }
}