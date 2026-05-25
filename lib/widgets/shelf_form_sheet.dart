import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../models/shelf.dart';
import '../services/database.dart';
import '../controllers/books_controller.dart';
import '../controllers/database_provider.dart';
import '../l10n/l10n_extension.dart';
import 'tag_chip.dart';
import 'filter_grid_box.dart';
import 'entity_selector_grid.dart';

class ShelfFormSheet extends ConsumerStatefulWidget {
  final Shelf? existing;
  final Future<void> Function(ShelvesCompanion) onSave;
  
  const ShelfFormSheet({super.key, this.existing, required this.onSave});
  
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
                              Tab(text: context.l10n.navShelves),
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
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: _StatusFilterRow(
                                    selectedStatus: _status,
                                    onChanged: (s) => setState(() => _status = s),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SingleChildScrollView(
                                    child: EntitySelectorGrid(
                                      selected: _selectedTags,
                                      onChanged: (list) => setState(() => _selectedTags = list),
                                      provider: allTagsProvider,
                                      type: 'tag',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SingleChildScrollView(
                                    child: EntitySelectorGrid(
                                      selected: _selectedCollections,
                                      onChanged: (list) => setState(() => _selectedCollections = list),
                                      provider: allCollectionsProvider,
                                      type: 'collection',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SingleChildScrollView(
                                    child: EntitySelectorGrid(
                                      selected: _selectedImprints,
                                      onChanged: (list) => setState(() => _selectedImprints = list),
                                      provider: allImprintsProvider,
                                      type: 'imprint',
                                      isImprint: true,
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