import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import '../models/shelf.dart';
import '../models/tag_type.dart';
import '../services/database.dart';
import '../utils/book_sorting.dart';
import 'database_provider.dart';
import 'display_preferences_controller.dart';
import 'search_filters_controller.dart';

/// Stream of all books in the database
final allBooksProvider = StreamProvider<List<Book>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.bookDao.watchAllBooks();
});

final allShelvesProvider = StreamProvider<List<Shelf>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.shelfDao.watchAllShelves();
});

/// Provider for shelves with calculated book counts
final allShelvesWithStatsProvider = StreamProvider<List<(Shelf, int, int)>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.shelfDao.watchAllShelves().switchMap((list) {
    if (list.isEmpty) return Stream.value([]);
    
    final streams = list.map((shelf) {
      return db.shelfDao.watchTagsForShelf(shelf.id).switchMap((shelfTags) {
        return db.bookDao.watchBooksFiltered(
          query: shelf.filterQuery,
          author: shelf.filterAuthor,
          publisher: shelf.filterPublisher,
          isbn: shelf.filterIsbn,
          language: shelf.filterLanguage,
          // Note: collectionId and imprintId are now just Tags in the shelfTags list
          // We need to filter them by type here or store them separately.
          // For now, let's pass all tagIds to watchBooksFiltered and let it handle the types if it can,
          // or we filter them here.
          collectionIds: shelfTags.where((t) => t.type == TagType.collection).map((t) => t.id).toList().nullIfEmpty(),
          tagIds: shelfTags.where((t) => t.type == TagType.tag).map((t) => t.id).toList().nullIfEmpty(),
          imprintIds: shelfTags.where((t) => t.type == TagType.imprint).map((t) => t.id).toList().nullIfEmpty(),
          noCover: shelf.filterNoCover,
          status: shelf.filterStatus != null ? ReadingStatus.values.firstWhereOrNull((s) => s.name == shelf.filterStatus) : null,
        ).map((books) {
          final readCount = books.where((b) => b.status == ReadingStatus.read).length;
          return (shelf, books.length, readCount);
        });
      });
    }).toList();
    
    return CombineLatestStream.list(streams);
  });
});

/// Specific provider for books within a dynamic shelf
final shelfBooksProvider =
StreamProvider.family<List<Book>, Shelf>((ref, shelf) {
  final db = ref.watch(databaseProvider);
  
  return db.shelfDao.watchTagsForShelf(shelf.id).switchMap((shelfTags) {
    final tagIds = shelfTags.where((t) => t.type == TagType.tag).map((t) => t.id).toList();
    final imprintIds = shelfTags.where((t) => t.type == TagType.imprint).map((t) => t.id).toList();
    final collectionIds = shelfTags.where((t) => t.type == TagType.collection).map((t) => t.id).toList();

    // If only a status filter is set, use the faster status-only query
    if (shelf.filterStatus != null &&
        tagIds.isEmpty &&
        imprintIds.isEmpty &&
        shelf.filterQuery == null &&
        shelf.filterAuthor == null &&
        shelf.filterPublisher == null &&
        shelf.filterIsbn == null &&
        collectionIds.isEmpty) {
      final status = ReadingStatus.values.firstWhere(
            (s) => s.name == shelf.filterStatus,
      );
      return db.bookDao.watchBooksByStatus(status);
    }

    return db.bookDao.watchBooksFiltered(
      query: shelf.filterQuery,
      tagIds: tagIds.isEmpty ? null : tagIds,
      author: shelf.filterAuthor,
      publisher: shelf.filterPublisher,
      isbn: shelf.filterIsbn,
      collectionIds: collectionIds.isEmpty ? null : collectionIds,
      imprintIds: imprintIds.isEmpty ? null : imprintIds,
      noCover: shelf.filterNoCover,
      status: shelf.filterStatus != null ? ReadingStatus.values.firstWhereOrNull((s) => s.name == shelf.filterStatus) : null,
    );
  });
});

/// Stream of books filtered by reading status
final booksByStatusProvider =
StreamProvider.family<List<Book>, ReadingStatus>((ref, status) {
  final db = ref.watch(databaseProvider);
  return db.bookDao.watchBooksByStatus(status);
});

