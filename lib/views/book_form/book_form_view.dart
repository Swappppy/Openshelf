import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/database.dart';
import '../../services/cover_service.dart';
import '../../controllers/database_provider.dart';

class BookFormView extends ConsumerStatefulWidget {
  final Book? existingBook;
  const BookFormView({super.key, this.existingBook});

  @override
  ConsumerState<BookFormView> createState() => _BookFormViewState();
}

// Tag pendiente de persistir — solo tiene nombre, aún sin id
class _PendingTag {
  final String name;
  final String? color;
  _PendingTag({required this.name, this.color});
}

class _BookFormViewState extends ConsumerState<BookFormView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TabController _tabController;

  // Controladores
  late final TextEditingController _titleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _publisherCtrl;
  late final TextEditingController _totalPagesCtrl;
  late final TextEditingController _currentPageCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _collectionNameCtrl;
  late final TextEditingController _collectionNumberCtrl;

  ReadingStatus _status = ReadingStatus.wantToRead;
  BookFormat? _format;
  double? _rating;
  bool _isSaving = false;
  String? _coverPath;
  List<Tag> _selectedTags = [];        // tags ya existentes en BD
  List<_PendingTag> _pendingTags = []; // tags nuevos, aún no persistidos

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final b = widget.existingBook;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    _isbnCtrl = TextEditingController(text: b?.isbn ?? '');
    _publisherCtrl = TextEditingController(text: b?.publisher ?? '');
    _totalPagesCtrl =
        TextEditingController(text: b?.totalPages?.toString() ?? '');
    _currentPageCtrl = TextEditingController(text: '0');
    _notesCtrl = TextEditingController(text: b?.notes ?? '');
    _collectionNameCtrl =
        TextEditingController(text: b?.collectionName ?? '');
    _collectionNumberCtrl =
        TextEditingController(text: b?.collectionNumber?.toString() ?? '');
    if (b != null) {
      _status = b.status;
      _format = b.bookFormat;
      _rating = b.rating;
      _coverPath = b.coverPath;
      _currentPageCtrl.text = b.currentPage?.toString() ?? '0';
      _loadExistingTags(b.id);
    }
    _currentPageCtrl.addListener(_updateStatusFromPages);
    _totalPagesCtrl.addListener(_updateStatusFromPages);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _isbnCtrl.dispose();
    _publisherCtrl.dispose();
    _totalPagesCtrl.dispose();
    _currentPageCtrl.dispose();
    _notesCtrl.dispose();
    _collectionNameCtrl.dispose();
    _collectionNumberCtrl.dispose();
    _currentPageCtrl.removeListener(_updateStatusFromPages);
    _totalPagesCtrl.removeListener(_updateStatusFromPages);
    super.dispose();
  }

  // Ajusta página actual según estado seleccionado
  void _onStatusChanged(ReadingStatus s) {
    setState(() => _status = s);
    final total = int.tryParse(_totalPagesCtrl.text);
    switch (s) {
      case ReadingStatus.wantToRead:
        _currentPageCtrl.text = '0';
        break;
      case ReadingStatus.reading:
        if (_currentPageCtrl.text == '0') _currentPageCtrl.text = '1';
        break;
      case ReadingStatus.read:
        if (total != null) _currentPageCtrl.text = total.toString();
        break;
      case ReadingStatus.abandoned:
        break;
    }
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final saved = await CoverService.saveCover(picked.path);
    setState(() => _coverPath = saved);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }
    setState(() => _isSaving = true);

    final db = ref.read(databaseProvider);

    if (widget.existingBook != null) {
      // Editar libro existente
      final updated = widget.existingBook!.copyWith(
        title: _titleCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        isbn: Value(_isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim()),
        publisher: Value(_publisherCtrl.text.trim().isEmpty ? null : _publisherCtrl.text.trim()),
        totalPages: Value(int.tryParse(_totalPagesCtrl.text)),
        currentPage: Value(int.tryParse(_currentPageCtrl.text) ?? 0),
        status: _status,
        bookFormat: Value(_format),
        rating: Value(_rating),
        notes: Value(_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
        coverPath: Value(_coverPath),
        collectionName: Value(_collectionNameCtrl.text.trim().isEmpty ? null : _collectionNameCtrl.text.trim()),
        collectionNumber: Value(int.tryParse(_collectionNumberCtrl.text)),
      );
      await db.updateBook(updated);
      final existingIds = _selectedTags.map((t) => t.id).toList();
      for (final p in _pendingTags) {
        final newId = await db.insertTag(
          TagsCompanion(name: Value(p.name), type: const Value('tag')),
        );
        existingIds.add(newId);
      }
      await db.setBookTags(widget.existingBook!.id, existingIds);
      // Registrar colección si tiene nombre
      final collectionName = _collectionNameCtrl.text.trim();
      if (collectionName.isNotEmpty) {
        await db.getOrCreateCollection(collectionName);
      }
    } else {
      // Crear libro nuevo
      final companion = BooksCompanion.insert(
        title: _titleCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        isbn: Value(_isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim()),
        publisher: Value(_publisherCtrl.text.trim().isEmpty ? null : _publisherCtrl.text.trim()),
        totalPages: Value(int.tryParse(_totalPagesCtrl.text)),
        currentPage: Value(int.tryParse(_currentPageCtrl.text) ?? 0),
        status: _status,
        bookFormat: Value<BookFormat?>(_format),
        rating: Value(_rating),
        notes: Value(_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
        coverPath: Value(_coverPath),
        collectionName: Value(_collectionNameCtrl.text.trim().isEmpty ? null : _collectionNameCtrl.text.trim()),
        collectionNumber: Value(int.tryParse(_collectionNumberCtrl.text)),
      );
      final newId = await db.insertBook(companion);
      final existingIds = _selectedTags.map((t) => t.id).toList();
      for (final p in _pendingTags) {
        final tagId = await db.insertTag(
          TagsCompanion(name: Value(p.name), type: const Value('tag')),
        );
        existingIds.add(tagId);
      }
      await db.setBookTags(newId, existingIds);
      // Registrar colección si tiene nombre
      final collectionName = _collectionNameCtrl.text.trim();
      if (collectionName.isNotEmpty) {
        await db.getOrCreateCollection(collectionName);
      }
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _loadExistingTags(int bookId) async {
    final db = ref.read(databaseProvider);
    final existing = await db.watchTagsForBook(bookId).first;
    setState(() => _selectedTags = existing);
  }

  void _updateStatusFromPages() {
    final current = int.tryParse(_currentPageCtrl.text);
    final total = int.tryParse(_totalPagesCtrl.text);
    if (current == null || total == null || total == 0) return;

    ReadingStatus newStatus;
    if (current == 0) {
      newStatus = ReadingStatus.wantToRead;
    } else if (current >= total) {
      newStatus = ReadingStatus.read;
      // Sincroniza página actual al total exacto
      if (current > total) _currentPageCtrl.text = total.toString();
    } else {
      newStatus = ReadingStatus.reading;
    }

    if (newStatus != _status) {
      setState(() => _status = newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.existingBook != null ? 'Editar libro' : 'Nuevo libro'),
        toolbarHeight: 40,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Guardar'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_outlined), text: 'Principal'),
            Tab(icon: Icon(Icons.label_outline), text: 'Detalles'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _MainTab(
              titleCtrl: _titleCtrl,
              authorCtrl: _authorCtrl,
              isbnCtrl: _isbnCtrl,
              publisherCtrl: _publisherCtrl,
              totalPagesCtrl: _totalPagesCtrl,
              currentPageCtrl: _currentPageCtrl,
              status: _status,
              format: _format,
              rating: _rating,
              coverPath: _coverPath,
              onStatusChanged: _onStatusChanged,
              onFormatChanged: (f) => setState(() => _format = f),
              onRatingChanged: (r) => setState(() => _rating = r),
              onPickCover: _pickCover,
              selectedTags: _selectedTags,
              pendingTags: _pendingTags,
              onAddTag: (tag) => setState(() {
                if (!_selectedTags.any((t) => t.id == tag.id)) {
                  _selectedTags.add(tag);
                }
              }),
              onRemoveTag: (tag) => setState(() => _selectedTags.remove(tag)),
              onCreateTag: (name) => setState(() => _pendingTags.add(_PendingTag(name: name))),
              onRemovePending: (p) => setState(() => _pendingTags.remove(p)),
            ),
            _DetailsTab(
              notesCtrl: _notesCtrl,
              collectionNameCtrl: _collectionNameCtrl,
              collectionNumberCtrl: _collectionNumberCtrl,
              selectedTags: _selectedTags,
              onAddTag: (tag) => setState(() {
                if (!_selectedTags.any((t) => t.id == tag.id)) {
                  _selectedTags.add(tag);
                }
              }),
              onRemoveTag: (tag) => setState(() => _selectedTags.remove(tag)),
              onCreateTag: (name) {
                setState(() => _pendingTags.add(_PendingTag(name: name)));
              },
              pendingTags: _pendingTags,
              onRemovePending: (p) => setState(() => _pendingTags.remove(p)),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// Pestaña Principal
// -------------------------------------------------------
class _MainTab extends ConsumerWidget {
  final TextEditingController titleCtrl;
  final TextEditingController authorCtrl;
  final TextEditingController isbnCtrl;
  final TextEditingController publisherCtrl;
  final TextEditingController totalPagesCtrl;
  final TextEditingController currentPageCtrl;
  final ReadingStatus status;
  final BookFormat? format;
  final double? rating;
  final String? coverPath;
  final ValueChanged<ReadingStatus> onStatusChanged;
  final ValueChanged<BookFormat?> onFormatChanged;
  final ValueChanged<double?> onRatingChanged;
  final VoidCallback onPickCover;
  final List<Tag> selectedTags;
  final List<_PendingTag> pendingTags;
  final ValueChanged<Tag> onAddTag;
  final ValueChanged<Tag> onRemoveTag;
  final void Function(String) onCreateTag;
  final void Function(_PendingTag) onRemovePending;

  const _MainTab({
    required this.titleCtrl,
    required this.authorCtrl,
    required this.isbnCtrl,
    required this.publisherCtrl,
    required this.totalPagesCtrl,
    required this.currentPageCtrl,
    required this.status,
    required this.format,
    required this.rating,
    required this.coverPath,
    required this.onStatusChanged,
    required this.onFormatChanged,
    required this.onRatingChanged,
    required this.onPickCover,
    required this.selectedTags,
    required this.pendingTags,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onCreateTag,
    required this.onRemovePending,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- Portada ---
        Center(
          child: GestureDetector(
            onTap: onPickCover,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: coverPath != null
                      ? Image.file(
                    File(coverPath!),
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 100,
                    height: 150,
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.menu_book,
                      size: 48,
                      color: colorScheme.outline,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: colorScheme.primary,
                    child: Icon(Icons.edit,
                        size: 14, color: colorScheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Pulsa la portada para cambiar la imagen',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Guarda las imágenes en una carpeta fija para evitar perderlas',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // --- Información básica ---
        _SectionHeader(label: 'Información básica'),
        const SizedBox(height: 12),
        _FormField(
            controller: titleCtrl, label: 'Título', required: true,
            icon: Icons.title),
        const SizedBox(height: 12),
        _FormField(
            controller: authorCtrl, label: 'Autor', required: true,
            icon: Icons.person_outline),
        const SizedBox(height: 12),
        _FormField(
            controller: publisherCtrl,
            label: 'Editorial',
            icon: Icons.business_outlined),
        const SizedBox(height: 12),
        _FormField(
            controller: isbnCtrl,
            label: 'ISBN',
            icon: Icons.barcode_reader,
            keyboardType: TextInputType.number),
        const SizedBox(height: 24),

        // --- Etiquetas ---
        _SectionHeader(label: 'Categorías'),
        const SizedBox(height: 4),
        Text(
          'Escribe y pulsa Enter para añadir o crear',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),
        if (selectedTags.isNotEmpty || pendingTags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ...selectedTags.map((tag) => Chip(
                label: Text(tag.name),
                backgroundColor: tag.color != null
                    ? Color(int.parse('0xFF${tag.color!}'))
                    : null,
                onDeleted: () => onRemoveTag(tag),
              )),
              ...pendingTags.map((p) => Chip(
                label: Text(p.name),
                onDeleted: () => onRemovePending(p),
              )),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Autocomplete<Tag>(
          displayStringForOption: (t) => t.name,
          optionsBuilder: (textEditingValue) async {
            final input = textEditingValue.text.trim();
            if (input.isEmpty) return [];
            final results = await ref.read(databaseProvider).searchTags(input, 'tag');
            return results.where(
                  (t) => !selectedTags.any((s) => s.id == t.id),
            ).toList();
          },
          onSelected: onAddTag,
          fieldViewBuilder: (_, controller, focusNode, _) => TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Buscar o crear categoría',
              prefixIcon: Icon(Icons.label_outline),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              final name = value.trim();
              if (name.isEmpty) return;
              onCreateTag(name);
              controller.clear();
            },
          ),
        ),

        const SizedBox(height: 24),

        // --- Progreso ---
        _SectionHeader(label: 'Progreso'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FormField(
                controller: totalPagesCtrl,
                label: 'Total páginas',
                icon: Icons.menu_book_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FormField(
                controller: currentPageCtrl,
                label: 'Página actual',
                icon: Icons.bookmark_outline,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- Estado ---
        _SectionHeader(label: 'Estado de lectura'),
        const SizedBox(height: 12),
        _StatusSelector(selected: status, onChanged: onStatusChanged),
        const SizedBox(height: 24),

        // --- Formato ---
        _SectionHeader(label: 'Formato'),
        const SizedBox(height: 12),
        _FormatSelector(selected: format, onChanged: onFormatChanged),
        const SizedBox(height: 12),
        const SizedBox(height: 24),

        // --- Valoración ---
        _SectionHeader(label: 'Valoración'),
        const SizedBox(height: 12),
        _RatingSelector(rating: rating, onChanged: onRatingChanged),
        const SizedBox(height: 32),
      ],
    );
  }
}

// -------------------------------------------------------
// Pestaña Detalles
// -------------------------------------------------------
class _DetailsTab extends ConsumerWidget {
  final TextEditingController notesCtrl;
  final TextEditingController collectionNameCtrl;
  final TextEditingController collectionNumberCtrl;
  final List<Tag> selectedTags;
  final ValueChanged<Tag> onAddTag;
  final ValueChanged<Tag> onRemoveTag;
  final void Function(String name) onCreateTag;
  final List<_PendingTag> pendingTags;
  final void Function(_PendingTag) onRemovePending;

  const _DetailsTab({
    required this.notesCtrl,
    required this.collectionNameCtrl,
    required this.collectionNumberCtrl,
    required this.selectedTags,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onCreateTag,
    required this.pendingTags,
    required this.onRemovePending,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(label: 'Colección / Serie'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Autocomplete<Tag>(
                displayStringForOption: (t) => t.name,
                optionsBuilder: (textEditingValue) async {
                  final input = textEditingValue.text.trim();
                  if (input.isEmpty) return [];
                  return ref.read(databaseProvider).searchTags(input, 'collection');
                },
                onSelected: (tag) {
                  collectionNameCtrl.text = tag.name;
                },
                fieldViewBuilder: (_, controller, focusNode, _) {
                  controller.text = collectionNameCtrl.text;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: (v) => collectionNameCtrl.text = v,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la colección',
                      prefixIcon: Icon(Icons.collections_bookmark_outlined),
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _FormField(
                controller: collectionNumberCtrl,
                label: 'Nº',
                icon: Icons.tag,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _SectionHeader(label: 'Etiquetas'),
        const SizedBox(height: 4),
        Text(
          'Escribe y pulsa Enter para añadir o crear',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),

        // Chips de tags seleccionados
        if (selectedTags.isNotEmpty || pendingTags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ...selectedTags.map((tag) => Chip(
                label: Text(tag.name),
                backgroundColor: tag.color != null
                    ? Color(int.parse('0xFF${tag.color!}'))
                    : null,
                onDeleted: () => onRemoveTag(tag),
              )),
              ...pendingTags.map((p) => Chip(
                label: Text(p.name),
                avatar: const Icon(Icons.fiber_new, size: 16),
                onDeleted: () => onRemovePending(p),
              )),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Autocompletado
        Autocomplete<Tag>(
          displayStringForOption: (t) => t.name,
          optionsBuilder: (textEditingValue) async {
            final input = textEditingValue.text.trim();
            if (input.isEmpty) return [];
            final results = await ref.read(databaseProvider).searchTags(input, 'tag');
            return results.where(
                  (t) => !selectedTags.any((s) => s.id == t.id),
            ).toList();
          },
          onSelected: onAddTag,
          fieldViewBuilder: (_, controller, focusNode, _) => TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Buscar o crear etiqueta',
              prefixIcon: Icon(Icons.label_outline),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              final name = value.trim();
              if (name.isEmpty) return;
              onCreateTag(name);
              controller.clear();
            },
          ),
        ),
        const SizedBox(height: 24),

        _SectionHeader(label: 'Notas personales'),
        const SizedBox(height: 12),
        _FormField(
          controller: notesCtrl,
          label: 'Notas',
          icon: Icons.notes_outlined,
          maxLines: 6,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// -------------------------------------------------------
// Widgets auxiliares
// -------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool required;
  final TextInputType keyboardType;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    this.icon,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null
          : null,
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final ReadingStatus selected;
  final ValueChanged<ReadingStatus> onChanged;

  const _StatusSelector({required this.selected, required this.onChanged});

  static const _options = [
    (ReadingStatus.wantToRead, 'Por leer', Icons.bookmark_outline,
    Colors.orange),
    (ReadingStatus.reading, 'Leyendo', Icons.auto_stories, Colors.blue),
    (ReadingStatus.read, 'Leído', Icons.check_circle_outline, Colors.green),
    (ReadingStatus.abandoned, 'Abandonado', Icons.close, Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((opt) {
        final (status, label, icon, color) = opt;
        final isSelected = selected == status;
        return ChoiceChip(
          avatar: Icon(icon, size: 16, color: isSelected ? color : null),
          label: Text(label),
          selected: isSelected,
          selectedColor: color.withValues(alpha: 0.15),
          onSelected: (_) => onChanged(status),
        );
      }).toList(),
    );
  }
}

class _FormatSelector extends StatelessWidget {
  final BookFormat? selected;
  final ValueChanged<BookFormat?> onChanged;

  const _FormatSelector({this.selected, required this.onChanged});

  static const _options = [
    (BookFormat.paperback, 'Tapa blanda'),
    (BookFormat.hardcover, 'Tapa dura'),
    (BookFormat.leatherbound, 'Piel'),
    (BookFormat.rustic, 'Rústica'),
    (BookFormat.digital, 'Digital'),
    (BookFormat.other, 'Otro'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((opt) {
        final (format, label) = opt;
        final isSelected = selected == format;
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onChanged(isSelected ? null : format),
        );
      }).toList(),
    );
  }
}

class _RatingSelector extends StatelessWidget {
  final double? rating;
  final ValueChanged<double?> onChanged;

  const _RatingSelector({this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          final star = i + 1;
          return IconButton(
            icon: Icon(
              rating != null && rating! >= star
                  ? Icons.star
                  : Icons.star_border,
              color: Colors.amber[700],
            ),
            onPressed: () => onChanged(
                rating == star.toDouble() ? null : star.toDouble()),
          );
        }),
        if (rating != null)
          Text(
            rating!.toStringAsFixed(0),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    );
  }
}