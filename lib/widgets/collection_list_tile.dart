import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import '../controllers/books_controller.dart';
import '../views/shelves/shelf_books_view.dart';
import 'cover_stack_fade.dart';
import 'standard_progress_row.dart';

class CollectionListTile extends ConsumerWidget {
  final Tag collection;
  final int totalCount;
  final VoidCallback onLongPress;
  
  const CollectionListTile({
    super.key,
    required this.collection, 
    required this.totalCount,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksByCollectionProvider(collection.id));

    return booksAsync.maybeWhen(
      data: (bookList) {
        // Sort books by collection number for chronological preview
        final sortedBooks = List<Book>.from(bookList)
          ..sort((a, b) => (a.collectionNumber ?? 0).compareTo(b.collectionNumber ?? 0));

        final readCount = sortedBooks.where((b) => b.status == ReadingStatus.read).length;
        final progress = totalCount > 0 ? readCount / totalCount : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => TagBooksView(tag: collection)),
            ),
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CoverStackFade(
                    books: sortedBooks,
                    height: 50,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        StandardProgressRow(readCount: readCount, totalCount: totalCount, progress: progress),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
