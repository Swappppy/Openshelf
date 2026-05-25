import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:csv/csv.dart';

import '../models/tag_type.dart';
import '../services/database.dart';

/// Result of a GoodReads CSV import operation.
class GoodreadsImportResult {
  final int imported;
  final int skipped;
  final List<String> errors;

  const GoodreadsImportResult({
    required this.imported,
    required this.skipped,
    required this.errors,
  });

  @override
  String toString() =>
      'GoodreadsImportResult(imported: $imported, skipped: $skipped, errors: ${errors.length})';
}

/// Parses and imports a GoodReads CSV export into the app database.
///
/// GoodReads export columns (current format, as of 2023):
///   0  Book Id
///   1  Title
///   2  Author
///   3  Author l-f
///   4  Additional Authors
///   5  ISBN             (exported as ="0000000000")
///   6  ISBN13           (exported as ="9780000000000")
///   7  My Rating        (0 = not rated, 1–5)
///   8  Average Rating
///   9  Publisher
///  10  Binding
///  11  Number of Pages
///  12  Year Published
///  13  Original Publication Year
///  14  Date Read        (YYYY/MM/DD)
///  15  Date Added       (YYYY/MM/DD)
///  16  Bookshelves      (comma-separated custom shelf names)
///  17  Bookshelves with positions
///  18  Exclusive Shelf  ("read" | "currently-reading" | "to-read")
///  19  My Review
///  20  Spoiler
///  21  Private Notes
///  22  Read Count
///  23  Owned Copies
///
/// Usage:
/// ```dart
/// final service = GoodreadsImportService(database);
/// final result = await service.importFromFile(File('/path/to/goodreads_library_export.csv'));
/// ```
class GoodreadsImportService {
  final AppDatabase _db;

  GoodreadsImportService(this._db);

  // ── Column indices ────────────────────────────────────────────────────────

  static const int _colTitle             = 1;
  static const int _colAuthor            = 2;
  // static const int _colAdditionalAuthors = 4;
  static const int _colIsbn              = 5;
  static const int _colIsbn13            = 6;
  static const int _colMyRating          = 7;
  static const int _colPublisher         = 9;
  static const int _colBinding           = 10;
  static const int _colPageCount         = 11;
  static const int _colYearPublished     = 12;
  static const int _colDateRead          = 14;
  static const int _colDateAdded         = 15;
  static const int _colBookshelves       = 16;
  static const int _colExclusiveShelf    = 18;
  static const int _colMyReview         = 19;
  static const int _colPrivateNotes     = 21;

  static const int _minColumns = 19; // Up to Exclusive Shelf

  // Shelf names that GoodReads uses internally — not imported as tags.
  static const _exclusiveShelfNames = {'read', 'currently-reading', 'to-read'};

  // ── Public API ────────────────────────────────────────────────────────────

  Future<GoodreadsImportResult> importFromFile(File file) async {
    final contents = await file.readAsString(encoding: utf8);
    return _processContents(contents);
  }

  Future<GoodreadsImportResult> importFromString(String csvContent) =>
      _processContents(csvContent);

  // ── Core logic ────────────────────────────────────────────────────────────

