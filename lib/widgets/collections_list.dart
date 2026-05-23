import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import '../controllers/books_controller.dart';
import '../controllers/database_provider.dart';
import '../controllers/display_preferences_controller.dart';
import '../l10n/l10n_extension.dart';
import 'collection_list_tile.dart';
import 'tag_form_dialog.dart';
import 'os_empty_state.dart';

class CollectionsList extends ConsumerWidget {
  final ScrollController scrollController;
  const CollectionsList({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(allCollectionsWithCountsProvider);
    return collectionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(context.l10n.errorPrefix(e.toString()))),
      data: (list) {
        if (list.isEmpty) {
          return OsEmptyState(
            icon: Icons.collections_bookmark_outlined,
            message: context.l10n.collectionNone,
            subtitle: context.l10n.collectionNoneSubtitle,
          );
        }
        final p = ref.watch(displayPreferencesProvider);
        final sorted = List<(Tag, int)>.from(list);

        sorted.sort((a, b) {
          for (final criteria in p.collectionSortOrder) {
            int comparison = 0;
            final isAsc = p.collectionSortDirections[criteria] ?? true;

            switch (criteria) {
              case 'name':
                comparison = a.$1.name.toLowerCase().compareTo(b.$1.name.toLowerCase());
                break;
              case 'count':
                comparison = a.$2.compareTo(b.$2);
                break;
            }
            
            if (comparison != 0) return isAsc ? comparison : -comparison;
          }
          return a.$1.id.compareTo(b.$1.id);
        });

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final (col, count) = sorted[index];
            return CollectionListTile(
              collection: col, 
              totalCount: count,
              onLongPress: () => _showTagOptions(context, ref, col),
            );
          },
        );
      },
    );
  }

  void _showTagOptions(BuildContext context, WidgetRef ref, Tag tag) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.edit),
              onTap: () {
                Navigator.pop(ctx);
                showTagFormDialog(context, ref, existing: tag, title: context.l10n.edit, type: tag.type);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(context.l10n.delete, style: const TextStyle(color: Colors.red)),
              onTap: () async {
                await ref.read(databaseProvider).deleteTag(tag.id);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
