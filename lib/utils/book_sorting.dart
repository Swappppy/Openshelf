import '../services/database.dart';
import '../models/display_preferences.dart';

extension BookSortingExtension on List<Book> {
  /// Sorts the list of books based on user preferences.
  ///
  /// For criteria a book may lack (publisher, collection, imprint, year,
  /// finish date, rating), books without a value go last or first according
  /// to [DisplayPreferences.emptyAtEnd], whatever the sort direction.
  void applyLibrarySorting(DisplayPreferences prefs, {
    Map<int, String>? imprintNames,
    Map<int, String>? collectionNames,
  }) {
    String? collectionName(Book b) {
      final name = (collectionNames != null && b.collectionId != null)
          ? collectionNames[b.collectionId]
          : b.collectionName;
      return (name == null || name.isEmpty) ? null : name.toLowerCase();
    }

    String? imprintName(Book b) {
      final name = (imprintNames != null && b.imprintId != null) ? imprintNames[b.imprintId] : null;
      return (name == null || name.isEmpty) ? null : name.toLowerCase();
    }

    String? publisher(Book b) {
      final p = b.publisher;
      return (p == null || p.isEmpty) ? null : p.toLowerCase();
    }

    sort((a, b) {
      for (final criteria in prefs.sortOrder) {
        final isAsc = prefs.sortDirections[criteria] ?? true;
        final int comparison;

        switch (criteria) {
          case 'title':
            comparison = _directed(a.title.toLowerCase().compareTo(b.title.toLowerCase()), isAsc);
            break;
          case 'author':
            comparison = _directed(a.author.toLowerCase().compareTo(b.author.toLowerCase()), isAsc);
            break;
          case 'createdAt':
            comparison = _directed(a.createdAt.compareTo(b.createdAt), isAsc);
            break;
          case 'publisher':
            comparison = _compareOptional(publisher(a), publisher(b), isAsc, prefs.emptyAtEnd);
            break;
          case 'collection':
            comparison = _compareOptional(collectionName(a), collectionName(b), isAsc, prefs.emptyAtEnd);
            break;
          case 'imprint':
            comparison = _compareOptional(imprintName(a), imprintName(b), isAsc, prefs.emptyAtEnd);
            break;
          case 'publishYear':
            comparison = _compareOptional(a.publishYear, b.publishYear, isAsc, prefs.emptyAtEnd);
            break;
          case 'finishedAt':
            comparison = _compareOptional(a.finishedAt, b.finishedAt, isAsc, prefs.emptyAtEnd);
            break;
          case 'rating':
            comparison = _compareOptional(
                (a.rating ?? 0) > 0 ? a.rating : null, (b.rating ?? 0) > 0 ? b.rating : null, isAsc, prefs.emptyAtEnd);
            break;
          default:
            comparison = 0;
        }

        if (comparison != 0) return comparison;
      }
      return 0;
    });
  }
}

int _directed(int comparison, bool isAsc) => isAsc ? comparison : -comparison;

/// Compares two optional values; missing values are placed according to
/// [emptyAtEnd] independently of the sort direction.
int _compareOptional<T extends Comparable<Object>>(T? a, T? b, bool isAsc, bool emptyAtEnd) {
  if (a == null && b == null) return 0;
  if (a == null) return emptyAtEnd ? 1 : -1;
  if (b == null) return emptyAtEnd ? -1 : 1;
  return _directed(a.compareTo(b), isAsc);
}