  Future<GoodreadsImportResult> _processContents(String contents) async {
    final eol = contents.contains('\r\n') ? '\r\n' : '\n';
    final rows = Csv(lineDelimiter: eol, dynamicTyping: false, autoDetect: false)
        .decode(contents);

    if (rows.isEmpty) {
      return const GoodreadsImportResult(
        imported: 0,
        skipped: 0,
        errors: ['El archivo CSV está vacío.'],
      );
    }

    final dataRows = rows.skip(1).toList(); // Skip header

    int imported = 0;
    int skipped  = 0;
    final errors = <String>[];

    for (int i = 0; i < dataRows.length; i++) {
      final row       = dataRows[i].map((e) => e.toString().trim()).toList();
      final rowNumber = i + 2;

      if (row.length < _minColumns) {
        errors.add('Fila $rowNumber: columnas insuficientes (${row.length}).');
        skipped++;
        continue;
      }

      final title = _str(row, _colTitle);
      if (title.isEmpty) {
        errors.add('Fila $rowNumber: título vacío, se omite.');
        skipped++;
        continue;
      }

      try {
        // GoodReads exports ISBN as ="0000000000" — strip the Excel formula wrapper.
        final isbn13 = _parseGoodreadsIsbn(row, _colIsbn13);
        final isbn10 = _parseGoodreadsIsbn(row, _colIsbn);

        // Prefer ISBN13 for dedup; fall back to ISBN10, then title+author.
        final isDuplicate = isbn13.isNotEmpty
            ? await _db.getBookByIsbn(isbn13) != null
            : isbn10.isNotEmpty
            ? await _db.getBookByIsbn(isbn10) != null
            : await _existsByTitleAndAuthor(title, _str(row, _colAuthor));

        if (isDuplicate) {
          skipped++;
          continue;
        }

        final companion = _rowToCompanion(row, isbn13: isbn13, isbn10: isbn10);
        final bookId    = await _db.insertBook(companion);

        // Import custom bookshelves as tags (excluding the three built-in ones).
        final shelfTags = _parseCustomShelves(row);
        if (shelfTags.isNotEmpty) {
          final tagIds = <int>[];
          for (final name in shelfTags) {
            tagIds.add(await _getOrCreateTag(name, TagType.tag));
          }
          await _db.setBookTags(bookId, tagIds);
        }

        imported++;
      } catch (e) {
        errors.add('Fila $rowNumber ("$title"): $e');
        skipped++;
      }
    }

    return GoodreadsImportResult(
      imported: imported,
      skipped:  skipped,
      errors:   errors,
    );
  }

  // ── Row → BooksCompanion ─────────────────────────────────────────────────

  BooksCompanion _rowToCompanion(
      List<String> row, {
        required String isbn13,
        required String isbn10,
      }) {
    final title      = _str(row, _colTitle);
    final author     = _str(row, _colAuthor).let(_firstAuthor);
    final publisher  = _str(row, _colPublisher).nullIfEmpty();
    final totalPages = _parseInt(row, _colPageCount);
    final rating     = _parseRating(row);
    final bookFormat = _parseBinding(row);
    final publishYear= _parseYear(row);
    final finishedAt = _parseDate(row, _colDateRead);
    final createdAt  = _parseDate(row, _colDateAdded) ?? DateTime.now();
    final status     = _parseStatus(row, finishedAt);
    final notes      = _buildNotes(row);

    // Prefer ISBN13; use ISBN10 as fallback; store null if neither is present.
    final isbnToStore = isbn13.isNotEmpty
        ? isbn13
        : isbn10.isNotEmpty
        ? isbn10
        : null;

    return BooksCompanion.insert(
      title:       title,
      author:      author,
      isbn:        Value(isbnToStore),
      publisher:   Value(publisher),
      totalPages:  Value(totalPages),
      status:      status,
      rating:      Value(rating),
      bookFormat:  Value(bookFormat),
      notes:       Value(notes.nullIfEmpty()),
      publishYear: Value(publishYear),
      finishedAt:  Value(finishedAt),
      createdAt:   Value(createdAt),
      // Fields not present in GoodReads exports:
      subtitle:         const Value(null),
      language:         const Value(null),
      translator:       const Value(null),
      collectionName:   const Value(null),
      collectionNumber: const Value(null),
      description:      const Value(null),
      currentPage:      const Value(null),
      startedAt:        const Value(null),
    );
  }

  // ── Field parsers ─────────────────────────────────────────────────────────

  /// Strips GoodReads' Excel-formula ISBN wrapper: ="0140275363" → 0140275363
  String _parseGoodreadsIsbn(List<String> row, int col) {
    final raw = _str(row, col);
    if (raw.isEmpty) return '';
    // Format: ="digits" — remove leading =" and trailing "
    final stripped = raw.replaceAll(RegExp(r'^="?|"?$'), '').trim();
    return stripped == '0000000000' || stripped == '0000000000000'
        ? '' // GoodReads exports all-zeros when ISBN is unknown
        : stripped;
  }

