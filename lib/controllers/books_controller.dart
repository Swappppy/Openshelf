import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shelf.dart';
import '../models/display_preferences.dart';
import '../services/database.dart';
import 'database_provider.dart';
import 'display_preferences_controller.dart';
import 'search_filters_controller.dart';

/// Stream of all books in the database
final allBooksProvider = StreamProvider<List<Book>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllBooks();
});

/// Specific provider for books within a dynamic shelf
final shelfBooksProvider =
StreamProvider.family<List<Book>, Shelf>((ref, shelf) {
  final db = ref.watch(databaseProvider);
  final tagIds = shelf.filterTagIds != null
      ? (jsonDecode(shelf.filterTagIds!) as List).cast<int>()
      : <int>[];
      
  final imprintIds = shelf.filterImprintIds != null
      ? (jsonDecode(shelf.filterImprintIds!) as List).cast<int>()
      : <int>[];

  final collectionNames = shelf.filterCollection != null
      ? shelf.filterCollection!.split(' | ')
      : <String>[];

  // If only a status filter is set, use the faster status-only query
  if (shelf.filterStatus != null &&
      tagIds.isEmpty &&
      imprintIds.isEmpty &&
      shelf.filterQuery == null &&
      shelf.filterAuthor == null &&
      shelf.filterPublisher == null &&
      shelf.filterIsbn == null &&
      collectionNames.isEmpty) {
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
    collectionNames: collectionNames.isEmpty ? null : collectionNames,
    imprintIds: imprintIds.isEmpty ? null : imprintIds,
    noCover: shelf.filterNoCover,
  );
});

/// Stream of books filtered by reading status
final booksByStatusProvider =
StreamProvider.family<List<Book>, ReadingStatus>((ref, status) {
  final db = ref.watch(databaseProvider);
  return db.watchBooksByStatus(status);
});

/// Reactive count of books for a specific status
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

/// Provider for tags including their usage count for visual scaling (cloud).
final allTagsWithCountsProvider = StreamProvider<List<(Tag, int)>>((ref) {
  return ref.watch(databaseProvider).watchTagsByTypeWithCounts('tag');
});

final allImprintsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).watchTagsByType('imprint');
});

final allImprintsWithCountsProvider = StreamProvider<List<(Tag, int)>>((ref) {
  return ref.watch(databaseProvider).watchTagsByTypeWithCounts('imprint');
});

final allCollectionsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).watchTagsByType('collection');
});

final allCollectionsWithCountsProvider = StreamProvider<List<(Tag, int)>>((ref) {
  return ref.watch(databaseProvider).watchCollectionsWithCounts();
});

final bookImprintProvider = StreamProvider.family<Tag?, int>((ref, bookId) {
  return ref.watch(databaseProvider).watchImprintForBook(bookId);
});

final booksByImprintProvider = StreamProvider.family<List<Book>, int>((ref, imprintId) {
  final db = ref.watch(databaseProvider);
  return db.watchBooksFiltered(imprintIds: [imprintId]);
});

final booksByTagProvider = StreamProvider.family<List<Book>, int>((ref, tagId) {
  final db = ref.watch(databaseProvider);
  return db.watchBooksFiltered(tagIds: [tagId]);
});

final booksByCollectionProvider = StreamProvider.family<List<Book>, String>((ref, collectionName) {
  final db = ref.watch(databaseProvider);
  return db.watchBooksFiltered(collectionNames: [collectionName]);
});

/// Main filtered provider used by the Library view
final filteredBooksProvider = StreamProvider<List<Book>>((ref) {
  final filters = ref.watch(searchFiltersProvider);
  final db = ref.watch(databaseProvider);
  
  Stream<List<Book>> booksStream;

  final activeCollectionNames = {
    if (filters.collection.isNotEmpty) filters.collection,
    ...filters.collections.map((c) => c.name),
  }.toList();
  
  // Decide which database stream to use based on active filters
  if (filters.isEmpty && filters.status == null) {
    booksStream = db.watchAllBooks();
  } else if (filters.status != null && filters.isEmpty && filters.imprints.isEmpty && filters.collections.isEmpty) {
    booksStream = db.watchBooksByStatus(filters.status!);
  } else {
    booksStream = db.watchBooksFiltered(
      query: filters.query.isEmpty ? null : filters.query,
      tagIds: filters.tags.isEmpty ? null : filters.tags.map((t) => t.id).toList(),
      author: filters.author.isEmpty ? null : filters.author,
      publisher: filters.publisher.isEmpty ? null : filters.publisher,
      isbn: filters.isbn.isEmpty ? null : filters.isbn,
      language: filters.language.isEmpty ? null : filters.language,
      collectionNames: activeCollectionNames.isEmpty ? null : activeCollectionNames,
      imprintIds: filters.imprints.isEmpty ? null : filters.imprints.map((i) => i.id).toList(),
    );
  }

  return booksStream.map((list) => applyLibrarySorting(ref, list));
});

