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
  late final TextEditingController _labelCtrl;

  ReadingStatus _status = ReadingStatus.wantToRead;
  BookFormat? _format;
  double? _rating;
  bool _isSaving = false;
  String? _coverPath;
  final List<String> _labels = [];

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
    _labelCtrl = TextEditingController();
    if (b != null) {
      _status = b.status;
      _format = b.bookFormat;
      _rating = b.rating;
      _coverPath = b.coverPath;
      _currentPageCtrl.text = b.currentPage?.toString() ?? '0';
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
    _labelCtrl.dispose();
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
      await db.insertBook(companion);
    }

    if (mounted) Navigator.pop(context);
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
            ),
            _DetailsTab(
              notesCtrl: _notesCtrl,
              collectionNameCtrl: _collectionNameCtrl,
              collectionNumberCtrl: _collectionNumberCtrl,
              labelCtrl: _labelCtrl,
              labels: _labels,
              onAddLabel: (label) {
                if (label.trim().isNotEmpty &&
                    !_labels.contains(label.trim())) {
                  setState(() => _labels.add(label.trim()));
                  _labelCtrl.clear();
                }
              },
              onRemoveLabel: (label) =>
                  setState(() => _labels.remove(label)),
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
class _MainTab extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
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
            '⚠ Guarda las imágenes en una carpeta fija para evitar perderlas',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.error,
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

        // --- Estado ---
        _SectionHeader(label: 'Estado de lectura'),
        const SizedBox(height: 12),
        _StatusSelector(selected: status, onChanged: onStatusChanged),
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
class _DetailsTab extends StatelessWidget {
  final TextEditingController notesCtrl;
  final TextEditingController collectionNameCtrl;
  final TextEditingController collectionNumberCtrl;
  final TextEditingController labelCtrl;
  final List<String> labels;
  final ValueChanged<String> onAddLabel;
  final ValueChanged<String> onRemoveLabel;

  const _DetailsTab({
    required this.notesCtrl,
    required this.collectionNameCtrl,
    required this.collectionNumberCtrl,
    required this.labelCtrl,
    required this.labels,
    required this.onAddLabel,
    required this.onRemoveLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- Colección ---
        _SectionHeader(label: 'Colección / Serie'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _FormField(
                controller: collectionNameCtrl,
                label: 'Nombre de la colección',
                icon: Icons.collections_bookmark_outlined,
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

        // --- Etiquetas / Sellos ---
        _SectionHeader(label: 'Etiquetas'),
        const SizedBox(height: 4),
        Text(
          'Sellos editoriales, géneros, colecciones temáticas…',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nueva etiqueta',
                  prefixIcon: Icon(Icons.label_outline),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: onAddLabel,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.add),
              onPressed: () => onAddLabel(labelCtrl.text),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (labels.isEmpty)
          Text(
            'Sin etiquetas todavía',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: labels
                .map((label) => Chip(
              label: Text(label),
              onDeleted: () => onRemoveLabel(label),
            ))
                .toList(),
          ),
        const SizedBox(height: 24),

        // --- Notas ---
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