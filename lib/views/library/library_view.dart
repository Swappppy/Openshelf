import 'dart:io';

import 'package:flutter/material.dart';
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
import '../../widgets/tag_chip.dart';
import '../settings/settings_view.dart';
import '../../l10n/l10n_extension.dart';

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

// --- Pantallas placeholder ---

class _LibraryScreen extends ConsumerStatefulWidget {
  const _LibraryScreen();

  @override
  ConsumerState<_LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<_LibraryScreen> {
  bool _searchVisible = false;

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(displayPreferencesProvider);
    final controller = ref.read(displayPreferencesProvider.notifier);
    final filters = ref.watch(searchFiltersProvider);
    final booksAsync = ref.watch(filteredBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.libraryTitle),
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: Icon(
              _searchVisible ? Icons.search_off : Icons.search,
              color: _searchVisible
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: () {
              setState(() => _searchVisible = !_searchVisible);
              if (!_searchVisible) {
                ref.read(searchFiltersProvider.notifier).state =
                const SearchFilters();
              }
            },
          ),
          IconButton(
            icon: Icon(
              prefs.viewMode == LibraryViewMode.list
                  ? Icons.grid_view
                  : Icons.view_list,
            ),
            onPressed: controller.toggleViewMode,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsAndDisplay(context, ref),
          ),
        ],
      ),

      body: Column(
        children: [
          if (_searchVisible)
            _SearchPanel(
              filters: filters,
              onChanged: (f) =>
              ref.read(searchFiltersProvider.notifier).state = f,
            ),
          Expanded(
            child: booksAsync.when(
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(context.l10n.errorPrefix(e.toString()))),
              data: (bookList) {
                if (bookList.isEmpty) {
                  return Center(
                    child:  SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            filters.isEmpty
                                ? Icons.menu_book
                                : Icons.search_off,
                            size: 80,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            filters.isEmpty
                                ? context.l10n.libraryEmpty
                                : context.l10n.libraryNoResults,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            filters.isEmpty
                                ? context.l10n.libraryEmptyHint
                                : context.l10n.libraryNoResultsHint,
                            style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline,
                            ),
                          ),
                        ],
                      )
                    ),
                  );
                }

                return prefs.viewMode == LibraryViewMode.list
                    ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: bookList.length,
                  itemBuilder: (context, index) => BookListTile(
                    book: bookList[index],
                    prefs: prefs,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookDetailView(book: bookList[index]),
                      ),
                    ),
                  ),
                )
                    : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
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
                        builder: (_) =>
                            BookDetailView(book: bookList[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => const AddBookModal(),
        ),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.addBook),
      ),
    );
  }

  void _showSettingsAndDisplay(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final p = ref.watch(displayPreferencesProvider);
          final controller = ref.read(displayPreferencesProvider.notifier);

          final fieldLabels = {
            'author': l10n.fieldAuthor,
            'publisher': l10n.fieldPublisher,
            'year': l10n.fieldYear,
            'rating': l10n.fieldRating,
            'tags': l10n.fieldTags,
          };

          final fieldToggles = {
            'author': (bool v) => controller.toggleShowAuthor(),
            'publisher': (bool v) => controller.toggleShowPublisher(),
            'year': (bool v) => controller.toggleShowYear(),
            'rating': (bool v) => controller.toggleShowRating(),
            'tags': (bool v) => controller.toggleShowTags(),
          };

          final fieldValues = {
            'author': p.showAuthor,
            'publisher': p.showPublisher,
            'year': p.showYear,
            'rating': p.showRating,
            'tags': p.showTags,
          };

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            builder: (_, scrollController) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color:
                        Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Cabecera con botón de ajustes
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
                  Expanded(
                    child: ListView(
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchPanel extends ConsumerStatefulWidget {
  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;

  const _SearchPanel({required this.filters, required this.onChanged});

  @override
  ConsumerState<_SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends ConsumerState<_SearchPanel> {
  late final TextEditingController _queryCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _publisherCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _collectionCtrl;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController(text: widget.filters.query);
    _authorCtrl = TextEditingController(text: widget.filters.author);
    _publisherCtrl = TextEditingController(text: widget.filters.publisher);
    _isbnCtrl = TextEditingController(text: widget.filters.isbn);
    _collectionCtrl = TextEditingController(text: widget.filters.collection);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _authorCtrl.dispose();
    _publisherCtrl.dispose();
    _isbnCtrl.dispose();
    _collectionCtrl.dispose();
    super.dispose();
  }

  void _update() {
    widget.onChanged(widget.filters.copyWith(
      query: _queryCtrl.text,
      author: _authorCtrl.text,
      publisher: _publisherCtrl.text,
      isbn: _isbnCtrl.text,
      collection: _collectionCtrl.text,
    ));
  }

  void _showTagPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _TagPickerSheet(
        onChanged: widget.onChanged,
      ),
    );
  }

  void _showImprintPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(context.l10n.managementImprints,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ref.watch(allImprintsProvider).maybeWhen(
                  data: (allImprints) => StatefulBuilder(
                    builder: (context, setStateSheet) => SingleChildScrollView(
                      controller: scrollController,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: allImprints.map((imp) {
                          final isActive =
                              widget.filters.imprint?.id == imp.id;
                          final colorScheme =
                              Theme.of(context).colorScheme;
                          return GestureDetector(
                            onTap: () {
                              widget.onChanged(isActive
                                  ? widget.filters
                                  .copyWith(clearImprint: true)
                                  : widget.filters
                                  .copyWith(imprint: imp));
                              setStateSheet(() {});
                            },
                            child: SizedBox(
                              width: 80,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(8),
                                      border: isActive
                                          ? Border.all(
                                          color: colorScheme.primary,
                                          width: 2)
                                          : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(7),
                                      child: imp.imagePath != null
                                          ? Image.file(
                                        File(imp.imagePath!),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                          : Container(
                                        width: 80,
                                        height: 80,
                                        color: colorScheme
                                            .surfaceContainerHighest,
                                        child: Icon(
                                          Icons.business_outlined,
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    imp.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(context.l10n.done),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeTags = widget.filters.tags;

    return Container(
      color: colorScheme.surfaceContainerLow,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 4, right: 4, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  child:
                  // Botón expandir filtros avanzados
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () => setState(() => _expanded = !_expanded),
                  ),
                ),
                Expanded(
                  child:
                    // Campo principal
                    TextField(
                      controller: _queryCtrl,
                      autofocus: true,
                      onChanged: (_) => _update(),
                      decoration: InputDecoration(
                        hintText: context.l10n.searchHint,
                        suffixIcon: _queryCtrl.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close, size: 35),
                          onPressed: () {
                            _queryCtrl.clear();
                            _update();
                          },
                        )
                            : null,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                      ),
                    ),
                ),
              ],
            ),
            // Tags y sellos activos
            if (activeTags.isNotEmpty || widget.filters.imprint != null) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  ...activeTags.map((tag) => TagChip(
                    label: tag.name,
                    colorHex: tag.color,
                    onDeleted: () {
                      final newTags = List<Tag>.from(activeTags)
                        ..removeWhere((t) => t.id == tag.id);
                      widget.onChanged(widget.filters.copyWith(tags: newTags));
                    },
                  )),
                  if (widget.filters.imprint != null)
                    TagChip(
                      label: widget.filters.imprint!.name,
                      colorHex: null,
                      onDeleted: () => widget.onChanged(
                        widget.filters.copyWith(clearImprint: true),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            if (_expanded) ...[
              // Categorías
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: _FilterField(
                      controller: _authorCtrl,
                      label: context.l10n.filterAuthor,
                      icon: Icons.person_outline,
                      onChanged: (_) => _update(),
                    )
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _FilterField(
                      controller: _isbnCtrl,
                      label: context.l10n.filterIsbn,
                      icon: Icons.barcode_reader,
                      onChanged: (_) => _update(),
                    ),
                  )
                ]
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                      child: _FilterField(
                        controller: _publisherCtrl,
                        label: context.l10n.filterPublisher,
                        icon: Icons.business_outlined,
                        onChanged: (_) => _update(),
                      )
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _FilterField(
                      controller: _collectionCtrl,
                      label: context.l10n.filterCollection,
                      icon: Icons.collections_bookmark_outlined,
                      onChanged: (_) => _update(),
                    ),
                  )
                ]
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.filterImprintLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 4),
              ref.watch(allImprintsProvider).maybeWhen(
                data: (allImprints) => allImprints.isEmpty
                    ? const SizedBox.shrink()
                    : _SingleRowWithOverflow(
                  items: allImprints,
                  isActive: (imp) => widget.filters.imprint?.id == imp.id,
                  labelFor: (imp) => imp.name,
                  colorFor: (_) => null,
                  imageFor: (imp) => imp.imagePath,
                  onTap: (imp) {
                    final isActive = widget.filters.imprint?.id == imp.id;
                    widget.onChanged(isActive
                        ? widget.filters.copyWith(clearImprint: true)
                        : widget.filters.copyWith(imprint: imp));
                  },
                  onTapMore: () => _showImprintPicker(context),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),

              // Selector de tags
              Text(
                context.l10n.filterTagsLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 4),
              ref.watch(allTagsProvider).maybeWhen(
                data: (allTags) => allTags.isEmpty
                    ? const SizedBox.shrink()
                    : _SingleRowWithOverflow(
                  items: allTags,
                  isActive: (tag) => activeTags.any((t) => t.id == tag.id),
                  labelFor: (tag) => tag.name,
                  colorFor: (tag) => tag.color,
                  imageFor: (_) => null,
                  onTap: (tag) {
                    final newTags = List<Tag>.from(activeTags);
                    if (activeTags.any((t) => t.id == tag.id)) {
                      newTags.removeWhere((t) => t.id == tag.id);
                    } else {
                      newTags.add(tag);
                    }
                    widget.onChanged(widget.filters.copyWith(tags: newTags));
                  },
                  onTapMore: () => _showTagPicker(context),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const _FilterField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, size: 18),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
      ),
    );
  }
}

class _StatsScreen extends StatelessWidget {
  const _StatsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.statsTitle)),
      body: Center(child: Text(context.l10n.statsPlaceholder)),
    );
  }
}

