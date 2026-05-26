import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shelf.dart';
import '../services/database.dart';
import '../controllers/books_controller.dart';
import '../controllers/database_provider.dart';
import '../l10n/l10n_extension.dart';
import '../views/shelves/shelf_books_view.dart';
import 'cover_mosaic.dart';
import 'status_chip.dart';
import 'standard_progress_row.dart';

class ModernShelfCard extends ConsumerWidget {
  final Shelf shelf;
  final int count;
  final int readCount;
  final VoidCallback onLongPress;
  
  const ModernShelfCard({
    super.key,
    required this.shelf,
    required this.count,
    required this.readCount,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final booksAsync = ref.watch(shelfBooksProvider(shelf));
    
    return booksAsync.maybeWhen(
      data: (books) {
        final progress = count > 0 ? readCount / count : 0.0;
        ReadingStatus? activeStatus;
        if (shelf.filterStatus != null) {
          activeStatus = ReadingStatus.values.firstWhere((s) => s.name == shelf.filterStatus);
        }

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ShelfBooksView(shelf: shelf)),
          ),
          onLongPress: () {
            HapticFeedback.mediumImpact();
            onLongPress();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'shelf_mosaic_${shelf.id}',
                  child: Stack(
                    children: [
                      CoverMosaic(books: books),
                      Positioned(
                        bottom: 4, left: 4, right: 4,
                        child: Text(
                          '$count ${context.l10n.imprintBookCount(count).split(' ').last.toUpperCase()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 7, 
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Hero(
                              tag: 'shelf_title_${shelf.id}',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  shelf.name,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          if (activeStatus != null)
                            StatusChip(status: activeStatus),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _SummaryDisplay(shelf: shelf, books: books),
                      const SizedBox(height: 12),
                      StandardProgressRow(readCount: readCount, totalCount: count, progress: progress),
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
}

class _SummaryDisplay extends ConsumerWidget {
  final Shelf shelf;
  final List<Book> books;

  const _SummaryDisplay({required this.shelf, required this.books});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return FutureBuilder<List<String>>(
      future: _getTopTags(ref, books),
      builder: (context, snapshot) {
        final tags = snapshot.data ?? [];
        if (tags.isEmpty) {
          final filterSummary = _buildFilterSummary(context, shelf);
          return Text(
            filterSummary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }
        
        return Wrap(
          spacing: 4,
          children: tags.map((t) => Text(
            '#$t',
            style: TextStyle(fontSize: 9, color: colorScheme.primary.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
          )).toList(),
        );
      },
    );
  }

  Future<List<String>> _getTopTags(WidgetRef ref, List<Book> books) async {
    if (books.isEmpty) return [];
    final db = ref.read(databaseProvider);
    final counts = <String, int>{};
    
    final limited = books.take(10);
    for (final b in limited) {
      final tags = await db.watchTagsForBook(b.id).first;
      for (final t in tags) {
        counts[t.name] = (counts[t.name] ?? 0) + 1;
      }
    }
    
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return sorted.take(3).map((e) => e.key).toList();
  }

  String _buildFilterSummary(BuildContext context, Shelf s) {
    final parts = <String>[];
    if (s.filterAuthor != null) parts.add(s.filterAuthor!);
    if (s.filterPublisher != null) parts.add(s.filterPublisher!);
    if (s.filterCollection != null) parts.add(s.filterCollection!);
    return parts.isEmpty ? '—' : parts.join(' · ');
  }
}
