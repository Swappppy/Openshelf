import 'dart:convert';
import 'dart:io';
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
import '../../l10n/l10n_extension.dart';
import 'shelf_books_view.dart';

/// Screen for managing personal dynamic shelves and system categories/imprints/collections.
class ShelvesScreen extends ConsumerWidget {
  const ShelvesScreen({super.key});

  /// Opens the creation dialog for a new dynamic shelf.
  void _showCreateShelfDialog(BuildContext context, WidgetRef ref) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section header for User-defined shelves
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.shelvesSectionMine,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showCreateShelfDialog(context, ref),
                tooltip: context.l10n.shelfNewTooltip,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _ShelvesSection(),
          
          const SizedBox(height: 24),
          
          // Management section for Categories, Imprints, etc.
          Text(
            context.l10n.shelvesSectionManagement,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          const _ManagementSection(),
        ],
      ),
    );
  }
}

/// Displays the list of user-created dynamic shelves.
class _ShelvesSection extends ConsumerWidget {
  const _ShelvesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelvesAsync = ref.watch(allShelvesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return shelvesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text(context.l10n.errorPrefix(e.toString())),
      data: (shelfList) {
        if (shelfList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.bookmarks_outlined,
                      size: 48, color: colorScheme.outline),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.shelfEmpty,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: shelfList
              .map((shelf) => _ShelfTile(shelf: shelf))
              .toList(),
        );
      },
    );
  }
}

/// Individual tile for a dynamic shelf, showing book count and criteria summary.
class _ShelfTile extends ConsumerWidget {
  final Shelf shelf;
  const _ShelfTile({required this.shelf});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(shelfBooksProvider(shelf));
    final count = booksAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          child: Icon(Icons.bookmarks_outlined,
              color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(shelf.name),
        subtitle: _buildSubtitle(context, shelf),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShelfBooksView(shelf: shelf),
          ),
        ),
        onLongPress: () => _showOptions(context, ref),
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context, Shelf shelf) {
    final parts = <String>[];
    if (shelf.filterStatus != null) {
      parts.add(_statusLabel(context, shelf.filterStatus!));
    }
    if (shelf.filterAuthor != null) parts.add(shelf.filterAuthor!);
    if (shelf.filterCollection != null) parts.add(shelf.filterCollection!);
    if (parts.isEmpty) return null;
    return Text(
      parts.join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.outline,
      ),
    );
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

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
                  ),
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
                        filterImprintId: companion.filterImprintId.value,
                      );
                      await ref.read(databaseProvider).updateShelf(updated);
                      if (ctx2.mounted) Navigator.pop(ctx2);
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              title: Text(context.l10n.shelfOptionDelete,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error)),
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

/// Form for creating or editing dynamic shelf criteria.
class _ShelfFormSheet extends ConsumerStatefulWidget {
  final Shelf? existing;
  final Future<void> Function(ShelvesCompanion) onSave;

  const _ShelfFormSheet({this.existing, required this.onSave});

  @override
  ConsumerState<_ShelfFormSheet> createState() => _ShelfFormSheetState();
}

