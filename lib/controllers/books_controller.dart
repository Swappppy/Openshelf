import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import '../models/search_filters.dart';
import '../models/shelf.dart';
import '../services/database.dart';
import '../utils/book_sorting.dart';
import 'database_provider.dart';
import 'display_preferences_controller.dart';
import 'search_filters_controller.dart';
import 'app_settings_controller.dart';

/// Manages and provides streams of books filtered by different criteria.
final allBooksProvider = StreamProvider<List<Book>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.bookDao.watchAllBooks();
});

final allShelvesProvider = StreamProvider<List<Shelf>>((ref) {
  final db = ref.watch(databaseProvider);
  // Reaccionamos al toggle para que el stream sepa que puede haber cambios externos (automation)
  ref.watch(appSettingsProvider.select((s) => s.autoNoCoverShelf));
  return db.shelfDao.watchAllShelves();
});

/// Provider for shelves with calculated book counts.
///
/// Instead of keeping one live filtered query per shelf (each of which re-ran
/// on every single write, e.g. N shelves x 500 writes during an import), this
/// listens to the relevant tables once, debounces bursts of writes, and then
/// recomputes all counts in one pass. Stale recomputations are dropped.
final allShelvesWithStatsProvider = StreamProvider<List<(Shelf, int, int)>>((ref) {
  final db = ref.watch(databaseProvider);
  ref.watch(appSettingsProvider.select((s) => s.autoNoCoverShelf));

  final changes = db
      .tableUpdates(TableUpdateQuery.onAllTables([db.books, db.bookTags, db.tags, db.shelves, db.shelfTags]))
      .debounceTime(const Duration(milliseconds: 250))
      .startWith(const <TableUpdate>{});

  return changes.switchMap((_) => Stream.fromFuture(() async {
        final shelves = await db.shelfDao.watchAllShelves().first;
        final result = <(Shelf, int, int)>[];
        for (final shelf in shelves) {
          final hasTagRelatedFilters = shelf.id > 0 &&
              (shelf.filterTagIds != null || shelf.filterCollectionIds != null || shelf.filterImprintIds != null);
          final shelfTags = hasTagRelatedFilters ? await db.shelfDao.watchTagsForShelf(shelf.id).first : <Tag>[];
          final books = await _watchFiltered(db, shelf, shelfTags).first;
          result.add((shelf, books.length, books.where((b) => b.status == ReadingStatus.read).length));
        }
        return result;
      }()));
});

/// Specific provider for books within a dynamic shelf
final shelfBooksProvider = StreamProvider.family<List<Book>, Shelf>((ref, shelf) {
  final db = ref.watch(databaseProvider);

  final bool hasTagRelatedFilters = shelf.filterTagIds != null || 
                                   shelf.filterCollectionIds != null || 
                                   shelf.filterImprintIds != null ||
                                   shelf.id > 0;

  if (!hasTagRelatedFilters) {
    return _watchFiltered(db, shelf, []);
  }

  return db.shelfDao.watchTagsForShelf(shelf.id).switchMap((shelfTags) {
    return _watchFiltered(db, shelf, shelfTags);
  });
});

