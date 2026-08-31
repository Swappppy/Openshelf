import 'package:drift/drift.dart';
import '../services/database.dart';

/// Represents a book metadata result fetched from an external provider (Google Books, Open Library, etc.)
class BookSearchResult {
  /// Internal identifier for results synthesized by Openshelf's merging logic.
  static const String recommendedSource = 'openshelf_recommended';

  final String title;
  final String? subtitle;
  final String? originalTitle;
  final List<String> authors;
  final String? isbn;
  final String? language;
  final String? originalLanguage;
  final String? translator;
  final String? publisher;
  final String? coverUrl;
  final int? pageCount;
  final int? publishYear;
  final String? description;
  final List<String> categories;
  
  /// The source that provided this data.
  final String source;

  /// Optional URI for Inventaire deep lookups (Works vs Editions)
  final String? inventaireWorkUri;

  const BookSearchResult({
    required this.title,
    this.subtitle,
    this.originalTitle,
    required this.authors,
    this.isbn,
    this.language,
    this.originalLanguage,
    this.translator,
    this.publisher,
    this.coverUrl,
    this.pageCount,
    this.publishYear,
    this.description,
    this.categories = const [],
    required this.source,
    this.inventaireWorkUri,
  });

  BookSearchResult copyWith({
    String? title,
    String? subtitle,
    String? originalTitle,
    List<String>? authors,
    String? isbn,
    String? language,
    String? originalLanguage,
    String? translator,
    String? publisher,
    String? coverUrl,
    int? pageCount,
    int? publishYear,
    String? description,
    List<String>? categories,
    String? source,
    String? inventaireWorkUri,
  }) {
    return BookSearchResult(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      originalTitle: originalTitle ?? this.originalTitle,
      authors: authors ?? this.authors,
      isbn: isbn ?? this.isbn,
      language: language ?? this.language,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      translator: translator ?? this.translator,
      publisher: publisher ?? this.publisher,
      coverUrl: coverUrl ?? this.coverUrl,
      pageCount: pageCount ?? this.pageCount,
      publishYear: publishYear ?? this.publishYear,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      source: source ?? this.source,
      inventaireWorkUri: inventaireWorkUri ?? this.inventaireWorkUri,
    );
  }

  /// Converts this search result into a database companion for insertion.
  BooksCompanion toCompanion() {
    return BooksCompanion.insert(
      title: title,
      subtitle: Value(subtitle),
      originalTitle: Value(originalTitle),
      author: authors.join(', '),
      isbn: Value(isbn),
      language: Value(language),
      originalLanguage: Value(originalLanguage),
      translator: Value(translator),
      publisher: Value(publisher),
      coverUrl: Value(coverUrl),
      totalPages: Value(pageCount),
      description: Value(description),
      status: ReadingStatus.wantToRead,
      publishYear: Value(publishYear),
    );
  }
}
