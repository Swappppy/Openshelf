import 'dart:convert';
import 'dart:io';
import '../services/database.dart';
import 'import_export_base.dart';

/// Exports Openshelf's library to a LibraryThing-shaped JSON file: an object
/// keyed by `books_id` (here, Openshelf's own book id) whose values mirror
/// the fields LibrarythingImportService knows how to read back in.
///
/// This is a round-trip format between Openshelf and itself, not a file
/// meant to be re-uploaded to LibraryThing's own site (LT's *importer*
/// expects a different, simpler tab/CSV format; this mirrors LT's *export*
/// JSON shape instead, since that's what the other half of this pair reads).
///
/// Fields Openshelf has no equivalent for (ddc, lcc, subject, awards,
/// workcode, asin/ean/upc, physical dimensions) are omitted entirely rather
/// than emitted as empty placeholders.
class LibrarythingExportService {
  final AppDatabase _db;
  LibrarythingExportService(this._db);

  Future<ExportResult> export() async {
    final books = await _db.bookDao.watchAllBooks().first;
    final errors = <String>[];
    final result = <String, dynamic>{};
    int exported = 0;

    for (final book in books) {
      try {
        final tags = await _db.tagDao.watchTagsForBook(book.id).first;

        String? collectionName = book.collectionName;
        if (collectionName == null && book.collectionId != null) {
          final collTag = await (_db.tagDao.select(_db.tagDao.tags)..where((t) => t.id.equals(book.collectionId!))).getSingleOrNull();
          collectionName = collTag?.name;
        }

        result[book.id.toString()] = _bookToEntry(book, tags, collectionName);
        exported++;
      } catch (e) {
        errors.add('Book "${book.title}" (id ${book.id}): $e');
      }
    }

    final content = const JsonEncoder.withIndent('  ').convert(result);
    return ExportResult(exported: exported, content: content, errors: errors);
  }

  Future<void> writeToFile(ExportResult result, File file) async {
    await file.writeAsString(result.content, encoding: utf8);
  }

  Map<String, dynamic> _bookToEntry(Book book, List<Tag> categoryTags, String? collectionName) {
    final primaryAuthorLf = _firstLastToLastFirst(book.author);
    final authors = <Map<String, String>>[
      {'lf': primaryAuthorLf, 'fl': book.author, 'role': 'Author'},
    ];
    final translator = book.translator;
    if (translator != null && translator.trim().isNotEmpty) {
      authors.add({'lf': _firstLastToLastFirst(translator), 'fl': translator, 'role': 'Translator'});
    }

    final publication = _publicationString(book);
    final formatEntry = _formatEntry(book.bookFormat);

    return {
      'books_id': book.id.toString(),
      'title': book.title,
      'primaryauthor': primaryAuthorLf,
      'primaryauthorrole': 'Author',
      'authors': authors,
      // Openshelf doesn't model LT's own multi-library concept separately
      // from category tags, so every export lands in the default library.
      'collections': ['Your library'],
      if (categoryTags.isNotEmpty) 'genre': categoryTags.map((t) => t.name).toList(),
      if (book.isbn != null && book.isbn!.trim().isNotEmpty) 'isbn': _isbnKeyed(book.isbn!),
      if (book.language != null && book.language!.trim().isNotEmpty) 'language': [book.language],
      if (collectionName != null) 'series': [collectionName],
      'publication': ?publication,
      if (book.publishYear != null) 'date': book.publishYear.toString(),
      'summary': '${book.title} by $primaryAuthorLf${book.publishYear != null ? ' (${book.publishYear})' : ''}',
      if (book.totalPages != null) 'pages': book.totalPages.toString(),
      if (formatEntry != null) 'format': [formatEntry],
      'copies': book.copies.toString(),
      'entrydate': _formatDate(book.createdAt),
    };
  }

  Map<String, String> _isbnKeyed(String isbn) {
    final clean = isbn.replaceAll(RegExp(r'[^0-9Xx]'), '');
    // Mirrors the key convention observed in real LT exports: "0" for
    // ISBN-10, "2" for ISBN-13.
    return {clean.length == 13 ? '2' : '0': isbn};
  }

  String? _publicationString(Book book) {
    if (book.publisher == null && book.publishYear == null && book.totalPages == null) return null;
    final buffer = StringBuffer(book.publisher ?? '');
    if (book.publishYear != null) buffer.write(' (${book.publishYear})');
    if (book.totalPages != null) buffer.write(', ${book.totalPages} pages');
    final text = buffer.toString().trim();
    return text.isEmpty ? null : text;
  }

  Map<String, String>? _formatEntry(BookFormat? format) {
    final text = switch (format) {
      BookFormat.paperback => 'Paperback',
      BookFormat.hardcover => 'Hardcover',
      BookFormat.leatherbound => 'Leatherbound',
      BookFormat.rustic => 'Rústica',
      BookFormat.digital => 'Ebook',
      BookFormat.other => 'Other',
      null => null,
    };
    if (text == null) return null;
    return {'code': '', 'text': text};
  }

  /// Best-effort "First Last" -> "Last, First" reversal (splits on the last
  /// space). Fails gracefully on multi-word surnames or suffixes, same
  /// tradeoff the import side makes in reverse.
  String _firstLastToLastFirst(String fl) {
    final trimmed = fl.trim();
    final idx = trimmed.lastIndexOf(' ');
    if (idx == -1) return trimmed;
    return '${trimmed.substring(idx + 1).trim()}, ${trimmed.substring(0, idx).trim()}';
  }

  String _formatDate(DateTime dt) => '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
