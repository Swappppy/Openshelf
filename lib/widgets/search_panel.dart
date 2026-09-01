import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/books_controller.dart';
import '../controllers/search_filters_controller.dart';
import '../models/search_filters.dart';
import '../services/database.dart';
import '../l10n/l10n_extension.dart';
import 'entity_selector_grid.dart';
import 'search_filters_components.dart';

class SearchPanel extends ConsumerStatefulWidget {
  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;
  final VoidCallback? onSaveAsShelf;

  const SearchPanel({super.key, required this.filters, required this.onChanged, this.onSaveAsShelf});

  @override
  ConsumerState<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends ConsumerState<SearchPanel> with SingleTickerProviderStateMixin {
  late final TextEditingController _queryCtrl;
  late final TextEditingController _subtitleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _publisherCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _langCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _titleCtrl;
  late final TabController _tabController;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController(text: widget.filters.query);
    _subtitleCtrl = TextEditingController(text: widget.filters.subtitle);
    _authorCtrl = TextEditingController(text: widget.filters.author);
    _publisherCtrl = TextEditingController(text: widget.filters.publisher);
    _isbnCtrl = TextEditingController(text: widget.filters.isbn);
    _langCtrl = TextEditingController(text: widget.filters.language);
    _notesCtrl = TextEditingController(text: widget.filters.notes);
    _titleCtrl = TextEditingController(text: widget.filters.query);
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _subtitleCtrl.dispose();
    _authorCtrl.dispose();
    _publisherCtrl.dispose();
    _isbnCtrl.dispose();
    _langCtrl.dispose();
    _notesCtrl.dispose();
    _titleCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updateQuery(String val) {
    widget.onChanged(widget.filters.copyWith(query: val));
  }

  void _handleModeTap(SearchMode mode) {
    if (widget.filters.mode == mode) {
      if (mode != SearchMode.basic) {
        setState(() => _isExpanded = !_isExpanded);
      }
    } else {
      setState(() => _isExpanded = true);
      ref.read(searchFiltersProvider.notifier).setMode(mode);
    }
  }

  String _formatLabel(BuildContext context, BookFormat format) {
    switch (format) {
      case BookFormat.paperback: return context.l10n.formatPaperback;
      case BookFormat.hardcover: return context.l10n.formatHardcover;
      case BookFormat.rustic: return context.l10n.formatRustic;
      case BookFormat.digital: return context.l10n.formatDigital;
      case BookFormat.leatherbound: return context.l10n.formatLeatherbound;
      case BookFormat.other: return context.l10n.formatOther;
    }
  }

  String _ownershipLabel(BuildContext context, OwnershipStatus status) {
    switch (status) {
      case OwnershipStatus.bought: return context.l10n.ownershipStatusBought;
      case OwnershipStatus.gifted: return context.l10n.ownershipStatusGifted;
      case OwnershipStatus.borrowed: return context.l10n.ownershipStatusBorrowed;
      case OwnershipStatus.returned: return context.l10n.ownershipStatusReturned;
      case OwnershipStatus.sold: return context.l10n.ownershipStatusSold;
      case OwnershipStatus.other: return context.l10n.ownershipStatusOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TapRegion(
      onTapOutside: (_) {
        if (widget.filters.mode != SearchMode.basic) {
          setState(() => _isExpanded = false);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode Switcher - 3 Stages
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Row(
                children: [
                  _ModeButton(
                    label: context.l10n.searchModeBasic,
                    isActive: widget.filters.mode == SearchMode.basic,
                    onTap: () => _handleModeTap(SearchMode.basic),
                  ),
                  const SizedBox(width: 4),
                  _ModeButton(
                    label: context.l10n.searchModeAdvanced,
                    isActive: widget.filters.mode == SearchMode.advanced,
                    onTap: () => _handleModeTap(SearchMode.advanced),
                  ),
                  const SizedBox(width: 4),
                  _ModeButton(
                    label: context.l10n.searchModeBoolean,
                    isActive: widget.filters.mode == SearchMode.boolean,
                    onTap: () => _handleModeTap(SearchMode.boolean),
                  ),
                ],
              ),
            ),

            if (widget.filters.mode == SearchMode.basic) ...[
              // Search Bar (Stage 1)
              SizedBox(
                height: 40,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _queryCtrl,
                        onChanged: _updateQuery,
                        textAlignVertical: TextAlignVertical.center,
                        style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: context.l10n.bookSearchHint,
                          hintStyle: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.38)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Chips (Stage 2 mostly, but can show in 1 if filters active)
              if (widget.filters.tags.isNotEmpty || widget.filters.status != null || widget.filters.imprints.isNotEmpty || widget.filters.collections.isNotEmpty || widget.filters.author.isNotEmpty || widget.filters.publisher.isNotEmpty || widget.filters.isbn.isNotEmpty || widget.filters.language.isNotEmpty || widget.filters.format != null || widget.filters.ownership != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
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
                      if (widget.filters.format != null)
                        _FilterChip(
                          label: _formatLabel(context, widget.filters.format!),
                          onDelete: () => widget.onChanged(widget.filters.copyWith(clearFormat: true)),
                        ),
                      if (widget.filters.ownership != null)
                        _FilterChip(
                          label: _ownershipLabel(context, widget.filters.ownership!),
                          onDelete: () => widget.onChanged(widget.filters.copyWith(clearOwnership: true)),
                        ),
                      if (widget.filters.author.isNotEmpty)
                        _FilterChip(
                          label: context.l10n.searchFilterAuthorLabel(widget.filters.author),
                          onDelete: () {
                            _authorCtrl.clear();
                            widget.onChanged(widget.filters.copyWith(author: ''));
                          },
                        ),
                      if (widget.filters.subtitle.isNotEmpty)
                        _FilterChip(
                          label: context.l10n.searchFilterSubtitleLabel(widget.filters.subtitle),
                          onDelete: () {
                            _subtitleCtrl.clear();
                            widget.onChanged(widget.filters.copyWith(subtitle: ''));
                          },
                        ),
                      if (widget.filters.publisher.isNotEmpty)
                        _FilterChip(
                          label: context.l10n.searchFilterPublisherLabel(widget.filters.publisher),
                          onDelete: () {
                            _publisherCtrl.clear();
                            widget.onChanged(widget.filters.copyWith(publisher: ''));
                          },
                        ),
                      if (widget.filters.isbn.isNotEmpty)
                        _FilterChip(
                          label: context.l10n.searchFilterIsbnLabel(widget.filters.isbn),
                          onDelete: () {
                            _isbnCtrl.clear();
                            widget.onChanged(widget.filters.copyWith(isbn: ''));
                          },
                        ),
                      if (widget.filters.language.isNotEmpty)
                        _FilterChip(
                          label: context.l10n.searchFilterLanguageLabel(widget.filters.language),
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
            ],

            // Tabs (Advanced mode only)
            if (widget.filters.mode == SearchMode.advanced && _isExpanded) ...[
              Divider(height: 1, color: colorScheme.onSurface.withValues(alpha: 0.1)),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                unselectedLabelStyle: textTheme.labelSmall,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.38),
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
                  constraints: const BoxConstraints(maxHeight: 260), 
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            FilterTextField(
                              controller: _titleCtrl,
                              hint: context.l10n.fieldTitle,
                              onChanged: (v) => widget.onChanged(widget.filters.copyWith(query: v)),
                            ),
                            const SizedBox(height: 8),
                            FilterTextField(
                              controller: _authorCtrl,
                              hint: context.l10n.fieldAuthor,
                              onChanged: (v) => widget.onChanged(widget.filters.copyWith(author: v)),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: FilterTextField(
                                    controller: _publisherCtrl,
                                    hint: context.l10n.fieldPublisher,
                                    onChanged: (v) => widget.onChanged(widget.filters.copyWith(publisher: v)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilterTextField(
                                    controller: _notesCtrl,
                                    hint: context.l10n.searchFieldNotes,
                                    onChanged: (v) => widget.onChanged(widget.filters.copyWith(notes: v)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: FilterTextField(
                                    controller: _isbnCtrl,
                                    hint: context.l10n.fieldIsbn,
                                    onChanged: (v) => widget.onChanged(widget.filters.copyWith(isbn: v)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilterTextField(
                                    controller: _langCtrl,
                                    hint: context.l10n.fieldLanguage,
                                    onChanged: (v) => widget.onChanged(widget.filters.copyWith(language: v)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: FilterDateSelector(
                                    label: context.l10n.bookDetailFieldStarted,
                                    value: widget.filters.startedAt,
                                    operator: widget.filters.startedAtOp,
                                    onChanged: (d) => widget.onChanged(widget.filters.copyWith(startedAt: d, clearStartedAt: d == null)),
                                    onOpChanged: (op) => widget.onChanged(widget.filters.copyWith(startedAtOp: op)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilterDateSelector(
                                    label: context.l10n.bookDetailFieldFinished,
                                    value: widget.filters.finishedAt,
                                    operator: widget.filters.finishedAtOp,
                                    onChanged: (d) => widget.onChanged(widget.filters.copyWith(finishedAt: d, clearFinishedAt: d == null)),
                                    onOpChanged: (op) => widget.onChanged(widget.filters.copyWith(finishedAtOp: op)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      StatusFiltersTab(
                        status: widget.filters.status,
                        format: widget.filters.format,
                        ownership: widget.filters.ownership,
                        onStatusChanged: (s, clear) => widget.onChanged(widget.filters.copyWith(status: s, clearStatus: clear)),
                        onFormatChanged: (f, clear) => widget.onChanged(widget.filters.copyWith(format: f, clearFormat: clear)),
                        onOwnershipChanged: (o, clear) => widget.onChanged(widget.filters.copyWith(ownership: o, clearOwnership: clear)),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: EntitySelectorGrid(
                          selected: widget.filters.imprints,
                          onChanged: (list) => widget.onChanged(widget.filters.copyWith(imprints: list)),
                          provider: allImprintsProvider,
                          type: TagType.imprint,
                          isImprint: true,
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: EntitySelectorGrid(
                          selected: widget.filters.tags,
                          onChanged: (list) => widget.onChanged(widget.filters.copyWith(tags: list)),
                          provider: allTagsProvider,
                          type: TagType.tag,
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: EntitySelectorGrid(
                          selected: widget.filters.collections,
                          onChanged: (list) => widget.onChanged(widget.filters.copyWith(collections: list)),
                          provider: allCollectionsProvider,
                          type: TagType.collection,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (widget.filters.mode == SearchMode.boolean && _isExpanded)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: BooleanQueryPanel(
                  query: widget.filters.booleanQuery,
                  onChanged: (bq) => ref.read(searchFiltersProvider.notifier).setBooleanQuery(bq),
                ),
              ),
            
            if (_activeFiltersCount() > 0 || (widget.filters.mode == SearchMode.boolean && widget.filters.booleanQuery.conditions.isNotEmpty))
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.filters.mode == SearchMode.boolean 
                          ? context.l10n.searchActiveFilters(widget.filters.booleanQuery.conditions.length)
                          : context.l10n.searchActiveFilters(_activeFiltersCount()),
                        style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 10),
                      ),
                    ),
                    if (widget.onSaveAsShelf != null)
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: TextButton(
                            onPressed: widget.onSaveAsShelf,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              minimumSize: const Size(50, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(context.l10n.searchSaveAsShelf, style: const TextStyle(fontSize: 11)),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _authorCtrl.clear();
                            _publisherCtrl.clear();
                            _isbnCtrl.clear();
                            _langCtrl.clear();
                            _notesCtrl.clear();
                            _titleCtrl.clear();
                            ref.read(searchFiltersProvider.notifier).clearAll();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero, 
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(context.l10n.searchClearAll, style: const TextStyle(fontSize: 11, color: Colors.redAccent)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _activeFiltersCount() {
    int count = 0;
    if (widget.filters.status != null) count++;
    if (widget.filters.format != null) count++;
    if (widget.filters.ownership != null) count++;
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

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeButton({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isActive ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
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
