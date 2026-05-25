import 'package:flutter/material.dart';
import '../shelves/shelves_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database.dart';
import '../../controllers/display_preferences_controller.dart';
import '../../controllers/fab_visibility_controller.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/search_filters_controller.dart';
import '../../widgets/sort_bottom_sheet.dart';
import '../../widgets/scrollable_selection_bar.dart';
import '../../widgets/books_list_or_grid.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/add_entity_fab.dart';
import '../../widgets/library_app_bar.dart';
import '../../widgets/search_panel.dart';

import '../stats/stats_view.dart';

/// Main container for the library, featuring a navigation bar for the three main sections.
class LibraryView extends ConsumerStatefulWidget {
  const LibraryView({super.key});

  @override
  ConsumerState<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends ConsumerState<LibraryView> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    _LibraryScreen(),
    ShelvesScreen(),
    StatsView(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = ref.read(searchFiltersProvider.notifier).getActiveLibraryTabIndex();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          ref.read(searchFiltersProvider.notifier).setActiveLibraryTabIndex(index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: context.l10n.navLibrary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmarks_outlined),
            selectedIcon: const Icon(Icons.bookmarks),
            label: context.l10n.navShelves,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: context.l10n.navStats,
          ),
        ],
      ),
    );
  }
}

/// The main library view showing either a list or a grid of books with advanced filtering.
class _LibraryScreen extends ConsumerStatefulWidget {
  const _LibraryScreen();

  @override
  ConsumerState<_LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<_LibraryScreen> {
  bool _searchVisible = false;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    ref.read(fabVisibilityProvider.notifier).handleScroll(_scrollController);
  }

  @override
  Widget build(BuildContext context) {
    final isFabVisible = ref.watch(fabVisibilityProvider);
    final filters = ref.watch(searchFiltersProvider);
    final booksAsync = ref.watch(filteredBooksProvider);

    return Scaffold(
      appBar: LibraryAppBar(
        searchVisible: _searchVisible,
        onSearchToggle: () {
          setState(() => _searchVisible = !_searchVisible);
          if (!_searchVisible) {
            ref.read(searchFiltersProvider.notifier).clearAll();
          }
        },
      ),
      body: Column(
        children: [
          ScrollableSelectionBar<ReadingStatus?>(
            items: [
              SelectionItem(value: null, label: context.l10n.shelfAllBooks),
              SelectionItem(value: ReadingStatus.reading, label: context.l10n.statusReading, color: Colors.blue),
              SelectionItem(value: ReadingStatus.wantToRead, label: context.l10n.statusWantToRead, color: Colors.orange),
              SelectionItem(value: ReadingStatus.read, label: context.l10n.statusRead, color: Colors.green),
              SelectionItem(value: ReadingStatus.paused, label: context.l10n.statusPaused, color: const Color(0xFFB39DDB)),
              SelectionItem(value: ReadingStatus.abandoned, label: context.l10n.statusAbandoned, color: Colors.red),
            ],
            selectedValue: filters.status,
            onSelected: (status) {
              ref.read(searchFiltersProvider.notifier).setStatus(status);
            },
            onSortTap: () {
              final controller = ref.read(displayPreferencesProvider.notifier);
              final l10n = context.l10n;

              SortBottomSheet.show(
                context,
                title: l10n.sortTitle,
                orderSelector: (p) => p.sortOrder,
                directionsSelector: (p) => p.sortDirections,
                labels: {
                  'title': l10n.fieldTitle,
                  'author': l10n.fieldAuthor,
                  'publisher': l10n.fieldPublisher,
                  'collection': l10n.fieldCollection,
                  'imprint': l10n.managementImprints,
                  'publishYear': l10n.fieldYear,
                  'createdAt': l10n.bookDetailFieldAdded,
                  'rating': l10n.fieldRating,
                },
                onReorder: controller.reorderSort,
                onToggleDirection: controller.toggleFieldSortDirection,
                showEmptyToggle: true,
                emptyAtEndSelector: (p) => p.emptyAtEnd,
                onToggleEmpty: controller.toggleEmptyAtEnd,
              );
            },
          ),
          if (_searchVisible)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchPanel(
                filters: filters,
                onChanged: (f) =>
                    ref.read(searchFiltersProvider.notifier).setFilters(f),
              ),
            ),
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: BooksListOrGrid(
                booksAsync: booksAsync,
                scrollController: _scrollController,
                filters: filters,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AddEntityFab(visible: isFabVisible),
    );
  }
}
