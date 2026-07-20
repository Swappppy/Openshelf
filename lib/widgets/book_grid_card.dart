import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import '../models/display_preferences.dart';
import '../controllers/app_settings_controller.dart';
import '../controllers/read_history_controller.dart';
import 'status_chip.dart';
import 'book_cover.dart';

import '../utils/pagination_helper.dart';

/// A compact card displaying a book in the Library grid view.
/// Features a large cover image with a centered-top focus and a discrete progress indicator.
class BookGridCard extends ConsumerWidget {
  final Book book;
  final DisplayPreferences prefs;
  final VoidCallback? onTap;
  final String? overlayLabel;

  const BookGridCard({
    super.key,
    required this.book,
    required this.prefs,
    this.onTap,
    this.overlayLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(readHistoryProvider(book.id));
    final colorScheme = theme.colorScheme;
    final gridColumns = ref.watch(appSettingsProvider.select((s) => s.libraryGridColumns));
    final statusColor = _getStatusColor(book.status);

    return historyAsync.maybeWhen(
      data: (history) {
        final percent = (book.totalPages != null && book.totalPages! > 0)
            ? PaginationHelper.getTotalReadPages(book, history) / book.totalPages!
            : 0.0;

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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      BookCover(
                        coverUrl: book.coverUrl,
                        coverPath: book.coverPath,
                        author: book.author,
                      ),
                      if (overlayLabel != null)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              overlayLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
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
                  padding: EdgeInsets.all(gridColumns >= 3 ? 8 : 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: (gridColumns >= 3 
                          ? theme.textTheme.labelMedium 
                          : theme.textTheme.labelLarge)?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (prefs.showAuthor)
                        Text(
                          book.author,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                            fontSize: gridColumns >= 3 ? 9 : 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (prefs.showStatusChip && gridColumns < 3) ...[
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
      },
      orElse: () => const SizedBox.shrink(),
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
