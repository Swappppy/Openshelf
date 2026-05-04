import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CoverService {
  /// Devuelve la carpeta donde se guardan las portadas.
  /// La crea si no existe.
  static Future<Directory> _coversDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final coversDir = Directory(p.join(appDir.path, 'covers'));
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }
    return coversDir;
  }

  /// Copia la imagen seleccionada a la carpeta de portadas
  /// y devuelve la ruta final.
  static Future<String> saveCover(String sourcePath) async {
    final dir = await _coversDir();
    final ext = p.extension(sourcePath);
    final filename = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final dest = File(p.join(dir.path, filename));
    await File(sourcePath).copy(dest.path);
    return dest.path;
  }

  /// Elimina una portada por su ruta.
  static Future<void> deleteCover(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}