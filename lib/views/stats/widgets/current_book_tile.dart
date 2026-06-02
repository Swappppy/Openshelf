import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/books_controller.dart';
import '../../../services/database.dart';
import '../../../models/stats_widget.dart';
import '../../book_detail/book_detail_view.dart';
import '../../../l10n/l10n_extension.dart';
import 'widget_header.dart';
import 'stats_scale_helper.dart';

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
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = StatsScaleHelper.getScale(constraints);
        
        return booksAsync.maybeWhen(
          data: (books) {
            final readingBooks = books.where((b) => b.status == ReadingStatus.reading).toList();
            if (readingBooks.isEmpty) {
              return Center(
                child: Text(
                  context.l10n.statsReadingNone,
                  style: TextStyle(fontSize: 12 * scale, color: Colors.grey),
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
                      ? _buildCompact(context, book, progress, scale)
                      : _buildWide(context, book, progress, scale),
                );
              },
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      }
    );
  }

  Widget _buildCompact(BuildContext context, Book book, double progress, double scale) {
    return Padding(
      padding: EdgeInsets.all(12 * scale.clamp(1.0, 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetHeader(title: context.l10n.statsReadingTitle, icon: Icons.auto_stories),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4 * scale),
                child: book.coverPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4 * scale),
                        child: Image.file(File(book.coverPath!), fit: BoxFit.contain),
                      )
                    : Icon(Icons.book, size: 32 * scale, color: Theme.of(context).colorScheme.outline),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4 * scale),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3 * scale,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          SizedBox(height: 2 * scale),
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(fontSize: 9 * scale, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWide(BuildContext context, Book book, double progress, double scale) {
    return Padding(
      padding: EdgeInsets.all(12 * scale.clamp(1.0, 1.2)),
      child: Row(
        children: [
          if (book.coverPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8 * scale),
              child: Image.file(File(book.coverPath!), width: 45 * scale, height: 68 * scale, fit: BoxFit.cover),
            )
          else
            Container(
              width: 45 * scale, 
              height: 68 * scale, 
              color: Colors.grey[800], 
              child: Icon(Icons.book, color: Colors.white24, size: 24 * scale)
            ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WidgetHeader(title: context.l10n.statsReadingNowTitle, icon: Icons.auto_stories),
                SizedBox(height: 2 * scale),
                Text(
                  book.title, 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9 * scale), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
                Text(
                  '${book.author}${book.publishYear != null ? " · ${book.publishYear}" : ""}', 
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 7.5 * scale),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4 * scale),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 2.5 * scale,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                SizedBox(height: 1 * scale),
                Text(
                  '${book.currentPage} / ${book.totalPages} págs · ${(progress * 100).toInt()}%', 
                  style: TextStyle(fontSize: 6.5 * scale)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
