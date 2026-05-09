import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:convert';
import '../models/shelf.dart';
import '../services/database.dart';
import 'database_provider.dart';

// Stream de todos los libros
final allBooksProvider = StreamProvider<List<Book>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllBooks();
});

// Provider específico para los libros de una estantería
final shelfBooksProvider =
StreamProvider.family<List<Book>, Shelf>((ref, shelf) {
  final db = ref.watch(databaseProvider);
  final tagIds = shelf.filterTagIds != null
      ? (jsonDecode(shelf.filterTagIds!) as List).cast<int>()
      : <int>[];

  // Si hay filtro de estado, combinar con los demás filtros
  if (shelf.filterStatus != null &&
      tagIds.isEmpty &&
      shelf.filterImprintId == null &&
      shelf.filterQuery == null &&
      shelf.filterAuthor == null &&
      shelf.filterPublisher == null &&
      shelf.filterIsbn == null &&
      shelf.filterCollection == null) {
    final status = ReadingStatus.values.firstWhere(
          (s) => s.name == shelf.filterStatus,
    );
    return db.watchBooksByStatus(status);
  }

  return db.watchBooksFiltered(
    query: shelf.filterQuery,
    tagIds: tagIds.isEmpty ? null : tagIds,
    author: shelf.filterAuthor,
    publisher: shelf.filterPublisher,
    isbn: shelf.filterIsbn,
    collectionName: shelf.filterCollection,
    imprintId: shelf.filterImprintId,
  );
});

// Stream por estado
final booksByStatusProvider =
StreamProvider.family<List<Book>, ReadingStatus>((ref, status) {
  final db = ref.watch(databaseProvider);
  return db.watchBooksByStatus(status);
});

// Conteo por estado (para las estanterías)
final bookCountByStatusProvider =
Provider.family<AsyncValue<int>, ReadingStatus>((ref, status) {
  return ref.watch(booksByStatusProvider(status)).whenData((books) => books.length);
});

final bookByIdProvider = StreamProvider.family<Book?, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return db.watchBookById(id);
});

final bookTagsProvider = StreamProvider.family<List<Tag>, int>((ref, bookId) {
  return ref.watch(databaseProvider).watchTagsForBook(bookId);
});

final allTagsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).watchTagsByType('tag');
});

final allImprintsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).watchTagsByType('imprint');
});

final allCollectionsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).watchTagsByType('collection');
});

final bookImprintProvider = StreamProvider.family<Tag?, int>((ref, bookId) {
  return ref.watch(databaseProvider).watchImprintForBook(bookId);
});

final filteredBooksProvider = StreamProvider<List<Book>>((ref) {
  final filters = ref.watch(searchFiltersProvider);
  final db = ref.watch(databaseProvider);
  if (filters.isEmpty) return db.watchAllBooks();
  return db.watchBooksFiltered(
    query: filters.query.isEmpty ? null : filters.query,
    tagIds: filters.tags.isEmpty ? null : filters.tags.map((t) => t.id).toList(),
    author: filters.author.isEmpty ? null : filters.author,
    publisher: filters.publisher.isEmpty ? null : filters.publisher,
    isbn: filters.isbn.isEmpty ? null : filters.isbn,
    collectionName: filters.collection.isEmpty ? null : filters.collection,
    imprintId: filters.imprint?.id,
  );
});

// Modelo de filtros de búsqueda
class SearchFilters {
  final String query;
  final List<Tag> tags;
  final String author;
  final String publisher;
  final String isbn;
  final String collection;
  final Tag? imprint;
  final ReadingStatus? status;

  const SearchFilters({
    this.query = '',
    this.tags = const [],
    this.author = '',
    this.publisher = '',
    this.isbn = '',
    this.collection = '',
    this.imprint,
    this.status,
  });

  bool get isEmpty =>
      query.isEmpty &&
          tags.isEmpty &&
          author.isEmpty &&
          publisher.isEmpty &&
          isbn.isEmpty &&
          collection.isEmpty &&
          imprint == null;

  SearchFilters copyWith({
    String? query,
    List<Tag>? tags,
    String? author,
    String? publisher,
    String? isbn,
    String? collection,
    Tag? imprint,
    bool clearImprint = false,
    ReadingStatus? status,
  }) =>
      SearchFilters(
        query: query ?? this.query,
        tags: tags ?? this.tags,
        author: author ?? this.author,
        publisher: publisher ?? this.publisher,
        isbn: isbn ?? this.isbn,
        collection: collection ?? this.collection,
        imprint: clearImprint ? null : (imprint ?? this.imprint),
        status: status ?? this.status,
      );
}

final searchFiltersProvider =
StateProvider<SearchFilters>((ref) => const SearchFilters());

final allShelvesProvider = StreamProvider<List<Shelf>>((ref) {
  return ref.watch(databaseProvider).watchAllShelves();
});