import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import '../controllers/books_controller.dart';
import '../controllers/database_provider.dart';
import '../controllers/display_preferences_controller.dart';
import '../l10n/l10n_extension.dart';
import 'categories_cloud_item.dart';
import 'app_color_picker.dart';
import 'tag_form_dialog.dart';
import 'os_empty_state.dart';
import 'package:drift/drift.dart' show Value;

class CategoriesCloud extends ConsumerWidget {
  final ScrollController scrollController;
  const CategoriesCloud({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(allTagsWithCountsProvider);

    return tagsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        if (list.isEmpty) {
          return OsEmptyState(
            icon: Icons.label_outline,
            message: context.l10n.tagNone,
            subtitle: context.l10n.tagNoneSubtitle,
          );
        }
        
        final p = ref.watch(displayPreferencesProvider);
        final sortedList = List<(Tag, int)>.from(list);

        sortedList.sort((a, b) {
          for (final criteria in p.categorySortOrder) {
            int comparison = 0;
            final isAsc = p.categorySortDirections[criteria] ?? true;

            switch (criteria) {
              case 'name':
                comparison = a.$1.name.toLowerCase().compareTo(b.$1.name.toLowerCase());
                break;
              case 'usage':
                comparison = a.$2.compareTo(b.$2);
                break;
              case 'color':
                comparison = (a.$1.color ?? '').compareTo(b.$1.color ?? '');
                break;
            }
            if (comparison != 0) return isAsc ? comparison : -comparison;
          }
          return a.$1.id.compareTo(b.$1.id);
        });
        
        int maxCount = 1;
        for (final (_, count) in sortedList) {
          if (count > maxCount) maxCount = count;
        }

        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: sortedList.map((item) {
              final (tag, count) = item;
              return CategoriesCloudItem(
                tag: tag, 
                count: count,
                maxCount: maxCount,
                onLongPress: () => _showTagOptions(context, ref, tag),
              );
            }).toList(),
          ),
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
              leading: const Icon(Icons.palette_outlined),
              title: Text(context.l10n.tagColorLabel),
              onTap: () {
                Navigator.pop(ctx);
                _showColorPicker(context, ref, tag);
              },
            ),
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

  void _showColorPicker(BuildContext context, WidgetRef ref, Tag tag) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.tagColorLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AppColorPicker(
              selectedColor: (tag.color != null && tag.color!.length == 6) ? Color(int.parse('0xFF${tag.color}')) : null,
              onColorSelected: (color) async {
                final hex = color?.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
                final updated = tag.copyWith(color: Value(hex));
                await ref.read(databaseProvider).updateTag(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              allowNoColor: true,
            ),
          ],
        ),
      ),
    );
  }
}
