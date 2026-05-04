import 'package:flutter/material.dart';
import '../services/database.dart';
import '../models/display_preferences.dart';
import 'status_chip.dart';
import 'dart:io';

class BookListTile extends StatelessWidget {
  final Book book;
  final DisplayPreferences prefs;
  final VoidCallback? onTap;

  static const double _tileHeight = 130;

  const BookListTile({
    super.key,
    required this.book,
    required this.prefs,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: _tileHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Portada — ocupa todo el alto del tile
              _BookCover(
                coverUrl: book.coverUrl,
                coverPath: book.coverPath,
                height: _tileHeight,
                width: _tileHeight * 0.65,
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título + chip — siempre visible
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

                      // Spacer flexible para empujar contenido inferior
                      const Spacer(),

                      // Autor — reserva espacio aunque esté oculto
                      Opacity(
                        opacity: prefs.showAuthor ? 1 : 0,
                        child: Text(
                          book.author,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Editorial — reserva espacio aunque esté oculta
                      Opacity(
                        opacity: prefs.showPublisher ? 1 : 0,
                        child: Text(
                          book.publisher ?? ' ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Rating — reserva espacio aunque esté oculto
                      Opacity(
                        opacity: prefs.showRating ? 1 : 0,
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
                      ),

                      // Progreso — reserva espacio aunque esté oculto
                      Opacity(
                        opacity: prefs.showProgress ? 1 : 0,
                        child: _ProgressBar(
                          current: book.currentPage ?? 0,
                          total: book.totalPages ?? 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      borderRadius: const BorderRadius.horizontal(
        left: Radius.circular(12),
      ),
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
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }
    if (coverUrl != null) {
      return Image.network(
        coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Icon(
        Icons.menu_book,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}