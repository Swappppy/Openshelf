import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/database.dart';
import 'database_provider.dart';

// Stream de todos los libros
final allBooksProvider = StreamProvider<List<Book>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllBooks();
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

  const SearchFilters({
    this.query = '',
    this.tags = const [],
    this.author = '',
    this.publisher = '',
    this.isbn = '',
    this.collection = '',
    this.imprint,
  });

  bool get isEmpty =>
      query.isEmpty &&
          tags.isEmpty &&
          author.isEmpty &&
          publisher.isEmpty &&
          isbn.isEmpty &&
          collection.isEmpty &&
          imprint == null;  // AÑADIR

  SearchFilters copyWith({
    String? query,
    List<Tag>? tags,
    String? author,
    String? publisher,
    String? isbn,
    String? collection,
    Tag? imprint,        // AÑADIR
    bool clearImprint = false,  // AÑADIR para poder poner null
  }) =>
      SearchFilters(
        query: query ?? this.query,
        tags: tags ?? this.tags,
        author: author ?? this.author,
        publisher: publisher ?? this.publisher,
        isbn: isbn ?? this.isbn,
        collection: collection ?? this.collection,
        imprint: clearImprint ? null : (imprint ?? this.imprint),  // AÑADIR
      );
}

final searchFiltersProvider =
StateProvider<SearchFilters>((ref) => const SearchFilters());