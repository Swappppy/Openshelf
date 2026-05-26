import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:csv/csv.dart';

import '../models/tag_type.dart';
import 'database.dart';
import 'import_export_base.dart';

/// Parses and imports a Bookshelf CSV export into the app database.
class BookshelfImportService {
  final AppDatabase _db;
  BookshelfImportService(this._db);

  static const int _colIsbn = 1;
  static const int _colStartedAt = 5;
  static const int _colEndedAt = 6;
  static const int _colPagesRead = 7;
  static const int _colRead = 8;
  static const int _colRating = 9;
  static const int _colReview = 10;
  static const int _colShortNote = 11;
  static const int _colTitle = 18;
  static const int _colSubtitle = 19;
  static const int _colLanguage = 20;
  static const int _colCategories = 21;
  static const int _colAuthors = 22;
  static const int _colTranslator = 24;
  static const int _colPublisher = 28;
  static const int _colPageCount = 29;
  static const int _colPublishedAt = 30;
  static const int _colFormat = 31;
  static const int _colSeries = 33;
  static const int _colVolume = 34;
  static const int _colDescription = 47;
  static const int _colDateAdded = 48;
  static const int _minColumns = 35;

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
        final author = _primaryAuthor(row);
        final isbn = _str(row, _colIsbn).nullIfEmpty();
        
        final isDuplicate = isbn != null 
          ? await _db.getBookByIsbn(isbn) != null
          : await _db.existsByTitleAndAuthor(title, author);

        if (isDuplicate) {
          skipped++;
          continue;
        }

        final ratingRaw = ImportExportUtils.parseRating(_str(row, _colRating));
        final rating = (ratingRaw != null && ratingRaw > 5) ? (ratingRaw / 2) : ratingRaw;

        final companion = _rowToCompanion(row, rating: rating);
        final bookId = await _db.insertBook(companion);

        // Link Collection
        final collName = _str(row, _colSeries).nullIfEmpty();
        if (collName != null) {
          final id = await ImportExportUtils.getOrCreateTag(_db, collName, TagType.collection);
          await (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(BooksCompanion(collectionId: Value(id)));
        }

        // Link Categories
        final catsRaw = _str(row, _colCategories).nullIfEmpty();
        if (catsRaw != null) {
          final names = catsRaw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
          final ids = <int>[];
          for (final name in names) {
            ids.add(await ImportExportUtils.getOrCreateTag(_db, name, TagType.tag));
          }
          if (ids.isNotEmpty) await _db.setBookTags(bookId, ids);
        }

        imported++;
      } catch (e) {
        errors.add('Row $rowNum ("$title"): $e');
        skipped++;
      }
    }

    return ImportResult(imported: imported, skipped: skipped, errors: errors);
  }

  BooksCompanion _rowToCompanion(List<String> row, {double? rating}) {
    final title = _str(row, _colTitle);
    final totalPages = ImportExportUtils.parseInt(_str(row, _colPageCount));
    final currentPage = ImportExportUtils.parseInt(_str(row, _colPagesRead));
    final endedAt = ImportExportUtils.parseDate(_str(row, _colEndedAt));

    return BooksCompanion.insert(
      title: title,
      subtitle: Value(_str(row, _colSubtitle).nullIfEmpty()),
      author: _primaryAuthor(row),
      isbn: Value(_str(row, _colIsbn).nullIfEmpty()),
      language: Value(_str(row, _colLanguage).nullIfEmpty()),
      translator: Value(_str(row, _colTranslator).nullIfEmpty()),
      publisher: Value(_str(row, _colPublisher).nullIfEmpty()),
      totalPages: Value(totalPages),
      currentPage: Value(currentPage),
      status: _parseStatus(row, currentPage, totalPages, endedAt != null),
      rating: Value(rating),
      bookFormat: Value(_parseFormat(_str(row, _colFormat))),
      collectionName: Value(_str(row, _colSeries).nullIfEmpty()),
      collectionNumber: Value(ImportExportUtils.parseInt(_str(row, _colVolume))),
      notes: Value(_buildNotes(row).nullIfEmpty()),
      description: Value(_str(row, _colDescription).nullIfEmpty()),
      publishYear: Value(_parseYear(_str(row, _colPublishedAt))),
      startedAt: Value(ImportExportUtils.parseDate(_str(row, _colStartedAt))),
      finishedAt: Value(endedAt),
      createdAt: Value(ImportExportUtils.parseDate(_str(row, _colDateAdded)) ?? DateTime.now()),
    );
  }

  String _primaryAuthor(List<String> row) {
    final raw = _str(row, _colAuthors);
    return raw.isEmpty ? 'Unknown' : raw.split(',').first.trim();
  }

  String _buildNotes(List<String> row) {
    return [_str(row, _colShortNote), _str(row, _colReview)].where((s) => s.isNotEmpty).join('\n\n');
  }

  BookFormat? _parseFormat(String raw) {
    return switch (raw.toLowerCase()) {
      'paperback' => BookFormat.paperback,
      'hardcover' => BookFormat.hardcover,
      'leatherbound' => BookFormat.leatherbound,
      'digital' || 'ebook' || 'e-book' => BookFormat.digital,
      _ => raw.isEmpty ? null : BookFormat.other,
    };
  }

  ReadingStatus _parseStatus(List<String> row, int? cur, int? tot, bool hasFinished) {
    if (_str(row, _colRead) == '1' || hasFinished) return ReadingStatus.read;
    if (cur != null && cur > 0) {
       if (tot != null && cur >= tot) return ReadingStatus.read;
       return ReadingStatus.reading;
    }
    return ReadingStatus.wantToRead;
  }

  int? _parseYear(String raw) => int.tryParse(raw.split('-').first);
  String _str(List<String> row, int col) => col < row.length ? row[col] : '';
}
