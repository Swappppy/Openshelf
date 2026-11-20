import 'package:drift/drift.dart';
import 'package:collection/collection.dart';
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
    final existing = await db.tagDao.searchTags(name, type);
    final exact = existing.firstWhereOrNull((t) => t.name.toLowerCase() == name.toLowerCase());
    
    if (exact != null) {
      // Update missing metadata if provided
      if ((color != null && exact.color == null) || (imagePath != null && exact.imagePath == null)) {
        final updated = exact.copyWith(
          color: Value(exact.color ?? color),
          imagePath: Value(exact.imagePath ?? imagePath),
        );
        await db.tagDao.updateTag(updated);
      }
      return exact.id;
    }

    return await db.tagDao.insertTag(TagsCompanion.insert(
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

    // 2. Manual split fallback: yyyy/MM/dd, dd/MM/yyyy, or MM/dd/yyyy when the
    //    order is unambiguous (e.g. 12/25/2024). Out-of-range values are
    //    rejected instead of silently rolling over (DateTime(2024, 25, 12)
    //    would otherwise become 2026-01-12).
    final parts = clean.split(RegExp(r'[/ \-.]'));
    if (parts.length >= 3) {
      final a = int.tryParse(parts[0]);
      final b = int.tryParse(parts[1]);
      final c = int.tryParse(parts[2]);
      if (a == null || b == null || c == null) return null;
      if (parts[0].length == 4) return _validDate(a, b, c); // YYYY MM DD
      if (parts[2].length == 4) {
        // Day-first is the default (most locales); month-first only when the
        // first number cannot be a month.
        if (b > 12 && a <= 12) return _validDate(c, a, b); // MM DD YYYY
        return _validDate(c, b, a); // DD MM YYYY
      }
    }
    return null;
  }

  static DateTime? _validDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final d = DateTime(year, month, day);
    return (d.month == month && d.day == day) ? d : null;
  }
}

extension StringImportExt on String {
  String? nullIfEmpty() => trim().isEmpty || trim().toLowerCase() == 'null' ? null : trim();
}
