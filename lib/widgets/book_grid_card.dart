import 'package:flutter/material.dart';
import '../services/database.dart';
import '../models/display_preferences.dart';
import 'status_chip.dart';
import 'book_cover.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A compact card displaying a book in the Library grid view.
/// Features a large cover image with a centered-top focus and a discrete progress indicator.
class BookGridCard extends ConsumerWidget {
  final Book book;
  final DisplayPreferences prefs;
  final VoidCallback? onTap;

  const BookGridCard({
    super.key,
    required this.book,
    required this.prefs,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percent = (book.totalPages != null && book.totalPages! > 0)
        ? (book.currentPage ?? 0) / book.totalPages!
        : 0.0;
    final statusColor = _getStatusColor(book.status);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Expanded(
              child: BookCover(
                coverUrl: book.coverUrl,
                coverPath: book.coverPath,
                author: book.author,
              ),
            ),

            // Progress bar (visible if there is active progress)
            if (prefs.showProgress && percent > 0)
              LinearProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                minHeight: 2,
                backgroundColor: statusColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),

            // Text Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (book.subtitle != null)
                    Text(
                      book.subtitle!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 2),
                  if (prefs.showAuthor)
                    Text(
                      book.author,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (prefs.showStatusChip) ...[
                    const SizedBox(height: 8),
                    StatusChip(status: book.status, isGrid: true),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.wantToRead:
        return Colors.orange;
      case ReadingStatus.reading:
        return Colors.blue;
      case ReadingStatus.read:
        return Colors.green;
      case ReadingStatus.abandoned:
        return Colors.red;
      case ReadingStatus.paused:
        return const Color(0xFFB39DDB);
    }
  }
}


