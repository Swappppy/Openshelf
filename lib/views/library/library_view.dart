import 'package:flutter/material.dart';
import 'package:openshelf/views/shelves/shelves_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/display_preferences_controller.dart';
import '../../models/display_preferences.dart';
import '../../widgets/book_list_tile.dart';
import '../../widgets/book_grid_card.dart';
import '../../controllers/books_controller.dart';
import '../book_form/add_book_modal.dart';
import '../book_detail/book_detail_view.dart';

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

class _LibraryScreen extends ConsumerWidget {
  const _LibraryScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(displayPreferencesProvider);
    final controller = ref.read(displayPreferencesProvider.notifier);
    final booksAsync = ref.watch(allBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Biblioteca'),
        toolbarHeight: 40,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
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
      body: booksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (bookList) {
          if (bookList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 80,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tu biblioteca está vacía',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pulsa + para añadir tu primer libro',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
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
                        builder: (_) => BookDetailView(book: bookList[index]),
                      ),
                    ),
                  ),
                )
              : GridView.builder(
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
                  // Handle
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

                  // Campos reordenables
                  Expanded(
                    child: ReorderableListView(
                      onReorder: controller.reorderFields,
                      shrinkWrap: true,
                      children: [
                        ...p.fieldOrder.map(
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
                        ),

                        // Campos fijos — no arrastrables
                        ListTile(
                          key: const ValueKey('progress_fixed'),
                          leading: const Icon(
                            Icons.drag_handle,
                            color: Colors.transparent,
                          ),
                          title: const Text('Progreso de lectura'),
                          trailing: Switch(
                            value: p.showProgress,
                            onChanged: (_) => controller.toggleShowProgress(),
                          ),
                        ),
                        ListTile(
                          key: const ValueKey('status_fixed'),
                          leading: const Icon(
                            Icons.drag_handle,
                            color: Colors.transparent,
                          ),
                          title: const Text('Chip de estado'),
                          trailing: Switch(
                            value: p.showStatusChip,
                            onChanged: (_) => controller.toggleShowStatusChip(),
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
