import 'package:flutter/material.dart';
import '../services/database.dart';
import '../models/display_preferences.dart';
import 'status_chip.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/books_controller.dart';
import 'tag_chip.dart';

class BookListTile extends ConsumerWidget {
  final Book book;
  final DisplayPreferences prefs;
  final VoidCallback? onTap;

  static const double _tileHeight = 170;
  static const double _coverHeight = 158; // _tileHeight - 12
  static const double _coverWidth = 102;  // _coverHeight * 0.65

  const BookListTile({
    super.key,
    required this.book,
    required this.prefs,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Espacio izquierdo
            const SizedBox(width: 16),

            // Portada
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
              child: _BookCover(
                coverUrl: book.coverUrl,
                coverPath: book.coverPath,
                height: _coverHeight,
                width: _coverWidth,
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título + chip
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            book.title,
                            style: theme.textTheme.titleSmall?.copyWith(
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

                    const SizedBox(height: 4),

                    // Campos ordenables
                    ...prefs.fieldOrder.map((field) {
                      switch (field) {
                        case 'author':
                          if (!prefs.showAuthor) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              book.author,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        case 'publisher':
                          if (!prefs.showPublisher) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              book.publisher ?? ' ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        case 'rating':
                          if (!prefs.showRating) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Icon(Icons.star, size: 14, color: Colors.amber[700]),
                                const SizedBox(width: 2),
                                Text(
                                  book.rating?.toStringAsFixed(1) ?? '-',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          );
                        case 'tags':
                          if (!prefs.showTags) return const SizedBox.shrink();
                          final tagsAsync = ref.watch(bookTagsProvider(book.id));
                          return tagsAsync.maybeWhen(
                            data: (tagList) => tagList.isEmpty
                                ? const SizedBox.shrink()
                                : Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 84),
                                child: ClipRect(
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: tagList.map((tag) => TagChip(
                                      label: tag.name,
                                      colorHex: tag.color,
                                    )).toList(),
                                  ),
                                ),
                              ),
                            ),
                            orElse: () => const SizedBox.shrink(),
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    }),

                    const Spacer(),

                    // Progreso — fijo abajo
                    if (prefs.showProgress)
                      _ProgressBar(
                        current: book.currentPage ?? 0,
                        total: book.totalPages ?? 1,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final percent = (current / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: percent,
          borderRadius: BorderRadius.circular(4),
          minHeight: 3,
        ),
        const SizedBox(height: 2),
        Text(
          '$current / $total págs · ${(percent * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _BookCover extends StatelessWidget {
  final String? coverUrl;
  final String? coverPath;
  final double height;
  final double width;

  const _BookCover({
    this.coverUrl,
    this.coverPath,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: width,
        height: height,
        child: _buildImage(context),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (coverPath != null) {
      return Image.file(
        File(coverPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }
    if (coverUrl != null) {
      return Image.network(
        coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}