/// Reactive count of books for a specific status
final bookCountByStatusProvider =
Provider.family<AsyncValue<int>, ReadingStatus>((ref, status) {
  return ref.watch(booksByStatusProvider(status)).whenData((books) => books.length);
});

final bookByIdProvider = StreamProvider.family<Book?, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return db.bookDao.watchBookById(id);
});

final bookTagsProvider = StreamProvider.family<List<Tag>, int>((ref, bookId) {
  return ref.watch(databaseProvider).tagDao.watchTagsForBook(bookId);
});

final allTagsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).tagDao.watchTagsByType(TagType.tag);
});

/// Provider for tags including their usage count for visual scaling (cloud).
final allTagsWithCountsProvider = StreamProvider<List<(Tag, int)>>((ref) {
  return ref.watch(databaseProvider).tagDao.watchTagsByTypeWithCounts(TagType.tag);
});

final allImprintsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).tagDao.watchTagsByType(TagType.imprint);
});

final allImprintsWithCountsProvider = StreamProvider<List<(Tag, int)>>((ref) {
  return ref.watch(databaseProvider).tagDao.watchTagsByTypeWithCounts(TagType.imprint);
});

final allCollectionsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).tagDao.watchTagsByType(TagType.collection);
});

final allCollectionsWithCountsProvider = StreamProvider<List<(Tag, int)>>((ref) {
  return ref.watch(databaseProvider).tagDao.watchCollectionsWithCounts();
});

final bookImprintProvider = StreamProvider.family<Tag?, int>((ref, bookId) {
  return ref.watch(databaseProvider).tagDao.watchImprintForBook(bookId);
});

final booksByImprintProvider = StreamProvider.family<List<Book>, int>((ref, imprintId) {
  final db = ref.watch(databaseProvider);
  return db.bookDao.watchBooksFiltered(imprintIds: [imprintId]);
});

final booksByTagProvider = StreamProvider.family<List<Book>, int>((ref, tagId) {
  final db = ref.watch(databaseProvider);
  return db.bookDao.watchBooksFiltered(tagIds: [tagId]);
});

final booksByCollectionProvider = StreamProvider.family<List<Book>, int>((ref, collectionId) {
  final db = ref.watch(databaseProvider);
  return db.bookDao.watchBooksFiltered(collectionIds: [collectionId]);
});

final imprintBookCountProvider = StreamProvider.family<int, int>((ref, imprintId) {
  return ref.watch(databaseProvider).tagDao.watchBookCountByImprint(imprintId);
});

final topTagsForBooksProvider = StreamProvider.family<List<String>, List<int>>((ref, bookIds) {
  return ref.watch(databaseProvider).tagDao.watchTopTagNamesForBooks(bookIds);
});

/// Main filtered provider used by the Library view
final filteredBooksProvider = StreamProvider<List<Book>>((ref) {
  final filters = ref.watch(searchFiltersProvider);
  final prefs = ref.watch(displayPreferencesProvider);
  final db = ref.watch(databaseProvider);
  
  // Watch all imprints to get names for sorting
  final imprintsAsync = ref.watch(allImprintsProvider);
  final imprintNames = imprintsAsync.maybeWhen(
    data: (list) => {for (final t in list) t.id: t.name},
    orElse: () => <int, String>{},
  );

  final stream = db.bookDao.watchBooksFiltered(
    query: filters.query,
    author: filters.author,
    publisher: filters.publisher,
    isbn: filters.isbn,
    language: filters.language,
    collectionIds: filters.collections.isEmpty ? null : filters.collections.map((t) => t.id).toList(),
    tagIds: filters.tags.isEmpty ? null : filters.tags.map((t) => t.id).toList(),
    imprintIds: filters.imprints.isEmpty ? null : filters.imprints.map((t) => t.id).toList(),
    status: filters.status,
  );

  return stream.map((allBooks) {
    var filtered = allBooks.toList();

    // Sort
    filtered.applyLibrarySorting(prefs, imprintNames: imprintNames);

    return filtered;
  });
});

extension ListExt<T> on List<T> {
  List<T>? nullIfEmpty() => isEmpty ? null : this;
}
