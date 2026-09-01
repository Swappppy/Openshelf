import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../models/shelf.dart';
import '../models/search_filters.dart';
import '../services/database.dart';
import '../controllers/books_controller.dart';
import '../controllers/database_provider.dart';
import '../controllers/search_filters_controller.dart';
import '../controllers/library_navigation_controller.dart';
import '../l10n/l10n_extension.dart';
import 'tag_chip.dart';
import 'entity_selector_grid.dart';
import 'search_filters_components.dart';

class ShelfFormSheet extends ConsumerStatefulWidget {
  final Shelf? existing;
  final SearchFilters? initialFilters;
  final Future<int?> Function(ShelvesCompanion, List<int>) onSave;
  
  const ShelfFormSheet({super.key, this.existing, this.initialFilters, required this.onSave});
  
  @override
  ConsumerState<ShelfFormSheet> createState() => _ShelfFormSheetState();
}

class _ShelfFormSheetState extends ConsumerState<ShelfFormSheet> with SingleTickerProviderStateMixin {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _queryCtrl;
  late final TextEditingController _subtitleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _publisherCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _langCtrl;
  late final TextEditingController _notesCtrl;
  late final TabController _tabController;
  ReadingStatus? _status;
  List<Tag> _selectedTags = [];
  List<Tag> _selectedImprints = [];
  List<Tag> _selectedCollections = [];
  BooleanQuery? _booleanQuery;
  SearchMode _searchMode = SearchMode.basic;
  BookFormat? _format;
  OwnershipStatus? _ownership;
  DateTime? _startedAt;
  BooleanOperator _startedAtOp = BooleanOperator.equals;
  DateTime? _finishedAt;
  BooleanOperator _finishedAtOp = BooleanOperator.equals;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    final f = widget.initialFilters;

    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _queryCtrl = TextEditingController(text: s?.filterQuery ?? f?.query ?? '');
    _subtitleCtrl = TextEditingController(text: s?.filterSubtitle ?? '');
    _authorCtrl = TextEditingController(text: s?.filterAuthor ?? f?.author ?? '');
    _publisherCtrl = TextEditingController(text: s?.filterPublisher ?? f?.publisher ?? '');
    _isbnCtrl = TextEditingController(text: s?.filterIsbn ?? f?.isbn ?? '');
    _langCtrl = TextEditingController(text: s?.filterLanguage ?? f?.language ?? '');
    _notesCtrl = TextEditingController(text: s?.filterNotes ?? f?.notes ?? '');
    _tabController = TabController(length: 5, vsync: this);
    
    if (s?.filterStatus != null) {
      _status = ReadingStatus.values.where((r) => r.name == s!.filterStatus).firstOrNull;
    } else if (f?.status != null) {
      _status = f!.status;
    }

    if (s?.filterFormat != null) {
      _format = BookFormat.values.where((r) => r.name == s!.filterFormat).firstOrNull;
    } else if (f?.format != null) {
      _format = f!.format;
    }

    if (s?.filterOwnership != null) {
      _ownership = OwnershipStatus.values.where((r) => r.name == s!.filterOwnership).firstOrNull;
    } else if (f?.ownership != null) {
      _ownership = f!.ownership;
    }

