import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openshelf/views/shelves/shelves_view.dart';
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Biblioteca',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmarks_outlined),
            selectedIcon: Icon(Icons.bookmarks),
            label: 'Estanterías',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
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
        title: const Text('Mi Biblioteca'),
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
            icon: const Icon(Icons.tune),
            onPressed: () => _showDisplayOptions(context, ref),
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
              error: (e, _) => Center(child: Text('Error: $e')),
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
                                ? 'Tu biblioteca está vacía'
                                : 'Sin resultados',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            filters.isEmpty
                                ? 'Pulsa + para añadir tu primer libro'
                                : 'Prueba con otros filtros',
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
        label: const Text('Añadir libro'),
      ),
    );
  }

  void _showDisplayOptions(BuildContext context, WidgetRef ref) {
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
            'author': 'Autor',
            'publisher': 'Editorial',
            'rating': 'Valoración',
            'tags': 'Etiquetas',
          };

          final fieldToggles = {
            'author': (bool v) => controller.toggleShowAuthor(),
            'publisher': (bool v) => controller.toggleShowPublisher(),
            'rating': (bool v) => controller.toggleShowRating(),
            'tags': (bool v) => controller.toggleShowTags(),
          };

          final fieldValues = {
            'author': p.showAuthor,
            'publisher': p.showPublisher,
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
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Mostrar en la biblioteca',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Arrastra para reordenar',
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
                          title: const Text('Progreso de lectura'),
                          trailing: Switch(
                            value: p.showProgress,
                            onChanged: (_) => controller.toggleShowProgress(),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.drag_handle,
                              color: Colors.transparent),
                          title: const Text('Chip de estado'),
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
                        hintText: 'Buscar por título…',
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
            // Tags activos
            if (activeTags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: activeTags
                    .map((tag) => TagChip(
                  label: tag.name,
                  colorHex: tag.color,
                  onDeleted: () {
                    final newTags = List<Tag>.from(activeTags)
                      ..remove(tag);
                    widget.onChanged(
                        widget.filters.copyWith(tags: newTags));
                  },
                ))
                    .toList(),
              ),
              const SizedBox(height: 8),
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
                      label: 'Autor',
                      icon: Icons.person_outline,
                      onChanged: (_) => _update(),
                    )
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: _FilterField(
                      controller: _isbnCtrl,
                      label: 'ISBN',
                      icon: Icons.barcode_reader,
                      onChanged: (_) => _update(),
                    ),
                  )
                ]
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                      child: _FilterField(
                        controller: _publisherCtrl,
                        label: 'Editorial',
                        icon: Icons.business_outlined,
                        onChanged: (_) => _update(),
                      )
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: _FilterField(
                      controller: _collectionCtrl,
                      label: 'Colección',
                      icon: Icons.collections_bookmark_outlined,
                      onChanged: (_) => _update(),
                    ),
                  )
                ]
              ),
              const SizedBox(height: 8),
              Text(
                'Sello editorial',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 4),
              ref.watch(allImprintsProvider).maybeWhen(
                data: (allImprints) => allImprints.isEmpty
                    ? const SizedBox.shrink()
                    : Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: allImprints.map((imp) {
                    final isActive = widget.filters.imprint?.id == imp.id;
                    return GestureDetector(
                      onTap: () {
                        widget.onChanged(isActive
                            ? widget.filters.copyWith(clearImprint: true)
                            : widget.filters.copyWith(imprint: imp));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isActive
                                ? colorScheme.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (imp.imagePath != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: Image.file(
                                  File(imp.imagePath!),
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Icon(Icons.business_outlined,
                                  size: 14, color: colorScheme.outline),
                            const SizedBox(width: 6),
                            Text(
                              imp.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isActive
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                orElse: () => const SizedBox.shrink(),
              ),

              // Selector de tags
              Text(
                'Categorías',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 4),
              ref.watch(allTagsProvider).maybeWhen(
                data: (allTags) => allTags.isEmpty
                    ? const SizedBox.shrink()
                    : Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: allTags.map((tag) {
                    final isActive =
                    activeTags.any((t) => t.id == tag.id);
                    final baseColor = tag.color != null
                        ? Color(int.parse('0xFF${tag.color!}'))
                        : colorScheme.secondaryContainer;
                    return GestureDetector(
                      onTap: () {
                        final newTags = List<Tag>.from(activeTags);
                        if (isActive) {
                          newTags.removeWhere((t) => t.id == tag.id);
                        } else {
                          newTags.add(tag);
                        }
                        widget.onChanged(
                            widget.filters.copyWith(tags: newTags));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? baseColor.withValues(alpha: 0.25)
                              : baseColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isActive
                                ? baseColor
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          tag.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: tag.color != null
                                ? baseColor
                                : colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
      appBar: AppBar(title: const Text('Estadísticas')),
      body: const Center(child: Text('Tus estadísticas aparecerán aquí')),
    );
  }
}
