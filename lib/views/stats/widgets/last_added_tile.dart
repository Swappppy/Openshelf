import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/books_controller.dart';
import '../../../models/stats_widget.dart';
import '../../../services/database.dart';
import '../../book_detail/book_detail_view.dart';
import 'widget_header.dart';
import '../../../l10n/l10n_extension.dart';

class LastAddedTile extends ConsumerStatefulWidget {
  final StatWidgetSize size;
  const LastAddedTile({super.key, required this.size});

  @override
  ConsumerState<LastAddedTile> createState() => _LastAddedTileState();
}

class _LastAddedTileState extends ConsumerState<LastAddedTile> {
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
        final sorted = List<Book>.from(books)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final lastBooks = sorted.take(10).toList();

        if (lastBooks.isEmpty) {
          return Center(child: Text(context.l10n.statsAddedNoData, style: const TextStyle(fontSize: 12, color: Colors.grey)));
        }

        if (widget.size == StatWidgetSize.s1x1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: WidgetHeader(title: context.l10n.statsLastAddedTitle, icon: Icons.history),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: lastBooks.length,
                  itemBuilder: (context, index) {
                    final book = lastBooks[index];
                    return _buildCompactBook(context, book);
                  },
                ),
              ),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetHeader(title: context.l10n.statsLastAddedTitle, icon: Icons.history),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  scrollDirection: widget.size == StatWidgetSize.s1x2 ? Axis.vertical : Axis.horizontal,
                  itemCount: lastBooks.length,
                  separatorBuilder: (_, _) => widget.size == StatWidgetSize.s1x2 ? const SizedBox(height: 12) : const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final book = lastBooks[index];
                    return widget.size == StatWidgetSize.s1x2 ? _buildVerticalBook(context, book) : _buildWideBook(context, book);
                  },
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildVerticalBook(BuildContext context, Book book) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailView(book: book))),
      child: Row(
        children: [
          if (book.coverPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(File(book.coverPath!), width: 40, height: 60, fit: BoxFit.cover),
            )
          else
            Container(
              width: 40, height: 60, 
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.book, size: 20, color: Colors.white24),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title, 
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  book.author, 
                  style: const TextStyle(fontSize: 10, color: Colors.grey), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBook(BuildContext context, Book book) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailView(book: book))),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: book.coverPath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(File(book.coverPath!), fit: BoxFit.contain),
                )
              : Icon(Icons.book, size: 48, color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }

  Widget _buildWideBook(BuildContext context, Book book) {
    final double coverHeight = widget.size == StatWidgetSize.s1x2 ? 100 : 70;
    final double coverWidth = coverHeight * 0.7;

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailView(book: book))),
      child: Column(
        children: [
          if (book.coverPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(File(book.coverPath!), width: coverWidth, height: coverHeight, fit: BoxFit.cover),
            )
          else
            Container(
              width: coverWidth, height: coverHeight, 
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.book, size: 24, color: Colors.white24),
            ),
          const SizedBox(height: 4),
          SizedBox(
            width: coverWidth,
            child: Text(
              book.title, 
              style: const TextStyle(fontSize: 9), 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis, 
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
