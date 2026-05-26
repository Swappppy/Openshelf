import 'dart:convert';
import 'dart:io';
import '../services/database.dart';
import 'import_export_base.dart';

/// Exports OpenShelf books to a GoodReads-compatible CSV file.
class GoodreadsExportService {
  final AppDatabase _db;
  GoodreadsExportService(this._db);

  static const List<String> _headers = [
    'Book Id', 'Title', 'Author', 'Author l-f', 'Additional Authors', 'ISBN', 'ISBN13', 'My Rating',
    'Average Rating', 'Publisher', 'Binding', 'Number of Pages', 'Year Published', 'Original Publication Year',
    'Date Read', 'Date Added', 'Bookshelves', 'Bookshelves with positions', 'Exclusive Shelf', 'My Review',
    'Spoiler', 'Private Notes', 'Read Count', 'Owned Copies',
  ];

  Future<ExportResult> export() async {
    final books = await _db.watchAllBooks().first;
    final errors = <String>[];
    final rows = <List<String>>[_headers];

    for (final book in books) {
      try {
        final tags = await _db.watchTagsForBook(book.id).first;
        rows.add(_bookToRow(book, tags));
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

  List<String> _bookToRow(Book book, List<Tag> tags) {
    final row = List<String>.filled(_headers.length, '');
    final shelfNames = tags.map((t) => t.name).join(',');

    row[0] = book.id.toString();
    row[1] = book.title;
    row[2] = book.author;
    row[5] = book.isbn != null && book.isbn!.length == 10 ? '="${book.isbn}"' : '';
    row[6] = book.isbn != null && book.isbn!.length == 13 ? '="${book.isbn}"' : '';
    row[7] = book.rating?.round().clamp(1, 5).toString() ?? '0';
    row[9] = book.publisher ?? '';
    row[10] = _mapFormat(book.bookFormat);
    row[11] = book.totalPages?.toString() ?? '';
    row[12] = book.publishYear?.toString() ?? '';
    row[14] = _formatDate(book.finishedAt);
    row[15] = _formatDate(book.createdAt);
    row[16] = shelfNames;
    row[18] = _mapStatus(book.status);
    row[19] = book.notes ?? '';
    row[22] = book.status == ReadingStatus.read ? '1' : '0';

    return row;
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  String _mapFormat(BookFormat? format) => switch (format) {
    BookFormat.paperback => 'Paperback',
    BookFormat.hardcover => 'Hardcover',
    BookFormat.digital => 'Kindle Edition',
    _ => format == null ? '' : 'Other',
  };

  String _mapStatus(ReadingStatus status) => switch (status) {
    ReadingStatus.read => 'read',
    ReadingStatus.reading => 'currently-reading',
    _ => 'to-read',
  };

  String _encodeCsv(List<List<String>> rows) {
    return rows.map((r) => r.map(_quote).join(',')).join('\r\n');
  }

  String _quote(String v) => (v.contains(',') || v.contains('"') || v.contains('\n')) ? '"${v.replaceAll('"', '""')}"' : v;
}
