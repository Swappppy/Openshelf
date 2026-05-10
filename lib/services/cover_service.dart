import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
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
  // Deduplicación por hash
  // -------------------------------------------------------

  /// Calcula el MD5 de los bytes y busca si ya existe un archivo
  /// con ese contenido en el directorio de portadas.
  /// Devuelve el path existente o null si no hay duplicado.
  static Future<String?> _findExisting(List<int> bytes) async {
    final hash = md5.convert(bytes).toString();
    final dir = await _coversDir();
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final existing = await entity.readAsBytes();
      if (md5.convert(existing).toString() == hash) return entity.path;
    }
    return null;
  }

  // -------------------------------------------------------
  // Recorte
  // -------------------------------------------------------
  static Future<String?> cropCover(String sourcePath, {required String title}) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: const Color(0xFF6B4E3D),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: title,
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    return cropped?.path;
  }

  static Future<String?> cropImprint(String sourcePath, {required String title}) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: const Color(0xFF6B4E3D),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: title,
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
    final bytes = await File(sourcePath).readAsBytes();
    final existing = await _findExisting(bytes);
    if (existing != null) return existing;

    final dir = await _coversDir();
    final ext = p.extension(sourcePath);
    final filename = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final dest = File(p.join(dir.path, filename));
    await dest.writeAsBytes(bytes);
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
  // Descarga para previsualización (sin recortar)
  // -------------------------------------------------------

  /// Descarga una imagen a /tmp y devuelve el path.
  /// Solo para mostrar en la cuadrícula — no va a /covers.
  /// Implementa reintentos en caso de fallo transitorio.
  static Future<String?> downloadForPreview(String url) async {
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 8));

        // 404 es definitivo, no reintentamos
        if (response.statusCode == 404) {
          debugPrint('Preview 404 (No reintentar): $url');
          return null;
        }

        // Errores de servidor (5xx) o rate limit (429) merecen reintento
        if (response.statusCode != 200) {
          debugPrint('Preview error ${response.statusCode} (Intento ${attempts + 1}): $url');
          attempts++;
          if (attempts < maxAttempts) {
            await Future.delayed(Duration(milliseconds: 500 * attempts));
            continue;
          }
          return null;
        }

        // Validar que sea una imagen (evitar HTML/JSON devuelto con status 200)
        final contentType = response.headers['content-type']?.toLowerCase() ?? '';
        if (!contentType.contains('image/')) {
          debugPrint('Preview no es una imagen ($contentType): $url');
          return null;
        }

        // Open Library devuelve una gif de 1x1 (~43 bytes) si no existe la portada
        if (response.bodyBytes.length < 500) {
          debugPrint('Preview too small (${response.bodyBytes.length}b): $url');
          return null;
        }

        final tempDir = await getTemporaryDirectory();
        final ext = _extensionFromUrl(url);
        final path = p.join(
          tempDir.path,
          'preview_${DateTime.now().millisecondsSinceEpoch}$ext',
        );
        await File(path).writeAsBytes(response.bodyBytes);
        return path;
      } catch (e) {
        attempts++;
        debugPrint('downloadForPreview error (Intento $attempts): $e — $url');
        if (attempts < maxAttempts) {
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          continue;
        }
        return null;
      }
    }
    return null;
  }

  // -------------------------------------------------------
  // Guardar desde URL (con recorte opcional) — deduplicado
  // -------------------------------------------------------
  static Future<String?> saveCoverFromUrl(String url, {bool shouldCrop = true, String? cropTitle}) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      if (response.bodyBytes.length < 1000) return null;

      // Deduplicación: si ya tenemos esta imagen, no volvemos a descargar
      final existing = await _findExisting(response.bodyBytes);
      if (existing != null) return existing;

      final tempDir = await getTemporaryDirectory();
      final ext = _extensionFromUrl(url);
      final tempFile = File(p.join(
        tempDir.path,
        'temp_cover_${DateTime.now().millisecondsSinceEpoch}$ext',
      ));
      await tempFile.writeAsBytes(response.bodyBytes);

      // Si el ratio ya es el correcto (o muy cercano), omitir el recorte
      if (await isRatioCorrect(tempFile.path, 2 / 3)) {
        debugPrint('Smart Crop (Portada): Ratio correcto, omitiendo recorte.');
        final saved = await saveCover(tempFile.path);
        await tempFile.delete();
        return saved;
      }

      if (!shouldCrop) {
        final saved = await saveCover(tempFile.path);
        await tempFile.delete();
        return saved;
      }

      final croppedPath = await cropCover(tempFile.path, title: cropTitle ?? 'Crop');
      await tempFile.delete();
      if (croppedPath == null) return null;
      return await saveCover(croppedPath);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> saveImprintFromUrl(String url, {bool shouldCrop = true, String? cropTitle}) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final tempDir = await getTemporaryDirectory();
      final ext = _extensionFromUrl(url);
      final tempFile = File(p.join(
        tempDir.path,
        'temp_imprint_${DateTime.now().millisecondsSinceEpoch}$ext',
      ));
      await tempFile.writeAsBytes(response.bodyBytes);

      // Sello es 1:1
      if (await isRatioCorrect(tempFile.path, 1.0)) {
        debugPrint('Smart Crop (Sello): Ratio correcto, omitiendo recorte.');
        final saved = await saveImprintImage(tempFile.path);
        await tempFile.delete();
        return saved;
      }

      if (!shouldCrop) {
        final saved = await saveImprintImage(tempFile.path);
        await tempFile.delete();
        return saved;
      }

      final croppedPath = await cropImprint(tempFile.path, title: cropTitle ?? 'Crop');
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

  /// Comprueba si el aspect ratio de una imagen es cercano al deseado (con 5% de tolerancia).
  static Future<bool> isRatioCorrect(String path, double targetRatio) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return false;

      // Usar decodeImage directly para mayor robustez ante archivos con extensiones incorrectas
      final image = img.decodeImage(bytes);
      if (image == null) {
        debugPrint('isRatioCorrect: No se pudo decodificar la imagen (${bytes.length} bytes).');
        return false;
      }

      final currentRatio = image.width / image.height;
      const tolerance = 0.05; // 5% de margen

      final diff = (currentRatio - targetRatio).abs();
      debugPrint('Smart Crop: Detectado ratio ${currentRatio.toStringAsFixed(3)} '
          '(objetivo: ${targetRatio.toStringAsFixed(3)}, diff: ${diff.toStringAsFixed(3)})');
      
      return diff < tolerance;
    } catch (e) {
      debugPrint('isRatioCorrect error: $e');
      return false;
    }
  }

  static String _extensionFromUrl(String url) {
    final uri = Uri.parse(url);
    final ext = p.extension(uri.path);
    if (ext.isNotEmpty) return ext;
    return '.jpg';
  }
}