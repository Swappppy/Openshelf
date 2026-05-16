import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';

import '../services/database.dart';

/// Result of a Bookshelf CSV import operation.
class BookshelfImportResult {
  final int imported;
  final int skipped;
  final List<String> errors;

  const BookshelfImportResult({
    required this.imported,
    required this.skipped,
    required this.errors,
  });

  @override
  String toString() =>
      'BookshelfImportResult(imported: $imported, skipped: $skipped, errors: ${errors.length})';
}

/// Parses and imports a Bookshelf CSV export into the app database.
///
/// Usage:
/// ```dart
/// final service = BookshelfImportService(database);
/// final result = await service.importFromFile(File('/path/to/export.csv'));
/// ```
class BookshelfImportService {
  final AppDatabase _db;

  BookshelfImportService(this._db);

  // ── Column indices (based on Bookshelf 2026 export format) ───────────────

  static const int _colIsbn = 1;
  // 2: Bookshelf   — ignored
  // 3: Tags        — ignored
  // 4: Wishlist    — ignored
  static const int _colStartedAt = 5;
  static const int _colEndedAt = 6;
  static const int _colPagesRead = 7;
  static const int _colRead = 8;
  static const int _colRating = 9;
  static const int _colReview = 10;
  static const int _colShortNote = 11;
  // 12: Advanced note — ignored
  // 13: Signed        — ignored
  // 14: Condition     — ignored
  // 15: Number of copies — ignored
  // 16: Quotes        — ignored
  // 17: Flashcards    — ignored
  static const int _colTitle = 18;
  static const int _colSubtitle = 19;
  static const int _colLanguage = 20;
  static const int _colCategories = 21;
  static const int _colAuthors = 22;
  // 23: Illustrators  — ignored
  static const int _colTranslator = 24;
  // 25: Editors       — ignored
  // 26: Narrators     — ignored
  // 27: Photographers — ignored
  static const int _colPublisher = 28;
  static const int _colPageCount = 29;
  static const int _colPublishedAt = 30;
  static const int _colFormat = 31;
  // 32: Edition       — ignored
  static const int _colSeries = 33;
  static const int _colVolume = 34;
  // 35–47: Loan / Purchase / Transfer / Description / Date added — ignored

  static const int _minColumns = 35;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Imports books from a [File] containing a Bookshelf CSV export.
  Future<BookshelfImportResult> importFromFile(File file) async {
    final contents = await file.readAsString(encoding: utf8);
    return _processContents(contents);
  }

  /// Imports books from a raw CSV [String] (useful when reading from a picker
  /// that already gives you the bytes/string).
  Future<BookshelfImportResult> importFromString(String csvContent) {
    return _processContents(csvContent);
  }

  // ── Core logic ────────────────────────────────────────────────────────────

  Future<BookshelfImportResult> _processContents(String contents) async {
    // Detect the line ending used by this file. On Android, file_picker
    // typically gives \n-only files. CsvToListConverter defaults to \r\n,
    // which would treat the entire file as one row on \n-only files.
    // We detect explicitly so the parser splits rows correctly while still
    // respecting quoted multiline cells (e.g. multi-paragraph descriptions).
    final eol = contents.contains('\r\n') ? '\r\n' : '\n';
    final rows = CsvToListConverter(eol: eol, shouldParseNumbers: false)
        .convert(contents);

    if (rows.isEmpty) {
      return const BookshelfImportResult(
        imported: 0,
        skipped: 0,
        errors: ['El archivo CSV está vacío.'],
      );
    }

    // Skip the header row (index 0).
    final dataRows = rows.skip(1).toList();

    int imported = 0;
    int skipped = 0;
    final errors = <String>[];

    for (int i = 0; i < dataRows.length; i++) {
      final row = dataRows[i].map((e) => e.toString().trim()).toList();
      final rowNumber = i + 2; // 1-based + header offset

      // Guard: minimum column count.
      if (row.length < _minColumns) {
        errors.add('Fila $rowNumber: columnas insuficientes (${row.length}).');
        skipped++;
        continue;
      }

      // Guard: title must be present.
      final title = _str(row, _colTitle);
      if (title.isEmpty) {
        errors.add('Fila $rowNumber: título vacío, se omite.');
        skipped++;
        continue;
      }

      try {
        final companion = _rowToCompanion(row);

        // Avoid duplicates: check by ISBN when available, otherwise by title+author.
        final isbn = _str(row, _colIsbn);
        final isDuplicate = isbn.isNotEmpty
            ? await _db.getBookByIsbn(isbn) != null
            : await _existsByTitleAndAuthor(title, _primaryAuthor(row));

        if (isDuplicate) {
          skipped++;
          continue;
        }

        final bookId = await _db.insertBook(companion);
        
        // Handle Categories
        final categoriesRaw = _str(row, _colCategories);
        if (categoriesRaw.isNotEmpty) {
          final categoryNames = categoriesRaw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
          final List<int> tagIds = [];
          for (final name in categoryNames) {
            final tagId = await _getOrCreateTag(name);
            tagIds.add(tagId);
          }
          if (tagIds.isNotEmpty) {
            await _db.setBookTags(bookId, tagIds);
          }
        }
        
        imported++;
      } catch (e) {
        errors.add('Fila $rowNumber ("$title"): $e');
        skipped++;
      }
    }

    return BookshelfImportResult(
      imported: imported,
      skipped: skipped,
      errors: errors,
    );
  }

