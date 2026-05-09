import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shelf.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/display_preferences_controller.dart';
import '../../models/display_preferences.dart';
import '../../widgets/book_list_tile.dart';
import '../../widgets/book_grid_card.dart';
import '../book_detail/book_detail_view.dart';

class ShelfBooksView extends ConsumerWidget {
  final Shelf shelf;
  const ShelfBooksView({super.key, required this.shelf});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(displayPreferencesProvider);
    final controller = ref.read(displayPreferencesProvider.notifier);

    final booksAsync = ref.watch(
      shelfBooksProvider(shelf),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(shelf.name),
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: Icon(
              prefs.viewMode == LibraryViewMode.list
                  ? Icons.grid_view
                  : Icons.view_list,
            ),
            onPressed: controller.toggleViewMode,
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
                  Icon(Icons.search_off,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('Sin libros en esta estantería',
                      style: Theme.of(context).textTheme.titleLarge),
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
    );
  }
}
