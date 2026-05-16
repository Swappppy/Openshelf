import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/database.dart';
import '../../services/cover_service.dart';
import '../../services/permission_service.dart';
import '../../controllers/database_provider.dart';
import '../../controllers/books_controller.dart';
import '../../widgets/tag_chip.dart';
import '../../models/book_search_result.dart';
import '../../l10n/l10n_extension.dart';
import 'cover_picker_sheet.dart';

/// Form for adding a new book or editing an existing one.
/// Supports prefilling from external search results and handling M:M relationships.
class BookFormView extends ConsumerStatefulWidget {
  final Book? existingBook;
  final BookSearchResult? prefill;
  const BookFormView({super.key, this.existingBook, this.prefill});

  @override
  ConsumerState<BookFormView> createState() => _BookFormViewState();
}

/// Helper model for tags created during the form session but not yet saved to DB.
class _PendingTag {
  final String name;
  String? color;
  _PendingTag({required this.name});
}

class _BookFormViewState extends ConsumerState<BookFormView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TabController _tabController;

  // Controllers
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _languageCtrl;
  late final TextEditingController _translatorCtrl;
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
  DateTime? _startedAt;
  DateTime? _finishedAt;
  List<Tag> _selectedTags = [];        
  Tag? _selectedImprint;
  final List<_PendingTag> _pendingTags = []; 
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final b = widget.existingBook;
    final pre = widget.prefill;
    
    _titleCtrl = TextEditingController(text: b?.title ?? pre?.title ?? '');
    _subtitleCtrl = TextEditingController(text: b?.subtitle ?? pre?.subtitle ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? pre?.authors.join(', ') ?? '');
    _isbnCtrl = TextEditingController(text: b?.isbn ?? pre?.isbn ?? '');
    _languageCtrl = TextEditingController(text: b?.language ?? pre?.language ?? '');
    _translatorCtrl = TextEditingController(text: b?.translator ?? pre?.translator ?? '');
    _publisherCtrl = TextEditingController(
        text: b?.publisher ?? pre?.publisher ?? '');
    _totalPagesCtrl = TextEditingController(
        text: b?.totalPages?.toString() ?? pre?.pageCount?.toString() ?? '');
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
      _startedAt = b.startedAt;
      _finishedAt = b.finishedAt;
      _currentPageCtrl.text = b.currentPage?.toString() ?? '0';
      _loadExistingTags(b.id);
      _loadExistingImprint(b.id);
    } else if (pre?.coverUrl != null) {
      // Auto-prefill cover from provided URL in the background
      _prefillCoverFromUrl(pre!.coverUrl!);
    }
    
    _currentPageCtrl.addListener(_updateStatusFromPages);
    _totalPagesCtrl.addListener(_updateStatusFromPages);
    
    // End initialization phase in the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isInitializing = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _authorCtrl.dispose();
    _isbnCtrl.dispose();
    _languageCtrl.dispose();
    _translatorCtrl.dispose();
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

  /// Adjusts page count based on selected status.
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
      case ReadingStatus.paused:
        break;
    }
  }

  Future<void> _prefillCoverFromUrl(String url) async {
    final title = context.l10n.cropCoverTitle;
    final saved = await CoverService.saveCoverFromUrl(
      url, 
      cropTitle: title,
      doneButtonTitle: context.l10n.done,
      cancelButtonTitle: context.l10n.cancel,
    );
    if (saved != null && mounted) {
      setState(() => _coverPath = saved);
    }
  }

  Future<void> _pickCover() async {
    if (!await PermissionService.requestGallery()) return;
    if (!mounted) return;
    
    final l10n = context.l10n;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    
    final cropped = await CoverService.cropCover(
      picked.path, 
      title: l10n.cropCoverTitle,
      doneButtonTitle: l10n.done,
      cancelButtonTitle: l10n.cancel,
    );
    
    if (cropped != null) {
      final saved = await CoverService.saveLocalCover(cropped);
      setState(() => _coverPath = saved);
    }
  }

  Future<void> _takePhoto() async {
    if (!await PermissionService.requestCamera()) return;
    if (!mounted) return;
    
    final l10n = context.l10n;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    
    final cropped = await CoverService.cropCover(
      picked.path, 
      title: l10n.cropCoverTitle,
      doneButtonTitle: l10n.done,
      cancelButtonTitle: l10n.cancel,
    );

    if (cropped != null) {
      final saved = await CoverService.saveLocalCover(cropped);
      setState(() => _coverPath = saved);
    }
  }

  Future<void> _pickCoverFromUrl() async {
    final ctrl = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.coverUrlDialogTitle),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: context.l10n.coverUrlHint,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(context.l10n.download),
          ),
        ],
      ),
    );
    if (url == null || url.isEmpty) return;
    if (!mounted) return;
    
    setState(() => _isSaving = true);
    final title = context.l10n.cropCoverTitle;
    final saved = await CoverService.saveCoverFromUrl(
      url, 
      cropTitle: title,
      doneButtonTitle: context.l10n.done,
      cancelButtonTitle: context.l10n.cancel,
    );
    setState(() {
      _isSaving = false;
      if (saved != null) _coverPath = saved;
    });
    if (saved == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.coverDownloadError)),
      );
    }
  }

  Future<void> _searchCovers() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CoverPickerSheet(
        isbn: _isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim(),
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        author: _authorCtrl.text.trim().isEmpty ? null : _authorCtrl.text.trim(),
        publisher: _publisherCtrl.text.trim().isEmpty
            ? null
            : _publisherCtrl.text.trim(),
        onCoverSelected: (path) => setState(() => _coverPath = path),
      ),
    );
  }

  /// Handles saving the book and all its associations (tags, imprints, collections) to the DB.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    final db = ref.read(databaseProvider);
    final isbn = _isbnCtrl.text.trim();

    // Check for duplicates by ISBN (new books only)
    if (widget.existingBook == null && isbn.isNotEmpty) {
      final existing = await db.getBookByIsbn(isbn);
      if (existing != null && mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.bookDuplicateTitle),
            content: Text(context.l10n.bookDuplicateContent(isbn)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.l10n.addBook),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }
    }

    setState(() => _isSaving = true);

    if (widget.existingBook != null) {
      // Update existing record
      final updated = widget.existingBook!.copyWith(
        title: _titleCtrl.text.trim(),
        subtitle: Value(_subtitleCtrl.text.trim().isEmpty ? null : _subtitleCtrl.text.trim()),
        author: _authorCtrl.text.trim(),
        isbn: Value(_isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim()),
        language: Value(_languageCtrl.text.trim().isEmpty ? null : _languageCtrl.text.trim()),
        translator: Value(_translatorCtrl.text.trim().isEmpty ? null : _translatorCtrl.text.trim()),
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
        startedAt: Value(_startedAt),
        finishedAt: Value(_finishedAt),
      );
      await db.updateBook(updated);
      
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
      await db.setBookImprint(widget.existingBook!.id, _selectedImprint?.id);
      await db.pruneOrphanTags();
    } else {
      // Insert new record
      final companion = BooksCompanion.insert(
        title: _titleCtrl.text.trim(),
        subtitle: Value(_subtitleCtrl.text.trim().isEmpty ? null : _subtitleCtrl.text.trim()),
        author: _authorCtrl.text.trim(),
        isbn: Value(_isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim()),
        language: Value(_languageCtrl.text.trim().isEmpty ? null : _languageCtrl.text.trim()),
        translator: Value(_translatorCtrl.text.trim().isEmpty ? null : _translatorCtrl.text.trim()),
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
        startedAt: Value(_startedAt),
        finishedAt: Value(_finishedAt),
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
    }

    // Auto-create collection tag if name provided
    final collectionName = _collectionNameCtrl.text.trim();
    if (collectionName.isNotEmpty) {
      await db.getOrCreateCollection(collectionName);
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
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                context.l10n.sectionCategories,
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
                          context.l10n.tagNoCategories,
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
                                padding: const EdgeInsets.all(8),
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
                  child: Text(context.l10n.done),
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
      'E53935', 'D81B60', '8E24AA', '3949AB', '1E88E5', '00ACC1',
      '00897B', '43A047', 'C0CA33', 'FB8C00', '6D4C41', '757575',
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
              context.l10n.tagColorLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((hex) {
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

  /// Automatically updates reading status based on page progress.
  void _updateStatusFromPages() {
    if (_isInitializing) return;
    
    final current = int.tryParse(_currentPageCtrl.text);
    final total = int.tryParse(_totalPagesCtrl.text);
    if (current == null || total == null || total == 0) return;

    // Do not auto-update if status is terminal or paused
    if (_status == ReadingStatus.abandoned || _status == ReadingStatus.paused) return;

    ReadingStatus newStatus;
    if (current == 0) {
      newStatus = ReadingStatus.wantToRead;
    } else if (current >= total) {
      newStatus = ReadingStatus.read;
      // Sync current page to total if exceeded
      if (current > total) {
        _currentPageCtrl.text = total.toString();
        _currentPageCtrl.selection = TextSelection.fromPosition(
          TextPosition(offset: _currentPageCtrl.text.length),
        );
      }
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
            widget.existingBook != null ? context.l10n.bookFormEditTitle : context.l10n.bookFormNewTitle),
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
                : Text(context.l10n.save),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.menu_book_outlined), text: context.l10n.tabMain),
            Tab(icon: const Icon(Icons.label_outline), text: context.l10n.tabDetails),
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
              subtitleCtrl: _subtitleCtrl,
              authorCtrl: _authorCtrl,
              isbnCtrl: _isbnCtrl,
              languageCtrl: _languageCtrl,
              translatorCtrl: _translatorCtrl,
              publisherCtrl: _publisherCtrl,
              totalPagesCtrl: _totalPagesCtrl,
              currentPageCtrl: _currentPageCtrl,
              publishYearCtrl: _publishYearCtrl,
              status: _status,
              format: _format,
              rating: _rating,
              coverPath: _coverPath,
              startedAt: _startedAt,
              finishedAt: _finishedAt,
              onStatusChanged: _onStatusChanged,
              onFormatChanged: (f) => setState(() => _format = f),
              onRatingChanged: (r) => setState(() => _rating = r),
              onStartedAtChanged: (d) => setState(() => _startedAt = d),
              onFinishedAtChanged: (d) => setState(() => _finishedAt = d),
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
              onSearchCovers: _searchCovers,
            ),
            _DetailsTab(
              notesCtrl: _notesCtrl,
              translatorCtrl: _translatorCtrl,
              collectionNameCtrl: _collectionNameCtrl,
              collectionNumberCtrl: _collectionNumberCtrl,
              selectedImprint: _selectedImprint,
              startedAt: _startedAt,
              finishedAt: _finishedAt,
              onStartedAtChanged: (d) => setState(() => _startedAt = d),
              onFinishedAtChanged: (d) => setState(() => _finishedAt = d),
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
// Main Tab
// -------------------------------------------------------
class _MainTab extends ConsumerWidget {
  final TextEditingController titleCtrl;
  final TextEditingController subtitleCtrl;
  final TextEditingController authorCtrl;
  final TextEditingController isbnCtrl;
  final TextEditingController languageCtrl;
  final TextEditingController translatorCtrl;
  final TextEditingController publisherCtrl;
  final TextEditingController totalPagesCtrl;
  final TextEditingController currentPageCtrl;
  final TextEditingController publishYearCtrl;
  final ReadingStatus status;
  final BookFormat? format;
  final double? rating;
  final String? coverPath;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final ValueChanged<ReadingStatus> onStatusChanged;
  final ValueChanged<BookFormat?> onFormatChanged;
  final ValueChanged<double?> onRatingChanged;
  final ValueChanged<DateTime?> onStartedAtChanged;
  final ValueChanged<DateTime?> onFinishedAtChanged;
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
  final VoidCallback onSearchCovers;

  const _MainTab({
    required this.titleCtrl,
    required this.subtitleCtrl,
    required this.authorCtrl,
    required this.isbnCtrl,
    required this.languageCtrl,
    required this.translatorCtrl,
    required this.publisherCtrl,
    required this.totalPagesCtrl,
    required this.currentPageCtrl,
    required this.publishYearCtrl,
    required this.status,
    required this.format,
    required this.rating,
    this.coverPath,
    this.startedAt,
    this.finishedAt,
    required this.onStatusChanged,
    required this.onFormatChanged,
    required this.onRatingChanged,
    required this.onStartedAtChanged,
    required this.onFinishedAtChanged,
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
    required this.onSearchCovers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- Cover Image Selection ---
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
                        errorBuilder: (context, error, stackTrace) => const _CoverPlaceholder(width: 100, height: 150, iconSize: 48),
                      )
                          : const _CoverPlaceholder(width: 100, height: 150, iconSize: 48),
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
                    label: Text(context.l10n.photo),
                    onPressed: onTakePhoto,
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    icon: const Icon(Icons.link, size: 16),
                    label: Text(context.l10n.url),
                    onPressed: onPickCoverFromUrl,
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    icon: const Icon(Icons.image_search, size: 16),
                    label: Text(context.l10n.coverSearch),
                    onPressed: onSearchCovers,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // --- Basic Info Section ---
        _SectionHeader(label: context.l10n.sectionBasicInfo),
        const SizedBox(height: 12),
        _FormField(
            controller: titleCtrl, label: context.l10n.fieldTitle, required: true,
            icon: Icons.title),
        const SizedBox(height: 12),
        _FormField(
            controller: subtitleCtrl, label: context.l10n.fieldSubtitle,
            icon: Icons.subtitles_outlined),
        const SizedBox(height: 12),
        _FormField(
            controller: authorCtrl, label: context.l10n.fieldAuthor, required: true,
            icon: Icons.person_outline),
        const SizedBox(height: 12),
        _FormField(
            controller: publisherCtrl,
            label: context.l10n.fieldPublisher,
            icon: Icons.business_outlined),
        const SizedBox(height: 12),
        _FormField(
          controller: publishYearCtrl,
          label: context.l10n.fieldYear,
          icon: Icons.calendar_today_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _FormField(
            controller: isbnCtrl,
            label: context.l10n.fieldIsbn,
            icon: Icons.barcode_reader,
            keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        _FormField(
            controller: languageCtrl,
            label: context.l10n.fieldLanguage,
            icon: Icons.language_outlined),
        const SizedBox(height: 24),


        // --- Categories (Tags) Section ---
        _SectionHeader(label: context.l10n.sectionCategories),
        const SizedBox(height: 4),
        Text(
          context.l10n.tagCreateHint,
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
                  decoration: InputDecoration(
                    labelText: context.l10n.tagSearchOrCreate,
                    prefixIcon: const Icon(Icons.label_outline),
                    border: const OutlineInputBorder(),
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

        // --- Reading Progress Section ---
        _SectionHeader(label: context.l10n.fieldReadingProgress),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FormField(
                controller: totalPagesCtrl,
                label: context.l10n.fieldTotalPages,
                icon: Icons.menu_book_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FormField(
                controller: currentPageCtrl,
                label: context.l10n.fieldCurrentPage,
                icon: Icons.bookmark_outline,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        // --- Status Section ---
        _SectionHeader(label: context.l10n.sectionReadingStatus),
        const SizedBox(height: 12),
        _StatusSelector(selected: status, onChanged: onStatusChanged),
        const SizedBox(height: 24),

        // --- Format Section ---
        _SectionHeader(label: context.l10n.sectionFormat),
        const SizedBox(height: 12),
        _FormatSelector(selected: format, onChanged: onFormatChanged),
        const SizedBox(height: 24),

        // --- Rating Section ---
        _SectionHeader(label: context.l10n.sectionRating),
        const SizedBox(height: 12),
        _RatingSelector(rating: rating, onChanged: onRatingChanged),
        const SizedBox(height: 32),
      ],
    );
  }
}

// -------------------------------------------------------
// Details Tab
// -------------------------------------------------------
class _DetailsTab extends ConsumerWidget {
  final TextEditingController notesCtrl;
  final TextEditingController translatorCtrl;
  final TextEditingController collectionNameCtrl;
  final TextEditingController collectionNumberCtrl;
  final Tag? selectedImprint;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final ValueChanged<DateTime?> onStartedAtChanged;
  final ValueChanged<DateTime?> onFinishedAtChanged;
  final ValueChanged<Tag> onSelectImprint;
  final VoidCallback onClearImprint;

  const _DetailsTab({
    required this.notesCtrl,
    required this.translatorCtrl,
    required this.collectionNameCtrl,
    required this.collectionNumberCtrl,
    required this.selectedImprint,
    this.startedAt,
    this.finishedAt,
    required this.onStartedAtChanged,
    required this.onFinishedAtChanged,
    required this.onSelectImprint,
    required this.onClearImprint,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(label: context.l10n.fieldCollection),
        const SizedBox(height: 12),
        // ... (collection autocomplete)
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
                    decoration: InputDecoration(
                      labelText: context.l10n.fieldCollection,
                      prefixIcon: const Icon(Icons.collections_bookmark_outlined),
                      border: const OutlineInputBorder(),
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
                label: context.l10n.fieldCollectionNumber,
                icon: Icons.tag,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _SectionHeader(label: context.l10n.sectionImprint),
        const SizedBox(height: 12),
        _ImprintSelector(
          selected: selectedImprint,
          onSelect: onSelectImprint,
          onClear: onClearImprint,
        ),
        const SizedBox(height: 24),

        _SectionHeader(label: context.l10n.fieldTranslator),
        const SizedBox(height: 12),
        _FormField(
          controller: translatorCtrl,
          label: context.l10n.fieldTranslator,
          icon: Icons.translate_outlined,
        ),
        const SizedBox(height: 24),

        _SectionHeader(label: context.l10n.bookDetailNotesTitle),
        const SizedBox(height: 12),
        _FormField(
          controller: notesCtrl,
          label: context.l10n.fieldNotes,
          icon: Icons.notes_outlined,
          maxLines: 6,
        ),
        const SizedBox(height: 24),

        _SectionHeader(label: context.l10n.tabDetails),
        const SizedBox(height: 12),
        _DatePickerField(
          label: context.l10n.bookDetailFieldStarted,
          value: startedAt,
          onChanged: onStartedAtChanged,
          icon: Icons.play_circle_outline,
        ),
        const SizedBox(height: 12),
        _DatePickerField(
          label: context.l10n.bookDetailFieldFinished,
          value: finishedAt,
          onChanged: onFinishedAtChanged,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// -------------------------------------------------------
// Helper Widgets
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
            decoration: InputDecoration(
              labelText: context.l10n.imprintSearch,
              prefixIcon: const Icon(Icons.business_outlined),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImprintRow extends ConsumerWidget {
  final Tag imprint;
  final VoidCallback onClear;

  const _ImprintRow({required this.imprint, required this.onClear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Thumbnail or initials
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imprint.imagePath != null
                    ? Image.file(
                  File(imprint.imagePath!),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _ImprintPlaceholder(size: 40, iconSize: 20, name: imprint.name),
                )
                    : _ImprintPlaceholder(size: 40, iconSize: 20, name: imprint.name),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      imprint.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Consumer(builder: (context, ref, _) {
                      final countAsync =
                      ref.watch(imprintBookCountProvider(imprint.id));
                      return countAsync.maybeWhen(
                        data: (count) => Text(
                          context.l10n.imprintBookCount(count),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
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
      (v == null || v.trim().isEmpty) ? context.l10n.requiredField : null
          : null,
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final ReadingStatus selected;
  final ValueChanged<ReadingStatus> onChanged;

  const _StatusSelector({required this.selected, required this.onChanged});

  static const _options = [
    (ReadingStatus.wantToRead, Icons.bookmark_outline, Colors.orange),
    (ReadingStatus.reading, Icons.auto_stories, Colors.blue),
    (ReadingStatus.read, Icons.check_circle_outline, Colors.green),
    (ReadingStatus.abandoned, Icons.close, Colors.red),
    (ReadingStatus.paused, Icons.pause_circle_outline, Color(0xFFB39DDB)),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((opt) {
        final (status, icon, color) = opt;
        final isSelected = selected == status;
        final label = switch (status) {
          ReadingStatus.wantToRead => context.l10n.statusWantToRead,
          ReadingStatus.reading => context.l10n.statusReading,
          ReadingStatus.read => context.l10n.statusRead,
          ReadingStatus.abandoned => context.l10n.statusAbandoned,
          ReadingStatus.paused => context.l10n.statusPaused,
        };
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
    BookFormat.paperback,
    BookFormat.hardcover,
    BookFormat.leatherbound,
    BookFormat.rustic,
    BookFormat.digital,
    BookFormat.other,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((format) {
        final label = switch (format) {
          BookFormat.paperback => context.l10n.formatPaperback,
          BookFormat.hardcover => context.l10n.formatHardcover,
          BookFormat.leatherbound => context.l10n.formatLeatherbound,
          BookFormat.rustic => context.l10n.formatRustic,
          BookFormat.digital => context.l10n.formatDigital,
          BookFormat.other => context.l10n.formatOther,
        };
        final isSelected = selected == format;
        final color = Theme.of(context).colorScheme.primary;
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          selectedColor: color.withValues(alpha: 0.15),
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

class _CoverPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double iconSize;

  const _CoverPlaceholder({
    this.width = 90,
    this.height = 130,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book,
        size: iconSize,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

class _ImprintPlaceholder extends StatelessWidget {
  final double size;
  final double iconSize;
  final String? name;

  const _ImprintPlaceholder({
    this.size = 80,
    this.iconSize = 32,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget content;
    if (name != null && name!.isNotEmpty) {
      final initials = name!
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .take(3)
          .map((w) => w[0].toUpperCase())
          .join();
      content = Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: size * 0.35,
          ),
        ),
      );
    } else {
      content = Icon(
        Icons.business_outlined,
        size: iconSize,
        color: colorScheme.outline,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: content,
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final IconData icon;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onChanged(null),
                )
              : null,
        ),
        child: Text(
          value != null
              ? '${value!.day}/${value!.month}/${value!.year}'
              : '—',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
