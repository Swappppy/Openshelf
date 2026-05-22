import '../services/database.dart';

/// Model representing the current search and category filters.
class SearchFilters {
  final String query;
  final List<Tag> tags;
  final String author;
  final String publisher;
  final String isbn;
  final String collection;
  final String language;
  final List<Tag> imprints;
  final List<Tag> collections;
  final ReadingStatus? status;

  const SearchFilters({
    this.query = '',
    this.tags = const [],
    this.author = '',
    this.publisher = '',
    this.isbn = '',
    this.collection = '',
    this.language = '',
    this.imprints = const [],
    this.collections = const [],
    this.status,
  });

  bool get isEmpty =>
      query.isEmpty &&
          tags.isEmpty &&
          author.isEmpty &&
          publisher.isEmpty &&
          isbn.isEmpty &&
          collection.isEmpty &&
          language.isEmpty &&
          imprints.isEmpty &&
          collections.isEmpty;

  SearchFilters copyWith({
    String? query,
    List<Tag>? tags,
    String? author,
    String? publisher,
    String? isbn,
    String? collection,
    String? language,
    List<Tag>? imprints,
    bool clearImprints = false,
    List<Tag>? collections,
    bool clearCollections = false,
    ReadingStatus? status,
    bool clearStatus = false,
  }) =>
      SearchFilters(
        query: query ?? this.query,
        tags: tags ?? this.tags,
        author: author ?? this.author,
        publisher: publisher ?? this.publisher,
        isbn: isbn ?? this.isbn,
        collection: collection ?? this.collection,
        language: language ?? this.language,
        imprints: clearImprints ? [] : (imprints ?? this.imprints),
        collections: clearCollections ? [] : (collections ?? this.collections),
        status: clearStatus ? null : (status ?? this.status),
      );
}
