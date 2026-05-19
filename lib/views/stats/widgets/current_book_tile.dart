import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/books_controller.dart';
import '../../../services/database.dart';
import '../../../models/stats_widget.dart';
import '../../book_detail/book_detail_view.dart';
import '../../../l10n/l10n_extension.dart';
import 'widget_header.dart';

class CurrentBookTile extends ConsumerStatefulWidget {
  final StatWidgetSize size;
  const CurrentBookTile({super.key, required this.size});

  @override
  ConsumerState<CurrentBookTile> createState() => _CurrentBookTileState();
}

class _CurrentBookTileState extends ConsumerState<CurrentBookTile> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(allBooksProvider);
    return booksAsync.maybeWhen(
      data: (books) {
        final readingBooks = books.where((b) => b.status == ReadingStatus.reading).toList();
        if (readingBooks.isEmpty) {
          return Center(
            child: Text(
              context.l10n.statsReadingNone,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          );
        }

        return PageView.builder(
          controller: _pageController,
          itemCount: readingBooks.length,
          itemBuilder: (context, index) {
            final book = readingBooks[index];
            final progress = (book.currentPage ?? 0) / (book.totalPages ?? 1);

            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookDetailView(book: book)),
              ),
              child: widget.size == StatWidgetSize.s1x1
                  ? _buildCompact(context, book, progress)
                  : _buildWide(context, book, progress),
            );
          },
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildCompact(BuildContext context, Book book, double progress) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetHeader(title: context.l10n.statsReadingTitle, icon: Icons.auto_stories),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: book.coverPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(File(book.coverPath!), fit: BoxFit.contain),
                      )
                    : Icon(Icons.book, size: 32, color: Theme.of(context).colorScheme.outline),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWide(BuildContext context, Book book, double progress) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (book.coverPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(book.coverPath!), width: 50, height: 75, fit: BoxFit.cover),
            )
          else
            Container(width: 50, height: 75, color: Colors.grey[800], child: const Icon(Icons.book, color: Colors.white24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WidgetHeader(title: context.l10n.statsReadingNowTitle, icon: Icons.auto_stories),
                const SizedBox(height: 4),
                Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${book.author} · ${book.publishYear ?? ""}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${book.currentPage} / ${book.totalPages} págs · ${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
