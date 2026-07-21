import 'dart:io';
import 'package:flutter/material.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';

class BookHeader extends StatelessWidget {
  final Book book;
  const BookHeader({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
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
          const SizedBox(width: 20),
          // Titles and Author
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                  maxLines: 3,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  book.author,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                StatusChip(status: book.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final ReadingStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ReadingStatus.wantToRead => Colors.orange,
      ReadingStatus.reading => Colors.blue,
      ReadingStatus.read => Colors.green,
      ReadingStatus.abandoned => Colors.red,
      ReadingStatus.paused => Colors.deepPurpleAccent,
    };

    final label = switch (status) {
      ReadingStatus.wantToRead => context.l10n.statusWantToRead,
      ReadingStatus.reading => context.l10n.statusReading,
      ReadingStatus.read => context.l10n.statusRead,
      ReadingStatus.abandoned => context.l10n.statusAbandoned,
      ReadingStatus.paused => context.l10n.statusPaused,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
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
