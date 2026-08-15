import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../controllers/read_history_controller.dart';
import '../../../controllers/books_controller.dart';
import '../../../controllers/ownership_controller.dart';
import '../../../widgets/imprint_placeholder.dart';
import '../../../widgets/status_chip_field.dart';
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
    final ownershipAsync = ref.watch(ownershipLogProvider(book.id));

    String ownershipLabel(OwnershipStatus? status) {
      if (status == null) return '—';
      switch (status) {
        case OwnershipStatus.bought: return context.l10n.ownershipStatusBought;
        case OwnershipStatus.gifted: return context.l10n.ownershipStatusGifted;
        case OwnershipStatus.borrowed: return context.l10n.ownershipStatusBorrowed;
        case OwnershipStatus.returned: return context.l10n.ownershipStatusReturned;
        case OwnershipStatus.sold: return context.l10n.ownershipStatusSold;
        case OwnershipStatus.other: return context.l10n.ownershipStatusOther;
      }
    }

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (history) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ReadOnlyField(label: context.l10n.fieldIsbn, value: book.isbn ?? '—'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ReadOnlyField(
                    label: context.l10n.fieldYear,
                    value: book.publishYear?.toString() ?? '—',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ReadOnlyField(label: context.l10n.fieldLanguage, value: book.language ?? '—'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatusChipField(
                    label: context.l10n.fieldOwnershipStatus,
                    value: ownershipLabel(book.ownershipStatus),
                    icon: _ownershipIcon(book.ownershipStatus),
                    color: _ownershipColor(book.ownershipStatus),
                    onTap: () {
                      // TODO: Navigate to filtered view for ownership status
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (book.originalTitle != null && book.originalTitle!.isNotEmpty) ...[
              ReadOnlyField(label: context.l10n.fieldOriginalTitle, value: book.originalTitle!),
              const SizedBox(height: 20),
            ],
            if ((book.originalLanguage != null && book.originalLanguage!.isNotEmpty) || 
                (book.translator != null && book.translator!.isNotEmpty)) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (book.originalLanguage != null && book.originalLanguage!.isNotEmpty)
                    Expanded(
                      child: ReadOnlyField(label: context.l10n.fieldOriginalLanguage, value: book.originalLanguage!),
                    ),
                  if (book.originalLanguage != null && book.originalLanguage!.isNotEmpty && 
                      book.translator != null && book.translator!.isNotEmpty)
                    const SizedBox(width: 16),
                  if (book.translator != null && book.translator!.isNotEmpty)
                    Expanded(
                      child: ReadOnlyField(label: context.l10n.fieldTranslator, value: book.translator!),
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            Text(
              context.l10n.fieldCollection.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Consumer(builder: (context, ref, _) {
              final collectionsAsync = ref.watch(bookCollectionsProvider(book.id));
              return collectionsAsync.maybeWhen(
                data: (list) {
                  if (list.isEmpty) {
                    if (book.collectionName != null && book.collectionName!.isNotEmpty) {
                       return Text(book.collectionName!, style: Theme.of(context).textTheme.bodyLarge);
                    }
                    return Text('—', style: Theme.of(context).textTheme.bodyLarge);
                  }
                  
                  return Column(
                    children: list.map((item) {
                      final collection = item.$1;
                      final number = item.$2;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: GestureDetector(
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
                                Container(
                                  width: 48,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      number?.toString() ?? '#',
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
                        ),
                      );
                    }).toList(),
                  );
                },
                orElse: () => Text(book.collectionName ?? '—', style: Theme.of(context).textTheme.bodyLarge),
              );
            }),

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

            const SizedBox(height: 24),

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
                    value: DateFormat.yMd(Localizations.localeOf(context).toString()).format(book.createdAt),
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
                    final locale = Localizations.localeOf(context).toString();
                    if (h.startedAt != null) {
                      dateRange = DateFormat.yMd(locale).format(h.startedAt!);
                      if (h.finishedAt != null) {
                        dateRange += ' – ${DateFormat.yMd(locale).format(h.finishedAt!)}';
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

            // Ownership History Section
            Text(
              context.l10n.ownershipHistoryTitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 8),
            ownershipAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const Text('—'),
              data: (log) {
                if (log.isEmpty) return Text('—', style: Theme.of(context).textTheme.bodyLarge);
                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: log.asMap().entries.map((entry) {
                      final item = entry.value;
                      final isLast = entry.key == log.length - 1;
                      final locale = Localizations.localeOf(context).toString();
                      
                      final IconData icon = switch (item.eventType) {
                        OwnershipStatus.bought => Icons.shopping_cart_outlined,
                        OwnershipStatus.gifted => Icons.card_giftcard_outlined,
                        OwnershipStatus.borrowed => Icons.handshake_outlined,
                        OwnershipStatus.returned => Icons.keyboard_return_outlined,
                        OwnershipStatus.sold => Icons.sell_outlined,
                        OwnershipStatus.other => Icons.more_horiz_outlined,
                      };

                      return Column(
                        children: [
                          ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text(
                              ownershipLabel(item.eventType),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat.yMd(locale).format(item.date),
                                  style: TextStyle(color: colorScheme.outline, fontSize: 12),
                                ),
                                if (item.personName != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    item.personName!,
                                    style: TextStyle(
                                      color: colorScheme.primary.withValues(alpha: 0.8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            leading: Icon(icon, size: 18, color: colorScheme.primary),
                          ),
                          if (!isLast) Divider(height: 1, indent: 56, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
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

  IconData _ownershipIcon(OwnershipStatus? status) {
    switch (status) {
      case OwnershipStatus.bought: return Icons.shopping_cart_outlined;
      case OwnershipStatus.gifted: return Icons.card_giftcard_outlined;
      case OwnershipStatus.borrowed: return Icons.handshake_outlined;
      case OwnershipStatus.returned: return Icons.keyboard_return_outlined;
      case OwnershipStatus.sold: return Icons.sell_outlined;
      case OwnershipStatus.other:
      case null:
        return Icons.more_horiz_outlined;
    }
  }

  Color _ownershipColor(OwnershipStatus? status) {
    switch (status) {
      case OwnershipStatus.bought: return Colors.blue;
      case OwnershipStatus.gifted: return Colors.purple;
      case OwnershipStatus.borrowed: return Colors.orange;
      case OwnershipStatus.returned: return Colors.green;
      case OwnershipStatus.sold: return Colors.red;
      case OwnershipStatus.other:
      case null:
        return Colors.grey;
    }
  }
}
