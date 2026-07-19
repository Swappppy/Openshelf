import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:csv/csv.dart';

import '../models/tag_type.dart';
import 'database.dart';
import 'import_export_base.dart';

/// Parses and imports a GoodReads CSV export into the app database.
///
/// Columns are resolved by header name (not fixed index), because Goodreads
/// has been observed to omit columns (e.g. "Average Rating") depending on
/// account state / export version. This makes the parser tolerant of column
/// reordering or omission, as long as the header names stay the same.
class GoodreadsImportService {
  final AppDatabase _db;
  GoodreadsImportService(this._db);

  // Header names as they appear in a Goodreads export. Required columns
  // cause a hard failure if missing (we can't sensibly import without them).
  // Optional columns degrade gracefully to null/empty.
  static const _colTitle = 'Title';
  static const _colAuthor = 'Author';
  static const _colIsbn = 'ISBN';
  static const _colIsbn13 = 'ISBN13';
  static const _colMyRating = 'My Rating';
  static const _colPublisher = 'Publisher';
  static const _colBinding = 'Binding';
  static const _colPageCount = 'Number of Pages';
  static const _colYearPublished = 'Year Published';
  static const _colDateRead = 'Date Read';
  static const _colDateAdded = 'Date Added';
  static const _colBookshelves = 'Bookshelves';
  static const _colExclusiveShelf = 'Exclusive Shelf';
  static const _colMyReview = 'My Review';
  static const _colPrivateNotes = 'Private Notes';
  static const _colReadCount = 'Read Count';
  static const _colOwnedCopies = 'Owned Copies';

  static const _requiredColumns = [_colTitle, _colAuthor];

  static const _exclusiveShelfNames = {'read', 'currently-reading', 'to-read'};

  Future<ImportResult> importFromFile(File file) async {
    final contents = await file.readAsString(encoding: utf8);
    return importFromString(contents);
  }

  Future<ImportResult> importFromString(String contents) async {
    final eol = contents.contains('\r\n') ? '\r\n' : '\n';
    final rows = Csv(lineDelimiter: eol, dynamicTyping: false, autoDetect: false).decode(contents);

    if (rows.isEmpty) return const ImportResult(imported: 0, skipped: 0, errors: ['Empty CSV']);

    final header = rows.first.map((e) => e.toString().trim()).toList();
    final colIndex = <String, int>{};
    for (int i = 0; i < header.length; i++) {
      colIndex[header[i]] = i;
    }

    final missingRequired = _requiredColumns.where((c) => !colIndex.containsKey(c)).toList();
    if (missingRequired.isNotEmpty) {
      return ImportResult(
        imported: 0,
        skipped: 0,
        errors: ['CSV is missing required column(s): ${missingRequired.join(', ')}'],
      );
    }

    final dataRows = rows.skip(1).toList();
    int imported = 0;
    int skipped = 0;
    final errors = <String>[];

    for (int i = 0; i < dataRows.length; i++) {
      final row = dataRows[i].map((e) => e.toString().trim()).toList();
      final rowNum = i + 2;

      final title = _str(row, colIndex, _colTitle);
      if (title.isEmpty) {
        errors.add('Row $rowNum: Missing title');
        skipped++;
        continue;
      }

      try {
        final isbn13 = _parseIsbn(row, colIndex, _colIsbn13);
        final isbn10 = _parseIsbn(row, colIndex, _colIsbn);
        final author = _str(row, colIndex, _colAuthor).split(',').first.trim();

        final isDuplicate = isbn13.isNotEmpty
            ? await _db.bookDao.getBookByIsbn(isbn13) != null
            : isbn10.isNotEmpty
            ? await _db.bookDao.getBookByIsbn(isbn10) != null
            : await _db.bookDao.existsByTitleAndAuthor(title, author);

        if (isDuplicate) {
          skipped++;
          continue;
        }

        final companion = _rowToCompanion(row, colIndex, isbn13: isbn13, isbn10: isbn10);
        final bookId = await _db.bookDao.insertBook(companion);

        // Link Imprint (Publisher)
        final publisher = _str(row, colIndex, _colPublisher).nullIfEmpty();
        if (publisher != null) {
          final id = await ImportExportUtils.getOrCreateTag(_db, publisher, TagType.imprint);
          await (_db.bookDao.update(_db.bookDao.books)..where((b) => b.id.equals(bookId))).write(BooksCompanion(imprintId: Value(id)));
        }

        // Shelves as tags
        final shelfNames = _str(row, colIndex, _colBookshelves).nullIfEmpty()?.split(',').map((s) => s.trim()) ?? [];
        final ids = <int>[];
        for (final name in shelfNames) {
          if (name.isNotEmpty && !_exclusiveShelfNames.contains(name.toLowerCase())) {
            ids.add(await ImportExportUtils.getOrCreateTag(_db, name, TagType.tag));
          }
        }
        if (ids.isNotEmpty) await _db.tagDao.setBookTags(bookId, ids);

        imported++;
      } catch (e) {
        errors.add('Row $rowNum ("$title"): $e');
        skipped++;
      }
    }

    return ImportResult(imported: imported, skipped: skipped, errors: errors);
  }