  Future<int> _getOrCreateTag(String name) async {
    final existing = await _db.searchTags(name, 'tag');
    // searchTags uses .contains, so we check for exact match
    final exact = existing.cast<Tag?>().firstWhere(
      (t) => t?.name.toLowerCase() == name.toLowerCase(),
      orElse: () => null,
    );
    
    if (exact != null) return exact.id;

    return await _db.insertTag(TagsCompanion.insert(
      name: name,
      type: const Value('tag'),
    ));
  }

  // ── Row → BooksCompanion ─────────────────────────────────────────────────

  BooksCompanion _rowToCompanion(List<String> row) {
    final title = _str(row, _colTitle);
    final subtitle = _str(row, _colSubtitle);
    final author = _primaryAuthor(row);
    final isbn = _str(row, _colIsbn);
    final language = _str(row, _colLanguage);
    final translator = _str(row, _colTranslator);
    final publisher = _str(row, _colPublisher);
    final totalPages = _parseInt(row, _colPageCount);
    final currentPage = _parseInt(row, _colPagesRead);
    final rating = _parseRating(row);
    final bookFormat = _parseFormat(row);
    final collectionName = _str(row, _colSeries).nullIfEmpty();
    final collectionNumber = _parseInt(row, _colVolume);
    final notes = _buildNotes(row);
    final publishYear = _parseYear(row);
    final startedAt = _parseDate(row, _colStartedAt);
    final finishedAt = _parseDate(row, _colEndedAt);
    final status = _parseStatus(row, currentPage, totalPages);

    return BooksCompanion.insert(
      title: title,
      subtitle: Value(subtitle.nullIfEmpty()),
      author: author,
      isbn: Value(isbn.nullIfEmpty()),
      language: Value(language.nullIfEmpty()),
      translator: Value(translator.nullIfEmpty()),
      publisher: Value(publisher.nullIfEmpty()),
      totalPages: Value(totalPages),
      currentPage: Value(currentPage),
      status: status,
      rating: Value(rating),
      bookFormat: Value(bookFormat),
      collectionName: Value(collectionName),
      collectionNumber: Value(collectionNumber),
      notes: Value(notes.nullIfEmpty()),
      publishYear: Value(publishYear),
      startedAt: Value(startedAt),
      finishedAt: Value(finishedAt),
    );
  }

  // ── Field parsers ─────────────────────────────────────────────────────────

  /// Returns the first author from a comma-separated authors field.
  String _primaryAuthor(List<String> row) {
    final raw = _str(row, _colAuthors);
    if (raw.isEmpty) return 'Desconocido';
    // Bookshelf separates multiple authors with commas.
    return raw.split(',').first.trim();
  }

  /// Merges Short note and Review into a single notes string.
  String _buildNotes(List<String> row) {
    final parts = [
      _str(row, _colShortNote),
      _str(row, _colReview),
    ].where((s) => s.isNotEmpty).toList();
    return parts.join('\n\n');
  }

  /// Maps Bookshelf's "Format" string to [BookFormat].
  BookFormat? _parseFormat(List<String> row) {
    return switch (_str(row, _colFormat).toLowerCase()) {
      'paperback' => BookFormat.paperback,
      'hardcover' => BookFormat.hardcover,
      'leatherbound' => BookFormat.leatherbound,
      'digital' || 'ebook' || 'e-book' => BookFormat.digital,
      '' => null,
      _ => BookFormat.other,
    };
  }

  /// Derives [ReadingStatus] from the Read, Wishlist, page progress and date fields.
  ReadingStatus _parseStatus(List<String> row, int? currentPage, int? totalPages) {
    final isRead = _str(row, _colRead) == '1';
    final hasFinished = _str(row, _colEndedAt).isNotEmpty;

    if (isRead || hasFinished) return ReadingStatus.read;

    final cur = currentPage ?? 0;
    if (cur == 0) return ReadingStatus.wantToRead;

    final tot = totalPages ?? 0;
    if (tot > 0 && cur >= tot) return ReadingStatus.read;

    return ReadingStatus.reading;
  }

  /// Parses a rating value (0–5 or 0–10 in Bookshelf) as a nullable double.
  double? _parseRating(List<String> row) {
    final raw = _str(row, _colRating);
    if (raw.isEmpty || raw == '0') return null;
    return double.tryParse(raw);
  }

  /// Extracts the year from a "yyyy-MM-dd" or "yyyy" date string.
  int? _parseYear(List<String> row) {
    final raw = _str(row, _colPublishedAt);
    if (raw.isEmpty) return null;
    return int.tryParse(raw.split('-').first);
  }

  /// Parses an optional DateTime from a "yyyy-MM-dd" column.
  DateTime? _parseDate(List<String> row, int col) {
    final raw = _str(row, col);
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  /// Safely reads a string cell, returning '' on out-of-bounds.
  String _str(List<String> row, int col) =>
      col < row.length ? row[col] : '';

  /// Safely parses an integer cell.
  /// Handles both "518" and "518.0" (Bookshelf sometimes exports decimals).
  int? _parseInt(List<String> row, int col) {
    final raw = _str(row, col);
    if (raw.isEmpty) return null;
    return int.tryParse(raw) ?? double.tryParse(raw)?.toInt();
  }

  // ── Duplicate detection ───────────────────────────────────────────────────

  Future<bool> _existsByTitleAndAuthor(String title, String author) async {
    final all = await _db.watchAllBooks().first;
    return all.any(
          (b) =>
      b.title.toLowerCase() == title.toLowerCase() &&
          b.author.toLowerCase() == author.toLowerCase(),
    );
  }
}

// ── Extension helpers ────────────────────────────────────────────────────────

extension _StringNullable on String {
  String? nullIfEmpty() => isEmpty ? null : this;
}