import 'dart:convert';
import 'dart:io';
import '../services/database.dart';
import 'import_export_base.dart';

/// Exports OpenShelf books to a Bookshelf-compatible CSV file.
class BookshelfExportService {
  final AppDatabase _db;
  BookshelfExportService(this._db);

  static const List<String> _headers = [
    'Book Id', 'ISBN', 'Bookshelf', 'Tags', 'Wishlist', 'Started Reading On', 'Ended Reading On',
    'Pages Read', 'Read', 'My Rating', 'Review', 'Short note', 'Advanced note', 'Signed',
    'Condition', 'Number of copies', 'Quotes', 'Flashcards', 'Title', 'Subtitle', 'Language',
    'Categories', 'Authors', 'Illustrators', 'Translators', 'Editors', 'Narrators', 'Photographers',
    'Publisher', 'Page Count', 'Published At', 'Format', 'Edition', 'Series', 'Volume', 'Loan Type',
    'Loan Name', 'Loan Start Date', 'Loan Due Date', 'Purchase Type', 'Purchase From', 'Purchase Price',
    'Purchase Date', 'Transfer Type', 'Transfer place', 'Transfer Price', 'Transfer Date', 'Description', 'Date added',
  ];

  Future<ExportResult> export() async {
    final books = await _db.bookDao.watchAllBooks().first;
    final errors = <String>[];
    final rows = <List<String>>[_headers];

    for (final book in books) {
      try {
        final tags = await _db.tagDao.watchTagsForBook(book.id).first;
        String? collectionName = book.collectionName;
        if (collectionName == null && book.collectionId != null) {
          final collTag = await (_db.tagDao.select(_db.tagDao.tags)
            ..where((t) => t.id.equals(book.collectionId!))).getSingleOrNull();
          collectionName = collTag?.name;
        }

        rows.add(_bookToRow(book, tags, collectionName: collectionName));
      } catch (e) {
        errors.add('Book "${book.title}" (id ${book.id}): $e');
      }
    }

    return ExportResult(
      exported: rows.length - 1,
      content: _encodeCsv(rows),
      errors: errors,
    );
  }

  Future<void> writeToFile(ExportResult result, File file) async {
    await file.writeAsString(result.content, encoding: utf8);
  }

  List<String> _bookToRow(Book book, List<Tag> tags, {String? collectionName}) {
    final categoryNames = tags.map((t) => t.name).join(',');
    final row = List<String>.filled(49, '');

    row[0] = book.id.toString();
    row[1] = book.isbn ?? '';
    row[2] = book.status == ReadingStatus.wantToRead ? 'Wishlist' : 'My Books';
    row[3] = categoryNames;
    row[4] = '0';
    row[5] = _formatDate(book.startedAt);
    row[6] = _formatDate(book.finishedAt);
    row[7] = book.currentPage?.toString() ?? '';
    row[8] = book.status == ReadingStatus.read ? '1' : '0';
    row[9] = book.rating != null ? (book.rating! * 2).round().clamp(1, 10).toString() : '';
    row[10] = book.notes ?? '';
    row[18] = book.title;
    row[19] = book.subtitle ?? '';
    row[20] = book.language ?? '';
    row[21] = categoryNames;
    row[22] = book.author;
    row[24] = book.translator ?? '';
    row[28] = book.publisher ?? '';
    row[29] = book.totalPages?.toString() ?? '';
    row[30] = book.publishYear != null ? '${book.publishYear.toString().padLeft(4, '0')}-01-01' : '';
    row[31] = _mapFormat(book.bookFormat);
    row[33] = collectionName ?? '';
    row[34] = book.collectionNumber?.toString() ?? '';
    row[47] = book.description ?? '';
    row[48] = _formatDate(book.createdAt);

    return row;
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _mapFormat(BookFormat? format) => switch (format) {
    BookFormat.paperback => 'paperback',
    BookFormat.hardcover => 'hardcover',
    BookFormat.leatherbound => 'leatherbound',
    BookFormat.digital => 'digital',
    _ => format == null ? '' : 'other',
  };

  String _encodeCsv(List<List<String>> rows) {
    return rows.map((r) => r.map(_quote).join(',')).join('\r\n');
  }

  String _quote(String v) => (v.contains(',') || v.contains('"') || v.contains('\n')) ? '"${v.replaceAll('"', '""')}"' : v;
}