    if (s != null) {
      _searchMode = SearchMode.values[s.filterSearchMode];
      if (s.filterBooleanQuery != null) {
        try {
          _booleanQuery = BooleanQuery.fromJson(jsonDecode(s.filterBooleanQuery!));
        } catch (_) {}
      }
      _loadSelectedEntities(s.id);
    } else if (f != null) {
      _searchMode = f.mode;
      _booleanQuery = f.booleanQuery;
      _startedAt = f.startedAt;
      _startedAtOp = f.startedAtOp;
      _finishedAt = f.finishedAt;
      _finishedAtOp = f.finishedAtOp;
      if (f.tags.isNotEmpty) _selectedTags = List.from(f.tags);
      if (f.imprints.isNotEmpty) _selectedImprints = List.from(f.imprints);
      if (f.collections.isNotEmpty) _selectedCollections = List.from(f.collections);
    }
  }

  void _showInLibrary() {
    final filters = SearchFilters(
      query: _queryCtrl.text.trim(),
      author: _authorCtrl.text.trim(),
      publisher: _publisherCtrl.text.trim(),
      isbn: _isbnCtrl.text.trim(),
      language: _langCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      status: _status,
      format: _format,
      ownership: _ownership,
      startedAt: _startedAt,
      startedAtOp: _startedAtOp,
      finishedAt: _finishedAt,
      finishedAtOp: _finishedAtOp,
      tags: _selectedTags,
      imprints: _selectedImprints,
      collections: _selectedCollections,
      mode: _searchMode,
      booleanQuery: _booleanQuery ?? const BooleanQuery(),
    );

    ref.read(searchFiltersProvider.notifier).setFilters(filters);
    ref.read(libraryNavigationProvider.notifier).setIndex(0);
    Navigator.pop(context);
  }

  Future<void> _loadSelectedEntities(int shelfId) async {
    final db = ref.read(databaseProvider);
    final tagIds = await db.shelfDao.getTagIdsForShelf(shelfId);
    if (tagIds.isEmpty) return;

    final allEntities = await db.tagDao.getTagsByIds(tagIds);

    if (mounted) {
      setState(() {
        _selectedTags =
            allEntities.where((t) => t.type == TagType.tag).toList();
        _selectedImprints =
            allEntities.where((t) => t.type == TagType.imprint).toList();
        _selectedCollections =
            allEntities.where((t) => t.type == TagType.collection).toList();
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _queryCtrl.dispose(); _subtitleCtrl.dispose();
    _authorCtrl.dispose(); _publisherCtrl.dispose(); _isbnCtrl.dispose();
    _langCtrl.dispose(); _notesCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    
    try {
      final tagIds = _selectedTags.map((t) => t.id).toList();
      final imprintIds = _selectedImprints.map((t) => t.id).toList();
      final collectionIds = _selectedCollections.map((c) => c.id).toList();
      
      final companion = ShelvesCompanion(
        name: Value(_nameCtrl.text.trim()),
        filterQuery: Value(_queryCtrl.text.trim().isEmpty ? null : _queryCtrl.text.trim()),
        filterSubtitle: Value(_subtitleCtrl.text.trim().isEmpty ? null : _subtitleCtrl.text.trim()),
        filterAuthor: Value(_authorCtrl.text.trim().isEmpty ? null : _authorCtrl.text.trim()),
        filterPublisher: Value(_publisherCtrl.text.trim().isEmpty ? null : _publisherCtrl.text.trim()),
        filterIsbn: Value(_isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim()),
        filterLanguage: Value(_langCtrl.text.trim().isEmpty ? null : _langCtrl.text.trim()),
        filterNotes: Value(_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
        filterStatus: Value(_status?.name),
        filterBooleanQuery: Value(_booleanQuery != null ? jsonEncode(_booleanQuery!.toJson()) : null),
        filterSearchMode: Value(_searchMode.index),
        filterFormat: Value(_format?.name),
        filterOwnership: Value(_ownership?.name),
      );
      
      await widget.onSave(companion, [...tagIds, ...imprintIds, ...collectionIds]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorPrefix(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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

    if (widget.existing != null && 
        (widget.existing!.filterNoCover || widget.existing!.name == '__auto_no_cover__') &&
        _nameCtrl.text == '__auto_no_cover__') {
      _nameCtrl.text = context.l10n.noCoverShelfTitle;
    }

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
              decoration: InputDecoration(
                labelText: context.l10n.shelfFormNameLabel, 
                border: const OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
            
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Mode Switcher - 3 Stages
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        _ModeTabButton(
                          label: context.l10n.searchModeBasic,
                          isActive: _searchMode == SearchMode.basic,
                          onTap: () => setState(() => _searchMode = SearchMode.basic),
                        ),
                        const SizedBox(width: 8),
                        _ModeTabButton(
                          label: context.l10n.searchModeAdvanced,
                          isActive: _searchMode == SearchMode.advanced,
                          onTap: () => setState(() => _searchMode = SearchMode.advanced),
                        ),
                        const SizedBox(width: 8),
                        _ModeTabButton(
                          label: context.l10n.searchModeBoolean,
                          isActive: _searchMode == SearchMode.boolean,
                          onTap: () {
                            if (_searchMode != SearchMode.boolean && (_booleanQuery == null || _booleanQuery!.conditions.isEmpty)) {
                              final filters = SearchFilters(
                                query: _queryCtrl.text,
                                author: _authorCtrl.text,
                                publisher: _publisherCtrl.text,
                                isbn: _isbnCtrl.text,
                                language: _langCtrl.text,
                                notes: _notesCtrl.text,
                                status: _status,
                                format: _format,
                                ownership: _ownership,
                                startedAt: _startedAt,
                                startedAtOp: _startedAtOp,
                                finishedAt: _finishedAt,
                                finishedAtOp: _finishedAtOp,
                                tags: _selectedTags,
                                imprints: _selectedImprints,
                                collections: _selectedCollections,
                              );
                              _booleanQuery = filters.toBooleanQuery();
                            }
                            setState(() => _searchMode = SearchMode.boolean);
                          },
                        ),
                      ],
                    ),
                  ),

                  if (_searchMode == SearchMode.boolean)
                    BooleanQueryPanel(
                      query: _booleanQuery ?? const BooleanQuery(),
                      onChanged: (bq) => setState(() => _booleanQuery = bq),
                    )
                  else ...[
                    if (_selectedTags.isNotEmpty || _selectedImprints.isNotEmpty || _selectedCollections.isNotEmpty || _status != null || _format != null || _ownership != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Wrap(
                          spacing: 6, runSpacing: 6,
                          children: [
                            if (_status != null)
                              _StatusChipSummary(
                                status: _status!,
                                onDeleted: () => setState(() => _status = null),
                              ),
                            if (_format != null)
                              TagChip(
                                label: _formatLabel(context, _format!),
                                onDeleted: () => setState(() => _format = null),
                              ),
                            if (_ownership != null)
                              TagChip(
                                label: _ownershipLabel(context, _ownership!),
                                onDeleted: () => setState(() => _ownership = null),
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
                    
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          if (_searchMode == SearchMode.advanced) ...[
                            TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              labelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                              unselectedLabelStyle: textTheme.labelSmall,
                              tabs: [
                                Tab(text: context.l10n.tabMain),
                                Tab(text: context.l10n.searchTabStatus),
                                Tab(text: context.l10n.searchTabCategory),
                                Tab(text: context.l10n.searchTabCollection),
                                Tab(text: context.l10n.searchTabImprint),
                              ],
                            ),
                            const Divider(height: 1),
                            SizedBox(
                              height: 260,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child: FilterTextField(controller: _queryCtrl, hint: context.l10n.fieldTitle)),
                                            const SizedBox(width: 8),
                                            Expanded(child: FilterTextField(controller: _subtitleCtrl, hint: context.l10n.fieldSubtitle)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        FilterTextField(controller: _authorCtrl, hint: context.l10n.fieldAuthor),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(child: FilterTextField(controller: _publisherCtrl, hint: context.l10n.fieldPublisher)),
                                            const SizedBox(width: 8),
                                            Expanded(child: FilterTextField(controller: _notesCtrl, hint: context.l10n.searchFieldNotes)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(child: FilterTextField(controller: _isbnCtrl, hint: context.l10n.fieldIsbn)),
                                            const SizedBox(width: 8),
                                            Expanded(child: FilterTextField(controller: _langCtrl, hint: context.l10n.fieldLanguage)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: FilterDateSelector(
                                                label: context.l10n.bookDetailFieldStarted,
                                                value: _startedAt,
                                                operator: _startedAtOp,
                                                onChanged: (d) => setState(() => _startedAt = d),
                                                onOpChanged: (op) => setState(() => _startedAtOp = op),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: FilterDateSelector(
                                                label: context.l10n.bookDetailFieldFinished,
                                                value: _finishedAt,
                                                operator: _finishedAtOp,
                                                onChanged: (d) => setState(() => _finishedAt = d),
                                                onOpChanged: (op) => setState(() => _finishedAtOp = op),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusFiltersTab(
                                    status: _status,
                                    format: _format,
                                    ownership: _ownership,
                                    onStatusChanged: (s, clear) => setState(() => _status = clear ? null : s),
                                    onFormatChanged: (f, clear) => setState(() => _format = clear ? null : f),
                                    onOwnershipChanged: (o, clear) => setState(() => _ownership = clear ? null : o),
                                  ),
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.all(12),
                                    child: EntitySelectorGrid(
                                      selected: _selectedTags,
                                      onChanged: (list) => setState(() => _selectedTags = list),
                                      provider: allTagsProvider,
                                      type: TagType.tag,
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.all(12),
                                    child: EntitySelectorGrid(
                                      selected: _selectedCollections,
                                      onChanged: (list) => setState(() => _selectedCollections = list),
                                      provider: allCollectionsProvider,
                                      type: TagType.collection,
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.all(12),
                                    child: EntitySelectorGrid(
                                      selected: _selectedImprints,
                                      onChanged: (list) => setState(() => _selectedImprints = list),
                                      provider: allImprintsProvider,
                                      type: TagType.imprint,
                                      isImprint: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: FilterTextField(controller: _queryCtrl, hint: context.l10n.bookSearchHint),
                            ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton.icon(
                      onPressed: _showInLibrary,
                      icon: const Icon(Icons.search, size: 18),
                      label: Text(context.l10n.shelfShowInLibrary),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeTabButton({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
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
