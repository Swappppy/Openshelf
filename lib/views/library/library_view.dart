import 'package:flutter/material.dart';
import '../shelves/shelves_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/display_preferences_controller.dart';
import '../../models/display_preferences.dart';
import '../../services/database.dart';
import '../../controllers/fab_visibility_controller.dart';
import '../../widgets/book_list_tile.dart';
import '../../widgets/book_grid_card.dart';
import '../../controllers/books_controller.dart';
import '../book_detail/book_detail_view.dart';
import '../settings/settings_view.dart';
import '../../widgets/filter_grid_box.dart';
import '../../widgets/sort_bottom_sheet.dart';
import '../../widgets/scrollable_selection_bar.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/add_entity_fab.dart';

import 'stats_view.dart';

/// Main container for the library, featuring a navigation bar for the three main sections.
class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _LibraryScreen(),
    ShelvesScreen(),
    StatsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
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

  /// Handles auto-hiding the FAB based on scroll position and direction.
  void _scrollListener() {
    ref.read(fabVisibilityProvider.notifier).handleScroll(_scrollController);
  }

  @override
  Widget build(BuildContext context) {
    final isFabVisible = ref.watch(fabVisibilityProvider);
    final viewMode = ref.watch(displayPreferencesProvider.select((p) => p.viewMode));
    final filters = ref.watch(searchFiltersProvider);
    final booksAsync = ref.watch(filteredBooksProvider);

    return Scaffold(
      appBar: _LibraryAppBar(
        searchVisible: _searchVisible,
        onSearchToggle: () {
          setState(() => _searchVisible = !_searchVisible);
          if (!_searchVisible) {
            ref.read(searchFiltersProvider.notifier).state = const SearchFilters();
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
              ref.read(searchFiltersProvider.notifier).state =
                  filters.copyWith(status: status, clearStatus: status == null);
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
              child: _SearchPanel(
                filters: filters,
                onChanged: (f) =>
                    ref.read(searchFiltersProvider.notifier).state = f,
              ),
            ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: _BooksListOrGrid(
                booksAsync: booksAsync,
                viewMode: viewMode,
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

class _LibraryAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool searchVisible;
  final VoidCallback onSearchToggle;

  const _LibraryAppBar({
    required this.searchVisible,
    required this.onSearchToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(displayPreferencesProvider.select((p) => p.viewMode));
    final controller = ref.read(displayPreferencesProvider.notifier);

    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.black,
      title: Text(
        context.l10n.libraryTitle,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontFamily: 'Serif',
          color: Colors.white,
        ),
      ),
      toolbarHeight: 64,
      actions: [
        _BoxedIconButton(
          icon: searchVisible ? Icons.close : Icons.search,
          onPressed: onSearchToggle,
        ),
        const SizedBox(width: 8),
        _BoxedIconButton(
          icon: viewMode == LibraryViewMode.list
              ? Icons.grid_view
              : Icons.view_list,
          onPressed: controller.toggleViewMode,
          isActive: false,
        ),
        const SizedBox(width: 8),
        _BoxedIconButton(
          icon: Icons.settings_outlined,
          onPressed: () => _DisplaySettingsMenu.show(context),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

class _BooksListOrGrid extends ConsumerWidget {
  final AsyncValue<List<Book>> booksAsync;
  final LibraryViewMode viewMode;
  final ScrollController scrollController;
  final SearchFilters filters;

  const _BooksListOrGrid({
    required this.booksAsync,
    required this.viewMode,
    required this.scrollController,
    required this.filters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(displayPreferencesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return booksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(context.l10n.errorPrefix(e.toString()))),
      data: (bookList) {
        if (bookList.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    filters.isEmpty && filters.status == null
                        ? Icons.menu_book
                        : Icons.search_off,
                    size: 80,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    filters.isEmpty && filters.status == null
                        ? context.l10n.libraryEmpty
                        : context.l10n.libraryNoResults,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    filters.isEmpty && filters.status == null
                        ? context.l10n.libraryEmptyHint
                        : context.l10n.libraryNoResultsHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return viewMode == LibraryViewMode.list
            ? ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.zero,
          itemCount: bookList.length,
          itemBuilder: (context, index) => BookListTile(
            book: bookList[index],
            prefs: prefs,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookDetailView(book: bookList[index]),
              ),
            ),
          ),
        )
            : GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: bookList.length,
          itemBuilder: (context, index) => BookGridCard(
            book: bookList[index],
            prefs: prefs,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookDetailView(book: bookList[index]),
              ),
            ),
          ),
        );
      },
    );
  }
}

// _SortMenu was deleted as it was replaced by SortBottomSheet abstraction.

class _DisplaySettingsMenu extends ConsumerWidget {
  const _DisplaySettingsMenu();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _DisplaySettingsMenu(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = ref.watch(displayPreferencesProvider);
    final controller = ref.read(displayPreferencesProvider.notifier);

    final fieldLabels = {
      'info': 'Info',
      'rating': l10n.fieldRating,
      'tags': l10n.fieldTags,
      'spacer': '—',
    };

    final fieldToggles = {
      'info': (bool v) {},
      'rating': (bool v) => controller.toggleShowRating(),
      'tags': (bool v) => controller.toggleShowTags(),
      'spacer': (bool v) => controller.toggleShowSpacer(),
    };

    final fieldValues = {
      'info': true,
      'rating': p.showRating,
      'tags': p.showTags,
      'spacer': p.showSpacer,
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16, 16, 16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.displaySettings,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: Text(context.l10n.settingsButton),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsView(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.displaySettingsDragHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReorderableListView(
                    onReorder: controller.reorderFields,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: p.fieldOrder
                        .map(
                          (field) => ListTile(
                        key: ValueKey(field),
                        leading: ReorderableDragStartListener(
                          index: p.fieldOrder.indexOf(field),
                          child: const Icon(Icons.drag_handle),
                        ),
                        title: Text(fieldLabels[field] ?? field),
                        trailing: Switch(
                          value: fieldValues[field] ?? false,
                          onChanged: fieldToggles[field],
                        ),
                      ),
                    )
                        .toList(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.drag_handle,
                        color: Colors.transparent),
                    title: Text(context.l10n.fieldReadingProgress),
                    trailing: Switch(
                      value: p.showProgress,
                      onChanged: (_) =>
                          controller.toggleShowProgress(),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.drag_handle,
                        color: Colors.transparent),
                    title: Text(context.l10n.fieldStatusChip),
                    trailing: Switch(
                      value: p.showStatusChip,
                      onChanged: (_) =>
                          controller.toggleShowStatusChip(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// _SortToggleButton was removed as it was replaced by SortBottomSheet logic.

/// A compact icon button with a boxed background and rounded corners.
class _BoxedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  const _BoxedIconButton({
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primaryContainer.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 18,
          color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// _StatusFilterRow was deleted as it was replaced by ScrollableSelectionBar.

/// The advanced search panel featuring multi-tab filtering for statuses, imprints, and categories.
class _SearchPanel extends ConsumerStatefulWidget {
  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;

  const _SearchPanel({required this.filters, required this.onChanged});

  @override
  ConsumerState<_SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends ConsumerState<_SearchPanel> with SingleTickerProviderStateMixin {
  late final TextEditingController _queryCtrl;
  late final TabController _tabController;
  bool _isExpanded = false; // Collapsed by default to keep UI clean

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController(text: widget.filters.query);
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updateQuery(String val) {
    widget.onChanged(widget.filters.copyWith(query: val));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(10), // Matched to status indicators
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input Area (Ultra-thin structure)
          SizedBox(
            height: 36,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _queryCtrl,
                    onChanged: _updateQuery,
                    textAlignVertical: TextAlignVertical.center,
                    style: textTheme.bodySmall?.copyWith(color: Colors.white, fontSize: 11),
                    decoration: InputDecoration(
                      hintText: context.l10n.bookSearchHint,
                      hintStyle: textTheme.bodySmall?.copyWith(color: Colors.white38, fontSize: 11),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
                    child: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Active filter chips (Only visible if at least one filter is applied)
          if (widget.filters.tags.isNotEmpty || widget.filters.status != null || widget.filters.imprints.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.start,
                children: [
                  if (widget.filters.status != null)
                    _FilterChip(
                      label: context.l10n.searchFilterStatus(_statusLabel(context, widget.filters.status!.name)),
                      color: _statusColor(widget.filters.status!),
                      onDelete: () => widget.onChanged(widget.filters.copyWith(clearStatus: true)),
                    ),
                  ...widget.filters.imprints.map((imp) => _FilterChip(
                    label: context.l10n.searchFilterImprint(imp.name),
                    onDelete: () {
                      final newImprints = List<Tag>.from(widget.filters.imprints)..remove(imp);
                      widget.onChanged(widget.filters.copyWith(imprints: newImprints));
                    },
                  )),
                  ...widget.filters.collections.map((col) => _FilterChip(
                    label: context.l10n.searchFilterCollection(col.name),
                    onDelete: () {
                      final newCols = List<Tag>.from(widget.filters.collections)..remove(col);
                      widget.onChanged(widget.filters.copyWith(collections: newCols));
                    },
                  )),
                  ...widget.filters.tags.map((tag) => _FilterChip(
                    label: context.l10n.searchFilterCategory(tag.name),
                    color: tag.color != null ? Color(int.parse('0xFF${tag.color!}')) : null,
                    onDelete: () {
                      final newTags = List<Tag>.from(widget.filters.tags)..remove(tag);
                      widget.onChanged(widget.filters.copyWith(tags: newTags));
                    },
                  )),
                ],
              ),
            ),

          if (_isExpanded) ...[
            const Divider(height: 1, color: Colors.white10),
            // Multi-tab filter grid
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              unselectedLabelStyle: textTheme.labelSmall,
              labelColor: colorScheme.primary,
              unselectedLabelColor: Colors.white38,
              indicatorColor: colorScheme.primary,
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tabs: [
                Tab(text: context.l10n.searchTabStatus),
                Tab(text: context.l10n.searchTabImprint),
                Tab(text: context.l10n.searchTabCategory),
                Tab(text: context.l10n.searchTabCollection),
              ],
            ),

            // Tab Content with adaptive height (Max 3 rows)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _StatusFiltersTab(filters: widget.filters, onChanged: widget.onChanged),
                    _ImprintFiltersTab(filters: widget.filters, onChanged: widget.onChanged),
                    _TagFiltersTab(filters: widget.filters, onChanged: widget.onChanged),
                    _CollectionFiltersTab(filters: widget.filters, onChanged: widget.onChanged),
                  ],
                ),
              ),
            ),
          ],
          
          // Footer with filter count and "Clear All"
          if (_activeFiltersCount() > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: Row(
                children: [
                  Text(
                    context.l10n.searchActiveFilters(_activeFiltersCount()),
                    style: textTheme.labelSmall?.copyWith(color: Colors.white24, fontSize: 10),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => widget.onChanged(const SearchFilters()),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, 
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(context.l10n.searchClearAll, style: const TextStyle(fontSize: 11, color: Colors.redAccent)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  int _activeFiltersCount() {
    int count = 0;
    if (widget.filters.status != null) count++;
    count += widget.filters.imprints.length;
    count += widget.filters.tags.length;
    count += widget.filters.collections.length;
    return count;
  }

  String _statusLabel(BuildContext context, String status) {
    switch (status) {
      case 'reading': return context.l10n.shelfStatusLabelReading;
      case 'read': return context.l10n.shelfStatusLabelRead;
      case 'wantToRead': return context.l10n.shelfStatusLabelWantToRead;
      case 'abandoned': return context.l10n.shelfStatusLabelAbandoned;
      case 'paused': return context.l10n.shelfStatusLabelPaused;
      default: return status;
    }
  }

  Color _statusColor(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.wantToRead: return Colors.orange;
      case ReadingStatus.reading: return Colors.blue;
      case ReadingStatus.read: return Colors.green;
      case ReadingStatus.abandoned: return Colors.red;
      case ReadingStatus.paused: return const Color(0xFFB39DDB);
    }
  }
}

/// Compact chip for active search filters with thematic coloring and large delete target.
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;
  final Color? color;

  const _FilterChip({required this.label, required this.onDelete, this.color});

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Colors.white70;
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: baseColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: baseColor.withValues(alpha: 0.9))),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
              child: Icon(Icons.close, size: 16, color: baseColor.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFiltersTab extends StatelessWidget {
  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;

  const _StatusFiltersTab({required this.filters, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      (ReadingStatus.reading, context.l10n.statusReading, Colors.blue),
      (ReadingStatus.wantToRead, context.l10n.statusWantToRead, Colors.orange),
      (ReadingStatus.read, context.l10n.statusRead, Colors.green),
      (ReadingStatus.paused, context.l10n.statusPaused, const Color(0xFFB39DDB)),
      (ReadingStatus.abandoned, context.l10n.statusAbandoned, Colors.red),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: options.map((opt) {
          final isSelected = filters.status == opt.$1;
          return FilterGridBox(
            label: opt.$2,
            isSelected: isSelected,
            color: opt.$3,
            onTap: () => onChanged(filters.copyWith(status: opt.$1, clearStatus: isSelected)),
          );
        }).toList(),
      ),
    );
  }
}

class _ImprintFiltersTab extends ConsumerWidget {
  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;

  const _ImprintFiltersTab({required this.filters, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imprintsAsync = ref.watch(allImprintsProvider);
    return imprintsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (list) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: list.map((imp) {
            final isSelected = filters.imprints.any((i) => i.id == imp.id);
            return FilterGridBox(
              label: imp.name,
              isSelected: isSelected,
              imagePath: imp.imagePath,
              isImprint: true,
              onTap: () {
                final newImprints = List<Tag>.from(filters.imprints);
                if (isSelected) {
                  newImprints.removeWhere((i) => i.id == imp.id);
                } else {
                  newImprints.add(imp);
                }
                onChanged(filters.copyWith(imprints: newImprints));
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CollectionFiltersTab extends ConsumerWidget {
  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;

  const _CollectionFiltersTab({required this.filters, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(allCollectionsProvider);
    return collectionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (list) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: list.map((col) {
            final isSelected = filters.collections.any((c) => c.id == col.id);
            return FilterGridBox(
              label: col.name,
              isSelected: isSelected,
              onTap: () {
                final newCollections = List<Tag>.from(filters.collections);
                if (isSelected) {
                  newCollections.removeWhere((c) => c.id == col.id);
                } else {
                  newCollections.add(col);
                }
                onChanged(filters.copyWith(collections: newCollections));
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TagFiltersTab extends ConsumerWidget {
  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;

  const _TagFiltersTab({required this.filters, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(allTagsProvider);
    return tagsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (list) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: list.map((tag) {
            final isSelected = filters.tags.any((t) => t.id == tag.id);
            final color = tag.color != null ? Color(int.parse('0xFF${tag.color!}')) : null;
            return FilterGridBox(
              label: tag.name,
              isSelected: isSelected,
              color: color,
              onTap: () {
                final newTags = List<Tag>.from(filters.tags);
                if (isSelected) {
                  newTags.removeWhere((t) => t.id == tag.id);
                } else {
                  newTags.add(tag);
                }
                onChanged(filters.copyWith(tags: newTags));
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}