  BooksCompanion _rowToCompanion(
      List<String> row,
      Map<String, int> colIndex, {
        required String isbn13,
        required String isbn10,
      }) {
    final finishedAt = ImportExportUtils.parseDate(_str(row, colIndex, _colDateRead));
    final isbn = isbn13.isNotEmpty ? isbn13 : (isbn10.isNotEmpty ? isbn10 : null);
    final totalPages = ImportExportUtils.parseInt(_str(row, colIndex, _colPageCount));
    final readCount = ImportExportUtils.parseInt(_str(row, colIndex, _colReadCount)) ?? 0;
    final ownedCopies = ImportExportUtils.parseInt(_str(row, colIndex, _colOwnedCopies)) ?? 1;

    final sessions = <int, int>{};
    if (readCount > 0 && totalPages != null) {
      for (int i = 1; i <= readCount; i++) {
        sessions[i] = totalPages;
      }
    }

    return BooksCompanion.insert(
      title: _str(row, colIndex, _colTitle),
      author: _str(row, colIndex, _colAuthor).split(',').first.trim(),
      isbn: Value(isbn),
      publisher: Value(_str(row, colIndex, _colPublisher).nullIfEmpty()),
      totalPages: Value(totalPages),
      status: _parseStatus(row, colIndex, finishedAt),
      reads: Value(readCount),
      copies: Value(ownedCopies),
      readingSessions: Value(sessions),
      rating: Value(ImportExportUtils.parseRating(_str(row, colIndex, _colMyRating))),
      bookFormat: Value(_parseBinding(_str(row, colIndex, _colBinding))),
      notes: Value(
        [
          _str(row, colIndex, _colMyReview),
          _str(row, colIndex, _colPrivateNotes),
        ].where((s) => s.isNotEmpty).join('\n\n').nullIfEmpty(),
      ),
      publishYear: Value(ImportExportUtils.parseInt(_str(row, colIndex, _colYearPublished))),
      finishedAt: Value(finishedAt),
      createdAt: Value(ImportExportUtils.parseDate(_str(row, colIndex, _colDateAdded)) ?? DateTime.now()),
    );
  }

  String _parseIsbn(List<String> row, Map<String, int> colIndex, String colName) {
    final raw = _str(row, colIndex, colName).replaceAll(RegExp(r'^="?|"?$'), '').trim();
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

  ReadingStatus _parseStatus(List<String> row, Map<String, int> colIndex, DateTime? finishedAt) {
    return switch (_str(row, colIndex, _colExclusiveShelf).toLowerCase()) {
      'read' => ReadingStatus.read,
      'currently-reading' => ReadingStatus.reading,
      'to-read' => ReadingStatus.wantToRead,
      _ => finishedAt != null ? ReadingStatus.read : ReadingStatus.wantToRead,
    };
  }

  /// Looks up [colName] via the header-derived [colIndex] map. Returns ''
  /// if the column doesn't exist in this particular export (optional
  /// column) or if the row is shorter than expected (ragged row).
  String _str(List<String> row, Map<String, int> colIndex, String colName) {
    final idx = colIndex[colName];
    if (idx == null || idx >= row.length) return '';
    return row[idx];
  }
}