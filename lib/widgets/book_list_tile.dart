import 'package:flutter/material.dart';
import '../services/database.dart';
import '../models/display_preferences.dart';
import 'status_chip.dart';
import 'book_cover.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/books_controller.dart';
import '../l10n/l10n_extension.dart';

/// A comprehensive list tile for displaying book information in the Library list view.
/// Supports reorderable fields, custom status highlighting, and progress bars.
class BookListTile extends ConsumerWidget {
  final Book book;
  final DisplayPreferences prefs;
  final VoidCallback? onTap;

  const BookListTile({
    super.key,
    required this.book,
    required this.prefs,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 160, // Accommodates the larger cover image
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookCover(
              coverUrl: book.coverUrl,
              coverPath: book.coverPath,
              height: 136, 
              width: 92, 
              author: book.author,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (prefs.showStatusChip) ...[
                        const SizedBox(width: 8),
                        StatusChip(status: book.status),
                      ],
                    ],
                  ),

                  // Reorderable content based on user preferences
                  ...prefs.fieldOrder.map((field) {
                    switch (field) {
                      case 'tags':
                        if (!prefs.showTags) return const SizedBox.shrink();
                        final tagsAsync = ref.watch(bookTagsProvider(book.id));
                        return tagsAsync.maybeWhen(
                          data: (tagList) => tagList.isEmpty
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: _TagsRow(tags: tagList),
                                ),
                          orElse: () => const SizedBox.shrink(),
                        );
                      case 'spacer':
                        if (!prefs.showSpacer) return const SizedBox.shrink();
                        return const Spacer();
                      case 'info':
                        // Meta info row: Author (Left) | Year · Editorial (Right)
                        final rightParts = <String>[];
                        if (prefs.showYear && book.publishYear != null) {
                          rightParts.add(book.publishYear.toString());
                        }
                        if (prefs.showPublisher && book.publisher != null) {
                          rightParts.add(book.publisher!);
                        }

                        if (rightParts.isEmpty && !prefs.showAuthor) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              if (prefs.showAuthor)
                                Expanded(
                                  child: Text(
                                    book.author,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.outline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if (rightParts.isNotEmpty)
                                Text(
                                  rightParts.join(' · '),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        );
                      case 'rating':
                        if (!prefs.showRating || book.rating == null) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < (book.rating ?? 0) ? Icons.star : Icons.star_border,
                                color: Colors.amber[700],
                                size: 14,
                              );
                            }),
                          ),
                        );
                      default:
                        return const SizedBox.shrink();
                    }
                  }),

                  const Spacer(),

                  // Progress bar and percentage text
                  if (prefs.showProgress &&
                      book.totalPages != null &&
                      book.totalPages! > 0)
                    _ProgressBar(
                      current: book.currentPage ?? 0,
                      total: book.totalPages!,
                      status: book.status,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single-line row of tags with an overflow counter (+N)
class _TagsRow extends StatelessWidget {
  final List<Tag> tags;
  const _TagsRow({required this.tags});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final colorScheme = Theme.of(context).colorScheme;
        final textStyle = TextStyle(
          fontSize: 10,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        );

        final visibleTags = <Tag>[];
        double totalWidth = 0;
        const spacing = 6.0;
        const padding = 12.0; 
        const moreWidth = 25.0; // Width reserved for the "+N" indicator

        for (int i = 0; i < tags.length; i++) {
          final tag = tags[i];
          final painter = TextPainter(
            text: TextSpan(text: tag.name, style: textStyle),
            textDirection: TextDirection.ltr,
          )..layout();

          final tagWidth = painter.width + padding;
          final isLast = i == tags.length - 1;
          final neededWidth = totalWidth + tagWidth + (isLast ? 0 : spacing + moreWidth);

          if (neededWidth <= constraints.maxWidth) {
            visibleTags.add(tag);
            totalWidth += tagWidth + spacing;
          } else {
            break;
          }
        }

        final hiddenCount = tags.length - visibleTags.length;

        return Row(
          children: [
            ...visibleTags.map((tag) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _SimpleTagChip(label: tag.name),
                )),
            if (hiddenCount > 0)
              Text(
                '+$hiddenCount',
                style: textStyle.copyWith(fontWeight: FontWeight.bold),
              ),
          ],
        );
      },
    );
  }
}

class _SimpleTagChip extends StatelessWidget {
  final String label;
  const _SimpleTagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final ReadingStatus status;

  const _ProgressBar({
    required this.current,
    required this.total,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (current / total).clamp(0.0, 1.0);
    final color = _getStatusColor(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: percent,
          borderRadius: BorderRadius.circular(4),
          minHeight: 2,
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.pageProgress(
            current,
            total,
            (percent * 100).toStringAsFixed(0),
          ),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
                fontSize: 10,
              ),
        ),
      ],
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


