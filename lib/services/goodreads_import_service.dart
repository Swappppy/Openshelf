import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:csv/csv.dart';

import '../models/tag_type.dart';
import 'database.dart';
import 'import_export_base.dart';

/// Parses and imports a GoodReads CSV export into the app database.
class GoodreadsImportService {
  final AppDatabase _db;
  GoodreadsImportService(this._db);

  static const int _colTitle          = 1;
  static const int _colAuthor         = 2;
  static const int _colIsbn           = 5;
  static const int _colIsbn13         = 6;
  static const int _colMyRating       = 7;
  static const int _colPublisher      = 9;
  static const int _colBinding        = 10;
  static const int _colPageCount      = 11;
  static const int _colYearPublished  = 12;
  static const int _colDateRead       = 14;
  static const int _colDateAdded      = 15;
  static const int _colBookshelves    = 16;
  static const int _colExclusiveShelf = 18;
  static const int _colMyReview       = 19;
  static const int _colPrivateNotes   = 21;
  static const int _minColumns = 19;

  static const _exclusiveShelfNames = {'read', 'currently-reading', 'to-read'};

  Future<ImportResult> importFromFile(File file) async {
    final contents = await file.readAsString(encoding: utf8);
    return importFromString(contents);
  }

  Future<ImportResult> importFromString(String contents) async {
    final eol = contents.contains('\r\n') ? '\r\n' : '\n';
    final rows = Csv(lineDelimiter: eol, dynamicTyping: false, autoDetect: false).decode(contents);

    if (rows.isEmpty) return const ImportResult(imported: 0, skipped: 0, errors: ['Empty CSV']);
    
    final dataRows = rows.skip(1).toList();
    int imported = 0;
    int skipped = 0;
    final errors = <String>[];

    for (int i = 0; i < dataRows.length; i++) {
      final row = dataRows[i].map((e) => e.toString().trim()).toList();
      final rowNum = i + 2;

      if (row.length < _minColumns) {
        errors.add('Row $rowNum: Insufficient columns (${row.length})');
        skipped++;
        continue;
      }

      final title = _str(row, _colTitle);
      if (title.isEmpty) {
        errors.add('Row $rowNum: Missing title');
        skipped++;
        continue;
      }

      try {
        final isbn13 = _parseIsbn(row, _colIsbn13);
        final isbn10 = _parseIsbn(row, _colIsbn);
        final author = _str(row, _colAuthor).split(',').first.trim();

        final isDuplicate = isbn13.isNotEmpty
            ? await _db.getBookByIsbn(isbn13) != null
            : isbn10.isNotEmpty
            ? await _db.getBookByIsbn(isbn10) != null
            : await _db.existsByTitleAndAuthor(title, author);

        if (isDuplicate) {
          skipped++;
          continue;
        }

        final companion = _rowToCompanion(row, isbn13: isbn13, isbn10: isbn10);
        final bookId = await _db.insertBook(companion);

        // Shelves as tags
        final shelfNames = _str(row, _colBookshelves).nullIfEmpty()?.split(',').map((s) => s.trim()) ?? [];
        final ids = <int>[];
        for (final name in shelfNames) {
          if (name.isNotEmpty && !_exclusiveShelfNames.contains(name.toLowerCase())) {
            ids.add(await ImportExportUtils.getOrCreateTag(_db, name, TagType.tag));
          }
        }
        if (ids.isNotEmpty) await _db.setBookTags(bookId, ids);

        imported++;
      } catch (e) {
        errors.add('Row $rowNum ("$title"): $e');
        skipped++;
      }
    }

    return ImportResult(imported: imported, skipped: skipped, errors: errors);
  }

  BooksCompanion _rowToCompanion(List<String> row, {required String isbn13, required String isbn10}) {
    final finishedAt = ImportExportUtils.parseDate(_str(row, _colDateRead));
    final isbn = isbn13.isNotEmpty ? isbn13 : (isbn10.isNotEmpty ? isbn10 : null);

    return BooksCompanion.insert(
      title: _str(row, _colTitle),
      author: _str(row, _colAuthor).split(',').first.trim(),
      isbn: Value(isbn),
      publisher: Value(_str(row, _colPublisher).nullIfEmpty()),
      totalPages: Value(ImportExportUtils.parseInt(_str(row, _colPageCount))),
      status: _parseStatus(row, finishedAt),
      rating: Value(ImportExportUtils.parseRating(_str(row, _colMyRating))),
      bookFormat: Value(_parseBinding(_str(row, _colBinding))),
      notes: Value([_str(row, _colMyReview), _str(row, _colPrivateNotes)].where((s) => s.isNotEmpty).join('\n\n').nullIfEmpty()),
      publishYear: Value(ImportExportUtils.parseInt(_str(row, _colYearPublished))),
      finishedAt: Value(finishedAt),
      createdAt: Value(ImportExportUtils.parseDate(_str(row, _colDateAdded)) ?? DateTime.now()),
    );
  }

  String _parseIsbn(List<String> row, int col) {
    final raw = _str(row, col).replaceAll(RegExp(r'^="?|"?$'), '').trim();
    return (raw == '0000000000' || raw == '0000000000000') ? '' : raw;
  }

  BookFormat? _parseBinding(String raw) {
    return switch (raw.toLowerCase()) {
      'paperback' => BookFormat.paperback,
      'hardcover' || 'hardback' => BookFormat.hardcover,
      'kindle edition' || 'ebook' || 'e-book' || 'digital' => BookFormat.digital,
      'leather bound' || 'leatherbound' => BookFormat.leatherbound,
      _ => raw.isEmpty ? null : BookFormat.other,
    };
  }

  ReadingStatus _parseStatus(List<String> row, DateTime? finishedAt) {
    return switch (_str(row, _colExclusiveShelf).toLowerCase()) {
      'read' => ReadingStatus.read,
      'currently-reading' => ReadingStatus.reading,
      'to-read' => ReadingStatus.wantToRead,
      _ => finishedAt != null ? ReadingStatus.read : ReadingStatus.wantToRead,
    };
  }

  String _str(List<String> row, int col) => col < row.length ? row[col] : '';
}
