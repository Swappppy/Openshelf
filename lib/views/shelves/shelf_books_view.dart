import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shelf.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/display_preferences_controller.dart';
import '../../models/display_preferences.dart';
import '../../widgets/book_list_tile.dart';
import '../../widgets/book_grid_card.dart';
import '../book_detail/book_detail_view.dart';
import '../../services/database.dart';
import '../../l10n/l10n_extension.dart';

/// Displays the collection of books that match a dynamic shelf's criteria.
class ShelfBooksView extends ConsumerWidget {
  final Shelf shelf;
  const ShelfBooksView({super.key, required this.shelf});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(displayPreferencesProvider.select((p) => p.viewMode));
    final controller = ref.read(displayPreferencesProvider.notifier);
    final booksAsync = ref.watch(shelfBooksProvider(shelf));

    return Scaffold(
      appBar: AppBar(
        title: Text(shelf.name),
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: Icon(
              viewMode == LibraryViewMode.list
                  ? Icons.grid_view
                  : Icons.view_list,
            ),
            onPressed: controller.toggleViewMode,
          ),
        ],
      ),
      body: _BooksListOrGrid(
        booksAsync: booksAsync,
        viewMode: viewMode,
      ),
    );
  }
}

class TagBooksView extends ConsumerWidget {
  final Tag tag;
  const TagBooksView({super.key, required this.tag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(displayPreferencesProvider.select((p) => p.viewMode));
    final controller = ref.read(displayPreferencesProvider.notifier);

    // Dynamic filtering based on tag ID or collection name.
    final booksAsync = tag.type == 'collection' 
        ? ref.watch(booksByCollectionProvider(tag.name))
        : ref.watch(booksByImprintProvider(tag.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(tag.name),
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: Icon(
              viewMode == LibraryViewMode.list
                  ? Icons.grid_view
                  : Icons.view_list,
            ),
            onPressed: controller.toggleViewMode,
          ),
        ],
      ),
      body: _BooksListOrGrid(
        booksAsync: booksAsync,
        viewMode: viewMode,
        isCollection: tag.type == 'collection',
      ),
    );
  }
}

class StatusBooksView extends ConsumerWidget {
  final ReadingStatus? status;
  final String title;

  const StatusBooksView({
    super.key,
    required this.status,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(displayPreferencesProvider.select((p) => p.viewMode));
    final controller = ref.read(displayPreferencesProvider.notifier);

    final booksAsync = status == null
        ? ref.watch(allBooksProvider)
        : ref.watch(booksByStatusProvider(status!));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: Icon(
              viewMode == LibraryViewMode.list
                  ? Icons.grid_view
                  : Icons.view_list,
            ),
            onPressed: controller.toggleViewMode,
          ),
        ],
      ),
      body: _BooksListOrGrid(
        booksAsync: booksAsync,
        viewMode: viewMode,
      ),
    );
  }
}

class _BooksListOrGrid extends ConsumerWidget {
  final AsyncValue<List<Book>> booksAsync;
  final LibraryViewMode viewMode;
  final bool isCollection;

  const _BooksListOrGrid({
    required this.booksAsync,
    required this.viewMode,
    this.isCollection = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(displayPreferencesProvider);

    return booksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(context.l10n.errorPrefix(e.toString()))),
      data: (bookList) {
        if (bookList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book,
                    size: 80,
                    color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 16),
                Text(context.l10n.shelfStatusBooksEmpty,
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          );
        }

        final items = List<Book>.from(bookList);
        if (isCollection) {
          items.sort((a, b) => (a.collectionNumber ?? 0).compareTo(b.collectionNumber ?? 0));
        }

        return viewMode == LibraryViewMode.list
            ? ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final book = items[index];
            return BookListTile(
              book: book,
              prefs: prefs,
              leading: isCollection ? Container(
                width: 32,
                alignment: Alignment.center,
                child: Text(
                  '${book.collectionNumber ?? ""}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 10,
                  ),
                ),
              ) : null,
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
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
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

// Deleted _CollectionBookTile as it is no longer used.
