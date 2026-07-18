import 'dart:convert';
import 'dart:io';
import '../services/database.dart';
import 'import_export_base.dart';

/// Exports OpenShelf books to a GoodReads-compatible CSV file.
///
/// Rows are built as name -> value maps and then serialized against
/// [_headers], instead of writing into fixed numeric slots. This avoids
/// the class of bug where inserting/removing a header column silently
/// shifts every value after it (see GoodreadsImportService for the same
/// pattern on the read side).
class GoodreadsExportService {
  final AppDatabase _db;
  GoodreadsExportService(this._db);

  // Standard Goodreads header, including "Average Rating" (kept blank on
  // export, since OpenShelf doesn't track a global average) so files we
  // produce round-trip through Goodreads-compatible importers, including
  // our own.
  static const List<String> _headers = [
    'Book Id', 'Title', 'Author', 'Author l-f', 'Additional Authors', 'ISBN', 'ISBN13', 'My Rating',
    'Average Rating', 'Publisher', 'Binding', 'Number of Pages', 'Year Published', 'Original Publication Year',
    'Date Read', 'Date Added', 'Bookshelves', 'Bookshelves with positions', 'Exclusive Shelf', 'My Review',
    'Spoiler', 'Private Notes', 'Read Count', 'Owned Copies',
  ];

  Future<ExportResult> export() async {
    final books = await _db.bookDao.watchAllBooks().first;
    final errors = <String>[];
    final rows = <List<String>>[_headers];
    for (final book in books) {
      try {
        final tags = await _db.tagDao.watchTagsForBook(book.id).first;
        rows.add(_toRow(_bookToFields(book, tags)));
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

  /// Builds a name -> value map for one book. Any header not set here is
  /// exported as an empty string.
  Map<String, String> _bookToFields(Book book, List<Tag> tags) {
    final shelfNames = tags.map((t) => t.name).join(',');
    return {
      'Book Id': book.id.toString(),
      'Title': book.title,
      'Author': book.author,
      'ISBN': book.isbn != null && book.isbn!.length == 10 ? '="${book.isbn}"' : '',
      'ISBN13': book.isbn != null && book.isbn!.length == 13 ? '="${book.isbn}"' : '',
      'My Rating': book.rating?.round().clamp(1, 5).toString() ?? '0',
      'Publisher': book.publisher ?? '',
      'Binding': _mapFormat(book.bookFormat),
      'Number of Pages': book.totalPages?.toString() ?? '',
      'Year Published': book.publishYear?.toString() ?? '',
      'Date Read': _formatDate(book.finishedAt),
      'Date Added': _formatDate(book.createdAt),
      'Bookshelves': shelfNames,
      'Exclusive Shelf': _mapStatus(book.status),
      'My Review': book.notes ?? '',
      'Read Count': book.status == ReadingStatus.read ? '1' : '0',
    };
  }

  /// Serializes a name -> value map into a row matching [_headers], in
  /// order, filling any header without an entry with ''.
  List<String> _toRow(Map<String, String> fields) {
    return _headers.map((h) => fields[h] ?? '').toList();
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

  String _quote(String v) =>
      (v.contains(',') || v.contains('"') || v.contains('\n')) ? '"${v.replaceAll('"', '""')}"' : v;
}