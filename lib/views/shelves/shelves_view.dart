import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drift/drift.dart' show Value;
import '../../models/shelf.dart';
import '../../services/database.dart';
import '../../services/cover_service.dart';
import '../../services/permission_service.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/database_provider.dart';
import '../../widgets/filter_grid_box.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/tag_chip.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/scrollable_selection_bar.dart';
import '../../widgets/sort_bottom_sheet.dart';
import '../../controllers/display_preferences_controller.dart';
import '../../controllers/fab_visibility_controller.dart';
import '../../widgets/add_entity_fab.dart';
import 'shelf_books_view.dart';

enum _ShelvesTab { shelves, categories, imprints, collections }

/// Redesigned screen for managing library organization with a thin tabbed layout.
class ShelvesScreen extends ConsumerStatefulWidget {
  const ShelvesScreen({super.key});

  @override
  ConsumerState<ShelvesScreen> createState() => _ShelvesScreenState();
}

class _ShelvesScreenState extends ConsumerState<ShelvesScreen> {
  _ShelvesTab _activeTab = _ShelvesTab.shelves;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    ref.read(fabVisibilityProvider.notifier).handleScroll(_scrollController);
  }

  void _showCreateShelfDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ShelfFormSheet(
        onSave: (shelf) async {
          await ref.read(databaseProvider).insertShelf(shelf);
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showAddEntityDialog() {
    String title = '';
    String type = '';

    switch (_activeTab) {
      case _ShelvesTab.categories:
        title = context.l10n.tagNewDialogTitle;
        type = 'tag';
        break;
      case _ShelvesTab.imprints:
        title = context.l10n.imprintNewDialogTitle;
        type = 'imprint';
        break;
      case _ShelvesTab.collections:
        title = context.l10n.managementCollections;
        type = 'collection';
        break;
      default: return;
    }

    _showTagFormDialog(context, ref, title: title, type: type);
  }

  void _showSortOptions(BuildContext context, WidgetRef ref) {
    final controller = ref.read(displayPreferencesProvider.notifier);
    final l10n = context.l10n;

    switch (_activeTab) {
      case _ShelvesTab.shelves:
        SortBottomSheet.show(
          context,
          title: l10n.sortTitle,
          orderSelector: (p) => p.shelfSortOrder,
          directionsSelector: (p) => p.shelfSortDirections,
          labels: {
            'name': l10n.fieldTitle,
            'count': l10n.fieldTotalPages, 
            'progress': l10n.fieldReadingProgress,
          },
          onReorder: controller.reorderShelfSort,
          onToggleDirection: controller.toggleShelfSortDirection,
        );
        break;
      case _ShelvesTab.categories:
        SortBottomSheet.show(
          context,
          title: l10n.sortTitle,
          orderSelector: (p) => p.categorySortOrder,
          directionsSelector: (p) => p.categorySortDirections,
          labels: {
            'name': l10n.fieldTitle,
            'usage': l10n.managementCategoryCount,
            'color': l10n.tagColorLabel,
          },
          onReorder: controller.reorderCategorySort,
          onToggleDirection: controller.toggleCategorySortDirection,
          showNumericField: true,
          numericLabel: 'Curva algorítmica (Libros)',
          numericValueSelector: (p) => p.tagCloudMaxCount,
          onNumericChanged: (val) => controller.setTagCloudMaxCount(val),
        );
        break;
      case _ShelvesTab.imprints:
        SortBottomSheet.show(
          context,
          title: l10n.sortTitle,
          orderSelector: (p) => p.imprintSortOrder,
          directionsSelector: (p) => p.imprintSortDirections,
          labels: {
            'name': l10n.fieldTitle,
            'count': l10n.fieldTotalBooks,
          },
          onReorder: controller.reorderImprintSort,
          onToggleDirection: controller.toggleImprintSortDirection,
        );
        break;
      case _ShelvesTab.collections:
        SortBottomSheet.show(
          context,
          title: l10n.sortTitle,
          orderSelector: (p) => p.collectionSortOrder,
          directionsSelector: (p) => p.collectionSortDirections,
          labels: {
            'name': l10n.fieldTitle,
            'count': l10n.fieldTotalBooks,
          },
          onReorder: controller.reorderCollectionSort,
          onToggleDirection: controller.toggleCollectionSortDirection,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFabVisible = ref.watch(fabVisibilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.shelvesTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
            color: Colors.white,
          ),
        ),
        toolbarHeight: 64,
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          ScrollableSelectionBar<_ShelvesTab>(
            items: [
              SelectionItem(value: _ShelvesTab.shelves, label: context.l10n.shelvesSectionMine, color: colorScheme.primary),
              SelectionItem(value: _ShelvesTab.categories, label: context.l10n.managementCategories, color: Colors.blue),
              SelectionItem(value: _ShelvesTab.imprints, label: context.l10n.managementImprints, color: Colors.deepPurple),
              SelectionItem(value: _ShelvesTab.collections, label: context.l10n.managementCollections, color: Colors.teal),
            ],
            selectedValue: _activeTab,
            onSelected: (tab) => setState(() => _activeTab = tab),
            onSortTap: () => _showSortOptions(context, ref),
          ),
          Expanded(
            child: _TabContent(
              activeTab: _activeTab,
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
      floatingActionButton: AddEntityFab(
        visible: isFabVisible,
        onPressed: _activeTab == _ShelvesTab.shelves ? _showCreateShelfDialog : _showAddEntityDialog,
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final _ShelvesTab activeTab;
  final ScrollController scrollController;
  
  const _TabContent({
    required this.activeTab,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    switch (activeTab) {
      case _ShelvesTab.shelves: return _ShelvesSection(scrollController: scrollController);
      case _ShelvesTab.categories: return _CategoriesCloud(scrollController: scrollController);
      case _ShelvesTab.imprints: return _ImprintsList(scrollController: scrollController);
      case _ShelvesTab.collections: return _CollectionsList(scrollController: scrollController);
    }
  }
}

class _ShelvesSection extends ConsumerWidget {
  final ScrollController scrollController;
  const _ShelvesSection({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelvesAsync = ref.watch(allShelvesWithStatsProvider);
    
    return shelvesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        if (list.isEmpty) return const _EmptyState();

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
              final (shelf, count, progress) = sorted[index];
              return _ModernShelfCard(shelf: shelf, count: count, progress: progress);
            },
          ),
        );
      },
    );
  }
}

class _ShelfSortContainer extends ConsumerWidget {
  final List<(Shelf, int, double)> shelves;
  final List<String> sortOrder;
  final Map<String, bool> sortDirections;
  final Widget Function(List<(Shelf, int, double)>) builder;

  const _ShelfSortContainer({
    required this.shelves,
    required this.sortOrder,
    required this.sortDirections,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = List<(Shelf, int, double)>.from(shelves);
    
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
            comparison = a.$3.compareTo(b.$3);
            break;
        }
        
        if (comparison != 0) return isAsc ? comparison : -comparison;
      }
      return a.$1.id.compareTo(b.$1.id);
    });

    return builder(sorted);
  }
}

