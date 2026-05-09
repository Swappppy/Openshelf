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
  static const double _coverHeight = _tileHeight - 12;
  static const double _coverWidth = _coverHeight * 0.68;

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
      child: SizedBox(
        height: _tileHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _BookCover(
                coverUrl: book.coverUrl,
                coverPath: book.coverPath,
                height: _coverHeight,
                width: _coverWidth,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título + chip — ancla superior
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

                    // Campos opcionales centrados verticalmente
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...prefs.fieldOrder.map((field) {
                            switch (field) {
                              case 'author':
                                if (!prefs.showAuthor) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    book.author,
                                    style: theme.textTheme.bodyMedium?.copyWith(
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
                                    book.publisher ?? '',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.outline,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              case 'year':
                                if (!prefs.showYear) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    book.publishYear?.toString() ?? '',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                    maxLines: 1,
                                  ),
                                );
                              case 'rating':
                                if (!prefs.showRating) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star,
                                          size: 14, color: Colors.amber[700]),
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
                                    child: _TagsRow(tags: tagList),
                                  ),
                                  orElse: () => const SizedBox.shrink(),
                                );
                              default:
                                return const SizedBox.shrink();
                            }
                          }),
                        ],
                      ),
                    ),

                    // Progreso — ancla inferior
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

class _TagsRow extends StatelessWidget {
  final List<Tag> tags;
  const _TagsRow({required this.tags});

  @override
  Widget build(BuildContext context) {
    const double chipHeight = 24;
    const double chipSpacing = 4;
    const double chipPaddingH = 16;
    const double counterMinWidth = 28;

    final textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    // Medimos el ancho disponible usando MediaQuery menos
    // portada (102) + padding izquierdo (16) + padding info (24)
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth =
        screenWidth - 102 - 16 - 24 - counterMinWidth;

    final visibleTags = <Tag>[];
    double usedWidth = 0;

    for (final tag in tags) {
      final span = TextSpan(text: tag.name, style: textStyle);
      final painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      )..layout();

      final chipWidth = painter.width + chipPaddingH;

      if (usedWidth + chipWidth + chipSpacing <= availableWidth) {
        visibleTags.add(tag);
        usedWidth += chipWidth + chipSpacing;
      } else {
        break;
      }
    }

    final hiddenCount = tags.length - visibleTags.length;

    return SizedBox(
      height: chipHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...visibleTags.map((tag) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TagChip(
              label: tag.name,
              colorHex: tag.color,
            ),
          )),
          if (hiddenCount > 0)
            Text(
              '+$hiddenCount',
              style: textStyle.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
        ],
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