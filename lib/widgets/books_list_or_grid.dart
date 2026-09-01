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
import '../utils/book_sorting.dart';
import 'book_list_tile.dart';
import 'book_grid_card.dart';
import 'os_empty_state.dart';

/// A reusable widget that displays a list or grid of books based on user preferences.
/// Handles empty states, loading, and sorting internally or via provided providers.
class BooksListOrGrid extends ConsumerWidget {
  final AsyncValue<List<Book>> booksAsync;
  final ScrollController? scrollController;
  final SearchFilters? filters;
  final bool isCollection;
  final String? emptyMessage;
  final String? emptySubtitle;
  final VoidCallback? onAddPressed;

  const BooksListOrGrid({
    super.key,
    required this.booksAsync,
    this.scrollController,
    this.filters,
    this.isCollection = false,
    this.emptyMessage,
    this.emptySubtitle,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(displayPreferencesProvider);
    final gridColumns = ref.watch(appSettingsProvider.select((s) => s.libraryGridColumns));
    final viewMode = prefs.viewMode;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        // We handle AsyncValue state INSIDE the switcher to allow cross-fades
        child: booksAsync.when(
          skipLoadingOnRefresh: true, // IMPORTANT: Prevents showing spinner during data updates
          loading: () => const Center(
            key: ValueKey('loading_spinner'),
            child: CircularProgressIndicator(),
          ),
          error: (e, _) => Center(
            key: ValueKey('error_state'),
            child: Text(context.l10n.errorPrefix(e.toString())),
          ),
          data: (bookList) => _buildView(context, ref, bookList, viewMode, gridColumns, prefs),
        ),
      ),
    );
  }

  Widget _buildSoberEmptyState(
    BuildContext context,
    String message,
    String? subtitle, {
    IconData icon = Icons.shelves,
    Key? key,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      key: key ?? const ValueKey('sober_empty_state'),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Icon(
                  icon,
                  size: 80,
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildView(
    BuildContext context,
    WidgetRef ref,
    List<Book> bookList,
    LibraryViewMode viewMode,
    int gridColumns,
    DisplayPreferences prefs,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (bookList.isEmpty) {
      final isSearching = filters != null && (!filters!.isEmpty || filters!.status != null);

      if (isSearching) {
        return _buildSoberEmptyState(
          context,
          context.l10n.libraryNoResults,
          context.l10n.libraryNoResultsHint,
          icon: Icons.search_off,
          key: const ValueKey('empty_search_results'),
        );
      }

      if (onAddPressed == null) {
        return _buildSoberEmptyState(
          context,
          emptyMessage ?? context.l10n.shelfBooksEmpty,
          emptySubtitle ?? context.l10n.shelfBooksEmptyHint,
        );
      }

      return OsEmptyState(
        key: const ValueKey('empty_library_state'),
        iconWidget: OpenshelfLogoIcon(size: 70, color: colorScheme.primary),
        message: emptyMessage ?? context.l10n.libraryEmpty,
        subtitle: context.l10n.libraryEmptyHint,
        actionLabel: context.l10n.libraryAddFirstBook,
        onActionPressed: onAddPressed,
        accentColor: colorScheme.primary,
      );
    }

    // Sort items
    final items = List<Book>.from(bookList);
    if (isCollection) {
      items.sort((a, b) => (a.collectionNumber ?? 0).compareTo(b.collectionNumber ?? 0));
    } else {
      final imprintsAsync = ref.watch(allImprintsProvider);
      final imprintNames = imprintsAsync.maybeWhen(
        data: (list) => {for (final t in list) t.id: t.name},
        orElse: () => <int, String>{},
      );
      final collectionsAsync = ref.watch(allCollectionsProvider);
      final collectionNames = collectionsAsync.maybeWhen(
        data: (list) => {for (final t in list) t.id: t.name},
        orElse: () => <int, String>{},
      );
      items.applyLibrarySorting(
        prefs,
        imprintNames: imprintNames,
        collectionNames: collectionNames,
      );
    }

    if (viewMode == LibraryViewMode.list) {
      return ListView.builder(
        key: const ValueKey('list_layout'),
        controller: scrollController,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final book = items[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index.clamp(0, 10) * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: BookListTile(
              book: book,
              prefs: prefs,
              collectionNumber: isCollection ? book.collectionNumber : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookDetailView(book: book)),
              ),
            ),
          );
        },
      );
    } else {
      return GridView.builder(
        key: const ValueKey('grid_layout'),
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
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index.clamp(0, 10) * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: BookGridCard(
              book: book,
              prefs: prefs,
              overlayLabel: isCollection ? (book.collectionNumber?.toString()) : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookDetailView(book: book)),
              ),
            ),
          );
        },
      );
    }
  }
}
