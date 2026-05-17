import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shelf.dart';
import '../controllers/books_controller.dart';
import '../controllers/database_provider.dart';
import '../controllers/display_preferences_controller.dart';
import '../l10n/l10n_extension.dart';
import 'modern_shelf_card.dart';
import 'shelf_form_sheet.dart';
import 'os_empty_state.dart';

class ShelvesSection extends ConsumerWidget {
  final ScrollController scrollController;
  
  const ShelvesSection({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelvesAsync = ref.watch(allShelvesWithStatsProvider);
    
    return shelvesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        if (list.isEmpty) {
          return OsEmptyState(
            icon: Icons.bookmarks_outlined,
            message: context.l10n.shelfEmpty,
            subtitle: context.l10n.shelfEmptySubtitle,
          );
        }

        final p = ref.watch(displayPreferencesProvider);

        return _ShelfSortContainer(
          shelves: list,
          sortOrder: p.shelfSortOrder,
          sortDirections: p.shelfSortDirections,
          builder: (sorted) => ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final (shelf, count, readCount) = sorted[index];
              return ModernShelfCard(
                shelf: shelf, 
                count: count, 
                readCount: readCount,
                onLongPress: () => _showShelfOptions(context, ref, shelf),
              );
            },
          ),
        );
      },
    );
  }

  void _showShelfOptions(BuildContext context, WidgetRef ref, Shelf shelf) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.shelfOptionEdit),
              onTap: () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (ctx2) => ShelfFormSheet(
                    existing: shelf,
                    onSave: (companion) async {
                      final updated = shelf.copyWith(
                        name: companion.name.value,
                        filterQuery: companion.filterQuery.value,
                        filterAuthor: companion.filterAuthor.value,
                        filterPublisher: companion.filterPublisher.value,
                        filterIsbn: companion.filterIsbn.value,
                        filterCollection: companion.filterCollection.value,
                        filterStatus: companion.filterStatus.value,
                        filterTagIds: companion.filterTagIds.value,
                        filterImprintIds: companion.filterImprintIds.value,
                        filterSubtitle: companion.filterSubtitle.value,
                        filterLanguage: companion.filterLanguage.value,
                        filterTranslator: companion.filterTranslator.value,
                      );
                      await ref.read(databaseProvider).updateShelf(updated);
                      if (ctx2.mounted) Navigator.pop(ctx2);
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: Text(context.l10n.shelfOptionDelete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(databaseProvider).deleteShelf(shelf.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShelfSortContainer extends ConsumerWidget {
  final List<(Shelf, int, int)> shelves;
  final List<String> sortOrder;
  final Map<String, bool> sortDirections;
  final Widget Function(List<(Shelf, int, int)>) builder;

  const _ShelfSortContainer({
    required this.shelves,
    required this.sortOrder,
    required this.sortDirections,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = List<(Shelf, int, int)>.from(shelves);
    
    sorted.sort((a, b) {
      for (final criteria in sortOrder) {
        int comparison = 0;
        final isAsc = sortDirections[criteria] ?? true;
        
        switch (criteria) {
          case 'name':
            comparison = a.$1.name.toLowerCase().compareTo(b.$1.name.toLowerCase());
            break;
          case 'count':
            comparison = a.$2.compareTo(b.$2);
            break;
          case 'progress':
            final progA = a.$2 > 0 ? a.$3 / a.$2 : 0.0;
            final progB = b.$2 > 0 ? b.$3 / b.$2 : 0.0;
            comparison = progA.compareTo(progB);
            break;
        }
        
        if (comparison != 0) return isAsc ? comparison : -comparison;
      }
      return a.$1.id.compareTo(b.$1.id);
    });

    return builder(sorted);
  }
}
