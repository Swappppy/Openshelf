import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/books_controller.dart';
import '../services/database.dart';
import '../l10n/l10n_extension.dart';
import 'filter_grid_box.dart';

class SearchPanel extends ConsumerStatefulWidget {
  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;

  const SearchPanel({super.key, required this.filters, required this.onChanged});

  @override
  ConsumerState<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends ConsumerState<SearchPanel> with SingleTickerProviderStateMixin {
  late final TextEditingController _queryCtrl;
  late final TabController _tabController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController(text: widget.filters.query);
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updateQuery(String val) {
    widget.onChanged(widget.filters.copyWith(query: val));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 36,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _queryCtrl,
                    onChanged: _updateQuery,
                    textAlignVertical: TextAlignVertical.center,
                    style: textTheme.bodySmall?.copyWith(color: Colors.white, fontSize: 11),
                    decoration: InputDecoration(
                      hintText: context.l10n.bookSearchHint,
                      hintStyle: textTheme.bodySmall?.copyWith(color: Colors.white38, fontSize: 11),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
                    child: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (widget.filters.tags.isNotEmpty || widget.filters.status != null || widget.filters.imprints.isNotEmpty || widget.filters.collections.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.start,
                children: [
                  if (widget.filters.status != null)
                    _FilterChip(
                      label: context.l10n.searchFilterStatus(_statusLabel(context, widget.filters.status!.name)),
                      color: _statusColor(widget.filters.status!),
                      onDelete: () => widget.onChanged(widget.filters.copyWith(clearStatus: true)),
                    ),
                  ...widget.filters.imprints.map((imp) => _FilterChip(
                    label: context.l10n.searchFilterImprint(imp.name),
                    onDelete: () {
                      final newImprints = List<Tag>.from(widget.filters.imprints)..remove(imp);
                      widget.onChanged(widget.filters.copyWith(imprints: newImprints));
                    },
                  )),
                  ...widget.filters.collections.map((col) => _FilterChip(
                    label: context.l10n.searchFilterCollection(col.name),
                    onDelete: () {
                      final newCols = List<Tag>.from(widget.filters.collections)..remove(col);
                      widget.onChanged(widget.filters.copyWith(collections: newCols));
                    },
                  )),
                  ...widget.filters.tags.map((tag) => _FilterChip(
                    label: context.l10n.searchFilterCategory(tag.name),
                    color: tag.color != null ? Color(int.parse('0xFF${tag.color!}')) : null,
                    onDelete: () {
                      final newTags = List<Tag>.from(widget.filters.tags)..remove(tag);
                      widget.onChanged(widget.filters.copyWith(tags: newTags));
                    },
                  )),
                ],
              ),
            ),

          if (_isExpanded) ...[
            const Divider(height: 1, color: Colors.white10),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              unselectedLabelStyle: textTheme.labelSmall,
              labelColor: colorScheme.primary,
              unselectedLabelColor: Colors.white38,
              indicatorColor: colorScheme.primary,
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tabs: [
                Tab(text: context.l10n.searchTabStatus),
                Tab(text: context.l10n.searchTabImprint),
                Tab(text: context.l10n.searchTabCategory),
                Tab(text: context.l10n.searchTabCollection),
              ],
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _StatusFiltersTab(filters: widget.filters, onChanged: widget.onChanged),
                    _ImprintFiltersTab(filters: widget.filters, onChanged: widget.onChanged),
                    _TagFiltersTab(filters: widget.filters, onChanged: widget.onChanged),
                    _CollectionFiltersTab(filters: widget.filters, onChanged: widget.onChanged),
                  ],
                ),
              ),
            ),
          ],
          
          if (_activeFiltersCount() > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: Row(
                children: [
                  Text(
                    context.l10n.searchActiveFilters(_activeFiltersCount()),
                    style: textTheme.labelSmall?.copyWith(color: Colors.white24, fontSize: 10),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => widget.onChanged(const SearchFilters()),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, 
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(context.l10n.searchClearAll, style: const TextStyle(fontSize: 11, color: Colors.redAccent)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  int _activeFiltersCount() {
    int count = 0;
    if (widget.filters.status != null) count++;
    count += widget.filters.imprints.length;
    count += widget.filters.tags.length;
    count += widget.filters.collections.length;
    return count;
  }

  String _statusLabel(BuildContext context, String status) {
    switch (status) {
      case 'reading': return context.l10n.shelfStatusLabelReading;
      case 'read': return context.l10n.shelfStatusLabelRead;
      case 'wantToRead': return context.l10n.shelfStatusLabelWantToRead;
      case 'abandoned': return context.l10n.shelfStatusLabelAbandoned;
      case 'paused': return context.l10n.shelfStatusLabelPaused;
      default: return status;
    }
  }

  Color _statusColor(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.wantToRead: return Colors.orange;
      case ReadingStatus.reading: return Colors.blue;
      case ReadingStatus.read: return Colors.green;
      case ReadingStatus.abandoned: return Colors.red;
      case ReadingStatus.paused: return const Color(0xFFB39DDB);
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;
  final Color? color;

  const _FilterChip({required this.label, required this.onDelete, this.color});

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Colors.white70;
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: baseColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: baseColor.withValues(alpha: 0.9))),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
              child: Icon(Icons.close, size: 16, color: baseColor.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFiltersTab extends StatelessWidget {
  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;

  const _StatusFiltersTab({required this.filters, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      (ReadingStatus.reading, context.l10n.statusReading, Colors.blue),
      (ReadingStatus.wantToRead, context.l10n.statusWantToRead, Colors.orange),
      (ReadingStatus.read, context.l10n.statusRead, Colors.green),
      (ReadingStatus.paused, context.l10n.statusPaused, const Color(0xFFB39DDB)),
      (ReadingStatus.abandoned, context.l10n.statusAbandoned, Colors.red),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: options.map((opt) {
          final isSelected = filters.status == opt.$1;
          return FilterGridBox(
            label: opt.$2,
            isSelected: isSelected,
            color: opt.$3,
            onTap: () => onChanged(filters.copyWith(status: opt.$1, clearStatus: isSelected)),
          );
        }).toList(),
      ),
    );
  }
}

class _ImprintFiltersTab extends ConsumerWidget {
  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;

  const _ImprintFiltersTab({required this.filters, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imprintsAsync = ref.watch(allImprintsProvider);
    return imprintsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (list) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: list.map((imp) {
            final isSelected = filters.imprints.any((i) => i.id == imp.id);
            return FilterGridBox(
              label: imp.name,
              isSelected: isSelected,
              imagePath: imp.imagePath,
              isImprint: true,
              onTap: () {
                final newImprints = List<Tag>.from(filters.imprints);
                if (isSelected) {
                  newImprints.removeWhere((i) => i.id == imp.id);
                } else {
                  newImprints.add(imp);
                }
                onChanged(filters.copyWith(imprints: newImprints));
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CollectionFiltersTab extends ConsumerWidget {
  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;

  const _CollectionFiltersTab({required this.filters, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(allCollectionsProvider);
    return collectionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (list) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: list.map((col) {
            final isSelected = filters.collections.any((c) => c.id == col.id);
            return FilterGridBox(
              label: col.name,
              isSelected: isSelected,
              onTap: () {
                final newCollections = List<Tag>.from(filters.collections);
                if (isSelected) {
                  newCollections.removeWhere((c) => c.id == col.id);
                } else {
                  newCollections.add(col);
                }
                onChanged(filters.copyWith(collections: newCollections));
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TagFiltersTab extends ConsumerWidget {
  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;

  const _TagFiltersTab({required this.filters, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(allTagsProvider);
    return tagsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (list) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: list.map((tag) {
            final isSelected = filters.tags.any((t) => t.id == tag.id);
            final color = tag.color != null ? Color(int.parse('0xFF${tag.color!}')) : null;
            return FilterGridBox(
              label: tag.name,
              isSelected: isSelected,
              color: color,
              onTap: () {
                final newTags = List<Tag>.from(filters.tags);
                if (isSelected) {
                  newTags.removeWhere((t) => t.id == tag.id);
                } else {
                  newTags.add(tag);
                }
                onChanged(filters.copyWith(tags: newTags));
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
