import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shelf.dart';
import '../../services/database.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/display_preferences_controller.dart';
import '../../models/display_preferences.dart';
import '../../widgets/books_list_or_grid.dart';

/// Displays the collection of books that match a dynamic shelf's criteria.
class ShelfBooksView extends ConsumerWidget {
  final Shelf shelf;
  const ShelfBooksView({super.key, required this.shelf});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(shelfBooksProvider(shelf));

    return Scaffold(
      appBar: AppBar(
        title: Text(shelf.name),
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: Consumer(builder: (context, ref, _) {
              final mode = ref.watch(displayPreferencesProvider.select((p) => p.viewMode));
              return Icon(mode == LibraryViewMode.list ? Icons.grid_view : Icons.view_list);
            }),
            onPressed: () => ref.read(displayPreferencesProvider.notifier).toggleViewMode(),
          ),
        ],
      ),
      body: BooksListOrGrid(
        booksAsync: booksAsync,
      ),
    );
  }
}

class TagBooksView extends ConsumerWidget {
  final Tag tag;
  const TagBooksView({super.key, required this.tag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dynamic filtering based on tag type.
    final booksAsync = switch (tag.type) {
      'collection' => ref.watch(booksByCollectionProvider(tag.name)),
      'imprint' => ref.watch(booksByImprintProvider(tag.id)),
      _ => ref.watch(booksByTagProvider(tag.id)),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(tag.name),
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: Consumer(builder: (context, ref, _) {
              final mode = ref.watch(displayPreferencesProvider.select((p) => p.viewMode));
              return Icon(mode == LibraryViewMode.list ? Icons.grid_view : Icons.view_list);
            }),
            onPressed: () => ref.read(displayPreferencesProvider.notifier).toggleViewMode(),
          ),
        ],
      ),
      body: BooksListOrGrid(
        booksAsync: booksAsync,
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
    final booksAsync = status == null
        ? ref.watch(allBooksProvider)
        : ref.watch(booksByStatusProvider(status!));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: Consumer(builder: (context, ref, _) {
              final mode = ref.watch(displayPreferencesProvider.select((p) => p.viewMode));
              return Icon(mode == LibraryViewMode.list ? Icons.grid_view : Icons.view_list);
            }),
            onPressed: () => ref.read(displayPreferencesProvider.notifier).toggleViewMode(),
          ),
        ],
      ),
      body: BooksListOrGrid(
        booksAsync: booksAsync,
      ),
    );
  }
}