class _ShelfFormSheetState extends ConsumerState<_ShelfFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _queryCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _publisherCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _collectionCtrl;
  ReadingStatus? _status;
  List<Tag> _selectedTags = [];
  Tag? _selectedImprint;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _queryCtrl = TextEditingController(text: s?.filterQuery ?? '');
    _authorCtrl = TextEditingController(text: s?.filterAuthor ?? '');
    _publisherCtrl = TextEditingController(text: s?.filterPublisher ?? '');
    _isbnCtrl = TextEditingController(text: s?.filterIsbn ?? '');
    _collectionCtrl = TextEditingController(text: s?.filterCollection ?? '');
    
    if (s?.filterStatus != null) {
      _status = ReadingStatus.values.where(
            (r) => r.name == s!.filterStatus,
      ).firstOrNull;
    }
    if (s?.filterTagIds != null) _loadTags(s!.filterTagIds!);
    if (s?.filterImprintId != null) _loadImprint(s!.filterImprintId!);
  }

  Future<void> _loadTags(String json) async {
    final ids = (jsonDecode(json) as List).cast<int>();
    final db = ref.read(databaseProvider);
    final allTags = await db.getTagsByType('tag');
    setState(() {
      _selectedTags = allTags.where((t) => ids.contains(t.id)).toList();
    });
  }

  Future<void> _loadImprint(int id) async {
    final db = ref.read(databaseProvider);
    final allImprints = await db.getTagsByType('imprint');
    final imprint = allImprints.where((t) => t.id == id).firstOrNull;
    if (imprint != null) setState(() => _selectedImprint = imprint);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _queryCtrl.dispose();
    _authorCtrl.dispose();
    _publisherCtrl.dispose();
    _isbnCtrl.dispose();
    _collectionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    final tagIds = _selectedTags.map((t) => t.id).toList();
    final companion = ShelvesCompanion(
      name: Value(_nameCtrl.text.trim()),
      filterQuery: Value(_queryCtrl.text.trim().isEmpty
          ? null
          : _queryCtrl.text.trim()),
      filterAuthor: Value(_authorCtrl.text.trim().isEmpty
          ? null
          : _authorCtrl.text.trim()),
      filterPublisher: Value(_publisherCtrl.text.trim().isEmpty
          ? null
          : _publisherCtrl.text.trim()),
      filterIsbn: Value(_isbnCtrl.text.trim().isEmpty
          ? null
          : _isbnCtrl.text.trim()),
      filterCollection: Value(_collectionCtrl.text.trim().isEmpty
          ? null
          : _collectionCtrl.text.trim()),
      filterStatus: Value(_status?.name),
      filterTagIds: Value(tagIds.isEmpty ? null : jsonEncode(tagIds)),
      filterImprintId: Value(_selectedImprint?.id),
    );
    await widget.onSave(companion);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Padding(
        padding: EdgeInsets.fromLTRB(
          16, 16, 16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.existing == null
                        ? context.l10n.shelfFormNew
                        : context.l10n.shelfFormEdit,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(context.l10n.save),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.shelfFormNameLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _Label(context.l10n.shelfFormSectionStatus),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusOption(
                          label: context.l10n.shelfFormStatusAny,
                          selected: _status == null,
                          color: colorScheme.outline,
                          onTap: () => setState(() => _status = null),
                        ),
                        _StatusOption(
                          label: context.l10n.statusReading,
                          selected: _status == ReadingStatus.reading,
                          color: Colors.blue,
                          onTap: () => setState(
                                  () => _status = ReadingStatus.reading),
                        ),
                        _StatusOption(
                          label: context.l10n.statusRead,
                          selected: _status == ReadingStatus.read,
                          color: Colors.green,
                          onTap: () =>
                              setState(() => _status = ReadingStatus.read),
                        ),
                        _StatusOption(
                          label: context.l10n.statusWantToRead,
                          selected: _status == ReadingStatus.wantToRead,
                          color: Colors.orange,
                          onTap: () => setState(
                                  () => _status = ReadingStatus.wantToRead),
                        ),
                        _StatusOption(
                          label: context.l10n.statusPaused,
                          selected: _status == ReadingStatus.paused,
                          color: const Color(0xFFB39DDB),
                          onTap: () => setState(
                                  () => _status = ReadingStatus.paused),
                        ),
                        _StatusOption(
                          label: context.l10n.statusAbandoned,
                          selected: _status == ReadingStatus.abandoned,
                          color: Colors.red,
                          onTap: () => setState(
                                  () => _status = ReadingStatus.abandoned),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _Label(context.l10n.shelfFormSectionTitle),
                    const SizedBox(height: 8),
                    _ShelfFilterField(ctrl: _queryCtrl, hint: context.l10n.shelfFormHintTitle),
                    const SizedBox(height: 16),
                    _Label(context.l10n.shelfFormSectionAuthor),
                    const SizedBox(height: 8),
                    _ShelfFilterField(ctrl: _authorCtrl, hint: context.l10n.shelfFormHintAuthor),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label(context.l10n.shelfFormSectionPublisher),
                              const SizedBox(height: 8),
                              _ShelfFilterField(
                                  ctrl: _publisherCtrl,
                                  hint: context.l10n.shelfFormHintPublisher),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Label(context.l10n.shelfFormSectionIsbn),
                              const SizedBox(height: 8),
                              _ShelfFilterField(ctrl: _isbnCtrl, hint: context.l10n.shelfFormHintIsbn),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _Label(context.l10n.shelfFormSectionCollection),
                    const SizedBox(height: 8),
                    _ShelfFilterField(
                        ctrl: _collectionCtrl, hint: context.l10n.shelfFormHintCollection),
                    const SizedBox(height: 24),
                    _Label(context.l10n.shelfFormSectionCategories),
                    const SizedBox(height: 8),
                    if (_selectedTags.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _selectedTags.map((tag) {
                          final baseColor = tag.color != null
                              ? Color(int.parse('0xFF${tag.color!}'))
                              : colorScheme.secondaryContainer;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: baseColor.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: baseColor, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(tag.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: tag.color != null
                                          ? baseColor
                                          : colorScheme.onSecondaryContainer,
                                    )),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => setState(() =>
                                      _selectedTags.remove(tag)),
                                  child: Icon(Icons.close,
                                      size: 14,
                                      color: baseColor.withValues(alpha: 0.7)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    ref.watch(allTagsProvider).maybeWhen(
                      data: (allTags) => allTags.isEmpty
                          ? const SizedBox.shrink()
                          : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allTags
                            .where((t) => !_selectedTags.any((s) => s.id == t.id))
                            .map((tag) {
                          final baseColor = tag.color != null
                              ? Color(int.parse('0xFF${tag.color!}'))
                              : colorScheme.secondaryContainer;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedTags.add(tag)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: baseColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: Colors.transparent,
                                    width: 1.5),
                              ),
                              child: Text(tag.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: tag.color != null
                                        ? baseColor
                                        : colorScheme.onSecondaryContainer,
                                  )),
                            ),
                          );
                        }).toList(),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),
                    _Label(context.l10n.shelfFormSectionImprint),
                    const SizedBox(height: 8),
                    ref.watch(allImprintsProvider).maybeWhen(
                      data: (allImprints) => allImprints.isEmpty
                          ? Text(context.l10n.imprintNoImprints,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: colorScheme.outline))
                          : Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: allImprints.map((imp) {
                          final isActive = _selectedImprint?.id == imp.id;
                          return GestureDetector(
                            onTap: () => setState(() =>
                            _selectedImprint = isActive ? null : imp),
                            child: SizedBox(
                              width: 72,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: isActive
                                          ? Border.all(
                                          color: colorScheme.primary,
                                          width: 2)
                                          : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: imp.imagePath != null
                                          ? Image.file(
                                        File(imp.imagePath!),
                                        width: 72,
                                        height: 72,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => _ImprintPlaceholder(size: 72, iconSize: 28, name: imp.name),
                                      )
                                          : _ImprintPlaceholder(size: 72, iconSize: 28, name: imp.name),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(imp.name,
                                      style: Theme.of(context).textTheme.labelSmall,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      orElse: () => const SizedBox.shrink(),
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

/// A combined section featuring expandable panels for Tags, Imprints, and Collections.
class _ManagementSection extends ConsumerStatefulWidget {
  const _ManagementSection();
  @override
  ConsumerState<_ManagementSection> createState() => _ManagementSectionState();
}

class _ManagementSectionState extends ConsumerState<_ManagementSection> {
  bool _tagsExpanded = false;
  bool _imprintsExpanded = false;
  bool _collectionsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ExpandablePanel(
          icon: Icons.label_outline,
          label: context.l10n.managementCategories,
          color: Theme.of(context).colorScheme.primary,
          expanded: _tagsExpanded,
          onTap: () => setState(() => _tagsExpanded = !_tagsExpanded),
          child: const _TagsManager(),
        ),
        const SizedBox(height: 8),
        _ExpandablePanel(
          icon: Icons.business_outlined,
          label: context.l10n.managementImprints,
          color: Colors.deepPurple,
          expanded: _imprintsExpanded,
          onTap: () => setState(() => _imprintsExpanded = !_imprintsExpanded),
          child: const _ImprintsManager(),
        ),
        const SizedBox(height: 8),
        _ExpandablePanel(
          icon: Icons.collections_bookmark_outlined,
          label: context.l10n.managementCollections,
          color: Colors.teal,
          expanded: _collectionsExpanded,
          onTap: () => setState(() => _collectionsExpanded = !_collectionsExpanded),
          child: const _CollectionsManager(),
        ),
      ],
    );
  }
}

class _ExpandablePanel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;

  const _ExpandablePanel({
    required this.icon,
    required this.label,
    required this.color,
    required this.expanded,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            title: Text(label),
            trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
            onTap: onTap,
          ),
          if (expanded) ...[
            const Divider(height: 1),
            child,
          ],
        ],
      ),
    );
  }
}