class _TagPickerSheet extends ConsumerWidget {
  final ValueChanged<SearchFilters> onChanged;

  const _TagPickerSheet({required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);
    final activeTags = filters.tags;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
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
            Text(
              context.l10n.filterTagsLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ref.watch(allTagsProvider).maybeWhen(
                data: (allTags) => SingleChildScrollView(
                  controller: scrollController,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allTags.map((tag) {
                      final isActive = activeTags.any((t) => t.id == tag.id);
                      final baseColor = tag.color != null
                          ? Color(int.parse('0xFF${tag.color!}'))
                          : Theme.of(context).colorScheme.secondaryContainer;
                      return GestureDetector(
                        onTap: () {
                          final current = ref.read(searchFiltersProvider);
                          final newTags = List<Tag>.from(current.tags);
                          if (isActive) {
                            newTags.removeWhere((t) => t.id == tag.id);
                          } else {
                            newTags.add(tag);
                          }
                          final updated = current.copyWith(tags: newTags);
                          ref.read(searchFiltersProvider.notifier).state =
                              updated;
                          onChanged(updated);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? baseColor.withValues(alpha: 0.25)
                                : baseColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color:
                              isActive ? baseColor : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            tag.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: tag.color != null
                                  ? baseColor
                                  : Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.done),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SingleRowWithOverflow<T> extends StatelessWidget {
  final List<T> items;
  final bool Function(T) isActive;
  final String Function(T) labelFor;
  final String? Function(T) colorFor;
  final String? Function(T) imageFor;
  final void Function(T) onTap;
  final VoidCallback onTapMore;

  const _SingleRowWithOverflow({
    required this.items,
    required this.isActive,
    required this.labelFor,
    required this.colorFor,
    required this.imageFor,
    required this.onTap,
    required this.onTapMore,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      const chipSpacing = 6.0;
      const chipPaddingH = 20.0;
      const moreWidth = 36.0;
      final textStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);

      final visible = <T>[];
      double used = 0;

      for (final item in items) {
        final painter = TextPainter(
          text: TextSpan(text: labelFor(item), style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();

        final imgWidth = imageFor(item) != null ? 22.0 : 0.0;
        final chipW = painter.width + chipPaddingH + imgWidth;
        final remaining = items.length - visible.length - 1;
        final reserveMore = remaining > 0 ? moreWidth + chipSpacing : 0.0;

        if (used + chipW + chipSpacing + reserveMore <= maxWidth) {
          visible.add(item);
          used += chipW + chipSpacing;
        } else {
          break;
        }
      }

      final hiddenCount = items.length - visible.length;

      return Row(
        children: [
          ...visible.map((item) {
            final active = isActive(item);
            final hexColor = colorFor(item);
            final imgPath = imageFor(item);
            final baseColor = hexColor != null
                ? Color(int.parse('0xFF$hexColor'))
                : colorScheme.secondaryContainer;

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => onTap(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? baseColor.withValues(alpha: 0.25)
                        : baseColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: active ? baseColor : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (imgPath != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Image.file(File(imgPath),
                              width: 16, height: 16, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        labelFor(item),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: hexColor != null
                              ? baseColor
                              : colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (hiddenCount > 0)
            GestureDetector(
              onTap: onTapMore,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '+$hiddenCount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}