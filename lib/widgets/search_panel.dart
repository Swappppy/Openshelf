import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/books_controller.dart';
import '../models/search_filters.dart';
import '../services/database.dart';
import '../l10n/l10n_extension.dart';
import 'entity_selector_grid.dart';
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
  late final TextEditingController _authorCtrl;
  late final TextEditingController _publisherCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _langCtrl;
  late final TabController _tabController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController(text: widget.filters.query);
    _authorCtrl = TextEditingController(text: widget.filters.author);
    _publisherCtrl = TextEditingController(text: widget.filters.publisher);
    _isbnCtrl = TextEditingController(text: widget.filters.isbn);
    _langCtrl = TextEditingController(text: widget.filters.language);
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _authorCtrl.dispose();
    _publisherCtrl.dispose();
    _isbnCtrl.dispose();
    _langCtrl.dispose();
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
        color: colorScheme.primary.withValues(alpha: 0.1),
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
          
          if (widget.filters.tags.isNotEmpty || widget.filters.status != null || widget.filters.imprints.isNotEmpty || widget.filters.collections.isNotEmpty || widget.filters.author.isNotEmpty || widget.filters.publisher.isNotEmpty || widget.filters.isbn.isNotEmpty || widget.filters.language.isNotEmpty)
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
                  if (widget.filters.author.isNotEmpty)
                    _FilterChip(
                      label: '${context.l10n.fieldAuthor}: ${widget.filters.author}',
                      onDelete: () {
                        _authorCtrl.clear();
                        widget.onChanged(widget.filters.copyWith(author: ''));
                      },
                    ),
                  if (widget.filters.publisher.isNotEmpty)
                    _FilterChip(
                      label: '${context.l10n.fieldPublisher}: ${widget.filters.publisher}',
                      onDelete: () {
                        _publisherCtrl.clear();
                        widget.onChanged(widget.filters.copyWith(publisher: ''));
                      },
                    ),
                  if (widget.filters.isbn.isNotEmpty)
                    _FilterChip(
                      label: 'ISBN: ${widget.filters.isbn}',
                      onDelete: () {
                        _isbnCtrl.clear();
                        widget.onChanged(widget.filters.copyWith(isbn: ''));
                      },
                    ),
                  if (widget.filters.language.isNotEmpty)
                    _FilterChip(
                      label: '${context.l10n.fieldLanguage}: ${widget.filters.language}',
                      onDelete: () {
                        _langCtrl.clear();
                        widget.onChanged(widget.filters.copyWith(language: ''));
                      },
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
                Tab(text: context.l10n.tabMain),
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
                constraints: const BoxConstraints(maxHeight: 180),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _SearchFilterField(
                            controller: _authorCtrl,
                            hint: context.l10n.fieldAuthor,
                            onChanged: (v) => widget.onChanged(widget.filters.copyWith(author: v)),
                          ),
                          const SizedBox(height: 8),
                          _SearchFilterField(
                            controller: _publisherCtrl,
                            hint: context.l10n.fieldPublisher,
                            onChanged: (v) => widget.onChanged(widget.filters.copyWith(publisher: v)),
                          ),
                          const SizedBox(height: 8),
                          _SearchFilterField(
                            controller: _isbnCtrl,
                            hint: context.l10n.fieldIsbn,
                            onChanged: (v) => widget.onChanged(widget.filters.copyWith(isbn: v)),
                          ),
                          const SizedBox(height: 8),
                          _SearchFilterField(
                            controller: _langCtrl,
                            hint: context.l10n.fieldLanguage,
                            onChanged: (v) => widget.onChanged(widget.filters.copyWith(language: v)),
                          ),
                        ],
                      ),
                    ),
                    _StatusFiltersTab(filters: widget.filters, onChanged: widget.onChanged),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(8),
                      child: EntitySelectorGrid(
                        selected: widget.filters.imprints,
                        onChanged: (list) => widget.onChanged(widget.filters.copyWith(imprints: list)),
                        provider: allImprintsProvider,
                        type: 'imprint',
                        isImprint: true,
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(8),
                      child: EntitySelectorGrid(
                        selected: widget.filters.tags,
                        onChanged: (list) => widget.onChanged(widget.filters.copyWith(tags: list)),
                        provider: allTagsProvider,
                        type: 'tag',
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(8),
                      child: EntitySelectorGrid(
                        selected: widget.filters.collections,
                        onChanged: (list) => widget.onChanged(widget.filters.copyWith(collections: list)),
                        provider: allCollectionsProvider,
                        type: 'collection',
                      ),
                    ),
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
                    onPressed: () {
                      _authorCtrl.clear();
                      _publisherCtrl.clear();
                      _isbnCtrl.clear();
                      _langCtrl.clear();
                      widget.onChanged(const SearchFilters());
                    },
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

class _SearchFilterField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchFilterField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 12, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Colors.white38),
        isDense: true,
        filled: true,
        fillColor: colorScheme.primary.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;
  final Color? color;

  const _FilterChip({required this.label, required this.onDelete, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = color ?? colorScheme.primary;
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
        children: options.map<Widget>((opt) {
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
