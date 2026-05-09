import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/database.dart';
import '../../services/cover_service.dart';
import '../../services/permission_service.dart';
import '../../controllers/database_provider.dart';
import '../../widgets/tag_chip.dart';
import '../../models/book_search_result.dart';

class BookFormView extends ConsumerStatefulWidget {
  final Book? existingBook;
  final BookSearchResult? prefill;
  const BookFormView({super.key, this.existingBook, this.prefill});

  @override
  ConsumerState<BookFormView> createState() => _BookFormViewState();
}

// Tag pendiente de persistir — solo tiene nombre, aún sin id
class _PendingTag {
  final String name;
  String? color;
  _PendingTag({required this.name});
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
  late final TextEditingController _publishYearCtrl;

  ReadingStatus _status = ReadingStatus.wantToRead;
  BookFormat? _format;
  double? _rating;
  bool _isSaving = false;
  String? _coverPath;
  List<Tag> _selectedTags = [];        // tags ya existentes en BD
  Tag? _selectedImprint;
  final List<_PendingTag> _pendingTags = []; // tags nuevos, aún no persistidos

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final b = widget.existingBook;
    final pre = widget.prefill;
    _titleCtrl = TextEditingController(text: b?.title ?? pre?.title ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? pre?.author ?? '');
    _isbnCtrl = TextEditingController(text: b?.isbn ?? pre?.isbn ?? '');
    _publisherCtrl = TextEditingController(
        text: b?.publisher ?? pre?.publisher ?? '');
    _totalPagesCtrl = TextEditingController(
        text: b?.totalPages?.toString() ?? pre?.totalPages?.toString() ?? '');
    _currentPageCtrl = TextEditingController(text: '0');
    _notesCtrl = TextEditingController(text: b?.notes ?? '');
    _collectionNameCtrl =
        TextEditingController(text: b?.collectionName ?? '');
    _collectionNumberCtrl =
        TextEditingController(text: b?.collectionNumber?.toString() ?? '');
    _publishYearCtrl = TextEditingController(
        text: b?.publishYear?.toString() ?? pre?.publishYear?.toString() ?? '');
    if (b != null) {
      _status = b.status;
      _format = b.bookFormat;
      _rating = b.rating;
      _coverPath = b.coverPath;
      _currentPageCtrl.text = b.currentPage?.toString() ?? '0';
      _loadExistingTags(b.id);
      _loadExistingImprint(b.id);
    } else if (pre?.coverUrl != null) {
      // Pre-carga la portada desde la URL de Open Library en background
      _prefillCoverFromUrl(pre!.coverUrl!);
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
    _publishYearCtrl.dispose();
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

  Future<void> _prefillCoverFromUrl(String url) async {
    final saved = await CoverService.saveCoverFromUrl(url);
    if (saved != null && mounted) {
      setState(() => _coverPath = saved);
    }
  }

  Future<void> _pickCover() async {
    if (!await PermissionService.requestGallery()) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final cropped = await CoverService.cropCover(picked.path);
    if (cropped == null) return;
    final saved = await CoverService.saveCover(cropped);
    setState(() => _coverPath = saved);
  }

  Future<void> _takePhoto() async {
    if (!await PermissionService.requestCamera()) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    final cropped = await CoverService.cropCover(picked.path);
    if (cropped == null) return;
    final saved = await CoverService.saveCover(cropped);
    setState(() => _coverPath = saved);
  }

  Future<void> _pickCoverFromUrl() async {
    final ctrl = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('URL de la portada'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://ejemplo.com/portada.jpg',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Descargar'),
          ),
        ],
      ),
    );
    if (url == null || url.isEmpty) return;
    setState(() => _isSaving = true);
    final saved = await CoverService.saveCoverFromUrl(url);
    setState(() {
      _isSaving = false;
      if (saved != null) _coverPath = saved;
    });
    if (saved == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo descargar la imagen')),
      );
    }
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
        publishYear: Value(int.tryParse(_publishYearCtrl.text)),
      );
      await db.updateBook(updated);
      // Limpiar colección anterior si cambió o se borró
      final oldCollection = widget.existingBook!.collectionName;
      final newCollection = _collectionNameCtrl.text.trim().isEmpty
          ? null
          : _collectionNameCtrl.text.trim();
      if (oldCollection != null && oldCollection != newCollection) {
        await db.pruneCollectionIfOrphan(oldCollection);
      }
      final existingIds = _selectedTags.map((t) => t.id).toList();
      for (final p in _pendingTags) {
        final newId = await db.insertTag(
          TagsCompanion(
            name: Value(p.name),
            type: const Value('tag'),
            color: Value(p.color),
          ),
        );
        existingIds.add(newId);
      }
      await db.setBookTags(widget.existingBook!.id, existingIds);
      await db.setBookImprint(
        widget.existingBook!.id,
        _selectedImprint?.id,
      );
      await db.pruneOrphanTags();
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
        publishYear: Value(int.tryParse(_publishYearCtrl.text)),
      );
      final newId = await db.insertBook(companion);
      final existingIds = _selectedTags.map((t) => t.id).toList();
      for (final p in _pendingTags) {
        final newId = await db.insertTag(
          TagsCompanion(
            name: Value(p.name),
            type: const Value('tag'),
            color: Value(p.color),
          ),
        );
        existingIds.add(newId);
      }
      await db.setBookTags(newId, existingIds);
      await db.setBookImprint(newId, _selectedImprint?.id);
      // Registrar colección si tiene nombre
      final collectionName = _collectionNameCtrl.text.trim();
      if (collectionName.isNotEmpty) {
        await db.getOrCreateCollection(collectionName);
      }
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _showTagPicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Categorías',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Tag>>(
                  future: ref.read(databaseProvider).getTagsByType('tag'),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final allTags = snapshot.data!;
                    if (allTags.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay categorías creadas todavía',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      );
                    }
                    return StatefulBuilder(
                      builder: (context, setStateSheet) => SingleChildScrollView(
                        controller: scrollController,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: allTags.map((tag) {
                            final isSelected = _selectedTags.any((t) => t.id == tag.id)
                                || _pendingTags.any((p) => p.name == tag.name);
                            final baseColor = tag.color != null
                                ? Color(int.parse('0xFF${tag.color!}'))
                                : Theme.of(context).colorScheme.secondaryContainer;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedTags.removeWhere((t) => t.id == tag.id);
                                  } else {
                                    if (!_selectedTags.any((t) => t.id == tag.id)) {
                                      _selectedTags.add(tag);
                                    }
                                  }
                                });
                                setStateSheet(() {});
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? baseColor.withValues(alpha: 0.25)
                                      : baseColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: isSelected
                                      ? Border.all(color: baseColor, width: 1.5)
                                      : Border.all(color: Colors.transparent, width: 1.5),
                                ),
                                child: Text(
                                  tag.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: tag.color != null
                                        ? baseColor
                                        : Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hecho'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showColorPicker(BuildContext context, {
    Tag? existingTag,
    _PendingTag? pendingTag,
  }) async {
    final colors = [
      ('E53935', 'Rojo'),
      ('D81B60', 'Rosa'),
      ('8E24AA', 'Morado'),
      ('3949AB', 'Índigo'),
      ('1E88E5', 'Azul'),
      ('00ACC1', 'Cian'),
      ('00897B', 'Verde azulado'),
      ('43A047', 'Verde'),
      ('C0CA33', 'Lima'),
      ('FB8C00', 'Naranja'),
      ('6D4C41', 'Marrón'),
      ('757575', 'Gris'),
    ];

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Color de la etiqueta',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((c) {
                final (hex, name) = c;
                final color = Color(int.parse('0xFF$hex'));
                final currentHex = existingTag?.color ?? pendingTag?.color;
                final isSelected = currentHex == hex;
                return GestureDetector(
                  onTap: () async {
                    if (existingTag != null) {
                      final updated = Tag(
                        id: existingTag.id,
                        name: existingTag.name,
                        type: existingTag.type,
                        color: hex,
                        imagePath: existingTag.imagePath,
                      );
                      await ref.read(databaseProvider).updateTag(updated);
                      setState(() {
                        final idx = _selectedTags.indexWhere((t) => t.id == existingTag.id);
                        if (idx != -1) _selectedTags[idx] = updated;
                      });
                    } else if (pendingTag != null) {
                      setState(() => pendingTag.color = hex);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6)]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _loadExistingTags(int bookId) async {
    final db = ref.read(databaseProvider);
    final existing = await db.watchTagsForBook(bookId).first;
    setState(() => _selectedTags = existing);
  }

  Future<void> _loadExistingImprint(int bookId) async {
    final db = ref.read(databaseProvider);
    final existing = await db.watchImprintForBook(bookId).first;
    setState(() => _selectedImprint = existing);
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
              publishYearCtrl: _publishYearCtrl,
              status: _status,
              format: _format,
              rating: _rating,
              coverPath: _coverPath,
              onStatusChanged: _onStatusChanged,
              onFormatChanged: (f) => setState(() => _format = f),
              onRatingChanged: (r) => setState(() => _rating = r),
              onPickCover: _pickCover,
              onTakePhoto: _takePhoto,
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
              onTapTagColor: ({Tag? existingTag, _PendingTag? pendingTag}) =>
                  _showColorPicker(context, existingTag: existingTag, pendingTag: pendingTag),
              onTapGrid: () => _showTagPicker(context),
              onPickCoverFromUrl: _pickCoverFromUrl,
            ),
            _DetailsTab(
              notesCtrl: _notesCtrl,
              collectionNameCtrl: _collectionNameCtrl,
              collectionNumberCtrl: _collectionNumberCtrl,
              selectedImprint: _selectedImprint,
              onSelectImprint: (tag) => setState(() => _selectedImprint = tag),
              onClearImprint: () => setState(() => _selectedImprint = null),
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
  final TextEditingController publishYearCtrl;
  final ReadingStatus status;
  final BookFormat? format;
  final double? rating;
  final String? coverPath;
  final ValueChanged<ReadingStatus> onStatusChanged;
  final ValueChanged<BookFormat?> onFormatChanged;
  final ValueChanged<double?> onRatingChanged;
  final VoidCallback onPickCover;
  final VoidCallback onTakePhoto;
  final List<Tag> selectedTags;
  final List<_PendingTag> pendingTags;
  final ValueChanged<Tag> onAddTag;
  final ValueChanged<Tag> onRemoveTag;
  final void Function(String) onCreateTag;
  final void Function(_PendingTag) onRemovePending;
  final void Function({Tag? existingTag, _PendingTag? pendingTag}) onTapTagColor;
  final VoidCallback onTapGrid;
  final VoidCallback onPickCoverFromUrl;

  const _MainTab({
    required this.titleCtrl,
    required this.authorCtrl,
    required this.isbnCtrl,
    required this.publisherCtrl,
    required this.totalPagesCtrl,
    required this.currentPageCtrl,
    required this.publishYearCtrl,
    required this.status,
    required this.format,
    required this.rating,
    required this.coverPath,
    required this.onStatusChanged,
    required this.onFormatChanged,
    required this.onRatingChanged,
    required this.onPickCover,
    required this.onTakePhoto,
    required this.selectedTags,
    required this.pendingTags,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onCreateTag,
    required this.onRemovePending,
    required this.onTapTagColor,
    required this.onTapGrid,
    required this.onPickCoverFromUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- Portada ---
        Center(
          child: Column(
            children: [
              GestureDetector(
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
                        child: Icon(
                            Icons.photo_library_outlined,
                            size: 14,
                            color: colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: const Text('Foto'),
                    onPressed: onTakePhoto,
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    icon: const Icon(Icons.link, size: 16),
                    label: const Text('URL'),
                    onPressed: onPickCoverFromUrl,
                  ),
                ],
              ),
            ],
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
          controller: publishYearCtrl,
          label: 'Año de publicación',
          icon: Icons.calendar_today_outlined,
          keyboardType: TextInputType.number,
        ),
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
              ...selectedTags.map((tag) => TagChip(
                label: tag.name,
                colorHex: tag.color,
                onTap: () => onTapTagColor(existingTag: tag),
                onDeleted: () => onRemoveTag(tag),
              )),
              ...pendingTags.map((p) => TagChip(
                label: p.name,
                colorHex: p.color,
                onTap: () => onTapTagColor(pendingTag: p),
                onDeleted: () => onRemovePending(p),
              )),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Autocomplete<Tag>(
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
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: onTapGrid,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Icon(Icons.grid_view),
              ),
            ),
          ],
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
  final Tag? selectedImprint;
  final ValueChanged<Tag> onSelectImprint;
  final VoidCallback onClearImprint;

  const _DetailsTab({
    required this.notesCtrl,
    required this.collectionNameCtrl,
    required this.collectionNumberCtrl,
    required this.selectedImprint,
    required this.onSelectImprint,
    required this.onClearImprint,
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

        _SectionHeader(label: 'Sello editorial'),
        const SizedBox(height: 12),
        _ImprintSelector(
          selected: selectedImprint,
          onSelect: onSelectImprint,
          onClear: onClearImprint,
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

class _ImprintSelector extends ConsumerWidget {
  final Tag? selected;
  final ValueChanged<Tag> onSelect;
  final VoidCallback onClear;

  const _ImprintSelector({
    required this.selected,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selected != null) ...[
          _ImprintRow(imprint: selected!, onClear: onClear),
          const SizedBox(height: 12),
        ],
        Autocomplete<Tag>(
          displayStringForOption: (t) => t.name,
          optionsBuilder: (textEditingValue) async {
            final input = textEditingValue.text.trim();
            if (input.isEmpty) return [];
            return ref.read(databaseProvider).searchTags(input, 'imprint');
          },
          onSelected: (tag) => onSelect(tag),
          fieldViewBuilder: (_, controller, focusNode, _) => TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Buscar sello editorial',
              prefixIcon: Icon(Icons.business_outlined),
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImprintRow extends StatelessWidget {
  final Tag imprint;
  final VoidCallback onClear;

  const _ImprintRow({required this.imprint, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imprint.imagePath != null
                  ? Image.file(
                File(imprint.imagePath!),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business_outlined,
                  size: 32,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              imprint.name,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: onClear,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 14,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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