/// Category manager showing a fluid grid of tag chips with deletion support.
class _TagsManager extends ConsumerWidget {
  const _TagsManager();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(allTagsProvider);
    return tagsAsync.when(
      loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text(context.l10n.errorPrefix(e.toString()))),
      data: (tagList) => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tagList.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(context.l10n.tagNone, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
              )
            else
              Wrap(spacing: 8, runSpacing: 8, children: tagList.map((tag) => _TagChipItem(tag: tag)).toList()),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showCreateTagDialog(context, ref),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(context.l10n.tagNew, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTagDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    String? selectedColor;
    final colors = ['E53935', 'D81B60', '8E24AA', '3949AB', '1E88E5', '00ACC1', '00897B', '43A047', 'C0CA33', 'FB8C00', '6D4C41', '757575'];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(context.l10n.tagNewDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: ctrl, autofocus: true, decoration: InputDecoration(labelText: context.l10n.tagNameLabel, border: const OutlineInputBorder())),
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerLeft, child: Text(context.l10n.tagColorLabel)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: colors.map((hex) {
                  final color = Color(int.parse('0xFF$hex'));
                  final isSelected = selectedColor == hex;
                  return GestureDetector(
                    onTap: () => setStateDialog(() => selectedColor = hex),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: isSelected ? Border.all(color: Colors.white, width: 3) : null, boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6)] : null),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.cancel)),
            FilledButton(
              onPressed: () async {
                final name = ctrl.text.trim();
                if (name.isEmpty) return;
                await ref.read(databaseProvider).insertTag(TagsCompanion(name: Value(name), type: const Value('tag'), color: Value(selectedColor)));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(context.l10n.create),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChipItem extends ConsumerWidget {
  final Tag tag;
  const _TagChipItem({required this.tag});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseColor = tag.color != null ? Color(int.parse('0xFF${tag.color!}')) : Theme.of(context).colorScheme.secondaryContainer;
    final textColor = tag.color != null ? baseColor : Theme.of(context).colorScheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: baseColor.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
          const SizedBox(width: 8),
          GestureDetector(onTap: () => _confirmDelete(context, ref), child: Icon(Icons.delete_outline, size: 16, color: textColor.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.tagDeleteTitle),
        content: Text(context.l10n.tagDeleteConfirm(tag.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.cancel)),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), onPressed: () async { await ref.read(databaseProvider).deleteTag(tag.id); if (ctx.mounted) Navigator.pop(ctx); }, child: Text(context.l10n.delete)),
        ],
      ),
    );
  }
}

