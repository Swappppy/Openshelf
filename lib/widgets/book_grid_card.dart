import 'package:flutter/material.dart';
import '../services/database.dart';
import '../models/display_preferences.dart';
import 'status_chip.dart';
import 'dart:io';

class BookGridCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _coverWidget(context),
                  if (prefs.showStatusChip)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: StatusChip(status: book.status),
                    ),
                ],
              ),
            ),

            // Info inferior
            Padding(
              padding: const EdgeInsets.all(8),
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
                  if (prefs.showAuthor) ...[
                    const SizedBox(height: 2),
                    Text(
                      book.author,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (prefs.showPublisher && book.publisher != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      book.publisher!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (prefs.showProgress &&
                      book.totalPages != null &&
                      book.currentPage != null) ...[
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: (book.currentPage! / book.totalPages!).clamp(0.0, 1.0),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 3,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(book.currentPage! / book.totalPages! * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                  if (prefs.showRating && book.rating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.amber[700]),
                        const SizedBox(width: 2),
                        Text(
                          book.rating!.toStringAsFixed(1),
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverWidget(BuildContext context) {
    if (book.coverPath != null) {
      return Image.file(
        File(book.coverPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }
    if (book.coverUrl != null) {
      return Image.network(
        book.coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.menu_book,
          size: 48,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}