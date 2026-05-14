import 'package:drift/drift.dart';
import '../services/database.dart';

/// Represents a book metadata result fetched from an external provider (Google Books, Open Library, etc.)
class BookSearchResult {
  final String title;
  final List<String> authors;
  final String? isbn;
  final String? publisher;
  final String? coverUrl;
  final int? pageCount;
  final int? publishYear;
  final String? description;
  final List<String> categories;
  
  /// The source that provided this data.
  final String source;

  const BookSearchResult({
    required this.title,
    required this.authors,
    this.isbn,
    this.publisher,
    this.coverUrl,
    this.pageCount,
    this.publishYear,
    this.description,
    this.categories = const [],
    required this.source,
  });

  BookSearchResult copyWith({
    String? title,
    List<String>? authors,
    String? isbn,
    String? publisher,
    String? coverUrl,
    int? pageCount,
    int? publishYear,
    String? description,
    List<String>? categories,
    String? source,
  }) {
    return BookSearchResult(
      title: title ?? this.title,
      authors: authors ?? this.authors,
      isbn: isbn ?? this.isbn,
      publisher: publisher ?? this.publisher,
      coverUrl: coverUrl ?? this.coverUrl,
      pageCount: pageCount ?? this.pageCount,
      publishYear: publishYear ?? this.publishYear,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      source: source ?? this.source,
    );
  }

  /// Converts this search result into a database companion for insertion.
  BooksCompanion toCompanion() {
    return BooksCompanion.insert(
      title: title,
      author: authors.join(', '),
      isbn: Value(isbn),
      publisher: Value(publisher),
      coverUrl: Value(coverUrl),
      totalPages: Value(pageCount),
      status: ReadingStatus.wantToRead,
      publishYear: Value(publishYear),
    );
  }
}
