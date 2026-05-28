import '../services/database.dart';
import '../models/display_preferences.dart';

extension BookSortingExtension on List<Book> {
  /// Sorts the list of books based on user preferences.
  void applyLibrarySorting(DisplayPreferences prefs, {Map<int, String>? imprintNames}) {
    sort((a, b) {
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
            final nameA = (imprintNames != null && a.imprintId != null) ? (imprintNames[a.imprintId] ?? '') : '';
            final nameB = (imprintNames != null && b.imprintId != null) ? (imprintNames[b.imprintId] ?? '') : '';
            comparison = nameA.toLowerCase().compareTo(nameB.toLowerCase());
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
}