/// Imprint manager showing a list of publisher logos and their book counts.
class _ImprintsManager extends ConsumerWidget {
  const _ImprintsManager();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imprintsAsync = ref.watch(allImprintsProvider);
    return imprintsAsync.when(
      loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text(context.l10n.errorPrefix(e.toString()))),
      data: (imprintList) => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imprintList.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(context.l10n.imprintNone, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
              )
            else
              Column(children: imprintList.map((imp) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _ImprintGridItem(imprint: imp))).toList()),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showCreateImprintDialog(context, ref),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(context.l10n.imprintNew, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateImprintDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    String? imagePath;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(context.l10n.imprintNewDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (!await PermissionService.requestGallery()) return;
                      if (!context.mounted) return;
                      final title = context.l10n.cropImprintTitle;
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery);
                      if (picked == null) return;
                      final cropped = await CoverService.cropImprint(picked.path, title: title);
                      if (cropped == null) return;
                      final saved = await CoverService.saveImprintImage(cropped);
                      setStateDialog(() => imagePath = saved);
                    },
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                      child: imagePath != null && imagePath!.isNotEmpty
                          ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(imagePath!), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _ImprintPlaceholder(size: 80, iconSize: 32, name: ctrl.text)))
                          : _ImprintPlaceholder(size: 80, iconSize: 32, name: ctrl.text),
                    ),
                  ),
                  if (imagePath != null && imagePath!.isNotEmpty)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          await CoverService.deleteImprintImage(imagePath!);
                          setStateDialog(() => imagePath = null);
                        },
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(context.l10n.imprintAddImageHint, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(icon: const Icon(Icons.camera_alt_outlined, size: 16), label: Text(context.l10n.photo), onPressed: () async { if (!await PermissionService.requestCamera()) return; if (!context.mounted) return; final title = context.l10n.cropImprintTitle; final picker = ImagePicker(); final picked = await picker.pickImage(source: ImageSource.camera); if (picked == null) return; final cropped = await CoverService.cropImprint(picked.path, title: title); if (cropped == null) return; final saved = await CoverService.saveImprintImage(cropped); setStateDialog(() => imagePath = saved); }),
                  const SizedBox(width: 4),
                  TextButton.icon(icon: const Icon(Icons.link, size: 16), label: Text(context.l10n.url), onPressed: () async {
                    final ctrl = TextEditingController();
                    final url = await showDialog<String>(
                      context: context,
                      builder: (urlCtx) => AlertDialog(
                        title: Text(context.l10n.imprintUrlDialogTitle),
                        content: TextField(
                          controller: ctrl,
                          autofocus: true,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            hintText: context.l10n.imprintUrlHint,
                            border: const OutlineInputBorder(),
                          ),
                          onSubmitted: (v) => Navigator.pop(urlCtx, v.trim()),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(urlCtx),
                            child: Text(context.l10n.cancel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(urlCtx, ctrl.text.trim()),
                            child: Text(context.l10n.download),
                          ),
                        ],
                      ),
                    );
                    if (url == null || url.isEmpty) return;
                    if (!context.mounted) return;
                    final title = context.l10n.cropImprintTitle;
                    final saved = await CoverService.saveImprintFromUrl(url, cropTitle: title);
                    if (saved != null) setStateDialog(() => imagePath = saved);
                  }),
                ],
              ),
              const SizedBox(height: 16),
              TextField(controller: ctrl, decoration: InputDecoration(labelText: context.l10n.imprintNameLabel, border: const OutlineInputBorder())),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.cancel)),
            FilledButton(onPressed: () async { final name = ctrl.text.trim(); if (name.isEmpty) return; await ref.read(databaseProvider).insertTag(TagsCompanion(name: Value(name), type: const Value('imprint'), imagePath: Value(imagePath))); if (ctx.mounted) Navigator.pop(ctx); }, child: Text(context.l10n.create)),
          ],
        ),
      ),
    );
  }
}

