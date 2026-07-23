import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../controllers/books_controller.dart';
import '../../../widgets/tag_chip.dart';
import '../../shelves/shelf_books_view.dart';

class BookHeader extends StatelessWidget {
  final Book book;
  const BookHeader({super.key, required this.book});

  Color _getStatusColor(ReadingStatus status) {
    return switch (status) {
      ReadingStatus.wantToRead => Colors.orange,
      ReadingStatus.reading => Colors.blue,
      ReadingStatus.read => Colors.green,
      ReadingStatus.abandoned => Colors.red,
      ReadingStatus.paused => Colors.deepPurpleAccent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image with status indicator as a shadow behind
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Status color "shadow" peeking from behind
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: -1, // Peek 1px to the right
                child: Container(
                  decoration: BoxDecoration(
                    color: _getStatusColor(book.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Hero(
                tag: 'book-cover-${book.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: book.coverPath != null
                      ? Image.file(
                    File(book.coverPath!),
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                      : const CoverPlaceholder(width: 100, height: 150),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Titles and Author
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (book.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    book.subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, _) {
                    final tagsAsync = ref.watch(bookTagsProvider(book.id));
                    return tagsAsync.maybeWhen(
                      data: (tags) {
                        if (tags.isEmpty) return const SizedBox.shrink();
                        return _CompactTagsDisplay(tags: tags);
                      },
                      orElse: () => const SizedBox.shrink(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactTagsDisplay extends StatelessWidget {
  final List<Tag> tags;
  const _CompactTagsDisplay({required this.tags});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final colorScheme = Theme.of(context).colorScheme;
        final textStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);

        final rows = <List<Tag>>[];
        var currentContext = <Tag>[];
        double currentRowWidth = 0;
        const spacing = 8.0;
        const chipPadding = 20.0; // horizontal total

        for (var i = 0; i < tags.length; i++) {
          final tag = tags[i];
          final painter = TextPainter(
            text: TextSpan(text: tag.name, style: textStyle),
            textDirection: TextDirection.ltr,
          )..layout();

          final tagWidth = painter.width + chipPadding;

          if (currentRowWidth + tagWidth <= constraints.maxWidth) {
            currentContext.add(tag);
            currentRowWidth += tagWidth + spacing;
          } else {
            if (currentContext.isNotEmpty) {
              rows.add(currentContext);
            }
            currentContext = [tag];
            currentRowWidth = tagWidth + spacing;
          }

          if (rows.length == 2) break;
        }

        if (rows.length < 2 && currentContext.isNotEmpty) {
          rows.add(currentContext);
        }

        final visibleTags = rows.take(2).expand((r) => r).toList();
        final hiddenCount = tags.length - visibleTags.length;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...visibleTags.map((tag) {
              return TagChip(
                label: tag.name,
                colorHex: tag.color,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TagBooksView(tag: tag),
                  ),
                ),
              );
            }),
            if (hiddenCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.surfaceContainerHighest,
                ),
                child: Text(
                  '+$hiddenCount',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        );
      },
    );
  }
}

class CoverPlaceholder extends StatelessWidget {
  final double width;
  final double height;

  const CoverPlaceholder({
    super.key,
    this.width = 90,
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book,
        color: colorScheme.outline,
      ),
    );
  }
}
