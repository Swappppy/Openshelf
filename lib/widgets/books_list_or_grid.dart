import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/display_preferences.dart';
import '../models/search_filters.dart';
import '../services/database.dart';
import '../controllers/display_preferences_controller.dart';
import '../controllers/app_settings_controller.dart';
import '../controllers/books_controller.dart';
import '../views/book_detail/book_detail_view.dart';
import '../l10n/l10n_extension.dart';
import 'book_list_tile.dart';
import 'book_grid_card.dart';

/// A reusable widget that displays a list or grid of books based on user preferences.
/// Handles empty states, loading, and sorting internally or via provided providers.
class BooksListOrGrid extends ConsumerWidget {
  final AsyncValue<List<Book>> booksAsync;
  final ScrollController? scrollController;
  final SearchFilters? filters;
  final bool isCollection;
  final String? emptyMessage;

  const BooksListOrGrid({
    super.key,
    required this.booksAsync,
    this.scrollController,
    this.filters,
    this.isCollection = false,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(displayPreferencesProvider);
    final gridColumns = ref.watch(appSettingsProvider.select((s) => s.libraryGridColumns));
    final viewMode = prefs.viewMode;
    final colorScheme = Theme.of(context).colorScheme;

    return booksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(context.l10n.errorPrefix(e.toString()))),
      data: (bookList) {
        if (bookList.isEmpty) {
          final isSearching = filters != null && (!filters!.isEmpty || filters!.status != null);
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSearching ? Icons.search_off : Icons.menu_book,
                    size: 80,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emptyMessage ?? (isSearching ? context.l10n.libraryNoResults : context.l10n.libraryEmpty),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (!isSearching) ...[
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.libraryEmptyHint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        final items = List<Book>.from(bookList);
        if (isCollection) {
          items.sort((a, b) => (a.collectionNumber ?? 0).compareTo(b.collectionNumber ?? 0));
        } else {
          // Apply standard library sorting to all other views by default
          final prefs = ref.watch(displayPreferencesProvider);
          final imprintsAsync = ref.watch(allImprintsProvider);
          final imprintNames = imprintsAsync.maybeWhen(
            data: (list) => {for (final t in list) t.id: t.name},
            orElse: () => <int, String>{},
          );
          applyLibrarySorting(items, prefs, imprintNames: imprintNames);
        }

        return viewMode == LibraryViewMode.list
            ? ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final book = items[index];
                  return BookListTile(
                    book: book,
                    prefs: prefs,
                    collectionNumber: isCollection ? book.collectionNumber : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailView(book: book),
                      ),
                    ),
                  );
                },
              )
            : GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns,
                  childAspectRatio: gridColumns >= 3 ? 0.60 : 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final book = items[index];
                  return BookGridCard(
                    book: book,
                    prefs: prefs,
                    overlayLabel: isCollection ? (book.collectionNumber?.toString()) : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailView(book: book),
                      ),
                    ),
                  );
                },
              );
      },
    );
  }
}
