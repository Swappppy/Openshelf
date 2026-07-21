import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../utils/pagination_helper.dart';
import '../../../widgets/segmented_progress_bar.dart';
import '../../../controllers/read_history_controller.dart';

class MainTab extends StatelessWidget {
  final Book book;
  final VoidCallback onTapPages;

  const MainTab({
    super.key,
    required this.book,
    required this.onTapPages,
  });

  String _formatLabel(BuildContext context, BookFormat? format) {
    switch (format) {
      case BookFormat.paperback:
        return context.l10n.formatPaperback;
      case BookFormat.hardcover:
        return context.l10n.formatHardcover;
      case BookFormat.leatherbound:
        return context.l10n.formatLeatherbound;
      case BookFormat.rustic:
        return context.l10n.formatRustic;
      case BookFormat.digital:
        return context.l10n.formatDigital;
      case BookFormat.other:
        return context.l10n.formatOther;
      case null:
        return '—';
    }
  }

  String _getMultiBlockProgress(BuildContext context, Book book, List<ReadHistoryData> history) {
    if (book.paginationConfig == null || book.paginationConfig!.segments.isEmpty) {
      return '';
    }
    
    final completedReads = history.where((h) => h.finishedAt != null).length;
    final activeSessionNum = PaginationHelper.getActiveSessionNumber(book.status, completedReads);
    final activeSession = history.firstWhereOrNull((h) => h.readNumber == activeSessionNum);
    
    final Map<int, int> segProgress = activeSession?.segmentProgress ?? {};

    return book.paginationConfig!.segments.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      final endVisual = PaginationHelper.getVisualPageInSegment(s.endPhysical, s);
      
      final currentInSegment = segProgress[i] ?? 0;
      
      String visualProgress = '';
      if (currentInSegment == 0) {
        visualProgress = s.type == PageNumberingType.roman ? '-' : '0';
      } else {
        // Calculate physical page within segment to get visual representation
        final physForVisual = s.startPhysical + currentInSegment - 1;
        visualProgress = PaginationHelper.getVisualPageInSegment(physForVisual, s);
      }
      
      final sectionLabel = s.label ?? context.l10n.paginationSectionLabel(i + 1);
      return '$sectionLabel: $visualProgress/$endVisual';
    }).join('  •  ');
  }

  void _showFullDescription(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.fieldDescription.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ReadOnlyField(label: context.l10n.fieldTitle, value: book.title),
        const SizedBox(height: 20),
        if (book.subtitle != null) ...[
          ReadOnlyField(label: context.l10n.fieldSubtitle, value: book.subtitle!),
          const SizedBox(height: 20),
        ],
        ReadOnlyField(label: context.l10n.fieldAuthor, value: book.author),
        const SizedBox(height: 20),
        ReadOnlyField(label: context.l10n.fieldPublisher, value: book.publisher ?? '—'),
        const SizedBox(height: 20),
        
        if (book.description != null && book.description!.isNotEmpty) ...[
          GestureDetector(
            onTap: () => _showFullDescription(context, book.description!),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.fieldDescription.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 120),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    book.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Progress Section - Tap to edit
        GestureDetector(
          onTap: onTapPages,
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    context.l10n.bookDetailFieldPages,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit_outlined,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 4),
        Consumer(builder: (context, ref, _) {
          final historyAsync = ref.watch(readHistoryProvider(book.id));
          return historyAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const Text('—'),
            data: (history) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (book.totalPages != null) ...[
                    const SizedBox(height: 8),
                    SegmentedProgressBar(
                      book: book,
                      history: history,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getMultiBlockProgress(context, book, history),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 11,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Pág. ${PaginationHelper.getTotalReadPages(book, history)} / ${book.totalPages ?? 0}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ] else
                    Text('—', style: Theme.of(context).textTheme.bodyLarge),
                ],
              );
            },
          );
        }),
              
              if (book.paginationConfig != null && book.paginationConfig!.markers.isNotEmpty) ...[
                const SizedBox(height: 16),
                ExpansionTile(
                  title: Text(context.l10n.paginationMarkersAndIndices, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline, fontWeight: FontWeight.bold)),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  children: book.paginationConfig!.markers.map((m) => ListTile(
                    leading: Icon(Icons.location_on_outlined, size: 16, color: m.color != null ? Color(int.parse('0xFF${m.color}')) : null),
                    title: Text(m.label, style: const TextStyle(fontSize: 13)),
                    trailing: Text('${context.l10n.fieldCurrentPage.substring(0, 1).toUpperCase()}${context.l10n.fieldCurrentPage.substring(1).toLowerCase()}. ${PaginationHelper.getVisualPage(m.physicalPage, book.paginationConfig)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),
        ReadOnlyField(label: context.l10n.bookDetailFieldFormat, value: _formatLabel(context, book.bookFormat)),
        const SizedBox(height: 20),

        // Star Rating
        Text(
          context.l10n.bookDetailFieldRating,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (i) {
            return Icon(
              i < (book.rating ?? 0) ? Icons.star : Icons.star_border,
              color: Colors.amber[700],
              size: 24,
            );
          }),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const ReadOnlyField({
    super.key,
    required this.label, 
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
