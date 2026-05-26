import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shelf.dart';
import '../../models/tag_type.dart';
import '../../services/database.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/display_preferences_controller.dart';
import '../../models/display_preferences.dart';
import '../../widgets/books_list_or_grid.dart';
import '../../widgets/cover_mosaic.dart';
import '../../widgets/cover_stack_fade.dart';

/// Displays the collection of books that match a dynamic shelf's criteria.
class ShelfBooksView extends ConsumerWidget {
  final Shelf shelf;
  const ShelfBooksView({super.key, required this.shelf});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(shelfBooksProvider(shelf));

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Hero(
            tag: 'shelf_mosaic_${shelf.id}',
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CoverMosaic(books: booksAsync.value ?? []),
              ),
            ),
          ),
        ),
        title: Hero(
          tag: 'shelf_title_${shelf.id}',
          child: Material(
            color: Colors.transparent,
            child: Text(
              shelf.name,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
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
      TagType.collection => ref.watch(booksByCollectionProvider(tag.id)),
      TagType.imprint => ref.watch(booksByImprintProvider(tag.id)),
      _ => ref.watch(booksByTagProvider(tag.id)),
    };

    final prefix = switch (tag.type) {
      TagType.collection => 'collection',
      TagType.imprint => 'imprint',
      _ => 'tag',
    };

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Hero(
            tag: '${prefix}_stack_${tag.id}',
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CoverStackFade(books: booksAsync.value ?? [], height: 32),
              ),
            ),
          ),
        ),
        title: Hero(
          tag: '${prefix}_title_${tag.id}',
          child: Material(
            color: Colors.transparent,
            child: Text(
              tag.name,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
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
        isCollection: tag.type == TagType.collection,
      ),
    );
  }
}

class StatusBooksView extends ConsumerWidget {
  final ReadingStatus? status;
  final String title;
  final List<Book>? customBooks;

  const StatusBooksView({
    super.key,
    required this.status,
    required this.title,
    this.customBooks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = customBooks != null
        ? AsyncValue.data(customBooks!)
        : (status == null
            ? ref.watch(allBooksProvider)
            : ref.watch(booksByStatusProvider(status!)));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