Stream<List<Book>> _watchFiltered(AppDatabase db, Shelf shelf, List<Tag> shelfTags) {
  final tagIds = shelfTags.where((t) => t.type == TagType.tag).map((t) => t.id).toList();
  final imprintIds = shelfTags.where((t) => t.type == TagType.imprint).map((t) => t.id).toList();
  final collectionIds = shelfTags.where((t) => t.type == TagType.collection).map((t) => t.id).toList();

  BooleanQuery? bq;
  if (shelf.filterBooleanQuery != null) {
    try {
      bq = BooleanQuery.fromJson(jsonDecode(shelf.filterBooleanQuery!));
    } catch (_) {}
  }

  bool hasFilter(String? val) => val != null && val.trim().isNotEmpty;

  // Optimización para estanterías de solo estado
  if (bq == null &&
      shelf.filterStatus != null &&
      tagIds.isEmpty &&
      imprintIds.isEmpty &&
      !hasFilter(shelf.filterQuery) &&
      !hasFilter(shelf.filterAuthor) &&
      !hasFilter(shelf.filterSubtitle) &&
      !hasFilter(shelf.filterPublisher) &&
      !hasFilter(shelf.filterIsbn) &&
      !hasFilter(shelf.filterLanguage) &&
      !hasFilter(shelf.filterTranslator) &&
      !hasFilter(shelf.filterNotes) &&
      shelf.filterFormat == null &&
      shelf.filterMediaType == null &&
      shelf.filterOwnership == null &&
      shelf.filterNoCover == false &&
      collectionIds.isEmpty) {
    final status = ReadingStatus.values.firstWhere((s) => s.name == shelf.filterStatus);
    return db.bookDao.watchBooksByStatus(status);
  }

  final hasTagFilters = tagIds.isNotEmpty || imprintIds.isNotEmpty || collectionIds.isNotEmpty;
  final hasOtherFilters = hasFilter(shelf.filterQuery) || 
                         hasFilter(shelf.filterAuthor) || 
                         hasFilter(shelf.filterSubtitle) ||
                         hasFilter(shelf.filterPublisher) ||
                         hasFilter(shelf.filterIsbn) ||
                         hasFilter(shelf.filterLanguage) ||
                         hasFilter(shelf.filterTranslator) ||
                         hasFilter(shelf.filterNotes) ||
                         shelf.filterStatus != null ||
                         shelf.filterFormat != null ||
                         shelf.filterMediaType != null ||
                         shelf.filterOwnership != null ||
                         shelf.filterNoCover == true ||
                         (bq != null && bq.conditions.isNotEmpty);

  if (!hasTagFilters && !hasOtherFilters && shelf.name != '__auto_no_cover__') {
    return Stream.value([]);
  }

  return db.bookDao.watchBooksFiltered(
    query: shelf.filterQuery,
    tagIds: tagIds.nullIfEmpty(),
    author: shelf.filterAuthor,
    subtitle: shelf.filterSubtitle,
    publisher: shelf.filterPublisher,
    isbn: shelf.filterIsbn,
    language: shelf.filterLanguage,
    translator: shelf.filterTranslator,
    notes: shelf.filterNotes,
    collectionIds: collectionIds.nullIfEmpty(),
    imprintIds: imprintIds.nullIfEmpty(),
    noCover: shelf.filterNoCover ? true : null,
    status: shelf.filterStatus != null ? ReadingStatus.values.firstWhereOrNull((s) => s.name == shelf.filterStatus) : null,
    format: shelf.filterFormat,
    ownership: shelf.filterOwnership,
    mediaType: shelf.filterMediaType,
    booleanQuery: bq,
  );
}

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

final bookCollectionsProvider = StreamProvider.family<List<(Tag, int?)>, int>((ref, bookId) {
  return ref.watch(databaseProvider).tagDao.watchCollectionsForBook(bookId);
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
  return db.bookDao.watchBooksByCollectionWithNumbers(collectionId).map((list) {
    return list.map((item) => item.$1.copyWith(collectionNumber: Value(item.$2))).toList();
  });
});

final imprintBookCountProvider = StreamProvider.family<int, int>((ref, imprintId) {
  return ref.watch(databaseProvider).tagDao.watchBookCountByImprint(imprintId);
});

final topTagsForBooksProvider = StreamProvider.family<List<String>, String>((ref, bookIdsString) {
  if (bookIdsString.isEmpty) return Stream.value([]);
  final db = ref.watch(databaseProvider);
  final ids = bookIdsString.split(',').map(int.parse).toList();
  return db.tagDao.watchTopTagNamesForBooks(ids).distinct();
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

  // Watch all collections to get names for sorting
  final collectionsAsync = ref.watch(allCollectionsProvider);
  final collectionNames = collectionsAsync.maybeWhen(
    data: (list) => {for (final t in list) t.id: t.name},
    orElse: () => <int, String>{},
  );

  final isBoolean = filters.mode == SearchMode.boolean;

  final stream = db.bookDao.watchBooksFiltered(
    query: isBoolean ? null : filters.query,
    author: isBoolean ? null : filters.author,
    subtitle: isBoolean ? null : filters.subtitle,
    publisher: isBoolean ? null : filters.publisher,
    isbn: isBoolean ? null : filters.isbn,
    language: isBoolean ? null : filters.language,
    translator: isBoolean ? null : filters.translator,
    notes: isBoolean ? null : filters.notes,
    collectionIds: isBoolean ? null : (filters.collections.isEmpty ? null : filters.collections.map((t) => t.id).toList()),
    tagIds: isBoolean ? null : (filters.tags.isEmpty ? null : filters.tags.map((t) => t.id).toList()),
    imprintIds: isBoolean ? null : (filters.imprints.isEmpty ? null : filters.imprints.map((t) => t.id).toList()),
    status: isBoolean ? null : filters.status,
    format: isBoolean ? null : filters.format?.name,
    mediaType: isBoolean ? null : filters.mediaType?.name,
    ownership: isBoolean ? null : filters.ownership?.name,
    booleanQuery: isBoolean ? filters.booleanQuery : null,
  );

  return stream.map((allBooks) {
    var filtered = allBooks.toList();

    // Sort
    filtered.applyLibrarySorting(
      prefs, 
      imprintNames: imprintNames,
      collectionNames: collectionNames,
    );

    return filtered;
  });
});

extension ListExt<T> on List<T> {
  List<T>? nullIfEmpty() => isEmpty ? null : this;
}
