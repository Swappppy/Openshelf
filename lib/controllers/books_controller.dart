import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '../models/shelf.dart';
import '../models/display_preferences.dart';
import '../models/tag_type.dart';
import '../services/database.dart';
import 'database_provider.dart';
import 'display_preferences_controller.dart';
import 'search_filters_controller.dart';

/// Stream of all books in the database
final allBooksProvider = StreamProvider<List<Book>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllBooks();
});

final allShelvesProvider = StreamProvider<List<Shelf>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllShelves();
});

/// Provider for shelves with calculated book counts
final allShelvesWithStatsProvider = StreamProvider<List<(Shelf, int, int)>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllShelves().switchMap((list) {
    if (list.isEmpty) return Stream.value([]);
    
    final streams = list.map((shelf) {
      return db.watchBooksFiltered(
        query: shelf.filterQuery,
        author: shelf.filterAuthor,
        publisher: shelf.filterPublisher,
        isbn: shelf.filterIsbn,
        language: shelf.filterLanguage,
        collectionIds: shelf.filterCollectionIds != null ? (json.decode(shelf.filterCollectionIds!) as List).cast<int>() : null,
        tagIds: shelf.filterTagIds != null ? (json.decode(shelf.filterTagIds!) as List).cast<int>() : null,
        imprintIds: shelf.filterImprintIds != null ? (json.decode(shelf.filterImprintIds!) as List).cast<int>() : null,
        noCover: shelf.filterNoCover,
      ).map((books) {
        final readCount = books.where((b) => b.status == ReadingStatus.read).length;
        return (shelf, books.length, readCount);
      });
    }).toList();
    
    return CombineLatestStream.list(streams);
  });
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

  final collectionIds = shelf.filterCollectionIds != null
      ? (jsonDecode(shelf.filterCollectionIds!) as List).cast<int>()
      : <int>[];

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
    return db.watchBooksByStatus(status);
  }

  return db.watchBooksFiltered(
    query: shelf.filterQuery,
    tagIds: tagIds.isEmpty ? null : tagIds,
    author: shelf.filterAuthor,
    publisher: shelf.filterPublisher,
    isbn: shelf.filterIsbn,
    collectionIds: collectionIds.isEmpty ? null : collectionIds,
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
  return ref.watch(databaseProvider).watchTagsByType(TagType.tag);
});

/// Provider for tags including their usage count for visual scaling (cloud).
final allTagsWithCountsProvider = StreamProvider<List<(Tag, int)>>((ref) {
  return ref.watch(databaseProvider).watchTagsByTypeWithCounts(TagType.tag);
});

final allImprintsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).watchTagsByType(TagType.imprint);
});

final allImprintsWithCountsProvider = StreamProvider<List<(Tag, int)>>((ref) {
  return ref.watch(databaseProvider).watchTagsByTypeWithCounts(TagType.imprint);
});

final allCollectionsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).watchTagsByType(TagType.collection);
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

final booksByCollectionProvider = StreamProvider.family<List<Book>, int>((ref, collectionId) {
  final db = ref.watch(databaseProvider);
  return db.watchBooksFiltered(collectionIds: [collectionId]);
});

final imprintBookCountProvider = StreamProvider.family<int, int>((ref, imprintId) {
  return ref.watch(databaseProvider).watchBookCountByImprint(imprintId);
});

final collectionBookCountProvider = StreamProvider.family<int, String>((ref, collectionName) {
  final db = ref.watch(databaseProvider);
  // Still useful for some UI parts that only have the name string
  return db.watchBooksFiltered().map((list) => list.where((b) => b.collectionName == collectionName).length);
});

/// Main filtered provider used by the Library view
final filteredBooksProvider = Provider<AsyncValue<List<Book>>>((ref) {
  final booksAsync = ref.watch(allBooksProvider);
  final filters = ref.watch(searchFiltersProvider);
  final prefs = ref.watch(displayPreferencesProvider);

  return booksAsync.whenData((allBooks) {
    var filtered = allBooks.where((book) {
      // 1. Search Query (Title only)
      if (filters.query.isNotEmpty &&
          !book.title.toLowerCase().contains(filters.query.toLowerCase())) {
        return false;
      }
      
      // 2. Status Filter
      if (filters.status != null && book.status != filters.status) {
        return false;
      }

      // 3. ISBN Filter
      if (filters.isbn.isNotEmpty && book.isbn != filters.isbn) {
        return false;
      }

      // 4. Author Filter
      if (filters.author.isNotEmpty && 
          !book.author.toLowerCase().contains(filters.author.toLowerCase())) {
        return false;
      }

      // 5. Publisher Filter
      if (filters.publisher.isNotEmpty && 
          !(book.publisher ?? '').toLowerCase().contains(filters.publisher.toLowerCase())) {
        return false;
      }

      // 6. Language Filter
      if (filters.language.isNotEmpty && 
          !(book.language ?? '').toLowerCase().contains(filters.language.toLowerCase())) {
        return false;
      }

      return true;
    }).toList();

    // 7. Sort
    applyLibrarySorting(filtered, prefs);

    return filtered;
  });
});

/// Global utility to sort any list of books based on user preferences.
void applyLibrarySorting(List<Book> books, DisplayPreferences prefs) {
  books.sort((a, b) {
    for (final criteria in prefs.sortOrder) {
      final isAsc = prefs.sortDirections[criteria] ?? true;
      int comparison = 0;
      
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
      
      if (comparison != 0) return isAsc ? comparison : -comparison;
    }
    return 0;
  });
}

/// Dynamic helper for accessing book fields by string key
dynamic getBookFieldValue(Book b, String key) {
  switch (key) {
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
