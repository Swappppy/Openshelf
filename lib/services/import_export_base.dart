import 'package:drift/drift.dart';
import 'package:collection/collection.dart';
import '../models/tag_type.dart';
import 'database.dart';

/// Standard result for import operations.
class ImportResult {
  final int imported;
  final int skipped;
  final List<String> errors;

  const ImportResult({
    required this.imported,
    required this.skipped,
    this.errors = const [],
  });

  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() => 'ImportResult(imported: $imported, skipped: $skipped, errors: ${errors.length})';
}

/// Standard result for export operations.
class ExportResult {
  final int exported;
  final String content;
  final List<String> errors;

  const ExportResult({
    required this.exported,
    required this.content,
    this.errors = const [],
  });

  bool get hasErrors => errors.isNotEmpty;
}

/// Common utilities for parsing and database operations during import/export.
class ImportExportUtils {
  /// Heuristically finds or creates a tag/collection/imprint by name and type.
  static Future<int> getOrCreateTag(AppDatabase db, String name, TagType type, {String? color, String? imagePath}) async {
    final existing = await db.searchTags(name, type);
    final exact = existing.firstWhereOrNull((t) => t.name.toLowerCase() == name.toLowerCase());
    
    if (exact != null) {
      // Update missing metadata if provided
      if ((color != null && exact.color == null) || (imagePath != null && exact.imagePath == null)) {
        final updated = exact.copyWith(
          color: Value(exact.color ?? color),
          imagePath: Value(exact.imagePath ?? imagePath),
        );
        await db.updateTag(updated);
      }
      return exact.id;
    }

    return await db.insertTag(TagsCompanion.insert(
      name: name,
      type: Value(type),
      color: Value(color),
      imagePath: Value(imagePath),
    ));
  }

  /// Safely parses an integer from a string, supporting decimals (e.g. "518.0").
  static int? parseInt(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw) ?? double.tryParse(raw)?.toInt();
  }

  /// Safely parses a double rating.
  static double? parseRating(String? raw) {
    if (raw == null || raw.isEmpty || raw == '0') return null;
    return double.tryParse(raw);
  }

  /// Common date parser for multiple formats.
  static DateTime? parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final clean = raw.trim();

    // 1. ISO/Dart standard
    final parsed = DateTime.tryParse(clean);
    if (parsed != null) return parsed;

    // 2. Manual split fallback (yyyy/MM/dd or dd/MM/yyyy)
    final parts = clean.split(RegExp(r'[/ \-.]'));
    if (parts.length >= 3) {
      try {
        if (parts[0].length == 4) { // YYYY MM DD
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        } else if (parts[2].length == 4) { // DD MM YYYY
          return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      } catch (_) {}
    }
    return null;
  }
}

extension StringImportExt on String {
  String? nullIfEmpty() => trim().isEmpty || trim().toLowerCase() == 'null' ? null : trim();
}