class _ImprintGridItem extends ConsumerWidget {
  final Tag imprint;
  const _ImprintGridItem({required this.imprint});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookCountAsync = ref.watch(imprintBookCountProvider(imprint.id));
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TagBooksView(tag: imprint))),
      child: Container(
        decoration: BoxDecoration(color: colorScheme.surface.withValues(alpha: 0.0), border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: imprint.imagePath != null && imprint.imagePath!.isNotEmpty ? Image.file(File(imprint.imagePath!), width: 52, height: 52, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _ImprintPlaceholder(size: 52, iconSize: 24, name: imprint.name)) : _ImprintPlaceholder(size: 52, iconSize: 24, name: imprint.name)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(imprint.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 2), bookCountAsync.maybeWhen(data: (count) => Text(context.l10n.imprintBookCount(count), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.outline, letterSpacing: 0.4)), orElse: () => const SizedBox.shrink())])),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showEditDialog(context, ref)),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _confirmDelete(context, ref)),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController(text: imprint.name);
    String? imagePath = imprint.imagePath;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(context.l10n.imprintEditDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (!await PermissionService.requestGallery()) return;
                      if (!context.mounted) return;
                      final title = context.l10n.cropImprintTitle;
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery);
                      if (picked == null) return;
                      final cropped = await CoverService.cropImprint(picked.path, title: title);
                      if (cropped == null) return;
                      if (imagePath != null) {
                        await CoverService.deleteImprintImage(imagePath!);
                      }
                      final saved = await CoverService.saveImprintImage(cropped);
                      setStateDialog(() => imagePath = saved);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: imagePath != null && imagePath!.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _ImprintPlaceholder(size: 80, iconSize: 32, name: imprint.name),
                        ),
                      )
                          : _ImprintPlaceholder(size: 80, iconSize: 32, name: imprint.name),
                    ),
                  ),
                  if (imagePath != null && imagePath!.isNotEmpty)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          await CoverService.deleteImprintImage(imagePath!);
                          setStateDialog(() => imagePath = null);
                        },
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.imprintChangeImageHint,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  labelText: context.l10n.imprintNameLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: Text(context.l10n.photo),
                    onPressed: () async {
                      if (!await PermissionService.requestCamera()) return;
                      if (!context.mounted) return;
                      final title = context.l10n.cropImprintTitle;
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.camera);
                      if (picked == null) return;
                      final cropped = await CoverService.cropImprint(picked.path, title: title);
                      if (cropped == null) return;
                      final saved = await CoverService.saveImprintImage(cropped);
                      setStateDialog(() => imagePath = saved);
                    },
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    icon: const Icon(Icons.link, size: 16),
                    label: Text(context.l10n.url),
                    onPressed: () async {
                      final url = await showDialog<String>(
                        context: context,
                        builder: (urlCtx) => AlertDialog(
                          title: Text(context.l10n.imprintUrlDialogTitle),
                          content: TextField(
                            autofocus: true,
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              hintText: context.l10n.imprintUrlHint,
                              border: const OutlineInputBorder(),
                            ),
                            onSubmitted: (v) => Navigator.pop(urlCtx, v.trim()),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(urlCtx),
                              child: Text(context.l10n.cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(urlCtx),
                              child: Text(context.l10n.download),
                            ),
                          ],
                        ),
                      );
                      if (url == null || url.isEmpty) return;
                      if (!context.mounted) return;
                      final title = context.l10n.cropImprintTitle;
                      final saved = await CoverService.saveImprintFromUrl(url, cropTitle: title);
                      if (saved != null) setStateDialog(() => imagePath = saved);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final name = ctrl.text.trim();
                if (name.isEmpty) return;
                final updated = Tag(
                  id: imprint.id,
                  name: name,
                  type: imprint.type,
                  color: imprint.color,
                  imagePath: imagePath,
                );
                await ref.read(databaseProvider).updateTag(updated);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.imprintDeleteTitle),
        content: Text(context.l10n.imprintDeleteConfirm(imprint.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              if (imprint.imagePath != null) {
                await CoverService.deleteImprintImage(imprint.imagePath!);
              }
              await ref.read(databaseProvider).deleteTag(imprint.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }
}

/// Collection manager for organizing books into series.
class _CollectionsManager extends ConsumerWidget {
  const _CollectionsManager();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(allCollectionsProvider);
    return collectionsAsync.when(
      loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text(context.l10n.errorPrefix(e.toString()))),
      data: (collectionList) => Column(children: [...collectionList.map((col) => _CollectionTile(collection: col)), if (collectionList.isEmpty) Padding(padding: const EdgeInsets.all(16), child: Text(context.l10n.collectionNone, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)))]),
    );
  }
}

