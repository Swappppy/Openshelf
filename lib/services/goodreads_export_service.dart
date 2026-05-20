import 'dart:convert';
import 'dart:io';

import '../services/database.dart';

/// Result of a GoodReads CSV export operation.
class GoodreadsExportResult {
  final int exported;
  final String csvContent;
  final List<String> errors;

  const GoodreadsExportResult({
    required this.exported,
    required this.csvContent,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() =>
      'GoodreadsExportResult(exported: $exported, errors: ${errors.length})';
}

/// Exports OpenShelf books to a GoodReads-compatible CSV file.
///
/// GoodReads CSV columns (current format, as of 2023):
///   0  Book Id
///   1  Title
///   2  Author             (Firstname Lastname)
///   3  Author l-f         (Lastname, Firstname)
///   4  Additional Authors
///   5  ISBN               (="0000000000")
///   6  ISBN13             (="9780000000000")
///   7  My Rating          (0 = not rated, 1–5)
///   8  Average Rating
///   9  Publisher
///  10  Binding
///  11  Number of Pages
///  12  Year Published
///  13  Original Publication Year
///  14  Date Read          (YYYY/MM/DD)
///  15  Date Added         (YYYY/MM/DD)
///  16  Bookshelves
///  17  Bookshelves with positions
///  18  Exclusive Shelf
///  19  My Review
///  20  Spoiler
///  21  Private Notes
///  22  Read Count
///  23  Owned Copies
///
/// Usage:
/// ```dart
/// final service = GoodreadsExportService(database);
/// final result = await service.export();
/// if (!result.hasErrors) {
///   final file = File('/path/to/goodreads_export.csv');
///   await service.writeToFile(result, file);
/// }
/// ```
class GoodreadsExportService {
  final AppDatabase _db;

  GoodreadsExportService(this._db);

  static const List<String> _headers = [
    'Book Id',
    'Title',
    'Author',
    'Author l-f',
    'Additional Authors',
    'ISBN',
    'ISBN13',
    'My Rating',
    'Average Rating',
    'Publisher',
    'Binding',
    'Number of Pages',
    'Year Published',
    'Original Publication Year',
    'Date Read',
    'Date Added',
    'Bookshelves',
    'Bookshelves with positions',
    'Exclusive Shelf',
    'My Review',
    'Spoiler',
    'Private Notes',
    'Read Count',
    'Owned Copies',
  ];

  // ── Public API ────────────────────────────────────────────────────────────

  /// Exports all books to a GoodReads-compatible CSV string.
  Future<GoodreadsExportResult> export() async {
    final books  = await _db.watchAllBooks().first;
    final errors = <String>[];
    final rows   = <List<String>>[_headers];

    for (final book in books) {
      try {
        final tags = await _db.watchTagsForBook(book.id).first;
        rows.add(_bookToRow(book, tags));
      } catch (e) {
        errors.add('Libro "${book.title}" (id ${book.id}): $e');
      }
    }

    final csvContent = _encodeCsv(rows);
    return GoodreadsExportResult(
      exported:   rows.length - 1, // Exclude header
      csvContent: csvContent,
      errors:     errors,
    );
  }

  /// Writes a completed [GoodreadsExportResult] to a [File].
  Future<void> writeToFile(GoodreadsExportResult result, File file) async {
    await file.writeAsString(result.csvContent, encoding: utf8);
  }

  // ── Book → CSV row ────────────────────────────────────────────────────────

  List<String> _bookToRow(Book book, List<Tag> tags) {
    final exclusiveShelf = _mapStatus(book.status);
    final customShelves  = tags.map((t) => t.name).toList();
    final allShelves     = [exclusiveShelf, ...customShelves];

    // "Bookshelves with positions": "read (#1) philosophy (#2)"
    final shelvesWithPositions = allShelves
        .asMap()
        .entries
        .map((e) => '${e.value} (#${e.key + 1})')
        .join(' ');

    return [
      book.id.toString(),                             //  0  Book Id
      book.title,                                     //  1  Title
      book.author,                                    //  2  Author
      _authorLastFirst(book.author),                  //  3  Author l-f
      '',                                             //  4  Additional Authors
      _wrapIsbn(_isbn10(book.isbn)),                  //  5  ISBN
      _wrapIsbn(_isbn13(book.isbn)),                  //  6  ISBN13
      _formatRating(book.rating),                     //  7  My Rating
      '',                                             //  8  Average Rating (unknown)
      book.publisher ?? '',                           //  9  Publisher
      _mapFormat(book.bookFormat),                    // 10  Binding
      book.totalPages?.toString() ?? '',              // 11  Number of Pages
      book.publishYear?.toString() ?? '',             // 12  Year Published
      book.publishYear?.toString() ?? '',             // 13  Original Publication Year (same)
      _formatDate(book.finishedAt),                   // 14  Date Read
      _formatDate(book.createdAt),                    // 15  Date Added
      allShelves.join(', '),                          // 16  Bookshelves
      shelvesWithPositions,                           // 17  Bookshelves with positions
      exclusiveShelf,                                 // 18  Exclusive Shelf
      book.notes ?? '',                               // 19  My Review
      'false',                                        // 20  Spoiler
      '',                                             // 21  Private Notes
      book.status == ReadingStatus.read ? '1' : '0', // 22  Read Count
      '0',                                            // 23  Owned Copies
    ];
  }

  // ── Field mappers ─────────────────────────────────────────────────────────

  /// Maps [ReadingStatus] to GoodReads' Exclusive Shelf string.
  String _mapStatus(ReadingStatus status) => switch (status) {
    ReadingStatus.read      => 'read',
    ReadingStatus.reading   => 'currently-reading',
    ReadingStatus.paused    => 'currently-reading',
    ReadingStatus.abandoned => 'read', // Closest GoodReads equivalent
    ReadingStatus.wantToRead=> 'to-read',
  };

  /// Maps [BookFormat] to GoodReads' Binding string.
  String _mapFormat(BookFormat? format) => switch (format) {
    BookFormat.paperback    => 'Paperback',
    BookFormat.hardcover    => 'Hardcover',
    BookFormat.leatherbound => 'Leather Bound',
    BookFormat.digital      => 'Kindle Edition',
    BookFormat.rustic       => 'Paperback',    // No direct equivalent
    BookFormat.other        => 'Other Format',
    null                    => '',
  };

  /// Converts "Firstname Lastname" → "Lastname, Firstname".
  /// Handles single-name authors (e.g., "Homer", "Virgil") gracefully.
  String _authorLastFirst(String author) {
    final parts = author.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return author; // Single name: Homer, Virgil, etc.
    final last  = parts.last;
    final first = parts.sublist(0, parts.length - 1).join(' ');
    return '$last, $first';
  }

  /// Returns the ISBN10 from the stored value (if it has 10 digits).
  /// OpenShelf stores whichever ISBN was available at import time.
  String _isbn10(String? isbn) {
    if (isbn == null) return '';
    final digits = isbn.replaceAll(RegExp(r'[^0-9X]'), '');
    return digits.length == 10 ? digits : '';
  }

  /// Returns the ISBN13 from the stored value (if it has 13 digits).
  String _isbn13(String? isbn) {
    if (isbn == null) return '';
    final digits = isbn.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length == 13 ? digits : '';
  }

  /// Wraps an ISBN in GoodReads' Excel-formula format: 0140275363 → ="0140275363"
  /// Returns an empty string if the input is empty.
  String _wrapIsbn(String isbn) => isbn.isEmpty ? '' : '="$isbn"';

  /// Formats a nullable [DateTime] as YYYY/MM/DD (GoodReads standard).
  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }

  /// Converts a nullable double rating to an integer string (0 if null).
  String _formatRating(double? rating) {
    if (rating == null) return '0';
    return rating.round().clamp(0, 5).toString();
  }

  // ── CSV encoding ──────────────────────────────────────────────────────────

  /// Encodes a list of rows into a CSV string with CRLF line endings,
  /// quoting fields that contain commas, quotes, or newlines.
  String _encodeCsv(List<List<String>> rows) {
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.write(row.map(_quoteField).join(','));
      buffer.write('\r\n');
    }
    return buffer.toString();
  }

  /// Quotes a CSV field if necessary, escaping internal double quotes.
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