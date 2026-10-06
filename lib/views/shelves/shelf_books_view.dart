import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shelf.dart';
import '../../services/database.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/display_preferences_controller.dart';
import '../../controllers/database_provider.dart';
import '../../l10n/l10n_extension.dart';
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

    final displayName = (shelf.filterNoCover || shelf.name == '__auto_no_cover__')
        ? context.l10n.noCoverShelfTitle
        : shelf.name;

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
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Consumer(builder: (context, ref, _) {
                  return booksAsync.when(
                    data: (books) {
                      if (books.isEmpty) return const SizedBox.shrink();
                      final bookIds = books.map((b) => b.id).toList();
                      return Consumer(builder: (context, ref, _) {
                        final topTagsAsync = ref.watch(topTagsForBooksProvider(bookIds.join(',')));
                        return topTagsAsync.maybeWhen(
                          data: (tags) {
                            if (tags.isEmpty) return const SizedBox.shrink();
                            return Text(
                              tags.map((t) => '#$t').join(' '),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                          orElse: () => const SizedBox.shrink(),
                        );
                      });
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  );
                }),
              ],
            ),
          ),
        ),
        toolbarHeight: 72,
        actions: [
          IconButton(
            icon: Consumer(builder: (context, ref, _) {
              final mode = ref.watch(displayPreferencesProvider.select((p) => p.viewMode));
              return Icon(mode == LibraryViewMode.list ? Icons.grid_view : Icons.view_list);
            }),
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(displayPreferencesProvider.notifier).toggleViewMode();
            },
          ),
        ],
      ),
      body: BooksListOrGrid(
        booksAsync: booksAsync,
        emptySubtitle: context.l10n.shelfBooksEmptyHint,
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
        toolbarHeight: 56,
        actions: [
          IconButton(
            icon: Consumer(builder: (context, ref, _) {
              final mode = ref.watch(displayPreferencesProvider.select((p) => p.viewMode));
              return Icon(mode == LibraryViewMode.list ? Icons.grid_view : Icons.view_list);
            }),
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(displayPreferencesProvider.notifier).toggleViewMode();
            },
          ),
        ],
      ),
      body: BooksListOrGrid(
        booksAsync: booksAsync,
        isCollection: tag.type == TagType.collection,
        emptySubtitle: context.l10n.shelfBooksEmptyHint,
        onLongPress: (book) => _showBookOptions(context, ref, book),
      ),
    );
  }

  void _showBookOptions(BuildContext context, WidgetRef ref, Book book) {
    HapticFeedback.lightImpact();
    final l10n = context.l10n;
    final db = ref.read(databaseProvider);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  book.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.label_off_outlined),
                title: Text(switch (tag.type) {
                  TagType.collection => l10n.removeFromCollection,
                  TagType.imprint => l10n.removeFromImprint,
                  _ => l10n.removeFromCategory,
                }),
                onTap: () async {
                  Navigator.pop(context);
                  await db.tagDao.removeTagFromBook(book.id, tag);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                title: Text(
                  l10n.delete,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteBook(context, ref, book);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteBook(BuildContext context, WidgetRef ref, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.bookDetailDeleteTitle),
        content: Text(context.l10n.bookDetailDeleteConfirm(book.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(databaseProvider).bookDao.deleteBook(book.id);
            },
            child: Text(
              context.l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
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
        toolbarHeight: 56,
        actions: [
          IconButton(
            icon: Consumer(builder: (context, ref, _) {
              final mode = ref.watch(displayPreferencesProvider.select((p) => p.viewMode));
              return Icon(mode == LibraryViewMode.list ? Icons.grid_view : Icons.view_list);
            }),
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(displayPreferencesProvider.notifier).toggleViewMode();
            },
          ),
        ],
      ),
      body: BooksListOrGrid(
        booksAsync: booksAsync,
        emptySubtitle: context.l10n.shelfBooksEmptyHint,
      ),
    );
  }
}