class _CollectionTile extends ConsumerWidget {
  final Tag collection;
  const _CollectionTile({required this.collection});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(leading: CircleAvatar(backgroundColor: Colors.teal.withValues(alpha: 0.15), child: const Icon(Icons.collections_bookmark_outlined, color: Colors.teal)), title: Text(collection.name), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _confirmDelete(context, ref)));
  }
  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.collectionDeleteTitle),
        content: Text(context.l10n.collectionDeleteConfirm(collection.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await ref.read(databaseProvider).deleteTag(collection.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) { return Text(text.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2)); }
}

class _ShelfFilterField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  const _ShelfFilterField({required this.ctrl, required this.hint});
  @override
  Widget build(BuildContext context) { return TextField(controller: ctrl, decoration: InputDecoration(hintText: hint, isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12))); }
}

class _StatusOption extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _StatusOption({required this.label, required this.selected, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) { return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: selected ? color.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4), border: Border.all(color: selected ? color : Colors.transparent, width: 1.5)), child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? color : Theme.of(context).colorScheme.onSurface)))); }
}

/// Stylized placeholder for imprints when no logo image is available.
class _ImprintPlaceholder extends StatelessWidget {
  final double size;
  final double iconSize;
  final String? name;
  const _ImprintPlaceholder({this.size = 80, this.iconSize = 32, this.name});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget content;
    if (name != null && name!.isNotEmpty) {
      final initials = name!.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(3).map((w) => w[0].toUpperCase()).join();
      content = Center(child: Text(initials, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: size * 0.35)));
    } else { content = Icon(Icons.business_outlined, size: iconSize, color: colorScheme.outline); }
    return Container(width: size, height: size, decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(8)), child: content);
  }
}
