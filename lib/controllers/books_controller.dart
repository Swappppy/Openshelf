import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:convert';
import '../models/shelf.dart';
import '../services/database.dart';
import 'database_provider.dart';
import 'display_preferences_controller.dart';

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

  // If only a status filter is set, use the faster status-only query
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
    imprintIds: shelf.filterImprintId != null ? [shelf.filterImprintId!] : null,
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

final allImprintsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).watchTagsByType('imprint');
});

final allCollectionsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).watchTagsByType('collection');
});

final bookImprintProvider = StreamProvider.family<Tag?, int>((ref, bookId) {
  return ref.watch(databaseProvider).watchImprintForBook(bookId);
});

final booksByImprintProvider = StreamProvider.family<List<Book>, int>((ref, imprintId) {
  final db = ref.watch(databaseProvider);
  return db.watchBooksFiltered(imprintIds: [imprintId]);
});

/// Main filtered provider used by the Library view
final filteredBooksProvider = StreamProvider<List<Book>>((ref) {
  final filters = ref.watch(searchFiltersProvider);
  final db = ref.watch(databaseProvider);
  
  final sortOrder = ref.watch(displayPreferencesProvider.select((p) => p.sortOrder));
  final sortDirections = ref.watch(displayPreferencesProvider.select((p) => p.sortDirections));
  final emptyAtEnd = ref.watch(displayPreferencesProvider.select((p) => p.emptyAtEnd));
  
  Stream<List<Book>> booksStream;
  
  // Decide which database stream to use based on active filters
  if (filters.isEmpty && filters.status == null) {
    booksStream = db.watchAllBooks();
  } else if (filters.status != null && filters.isEmpty && filters.imprints.isEmpty) {
    booksStream = db.watchBooksByStatus(filters.status!);
  } else {
    booksStream = db.watchBooksFiltered(
      query: filters.query.isEmpty ? null : filters.query,
      tagIds: filters.tags.isEmpty ? null : filters.tags.map((t) => t.id).toList(),
      author: filters.author.isEmpty ? null : filters.author,
      publisher: filters.publisher.isEmpty ? null : filters.publisher,
      isbn: filters.isbn.isEmpty ? null : filters.isbn,
      collectionName: filters.collection.isEmpty ? null : filters.collection,
      imprintIds: filters.imprints.isEmpty ? null : filters.imprints.map((i) => i.id).toList(),
    );
  }

  // Handle client-side hierarchical sorting
  return booksStream.map((list) {
    final sortedList = List<Book>.from(list);
    sortedList.sort((a, b) {
      for (final criteria in sortOrder) {
        int comparison = 0;
        final isAsc = sortDirections[criteria] ?? true;

        // Push books with missing values to the end if preference is set
        if (emptyAtEnd) {
          final valA = _getSortValue(a, criteria);
          final valB = _getSortValue(b, criteria);
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
            comparison = (a.rating ?? 0).compareTo(b.rating ?? 0);
            break;
        }
        
        if (comparison != 0) {
          return isAsc ? comparison : -comparison;
        }
      }

      // Tie-breaker: Deterministic order by unique ID
      return a.id.compareTo(b.id);
    });
    return sortedList;
  });
});

/// Extracts property value for sorting logic
Object? _getSortValue(Book b, String criteria) {
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

/// Model representing the current search and category filters
class SearchFilters {
  final String query;
  final List<Tag> tags;
  final String author;
  final String publisher;
  final String isbn;
  final String collection;
  final List<Tag> imprints;
  final ReadingStatus? status;

  const SearchFilters({
    this.query = '',
    this.tags = const [],
    this.author = '',
    this.publisher = '',
    this.isbn = '',
    this.collection = '',
    this.imprints = const [],
    this.status,
  });

  bool get isEmpty =>
      query.isEmpty &&
          tags.isEmpty &&
          author.isEmpty &&
          publisher.isEmpty &&
          isbn.isEmpty &&
          collection.isEmpty &&
          imprints.isEmpty;

  SearchFilters copyWith({
    String? query,
    List<Tag>? tags,
    String? author,
    String? publisher,
    String? isbn,
    String? collection,
    List<Tag>? imprints,
    bool clearImprints = false,
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
        imprints: clearImprints ? [] : (imprints ?? this.imprints),
        status: clearStatus ? null : (status ?? this.status),
      );
}

final searchFiltersProvider =
StateProvider<SearchFilters>((ref) => const SearchFilters());

final allShelvesProvider = StreamProvider<List<Shelf>>((ref) {
  return ref.watch(databaseProvider).watchAllShelves();
});

final imprintBookCountProvider =
StreamProvider.family<int, int>((ref, imprintId) {
  return ref.watch(databaseProvider).watchBookCountByImprint(imprintId);
});