/// Reusable sorting logic based on global user preferences.
List<Book> applyLibrarySorting(dynamic refOrWidgetRef, List<Book> list) {
  final DisplayPreferences prefs = refOrWidgetRef is WidgetRef 
      ? refOrWidgetRef.watch(displayPreferencesProvider)
      : refOrWidgetRef.watch(displayPreferencesProvider);
  final sortOrder = prefs.sortOrder;
  final sortDirections = prefs.sortDirections;
  final emptyAtEnd = prefs.emptyAtEnd;

  final sortedList = List<Book>.from(list);
  sortedList.sort((a, b) {
    for (final criteria in sortOrder) {
      int comparison = 0;
      final isAsc = sortDirections[criteria] ?? true;

      // Push books with missing values to the end if preference is set
      if (emptyAtEnd) {
        final valA = getBookSortValue(a, criteria);
        final valB = getBookSortValue(b, criteria);
        final isEmptyA = valA == null || (valA is String && valA.isEmpty);
        final isEmptyB = valB == null || (valB is String && valB.isEmpty);
        
        if (isEmptyA && !isEmptyB) return 1;
        if (!isEmptyA && isEmptyB) return -1;
        if (isEmptyA && isEmptyB) continue; 
      }

      switch (criteria) {
        case 'title':
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case 'author':
          comparison = a.author.toLowerCase().compareTo(b.author.toLowerCase());
          break;
        case 'publisher':
          comparison = (a.publisher ?? '').toLowerCase().compareTo((b.publisher ?? '').toLowerCase());
          break;
        case 'collection':
          comparison = (a.collectionName ?? '').toLowerCase().compareTo((b.collectionName ?? '').toLowerCase());
          break;
        case 'imprint':
          comparison = (a.publisher ?? '').toLowerCase().compareTo((b.publisher ?? '').toLowerCase());
          break;
        case 'publishYear':
          comparison = (a.publishYear ?? 0).compareTo(b.publishYear ?? 0);
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'rating':
          comparison = (a.rating ?? 0.0).compareTo(b.rating ?? 0.0);
          break;
      }

      if (comparison != 0) {
        return isAsc ? comparison : -comparison;
      }
    }
    return 0;
  });
  return sortedList;
}

/// Helper to get the value of a specific field for sorting
Object? getBookSortValue(Book b, String criteria) {
  switch (criteria) {
    case 'title': return b.title;
    case 'author': return b.author;
    case 'publisher': return b.publisher;
    case 'collection': return b.collectionName;
    case 'imprint': return b.publisher;
    case 'publishYear': return b.publishYear;
    case 'createdAt': return b.createdAt;
    case 'rating': return b.rating;
    default: return null;
  }
}

final allShelvesProvider = StreamProvider<List<Shelf>>((ref) {
  return ref.watch(databaseProvider).watchAllShelves();
});

final imprintBookCountProvider =
StreamProvider.family<int, int>((ref, imprintId) {
  return ref.watch(databaseProvider).watchBookCountByImprint(imprintId);
});

final collectionBookCountProvider =
StreamProvider.family<int, String>((ref, collectionName) {
  final db = ref.read(databaseProvider);
  return db.watchBooksFiltered(collectionNames: [collectionName]).map((list) => list.length);
});

/// Provider that calculates stats (count, read count) for all shelves reactively.
final allShelvesWithStatsProvider = Provider<AsyncValue<List<(Shelf, int, int)>>>((ref) {
  final shelvesAsync = ref.watch(allShelvesProvider);
  
  return shelvesAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (shelves) {
      final stats = <(Shelf, int, int)>[];
      bool isAnyLoading = false;
      
      for (final shelf in shelves) {
        final booksAsync = ref.watch(shelfBooksProvider(shelf));
        booksAsync.when(
          data: (books) {
            final count = books.length;
            final readCount = books.where((b) => b.status == ReadingStatus.read).length;
            stats.add((shelf, count, readCount));
          },
          loading: () => isAnyLoading = true,
          error: (e, st) {}, // Ignore errors for individual shelves for now
        );
      }
      
      if (isAnyLoading) return const AsyncValue.loading();
      return AsyncValue.data(stats);
    },
  );
});
