import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import '../controllers/books_controller.dart';
import '../controllers/database_provider.dart';
import '../controllers/display_preferences_controller.dart';
import '../l10n/l10n_extension.dart';
import '../views/shelves/shelf_books_view.dart';
import 'tag_form_dialog.dart';
import 'standard_progress_row.dart';
import 'os_empty_state.dart';

class ImprintsList extends ConsumerWidget {
  final ScrollController scrollController;
  const ImprintsList({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imprintsAsync = ref.watch(allImprintsWithCountsProvider);
    return imprintsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(context.l10n.errorPrefix(e.toString()))),
      data: (list) {
        if (list.isEmpty) {
          return OsEmptyState(
            icon: Icons.business_outlined,
            message: context.l10n.imprintNone,
            subtitle: context.l10n.imprintNoneSubtitle,
          );
        }
        final p = ref.watch(displayPreferencesProvider);
        return _ImprintSortContainer(
          imprints: list,
          sortOrder: p.imprintSortOrder,
          sortDirections: p.imprintSortDirections,
          builder: (sorted) => ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: sorted.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final (imp, count) = sorted[index];
              final booksAsync = ref.watch(booksByImprintProvider(imp.id));
              
              return booksAsync.maybeWhen(
                data: (books) {
                  final readCount = books.where((b) => b.status == ReadingStatus.read).length;
                  final progress = count > 0 ? readCount / count : 0.0;

                  return Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TagBooksView(tag: imp))),
                      onLongPress: () => _showTagOptions(context, ref, imp),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Hero(
                              tag: 'imprint_stack_${imp.id}',
                              child: SizedBox(
                                width: 60, height: 60,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: imp.imagePath != null && File(imp.imagePath!).existsSync()
                                      ? Image.file(File(imp.imagePath!), width: 60, height: 60, fit: BoxFit.cover)
                                      : Container(
                                    width: 60, height: 60,
                                    color: imp.color != null ? Color(int.parse('0xFF${imp.color!}')) : Theme.of(context).colorScheme.surfaceContainerHighest,
                                    alignment: Alignment.center,
                                    child: Text(
                                      _getInitials(imp.name),
                                      style: TextStyle(fontWeight: FontWeight.bold, color: imp.color != null ? Colors.white : Theme.of(context).colorScheme.primary, fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Hero(
                                    tag: 'imprint_title_${imp.id}',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Text(
                                        imp.name, 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  StandardProgressRow(readCount: readCount, totalCount: count, progress: progress),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              );
            },
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

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return words.map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(3).join('');
  }
}

class _ImprintSortContainer extends ConsumerWidget {
  final List<(Tag, int)> imprints;
  final List<String> sortOrder;
  final Map<String, bool> sortDirections;
  final Widget Function(List<(Tag, int)>) builder;

  const _ImprintSortContainer({
    required this.imprints,
    required this.sortOrder,
    required this.sortDirections,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = List<(Tag, int)>.from(imprints);
    
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
        }
        
        if (comparison != 0) return isAsc ? comparison : -comparison;
      }
      return a.$1.id.compareTo(b.$1.id);
    });

    return builder(sorted);
  }
}