  /// Returns the first author from a "Firstname Lastname" string.
  /// GoodReads puts primary author in col 2 directly; Additional Authors in col 4.
  String _firstAuthor(String raw) {
    if (raw.isEmpty) return 'Desconocido';
    return raw.split(',').first.trim();
  }

  /// Maps GoodReads' "Binding" to [BookFormat].
  BookFormat? _parseBinding(List<String> row) {
    return switch (_str(row, _colBinding).toLowerCase()) {
      'paperback'                           => BookFormat.paperback,
      'hardcover' || 'hardback'             => BookFormat.hardcover,
      'kindle edition' || 'ebook' ||
      'e-book' || 'digital'                 => BookFormat.digital,
      'leather bound' || 'leatherbound'     => BookFormat.leatherbound,
      ''                                    => null,
      _                                     => BookFormat.other,
    };
  }

  /// Maps GoodReads' Exclusive Shelf to [ReadingStatus].
  ReadingStatus _parseStatus(List<String> row, DateTime? finishedAt) {
    return switch (_str(row, _colExclusiveShelf)) {
      'read'               => ReadingStatus.read,
      'currently-reading'  => ReadingStatus.reading,
      'to-read'            => ReadingStatus.wantToRead,
    // Edge case: finished date present but shelf miscategorized
      _ when finishedAt != null => ReadingStatus.read,
      _                         => ReadingStatus.wantToRead,
    };
  }

  /// Rating 0 in GoodReads means "not rated" → null.
  double? _parseRating(List<String> row) {
    final raw = _str(row, _colMyRating);
    if (raw.isEmpty || raw == '0') return null;
    return double.tryParse(raw);
  }

  /// Extracts four-digit year from "Year Published" column.
  int? _parseYear(List<String> row) {
    final raw = _str(row, _colYearPublished);
    if (raw.isEmpty) return null;
    return int.tryParse(raw.split(RegExp(r'[/\-]')).first);
  }

  /// Parses GoodReads date format: YYYY/MM/DD
  DateTime? _parseDate(List<String> row, int col) {
    final raw = _str(row, col).trim();
    if (raw.isEmpty) return null;

    // Primary: YYYY/MM/DD (GoodReads standard)
    final parts = raw.split(RegExp(r'[/\-.]'));
    if (parts.length >= 3) {
      try {
        if (parts[0].length == 4) {
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      } catch (_) {}
    }

    // Fallback: ISO 8601
    return DateTime.tryParse(raw);
  }

  /// Merges My Review and Private Notes into a single notes string.
  String _buildNotes(List<String> row) {
    return [
      _str(row, _colMyReview),
      _str(row, _colPrivateNotes),
    ].where((s) => s.isNotEmpty).join('\n\n');
  }

  /// Parses custom bookshelves, filtering out GoodReads' built-in shelf names.
  List<String> _parseCustomShelves(List<String> row) {
    final raw = _str(row, _colBookshelves);
    if (raw.isEmpty) return [];
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && !_exclusiveShelfNames.contains(s))
        .toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _str(List<String> row, int col) =>
      col < row.length ? row[col] : '';

  int? _parseInt(List<String> row, int col) {
    final raw = _str(row, col);
    if (raw.isEmpty) return null;
    return int.tryParse(raw) ?? double.tryParse(raw)?.toInt();
  }

  Future<int> _getOrCreateTag(String name, TagType type) async {
    final existing = await _db.searchTags(name, type);
    final exact = existing.cast<Tag?>().firstWhere(
          (t) => t?.name.toLowerCase() == name.toLowerCase(),
      orElse: () => null,
    );
    if (exact != null) return exact.id;
    return _db.insertTag(TagsCompanion.insert(
      name: name,
      type: Value(type),
    ));
  }

  Future<bool> _existsByTitleAndAuthor(String title, String author) async {
    final all = await _db.watchAllBooks().first;
    return all.any(
          (b) =>
      b.title.toLowerCase()  == title.toLowerCase() &&
          b.author.toLowerCase() == author.toLowerCase(),
    );
  }
}

// ── Extension helpers ────────────────────────────────────────────────────────

extension _StringHelpers on String {
  String? nullIfEmpty() => isEmpty ? null : this;
  T let<T>(T Function(String) fn) => fn(this);
}