import 'package:flutter/material.dart';
import 'package:openshelf/views/shelves/shelves_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/display_preferences_controller.dart';
import '../../models/display_preferences.dart';
import '../../models/book.dart';
import '../../widgets/book_list_tile.dart';
import '../../widgets/book_grid_card.dart';

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
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
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

  // Libros de prueba para ver las cards
  static final _mockBooks = [
    const Book(
      id: 1,
      title: 'La Suma Teológica',
      author: 'Santo Tomás de Aquino',
      publisher: 'BAC',
      status: ReadingStatus.reading,
      currentPage: 120,
      totalPages: 800,
      rating: 5.0,
    ),
    const Book(
      id: 2,
      title: 'La Ilíada',
      author: 'Homero',
      publisher:  'Gredos',
      status: ReadingStatus.wantToRead,
      totalPages: 450,
    ),
    const Book(
      id: 3,
      title: 'Metafísica',
      author: 'Aristóteles',
      publisher: 'Gredos',
      status: ReadingStatus.read,
      totalPages: 320,
      currentPage: 320,
      rating: 4.5,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(displayPreferencesProvider);
    final controller = ref.read(displayPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Biblioteca'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
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
      body: prefs.viewMode == LibraryViewMode.list
          ? ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _mockBooks.length,
        itemBuilder: (context, index) => BookListTile(
          book: _mockBooks[index],
          prefs: prefs,
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
        itemCount: _mockBooks.length,
        itemBuilder: (context, index) => BookGridCard(
          book: _mockBooks[index],
          prefs: prefs,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Añadir libro'),
      ),
    );
  }

  void _showDisplayOptions(BuildContext context, WidgetRef ref) {
    final controller = ref.read(displayPreferencesProvider.notifier);
    final prefs = ref.read(displayPreferencesProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final p = ref.watch(displayPreferencesProvider);
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mostrar en la biblioteca',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Autor'),
                  value: p.showAuthor,
                  onChanged: (_) => controller.toggleShowAuthor(),
                ),
                SwitchListTile(
                  title: const Text('Progreso de lectura'),
                  value: p.showProgress,
                  onChanged: (_) => controller.toggleShowProgress(),
                ),
                SwitchListTile(
                  title: const Text('Valoración'),
                  value: p.showRating,
                  onChanged: (_) => controller.toggleShowRating(),
                ),
                SwitchListTile(
                  title: const Text('Editorial'),
                  value: p.showPublisher,
                  onChanged: (_) => controller.toggleShowPublisher(),
                ),
                SwitchListTile(
                  title: const Text('Chip de estado'),
                  value: p.showStatusChip,
                  onChanged: (_) => controller.toggleShowStatusChip(),
                ),
                const SizedBox(height: 8),
              ],
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