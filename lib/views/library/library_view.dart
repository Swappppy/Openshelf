import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../shelves/shelves_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/display_preferences_controller.dart';
import '../../models/display_preferences.dart';
import '../../services/database.dart';
import '../../widgets/book_list_tile.dart';
import '../../widgets/book_grid_card.dart';
import '../../controllers/books_controller.dart';
import '../book_form/add_book_modal.dart';
import '../book_detail/book_detail_view.dart';
import '../settings/settings_view.dart';
import '../../l10n/l10n_extension.dart';

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
    _StatsScreen(),
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
  bool _isFabVisible = true;

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
    if (!_scrollController.hasClients) return;
    
    // Disable auto-hide if content doesn't exceed screen height.
    final isScrollable = _scrollController.position.maxScrollExtent > 0;
    if (!isScrollable) {
      if (!_isFabVisible) setState(() => _isFabVisible = true);
      return;
    }

    final isAtEnd = _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50;
    final isScrollingDown = _scrollController.position.userScrollDirection == ScrollDirection.reverse;

    if (isAtEnd || isScrollingDown) {
      if (_isFabVisible) setState(() => _isFabVisible = false);
    } else {
      if (!_isFabVisible) setState(() => _isFabVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(displayPreferencesProvider.select((p) => p.viewMode));
    final filters = ref.watch(searchFiltersProvider);
    final booksAsync = ref.watch(filteredBooksProvider);
    final colorScheme = Theme.of(context).colorScheme;

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
          // Quick status filter row with horizontal scrolling.
          Row(
            children: [
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _SortMenu.show(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.sort, size: 22, color: colorScheme.outline),
                ),
              ),
              Expanded(
                child: _StatusFilterRow(
                  selectedStatus: filters.status,
                  onChanged: (status) {
                    ref.read(searchFiltersProvider.notifier).state =
                        filters.copyWith(status: status, clearStatus: status == null);
                  },
                ),
              ),
            ],
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
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isFabVisible ? 1.0 : 0.0,
          child: FloatingActionButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => const AddBookModal(),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ),
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

class _SortMenu extends ConsumerWidget {
  const _SortMenu();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _SortMenu(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = ref.watch(displayPreferencesProvider);
    final controller = ref.read(displayPreferencesProvider.notifier);

    final sortLabels = {
      'title': l10n.fieldTitle,
      'author': l10n.fieldAuthor,
      'publisher': l10n.fieldPublisher,
      'collection': l10n.fieldCollection,
      'imprint': l10n.managementImprints,
      'publishYear': l10n.fieldYear,
      'createdAt': l10n.bookDetailFieldAdded,
      'rating': l10n.fieldRating,
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
                  l10n.displaySettingsDragHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              _SortToggleButton(
                label: p.emptyAtEnd ? 'V-↓' : 'V-↑',
                onPressed: controller.toggleEmptyAtEnd,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ReorderableListView(
            onReorder: controller.reorderSort,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: p.sortOrder
                .map(
                  (criteria) {
                final isAsc = p.sortDirections[criteria] ?? true;
                final isAlphabetical = ['title', 'author', 'publisher', 'collection', 'imprint'].contains(criteria);

                return ListTile(
                  key: ValueKey(criteria),
                  leading: ReorderableDragStartListener(
                    index: p.sortOrder.indexOf(criteria),
                    child: const Icon(Icons.drag_handle),
                  ),
                  title: Text(sortLabels[criteria] ?? criteria),
                  trailing: TextButton.icon(
                    onPressed: () => controller.toggleFieldSortDirection(criteria),
                    label: Text(
                      isAsc
                          ? (isAlphabetical ? 'A-Z' : '0-9')
                          : (isAlphabetical ? 'Z-A' : '9-0'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    icon: Icon(
                      isAsc ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            )
                .toList(),
          ),
        ],
      ),
    );
  }
}

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

class _SortToggleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SortToggleButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

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

class _StatusFilterRow extends StatelessWidget {
  final ReadingStatus? selectedStatus;
  final ValueChanged<ReadingStatus?> onChanged;

  const _StatusFilterRow({
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      (null, context.l10n.shelfAllBooks, Theme.of(context).colorScheme.outline),
      (ReadingStatus.reading, context.l10n.statusReading, Colors.blue),
      (ReadingStatus.wantToRead, context.l10n.statusWantToRead, Colors.orange),
      (ReadingStatus.read, context.l10n.statusRead, Colors.green),
      (ReadingStatus.paused, context.l10n.statusPaused, const Color(0xFFB39DDB)),
      (ReadingStatus.abandoned, context.l10n.statusAbandoned, Colors.red),
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final opt = options[index];
          final isSelected = selectedStatus == opt.$1;
          final statusColor = opt.$3;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(
                opt.$2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? statusColor : null,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onChanged(opt.$1),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.transparent,
              selectedColor: statusColor.withValues(alpha: 0.15),
              side: BorderSide(
                color: isSelected 
                    ? statusColor.withValues(alpha: 0.4) 
                    : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }
}

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
    _tabController = TabController(length: 3, vsync: this);
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
          return _FilterGridBox(
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
            return _FilterGridBox(
              label: imp.name,
              isSelected: isSelected,
              imagePath: imp.imagePath,
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
            return _FilterGridBox(
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

/// A flexible grid box that highlights when selected. Used for filter options.
class _FilterGridBox extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final String? imagePath;
  final VoidCallback onTap;

  const _FilterGridBox({
    required this.label,
    required this.isSelected,
    this.color,
    this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Colors.white70;
    return IntrinsicWidth(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? baseColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? baseColor.withValues(alpha: 0.5) : Colors.white10,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display either the imprint image or initials as placeholder.
              if (imagePath != null || (color == null && imagePath == null)) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: imagePath != null 
                    ? Image.file(
                        File(imagePath!),
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _initialsPlaceholder(context, label),
                      )
                    : _initialsPlaceholder(context, label),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? baseColor.withValues(alpha: 0.9) : Colors.white60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initialsPlaceholder(BuildContext context, String name) {
    final initials = name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
        
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        initials,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white38),
      ),
    );
  }
}

/// Placeholder screen for library statistics.
class _StatsScreen extends StatelessWidget {
  const _StatsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.navStats,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
            color: Colors.white,
          ),
        ),
        toolbarHeight: 64,
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0,
      ),
      body: Center(child: Text(context.l10n.statsPlaceholder)),
    );
  }
}
