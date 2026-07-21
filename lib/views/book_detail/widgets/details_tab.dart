import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../controllers/read_history_controller.dart';
import '../../../controllers/books_controller.dart';
import '../../../utils/pagination_helper.dart';
import '../../shelves/shelf_books_view.dart';
import 'main_tab.dart';

class DetailsTab extends ConsumerWidget {
  final Book book;
  final VoidCallback onTapNotes;
  final VoidCallback onStartNewReading;
  final Function(ReadHistoryData) onLongPressHistory;
  const DetailsTab({
    super.key,
    required this.book,
    required this.onTapNotes,
    required this.onStartNewReading,
    required this.onLongPressHistory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final historyAsync = ref.watch(readHistoryProvider(book.id));

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (history) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ReadOnlyField(
              label: context.l10n.fieldYear,
              value: book.publishYear?.toString() ?? '—',
            ),
            const SizedBox(height: 20),
            ReadOnlyField(label: context.l10n.fieldIsbn, value: book.isbn ?? '—'),
            const SizedBox(height: 20),
            ReadOnlyField(label: context.l10n.fieldLanguage, value: book.language ?? '—'),
            const SizedBox(height: 24),

            // Collection section
            Text(
              context.l10n.fieldCollection.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            if (book.collectionName != null && book.collectionName!.isNotEmpty)
              Consumer(builder: (context, ref, _) {
                final tagsAsync = ref.watch(allCollectionsProvider);
                return tagsAsync.maybeWhen(
                  data: (allCols) {
                    final collection = allCols.where((t) => t.id == book.collectionId).firstOrNull;
                    if (collection == null) return Text(book.collectionName ?? '—', style: Theme.of(context).textTheme.bodyLarge);
                    
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TagBooksView(tag: collection),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Collection number placeholder
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  book.collectionNumber?.toString() ?? '#',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    collection.name,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Consumer(builder: (context, ref, _) {
                                    final countAsync = ref.watch(booksByCollectionProvider(collection.id));
                                    return countAsync.maybeWhen(
                                      data: (list) => Text(
                                        context.l10n.imprintBookCount(list.length),
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                      orElse: () => const SizedBox.shrink(),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: colorScheme.outline, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                  orElse: () => Text(book.collectionName ?? '—', style: Theme.of(context).textTheme.bodyLarge),
                );
              })
            else
              Text('—', style: Theme.of(context).textTheme.bodyLarge),

            const SizedBox(height: 24),

            // Imprint section
            Text(
              context.l10n.bookDetailFieldImprintSection,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Consumer(builder: (context, ref, _) {
              final imprintAsync = ref.watch(bookImprintProvider(book.id));
              return imprintAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const Text('—'),
                data: (imprint) {
                  if (imprint == null) {
                    return Text('—', style: Theme.of(context).textTheme.bodyLarge);
                  }
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TagBooksView(tag: imprint),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Thumbnail or initials
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imprint.imagePath != null
                                ? Image.file(
                              File(imprint.imagePath!),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (context, error, stackTrace) => ImprintPlaceholder(size: 40, iconSize: 20, name: imprint.name),
                            )
                                : ImprintPlaceholder(size: 40, iconSize: 20, name: imprint.name),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  imprint.name,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Consumer(builder: (context, ref, _) {
                                  final countAsync =
                                  ref.watch(imprintBookCountProvider(imprint.id));
                                  return countAsync.maybeWhen(
                                    data: (count) => Text(
                                      context.l10n.imprintBookCount(count),
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                    orElse: () => const SizedBox.shrink(),
                                  );
                                }),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: colorScheme.outline, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),

            const SizedBox(height: 20),

            ReadOnlyField(
              label: context.l10n.fieldTranslator,
              value: book.translator ?? '—',
            ),
            const SizedBox(height: 20),

            // Personal Notes
            GestureDetector(
              onTap: onTapNotes,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        context.l10n.bookDetailFieldPersonalNotes,
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
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 100),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      book.notes ?? context.l10n.bookDetailNotesEmpty,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: book.notes == null
                            ? Theme.of(context).colorScheme.outline
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ReadOnlyField(
                    label: context.l10n.bookDetailFieldAdded,
                    value:
                    '${book.createdAt.day}/${book.createdAt.month}/${book.createdAt.year}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ReadOnlyField(
                    label: context.l10n.fieldCopies,
                    value: '${book.copies}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Independent Sections Summary
            if (book.paginationConfig != null && book.paginationConfig!.segments.isNotEmpty) ...[
              Text(
                context.l10n.paginationBlocksSegments.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: book.paginationConfig!.segments.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    final isLast = i == book.paginationConfig!.segments.length - 1;
                    
                    final completedReads = history.where((h) => h.finishedAt != null).length;
                    final sectionLabel = s.label ?? context.l10n.paginationSectionLabel(i + 1);
                    
                    final activeSessionForSegment = history.lastWhereOrNull((h) =>
                      h.sections == null || h.sections!.contains(sectionLabel)
                    );
                    
                    final sessionNumToShow = activeSessionForSegment?.readNumber ?? 
                        PaginationHelper.getActiveSessionNumber(book.status, completedReads);
                    
                    final Map<int, int> segProgress = activeSessionForSegment?.segmentProgress ?? {};

                    final currentInSegment = segProgress[i] ?? 0;
                    final segmentTotal = s.endPhysical - s.startPhysical + 1;

                    return Column(
                      children: [
                        ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(sectionLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${context.l10n.statusReading}: $sessionNumToShow'),
                          trailing: Text(
                            '${(segmentTotal > 0 ? (currentInSegment / segmentTotal * 100) : 0).toStringAsFixed(0)}%',
                            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (!isLast) Divider(height: 1, indent: 16, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Reading History Section
            Text(
              context.l10n.bookDetailReadHistoryTitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 8),
            if (history.isEmpty)
              Text('—', style: Theme.of(context).textTheme.bodyLarge)
            else
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: history.asMap().entries.map((entry) {
                    final h = entry.value;
                    final isLast = entry.key == history.length - 1;
                    
                    String dateRange = '';
                    if (h.startedAt != null) {
                      dateRange = '${h.startedAt!.day}/${h.startedAt!.month}/${h.startedAt!.year}';
                      if (h.finishedAt != null) {
                        dateRange += ' – ${h.finishedAt!.day}/${h.finishedAt!.month}/${h.finishedAt!.year}';
                      } else {
                        dateRange += ' – ${context.l10n.bookDetailReadOngoing}';
                      }
                    } else {
                      dateRange = '—';
                    }

                    return Column(
                      children: [
                        ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          onLongPress: () => onLongPressHistory(h),
                          title: Text(
                            context.l10n.bookDetailReadNumber(h.readNumber),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateRange,
                                style: TextStyle(color: colorScheme.outline, fontSize: 12),
                              ),
                              if (h.sections != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  h.sections!.join(' • '),
                                  style: TextStyle(
                                    color: colorScheme.primary.withValues(alpha: 0.8),
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          leading: Icon(
                            h.finishedAt != null ? Icons.check_circle_outline : Icons.play_circle_outline,
                            size: 18,
                            color: h.finishedAt != null ? Colors.green : colorScheme.primary,
                          ),
                        ),
                        if (!isLast) Divider(height: 1, indent: 56, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ],
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 24),

            // Start New Reading Button
            if (book.status != ReadingStatus.reading)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: OutlinedButton.icon(
                  onPressed: onStartNewReading,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(context.l10n.bookDetailStartNewReadingButton),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

class ImprintPlaceholder extends StatelessWidget {
  final double size;
  final double iconSize;
  final String? name;

  const ImprintPlaceholder({
    super.key,
    this.size = 80,
    this.iconSize = 32,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget content;
    if (name != null && name!.isNotEmpty) {
      final initials = name!
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .take(3)
          .map((w) => w[0].toUpperCase())
          .join();
      content = Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: size * 0.35,
            letterSpacing: 0.5,
          ),
        ),
      );
    } else {
      content = Icon(
        Icons.business_outlined,
        size: iconSize,
        color: colorScheme.outline,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: content,
    );
  }
}