class _ModernShelfCard extends ConsumerWidget {
  final Shelf shelf;
  final int count;
  final double progress;
  
  const _ModernShelfCard({
    required this.shelf,
    required this.count,
    required this.progress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final booksAsync = ref.watch(shelfBooksProvider(shelf));
    
    return booksAsync.maybeWhen(
      data: (books) {
        ReadingStatus? activeStatus;
        if (shelf.filterStatus != null) {
          activeStatus = ReadingStatus.values.firstWhere((s) => s.name == shelf.filterStatus);
        }

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ShelfBooksView(shelf: shelf)),
          ),
          onLongPress: () => _showShelfOptions(context, ref, shelf),
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
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      _CoverCollage(books: books),
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
                            child: Text(
                              shelf.name,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (activeStatus != null)
                            StatusChip(status: activeStatus),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildSummaryDisplay(context, ref, books),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                        backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(progress * 100).toInt()}% completado',
                        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline, fontSize: 9),
                      ),
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

  Widget _buildSummaryDisplay(BuildContext context, WidgetRef ref, List<Book> books) {
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

class _CategoriesCloud extends ConsumerWidget {
  final ScrollController scrollController;
  const _CategoriesCloud({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(allTagsWithCountsProvider);

    return tagsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        if (list.isEmpty) return const _EmptyState();
        
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
        
        // Find max count for normalization
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
              return _CategoriesCloudItem(
                tag: tag, 
                count: count,
                maxCount: maxCount,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _CategoriesCloudItem extends ConsumerWidget {
  final Tag tag;
  final int count;
  final int maxCount;
  
  const _CategoriesCloudItem({
    required this.tag, 
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final p = ref.watch(displayPreferencesProvider);
    
    // Logarithmic scaling: X books = 100% of max allowed size (~1.4 max).
    // X is defined by p.tagCloudMaxCount
    final logCount = math.log(count + 1);
    final logRef = math.log(p.tagCloudMaxCount + 1);
    final double logFactor = (logCount / logRef).clamp(0.0, 1.0);
    
    final double scale = 0.85 + (logFactor * 0.55);
    final double fontSize = 10 * scale;
    final double horizontalPadding = 8 * scale;
    final double verticalPadding = 4 * scale;

    final baseColor = tag.color != null 
        ? Color(int.parse('0xFF${tag.color!}')) 
        : colorScheme.secondaryContainer;
        
    final textColor = tag.color != null 
        ? baseColor 
        : colorScheme.onSecondaryContainer;

    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => TagBooksView(tag: tag)),
      ),
      onLongPress: () => _showTagOptions(context, ref, tag),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, 
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4 * scale),
          border: Border.all(
            color: baseColor.withValues(alpha: count > 0 ? 0.4 : 0.1),
            width: 0.5 * scale,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag.name,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: count > (maxCount / 2) ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: fontSize * 0.8,
                  fontWeight: FontWeight.bold,
                  color: textColor.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CoverCollage extends StatelessWidget {
  final List<Book> books;
  const _CoverCollage({required this.books});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const Center(child: Icon(Icons.library_books_outlined, size: 32, color: Colors.white10));
    }

    final hasCovers = books.where((b) => b.coverPath != null).take(4).toList();
    if (hasCovers.isEmpty) {
      return const Center(child: Icon(Icons.library_books_outlined, size: 32, color: Colors.white10));
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        if (index >= hasCovers.length) {
          return Container(color: Colors.black12);
        }
        final path = hasCovers[index].coverPath!;
        if (!File(path).existsSync()) return Container(color: Colors.black12);
        
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(color: Colors.black12),
        );
      },
    );
  }
}

class _ImprintsList extends ConsumerWidget {
  final ScrollController scrollController;
  const _ImprintsList({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imprintsAsync = ref.watch(allImprintsProvider);
    return imprintsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
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
              final imp = sorted[index];
              final bookCountAsync = ref.watch(imprintBookCountProvider(imp.id));
              return Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: SizedBox(
                    width: 50, height: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imp.imagePath != null && File(imp.imagePath!).existsSync()
                          ? Image.file(File(imp.imagePath!), width: 50, height: 50, fit: BoxFit.cover)
                          : Container(
                        width: 50, height: 50,
                        color: imp.color != null ? Color(int.parse('0xFF${imp.color!}')) : Theme.of(context).colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Text(
                          _getInitials(imp.name),
                          style: TextStyle(fontWeight: FontWeight.bold, color: imp.color != null ? Colors.white : Theme.of(context).colorScheme.primary, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  title: Text(imp.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: bookCountAsync.maybeWhen(
                      data: (count) => Text(context.l10n.imprintBookCount(count)),
                      orElse: () => const SizedBox.shrink()
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TagBooksView(tag: imp))),
                  onLongPress: () => _showTagOptions(context, ref, imp),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ImprintSortContainer extends ConsumerWidget {
  final List<Tag> imprints;
  final List<String> sortOrder;
  final Map<String, bool> sortDirections;
  final Widget Function(List<Tag>) builder;

  const _ImprintSortContainer({
    required this.imprints,
    required this.sortOrder,
    required this.sortDirections,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = List<Tag>.from(imprints);
    
    sorted.sort((a, b) {
      for (final criteria in sortOrder) {
        int comparison = 0;
        final isAsc = sortDirections[criteria] ?? true;

        if (criteria == 'name') {
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
        
        if (comparison != 0) return isAsc ? comparison : -comparison;
      }
      return a.id.compareTo(b.id);
    });

    return builder(sorted);
  }
}

class _CollectionsList extends ConsumerWidget {
  final ScrollController scrollController;
  const _CollectionsList({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(allCollectionsProvider);
    return collectionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        final p = ref.watch(displayPreferencesProvider);
        final sorted = List<Tag>.from(list);

        sorted.sort((a, b) {
          for (final criteria in p.collectionSortOrder) {
            int comparison = 0;
            final isAsc = p.collectionSortDirections[criteria] ?? true;

            if (criteria == 'name') {
              comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
            }
            if (comparison != 0) return isAsc ? comparison : -comparison;
          }
          return a.id.compareTo(b.id);
        });

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final col = sorted[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(Icons.collections_bookmark_outlined,
                    color: col.color != null ? Color(int.parse('0xFF${col.color}')) : null),
                title: Text(col.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TagBooksView(tag: col))),
                onLongPress: () => _showTagOptions(context, ref, col),
              ),
            );
          },
        );
      },
    );
  }
}


/// --- Form Component ---

class _ShelfFormSheet extends ConsumerStatefulWidget {
  final Shelf? existing;
  final Future<void> Function(ShelvesCompanion) onSave;
  const _ShelfFormSheet({this.existing, required this.onSave});
  @override
  ConsumerState<_ShelfFormSheet> createState() => _ShelfFormSheetState();
}

class _ShelfFormSheetState extends ConsumerState<_ShelfFormSheet> with SingleTickerProviderStateMixin {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _queryCtrl;
  late final TextEditingController _subtitleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _publisherCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _langCtrl;
  late final TextEditingController _collectionCtrl;
  late final TabController _tabController;
  ReadingStatus? _status;
  List<Tag> _selectedTags = [];
  List<Tag> _selectedImprints = [];
  List<Tag> _selectedCollections = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _queryCtrl = TextEditingController(text: s?.filterQuery ?? '');
    _subtitleCtrl = TextEditingController(text: s?.filterSubtitle ?? '');
    _authorCtrl = TextEditingController(text: s?.filterAuthor ?? '');
    _publisherCtrl = TextEditingController(text: s?.filterPublisher ?? '');
    _isbnCtrl = TextEditingController(text: s?.filterIsbn ?? '');
    _langCtrl = TextEditingController(text: s?.filterLanguage ?? '');
    _collectionCtrl = TextEditingController(text: s?.filterCollection ?? '');
    _tabController = TabController(length: 5, vsync: this);
    
    if (s?.filterStatus != null) {
      _status = ReadingStatus.values.where((r) => r.name == s!.filterStatus).firstOrNull;
    }
    final filterTagIds = s?.filterTagIds;
    if (filterTagIds != null) {
      _loadTags(filterTagIds);
    }
    final filterImprintIds = s?.filterImprintIds;
    if (filterImprintIds != null) {
      _loadImprints(filterImprintIds);
    }
    final filterCollection = s?.filterCollection;
    if (filterCollection != null && filterCollection.isNotEmpty) {
      _loadCollections(filterCollection);
    }
  }

  Future<void> _loadTags(String json) async {
    final ids = (jsonDecode(json) as List).cast<int>();
    final db = ref.read(databaseProvider);
    final allTags = await db.getTagsByType('tag');
    setState(() => _selectedTags = allTags.where((t) => ids.contains(t.id)).toList());
  }

  Future<void> _loadImprints(String json) async {
    final ids = (jsonDecode(json) as List).cast<int>();
    final db = ref.read(databaseProvider);
    final allImprints = await db.getTagsByType('imprint');
    setState(() => _selectedImprints = allImprints.where((t) => ids.contains(t.id)).toList());
  }

  Future<void> _loadCollections(String filterString) async {
    final names = filterString.split(' | ');
    final db = ref.read(databaseProvider);
    final allCols = await db.getTagsByType('collection');
    setState(() => _selectedCollections = allCols.where((c) => names.contains(c.name)).toList());
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _queryCtrl.dispose(); _subtitleCtrl.dispose();
    _authorCtrl.dispose(); _publisherCtrl.dispose(); _isbnCtrl.dispose();
    _langCtrl.dispose(); _collectionCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    final tagIds = _selectedTags.map((t) => t.id).toList();
    final imprintIds = _selectedImprints.map((t) => t.id).toList();
    final collectionNames = _selectedCollections.map((c) => c.name).toList();
    
    final companion = ShelvesCompanion(
      name: Value(_nameCtrl.text.trim()),
      filterQuery: Value(_queryCtrl.text.trim().isEmpty ? null : _queryCtrl.text.trim()),
      filterSubtitle: Value(_subtitleCtrl.text.trim().isEmpty ? null : _subtitleCtrl.text.trim()),
      filterAuthor: Value(_authorCtrl.text.trim().isEmpty ? null : _authorCtrl.text.trim()),
      filterPublisher: Value(_publisherCtrl.text.trim().isEmpty ? null : _publisherCtrl.text.trim()),
      filterIsbn: Value(_isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim()),
      filterLanguage: Value(_langCtrl.text.trim().isEmpty ? null : _langCtrl.text.trim()),
      filterCollection: Value(collectionNames.isEmpty ? null : collectionNames.join(' | ')),
      filterStatus: Value(_status?.name),
      filterTagIds: Value(tagIds.isEmpty ? null : jsonEncode(tagIds)),
      filterImprintIds: Value(imprintIds.isEmpty ? null : jsonEncode(imprintIds)),
    );
    await widget.onSave(companion);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false, initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.5,
      builder: (_, scrollController) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),

            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.existing == null ? context.l10n.shelfFormNew : context.l10n.shelfOptionEdit, 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), 
                    overflow: TextOverflow.visible, 
                    maxLines: 1
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isSaving ? null : _save, 
                  child: _isSaving 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : Text(context.l10n.save)
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            TextField(
              controller: _nameCtrl, 
              autofocus: true, 
              decoration: InputDecoration(
                labelText: context.l10n.shelfFormNameLabel, 
                border: const OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display selected dynamic criteria summary
                    if (_selectedTags.isNotEmpty || _selectedImprints.isNotEmpty || _selectedCollections.isNotEmpty || _status != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 6, runSpacing: 6,
                          children: [
                            if (_status != null)
                              _StatusChipSummary(
                                status: _status!,
                                onDeleted: () => setState(() => _status = null),
                              ),
                            ..._selectedTags.map((t) => TagChip(
                              label: t.name, 
                              colorHex: t.color,
                              onDeleted: () => setState(() => _selectedTags.removeWhere((tag) => tag.id == t.id)),
                            )),
                            ..._selectedImprints.map((i) => TagChip(
                              label: i.name, 
                              colorHex: i.color,
                              onDeleted: () => setState(() => _selectedImprints.removeWhere((imp) => imp.id == i.id)),
                            )),
                            ..._selectedCollections.map((c) => TagChip(
                              label: c.name, 
                              colorHex: c.color,
                              onDeleted: () => setState(() => _selectedCollections.removeWhere((col) => col.name == c.name)),
                            )),
                          ],
                        ),
                      ),
                      
                    const SizedBox(height: 24),
                    
                    // Multi-tab selection panel
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            labelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                            unselectedLabelStyle: textTheme.labelSmall,
                            tabs: [
                              Tab(text: context.l10n.navShelves), // General filters
                              Tab(text: context.l10n.searchTabStatus),
                              Tab(text: context.l10n.searchTabCategory),
                              Tab(text: context.l10n.searchTabCollection),
                              Tab(text: context.l10n.searchTabImprint),
                            ],
                          ),
                          const Divider(height: 1),
                          SizedBox(
                            height: 280,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // General Filters Tab
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      _ShelfFilterField(ctrl: _queryCtrl, hint: context.l10n.fieldTitle),
                                      const SizedBox(height: 12),
                                      _ShelfFilterField(ctrl: _subtitleCtrl, hint: context.l10n.fieldSubtitle),
                                      const SizedBox(height: 12),
                                      _ShelfFilterField(ctrl: _authorCtrl, hint: context.l10n.fieldAuthor),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(child: _ShelfFilterField(ctrl: _publisherCtrl, hint: context.l10n.fieldPublisher)),
                                          const SizedBox(width: 12),
                                          Expanded(child: _ShelfFilterField(ctrl: _langCtrl, hint: context.l10n.fieldLanguage)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Status Tab
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: _StatusFilterRow(
                                    selectedStatus: _status,
                                    onChanged: (s) => setState(() => _status = s),
                                  ),
                                ),
                                // Categories Tab
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SingleChildScrollView(
                                    child: _MultiTagSelector(
                                      selected: _selectedTags,
                                      onChanged: (list) => setState(() => _selectedTags = list),
                                    ),
                                  ),
                                ),
                                // Collections Tab
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SingleChildScrollView(
                                    child: _CollectionSelectGrid(
                                      selected: _selectedCollections,
                                      onChanged: (list) => setState(() => _selectedCollections = list),
                                    ),
                                  ),
                                ),
                                // Imprints Tab
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SingleChildScrollView(
                                    child: _ImprintSelectGrid(
                                      selected: _selectedImprints,
                                      onChanged: (list) => setState(() => _selectedImprints = list),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
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

class _StatusChipSummary extends StatelessWidget {
  final ReadingStatus status;
  final VoidCallback onDeleted;

  const _StatusChipSummary({required this.status, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _statusLabel(context, status).toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDeleted,
            child: Icon(Icons.close, size: 14, color: color.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  String _statusLabel(BuildContext context, ReadingStatus status) {
    switch (status) {
      case ReadingStatus.reading: return context.l10n.statusReading;
      case ReadingStatus.wantToRead: return context.l10n.statusWantToRead;
      case ReadingStatus.read: return context.l10n.statusRead;
      case ReadingStatus.paused: return context.l10n.statusPaused;
      case ReadingStatus.abandoned: return context.l10n.statusAbandoned;
    }
  }

  Color _statusColor(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.wantToRead: return Colors.orange;
      case ReadingStatus.reading: return Colors.blue;
      case ReadingStatus.read: return Colors.green;
      case ReadingStatus.paused: return const Color(0xFFB39DDB);
      case ReadingStatus.abandoned: return Colors.red;
    }
  }
}

class _ShelfFilterField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  const _ShelfFilterField({required this.ctrl, required this.hint});
  @override
  Widget build(BuildContext context) { 
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: ctrl, 
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint, 
        isDense: true, 
        filled: true,
        fillColor: colorScheme.surface.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), 
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      )
    ); 
  }
}

class _StatusFilterRow extends StatelessWidget {
  final ReadingStatus? selectedStatus;
  final ValueChanged<ReadingStatus?> onChanged;

  const _StatusFilterRow({required this.selectedStatus, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      (ReadingStatus.reading, context.l10n.statusReading, Colors.blue),
      (ReadingStatus.wantToRead, context.l10n.statusWantToRead, Colors.orange),
      (ReadingStatus.read, context.l10n.statusRead, Colors.green),
      (ReadingStatus.paused, context.l10n.statusPaused, const Color(0xFFB39DDB)),
      (ReadingStatus.abandoned, context.l10n.statusAbandoned, Colors.red),
    ];

    return Wrap(
      spacing: 6, runSpacing: 6,
      children: options.map((opt) {
        final isSelected = selectedStatus == opt.$1;
        final color = opt.$3;

        return FilterGridBox(
          label: opt.$2,
          isSelected: isSelected,
          color: color,
          onTap: () => onChanged(opt.$1),
        );
      }).toList(),
    );
  }
}

class _MultiTagSelector extends ConsumerWidget {
  final List<Tag> selected;
  final ValueChanged<List<Tag>> onChanged;
  const _MultiTagSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(allTagsProvider);
    
    return tagsAsync.maybeWhen(
      data: (all) => Wrap(
        spacing: 6, runSpacing: 6,
        children: all.map((tag) {
          final isSelected = selected.any((t) => t.id == tag.id);
          final color = tag.color != null ? Color(int.parse('0xFF${tag.color}')) : null;
          
          return FilterGridBox(
            label: tag.name,
            isSelected: isSelected,
            color: color,
            onTap: () {
              final newList = List<Tag>.from(selected);
              if (isSelected) {
                newList.removeWhere((t) => t.id == tag.id);
              } else {
                newList.add(tag);
              }
              onChanged(newList);
            },
            onLongPress: () => _showTagOptions(context, ref, tag),
          );
        }).toList(),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ImprintSelectGrid extends ConsumerWidget {
  final List<Tag> selected;
  final ValueChanged<List<Tag>> onChanged;
  const _ImprintSelectGrid({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imprintsAsync = ref.watch(allImprintsProvider);

    return imprintsAsync.maybeWhen(
      data: (all) => Wrap(
        spacing: 6, runSpacing: 6,
        children: all.map((imp) {
          final isSelected = selected.any((t) => t.id == imp.id);
          final color = imp.color != null ? Color(int.parse('0xFF${imp.color}')) : null;
          
          return FilterGridBox(
            label: imp.name,
            isSelected: isSelected,
            color: color,
            imagePath: imp.imagePath,
            isImprint: true,
            onTap: () {
              final newList = List<Tag>.from(selected);
              if (isSelected) {
                newList.removeWhere((t) => t.id == imp.id);
              } else {
                newList.add(imp);
              }
              onChanged(newList);
            },
            onLongPress: () => _showTagOptions(context, ref, imp),
          );
        }).toList(),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _CollectionSelectGrid extends ConsumerWidget {
  final List<Tag> selected;
  final ValueChanged<List<Tag>> onChanged;
  const _CollectionSelectGrid({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(allCollectionsProvider);

    return collectionsAsync.maybeWhen(
      data: (all) => Wrap(
        spacing: 6, runSpacing: 6,
        children: all.map((col) {
          final isSelected = selected.any((t) => t.id == col.id);
          final color = col.color != null ? Color(int.parse('0xFF${col.color}')) : null;
          
          return FilterGridBox(
            label: col.name,
            isSelected: isSelected,
            color: color,
            onTap: () {
              final newList = List<Tag>.from(selected);
              if (isSelected) {
                newList.removeWhere((t) => t.id == col.id);
              } else {
                newList.add(col);
              }
              onChanged(newList);
            },
            onLongPress: () => _showTagOptions(context, ref, col),
          );
        }).toList(),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}


class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmarks_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(context.l10n.shelfEmpty, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

String _getInitials(String name) {
  if (name.isEmpty) return '?';
  final words = name.trim().split(RegExp(r'\s+'));
  if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
  return words.map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').take(3).join('');
}

void _showTagOptions(BuildContext context, WidgetRef ref, Tag tag) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tag.type != 'imprint')
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
              _showTagFormDialog(context, ref, existing: tag, title: context.l10n.edit, type: tag.type);
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
                builder: (ctx2) => _ShelfFormSheet(
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

void _showTagFormDialog(BuildContext context, WidgetRef ref, {Tag? existing, required String title, required String type}) {
  final ctrl = TextEditingController(text: existing?.name ?? '');
  String? selectedColor = existing?.color;
  String? imagePath = existing?.imagePath;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        final colors = ['E53935', 'D81B60', '8E24AA', '3949AB', '1E88E5', '00ACC1', '00897B', '43A047', 'C0CA33', 'FB8C00', '6D4C41', '757575'];
        String hint = context.l10n.tagNameLabel;

        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (type == 'imprint') ...[
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (!await PermissionService.requestGallery()) return;
                            if (!context.mounted) return;
                            final l10n = context.l10n;
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(source: ImageSource.gallery);
                            if (picked == null) return;
                            final cropped = await CoverService.cropImprint(
                              picked.path, 
                              title: l10n.cropImprintTitle,
                              doneButtonTitle: l10n.done,
                              cancelButtonTitle: l10n.cancel,
                            );
                            if (cropped == null) return;
                            final saved = await CoverService.saveImprintImage(cropped);
                            setState(() => imagePath = saved);
                          },
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                            child: imagePath != null && imagePath!.isNotEmpty
                                ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(imagePath!), fit: BoxFit.cover))
                                : Center(child: Icon(Icons.business_outlined, size: 32, color: Theme.of(context).colorScheme.outline)),
                          ),
                        ),
                        if (imagePath != null)
                          Positioned(top: 0, right: 0, child: GestureDetector(onTap: () => setState(() => imagePath = null), child: Container(decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), padding: const EdgeInsets.all(2), child: const Icon(Icons.close, size: 14, color: Colors.white)))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.camera_alt_outlined, size: 16),
                        label: Text(context.l10n.photo),
                        onPressed: () async {
                          if (!await PermissionService.requestCamera()) return;
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(source: ImageSource.camera);
                          if (picked == null) return;
                          if (!context.mounted) return;
                          final l10n = context.l10n;
                          final cropped = await CoverService.cropImprint(
                            picked.path, 
                            title: l10n.cropImprintTitle,
                            doneButtonTitle: l10n.done,
                            cancelButtonTitle: l10n.cancel,
                          );
                          if (cropped == null) return;
                          final saved = await CoverService.saveImprintImage(cropped);
                          setState(() => imagePath = saved);
                        },
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        icon: const Icon(Icons.link, size: 16),
                        label: Text(context.l10n.url),
                        onPressed: () async {
                          final urlCtrl = TextEditingController();
                          final url = await showDialog<String>(
                            context: context,
                            builder: (urlCtx) => AlertDialog(
                              title: Text(context.l10n.imprintUrlDialogTitle),
                              content: TextField(controller: urlCtrl, autofocus: true, keyboardType: TextInputType.url, decoration: InputDecoration(hintText: context.l10n.imprintUrlHint, border: const OutlineInputBorder())),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(urlCtx), child: Text(context.l10n.cancel)),
                                FilledButton(onPressed: () => Navigator.pop(urlCtx, urlCtrl.text.trim()), child: Text(context.l10n.download)),
                              ],
                            ),
                          );
                          if (url == null || url.isEmpty) return;
                          if (!context.mounted) return;
                          final l10n = context.l10n;
                          final saved = await CoverService.saveImprintFromUrl(
                            url, 
                            cropTitle: l10n.cropImprintTitle,
                            doneButtonTitle: l10n.done,
                            cancelButtonTitle: l10n.cancel,
                          );
                          if (saved != null) setState(() => imagePath = saved);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: ctrl, 
                  autofocus: true, 
                  decoration: InputDecoration(hintText: hint)
                ),
                if (type == 'tag') ...[
                  const SizedBox(height: 20),
                  Text(context.l10n.tagColorLabel, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: colors.map((hex) {
                      final color = Color(int.parse('0xFF$hex'));
                      final isSelected = selectedColor == hex;
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = isSelected ? null : hex),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: color, 
                            shape: BoxShape.circle, 
                            border: isSelected ? Border.all(color: Colors.white, width: 2) : null
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.cancel)),
            TextButton(
              onPressed: () async {
                if (ctrl.text.trim().isNotEmpty) {
                  if (existing == null) {
                    await ref.read(databaseProvider).insertTag(TagsCompanion(
                      name: Value(ctrl.text.trim()), 
                      type: Value(type),
                      color: Value(selectedColor),
                      imagePath: Value(imagePath),
                    ));
                  } else {
                    final updated = existing.copyWith(
                      name: ctrl.text.trim(),
                      color: Value(selectedColor),
                      imagePath: Value(imagePath),
                    );
                    await ref.read(databaseProvider).updateTag(updated);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              }, 
              child: Text(context.l10n.save)
            ),
          ],
        );
      },
    ),
  );
}

void _showColorPicker(BuildContext context, WidgetRef ref, Tag tag) async {
  final colors = ['E53935', 'D81B60', '8E24AA', '3949AB', '1E88E5', '00ACC1', '00897B', '43A047', 'C0CA33', 'FB8C00', '6D4C41', '757575'];
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
          Wrap(
            spacing: 12, runSpacing: 12,
            children: colors.map((hex) {
              final color = Color(int.parse('0xFF$hex'));
              final isSelected = tag.color == hex;
              return GestureDetector(
                onTap: () async {
                  final updated = tag.copyWith(color: Value(hex));
                  await ref.read(databaseProvider).updateTag(updated);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: isSelected ? Border.all(color: Colors.white, width: 3) : null),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}
