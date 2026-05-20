import 'dart:convert';
import 'dart:io';

import '../services/database.dart';

/// Result of a Bookshelf CSV export operation.
class BookshelfExportResult {
  final int exported;
  final String csvContent;
  final List<String> errors;

  const BookshelfExportResult({
    required this.exported,
    required this.csvContent,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() =>
      'BookshelfExportResult(exported: $exported, errors: ${errors.length})';
}

/// Exports OpenShelf books to a Bookshelf-compatible CSV file.
///
/// Bookshelf CSV columns (2026 export format, 49 columns, indices 0–48):
///   0   Book Id
///   1   ISBN
///   2   Bookshelf
///   3   Tags
///   4   Wishlist
///   5   Started Reading On   (YYYY-MM-DD)
///   6   Ended Reading On     (YYYY-MM-DD)
///   7   Pages Read
///   8   Read                 (1 | 0)
///   9   My Rating
///  10   Review
///  11   Short note
///  12   Advanced note
///  13   Signed
///  14   Condition
///  15   Number of copies
///  16   Quotes
///  17   Flashcards
///  18   Title
///  19   Subtitle
///  20   Language
///  21   Categories           (comma-separated)
///  22   Authors
///  23   Illustrators
///  24   Translators
///  25   Editors
///  26   Narrators
///  27   Photographers
///  28   Publisher
///  29   Page Count
///  30   Published At         (YYYY-MM-DD)
///  31   Format
///  32   Edition
///  33   Series
///  34   Volume
///  35   Loan Type
///  36   Loan Name
///  37   Loan Start Date
///  38   Loan Due Date
///  39   Purchase Type
///  40   Purchase From
///  41   Purchase Price
///  42   Purchase Date
///  43   Transfer Type
///  44   Transfer place
///  45   Transfer Price
///  46   Transfer Date
///  47   Description
///  48   Date added           (YYYY-MM-DD)
///
/// Usage:
/// ```dart
/// final service = BookshelfExportService(database);
/// final result = await service.export();
/// if (!result.hasErrors) {
///   final file = File('/path/to/Bookshelf-export.csv');
///   await service.writeToFile(result, file);
/// }
/// ```
class BookshelfExportService {
  final AppDatabase _db;

  BookshelfExportService(this._db);

  static const List<String> _headers = [
    'Book Id',
    'ISBN',
    'Bookshelf',
    'Tags',
    'Wishlist',
    'Started Reading On',
    'Ended Reading On',
    'Pages Read',
    'Read',
    'My Rating',
    'Review',
    'Short note',
    'Advanced note',
    'Signed',
    'Condition',
    'Number of copies',
    'Quotes',
    'Flashcards',
    'Title',
    'Subtitle',
    'Language',
    'Categories',
    'Authors',
    'Illustrators',
    'Translators',
    'Editors',
    'Narrators',
    'Photographers',
    'Publisher',
    'Page Count',
    'Published At',
    'Format',
    'Edition',
    'Series',
    'Volume',
    'Loan Type',
    'Loan Name',
    'Loan Start Date',
    'Loan Due Date',
    'Purchase Type',
    'Purchase From',
    'Purchase Price',
    'Purchase Date',
    'Transfer Type',
    'Transfer place',
    'Transfer Price',
    'Transfer Date',
    'Description',
    'Date added',
  ];

  // ── Public API ────────────────────────────────────────────────────────────

  /// Exports all books to a Bookshelf-compatible CSV string.
  Future<BookshelfExportResult> export() async {
    final books  = await _db.watchAllBooks().first;
    final errors = <String>[];
    final rows   = <List<String>>[_headers];

    for (final book in books) {
      try {
        final tags = await _db.watchTagsForBook(book.id).first;
        rows.add(await _bookToRow(book, tags));
      } catch (e) {
        errors.add('Libro "${book.title}" (id ${book.id}): $e');
      }
    }

    return BookshelfExportResult(
      exported:   rows.length - 1,
      csvContent: _encodeCsv(rows),
      errors:     errors,
    );
  }

  /// Writes a completed [BookshelfExportResult] to a [File].
  Future<void> writeToFile(BookshelfExportResult result, File file) async {
    await file.writeAsString(result.csvContent, encoding: utf8);
  }

  // ── Book → CSV row ────────────────────────────────────────────────────────

  Future<List<String>> _bookToRow(Book book, List<Tag> tags) async {
    final categoryNames = tags.map((t) => t.name).join(',');

    // 49 fields, many of which OpenShelf doesn't track — left blank.
    final row = List<String>.filled(49, '');

    row[0]  = book.id.toString();
    row[1]  = book.isbn ?? '';
    row[2]  = _mapStatusToShelf(book.status);
    row[3]  = categoryNames;                         // Tags (mirrors Categories)
    row[4]  = '0';                                   // Wishlist: always false
    row[5]  = _formatDate(book.startedAt);
    row[6]  = _formatDate(book.finishedAt);
    row[7]  = book.currentPage?.toString() ?? '';
    row[8]  = book.status == ReadingStatus.read ? '1' : '0';
    row[9]  = _formatRating(book.rating);
    row[10] = book.notes ?? '';                      // Full notes → Review
    row[11] = '';                                    // Short note: not stored separately
    row[12] = '';                                    // Advanced note
    row[13] = '0';                                   // Signed
    row[14] = '';                                    // Condition
    row[15] = '1';                                   // Number of copies
    row[16] = '';                                    // Quotes
    row[17] = '';                                    // Flashcards
    row[18] = book.title;
    row[19] = book.subtitle ?? '';
    row[20] = book.language ?? '';
    row[21] = categoryNames;
    row[22] = book.author;
    row[23] = '';                                    // Illustrators
    row[24] = book.translator ?? '';
    row[25] = '';                                    // Editors
    row[26] = '';                                    // Narrators
    row[27] = '';                                    // Photographers
    row[28] = book.publisher ?? '';
    row[29] = book.totalPages?.toString() ?? '';
    row[30] = _formatPublishYear(book.publishYear);
    row[31] = _mapFormat(book.bookFormat);
    row[32] = '';                                    // Edition
    row[33] = book.collectionName ?? '';
    row[34] = book.collectionNumber?.toString() ?? '';
    // 35–46: Loan and transfer fields — not tracked in OpenShelf
    row[47] = book.description ?? '';
    row[48] = _formatDate(book.createdAt);

    return row;
  }

  // ── Field mappers ─────────────────────────────────────────────────────────

  /// Maps [ReadingStatus] to a Bookshelf shelf name.
  ///
  /// Bookshelf's shelf names are user-defined strings. These defaults follow
  /// the Bookshelf convention: all books belong to the main shelf; the reading
  /// state is captured separately via the Read (col 8) and date fields.
  /// Importing back into Bookshelf will place the book in whichever shelf
  /// name is written here — keep it simple and predictable.
  String _mapStatusToShelf(ReadingStatus status) => switch (status) {
    ReadingStatus.read       => 'My Books',
    ReadingStatus.reading    => 'My Books',
    ReadingStatus.paused     => 'My Books',
    ReadingStatus.abandoned  => 'My Books',
    ReadingStatus.wantToRead => 'Wishlist',
  };

  /// Maps [BookFormat] back to Bookshelf's format strings.
  String _mapFormat(BookFormat? format) => switch (format) {
    BookFormat.paperback    => 'paperback',
    BookFormat.hardcover    => 'hardcover',
    BookFormat.leatherbound => 'leatherbound',
    BookFormat.digital      => 'digital',
    BookFormat.rustic       => 'paperback',   // No equivalent in Bookshelf
    BookFormat.other        => 'other',
    null                    => '',
  };

  /// Formats a nullable [DateTime] as YYYY-MM-DD (Bookshelf standard).
  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Formats an optional publish year as YYYY-01-01, which is the convention
  /// Bookshelf uses when only the year is known.
  String _formatPublishYear(int? year) {
    if (year == null) return '';
    return '${year.toString().padLeft(4, '0')}-01-01';
  }

  /// Converts a nullable double rating to a string.
  /// Null ratings are exported as empty (not '0') so Bookshelf treats them
  /// as unrated rather than zero-star.
  String _formatRating(double? rating) {
    if (rating == null) return '';
    return rating.round().clamp(1, 10).toString();
  }

  // ── CSV encoding ──────────────────────────────────────────────────────────

  String _encodeCsv(List<List<String>> rows) {
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.write(row.map(_quoteField).join(','));
      buffer.write('\r\n');
    }
    return buffer.toString();
  }

  String _quoteField(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}