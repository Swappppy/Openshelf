import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/database.dart';
import '../../services/cover_service.dart';
import '../../services/permission_service.dart';
import '../../controllers/database_provider.dart';
import '../../controllers/shelf_automation_controller.dart';
import '../../controllers/reading_log_controller.dart';
import '../../widgets/entity_field_selector.dart';
import '../../widgets/tag_grid_selector.dart';
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
  late final TextEditingController _descriptionCtrl;
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
    _descriptionCtrl = TextEditingController(text: b?.description ?? '');
    _collectionNameCtrl =
        TextEditingController(text: b?.collectionName ?? '');
    _collectionNumberCtrl =
        TextEditingController(text: b?.collectionNumber?.toString() ?? '');
    _publishYearCtrl = TextEditingController(
        text: b?.publishYear?.toString() ?? pre?.publishYear?.toString() ?? '');
        
    _collectionNameCtrl.addListener(() {
      if (mounted) setState(() {});
    });

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
    _descriptionCtrl.dispose();
    _collectionNameCtrl.dispose();
    _collectionNumberCtrl.dispose();
    _publishYearCtrl.dispose();
    _currentPageCtrl.removeListener(_updateStatusFromPages);
    _totalPagesCtrl.removeListener(_updateStatusFromPages);
    super.dispose();
  }

  /// Adjusts page count based on selected status.
  void _onStatusChanged(ReadingStatus s) {
    setState(() {
      final oldStatus = _status;
      _status = s;
      if (s == ReadingStatus.read) {
        _finishedAt ??= DateTime.now();
      } else if (s == ReadingStatus.reading || s == ReadingStatus.wantToRead) {
        _finishedAt = null;
      }

      if (s == ReadingStatus.reading && oldStatus == ReadingStatus.wantToRead) {
        _startedAt ??= DateTime.now();
      }
    });
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
    if (!mounted) return;
    final title = context.l10n.cropCoverTitle;
    final l10n = context.l10n;
    final saved = await CoverService.saveCoverFromUrl(
      url, 
      cropTitle: title,
      doneButtonTitle: l10n.done,
      cancelButtonTitle: l10n.cancel,
    );
    if (saved != null && mounted) {
      setState(() => _coverPath = saved);
    }
  }

  Future<void> _pickCover() async {
    final result = await PermissionService.requestGallery();

    if (result == GalleryPermissionResult.permanentlyDenied) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(context.l10n.permissionRequired),
          content: Text(context.l10n.storagePermissionExplanation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                PermissionService.openSettings();
              },
              child: Text(context.l10n.openSettings),
            ),
          ],
        ),
      );
      return;
    }

    if (result != GalleryPermissionResult.granted) return;
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
    final granted = await PermissionService.requestCamera();

    if (!granted) {
      if (!mounted) return;
      final permanentlyDenied = await PermissionService
          .isPermanentlyDenied(Permission.camera);
      if (!mounted) return;

      if (permanentlyDenied) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(context.l10n.permissionRequired),
            content: Text(context.l10n.cameraPermissionExplanation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  PermissionService.openSettings();
                },
                child: Text(context.l10n.openSettings),
              ),
            ],
          ),
        );
      }
      return;
    }

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
    final l10n = context.l10n;
    final title = l10n.cropCoverTitle;
    final saved = await CoverService.saveCoverFromUrl(
      url, 
      cropTitle: title,
      doneButtonTitle: l10n.done,
      cancelButtonTitle: l10n.cancel,
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (saved != null) _coverPath = saved;
    });
    if (saved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.coverDownloadError)),
      );
    }
  }

  Future<void> _searchCovers() async {
    if (!mounted) return;
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
        final l10n = context.l10n;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.bookDuplicateTitle),
            content: Text(l10n.bookDuplicateContent(isbn)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.addBook),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }
    }
    if (!mounted) return;

    setState(() => _isSaving = true);

    if (widget.existingBook != null) {
      // Update existing record
      final oldPage = widget.existingBook!.currentPage ?? 0;
      final newPage = int.tryParse(_currentPageCtrl.text) ?? 0;

      final updated = widget.existingBook!.copyWith(
        title: _titleCtrl.text.trim(),
        subtitle: Value(_subtitleCtrl.text.trim().isEmpty ? null : _subtitleCtrl.text.trim()),
        author: _authorCtrl.text.trim(),
        isbn: Value(_isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim()),
        language: Value(_languageCtrl.text.trim().isEmpty ? null : _languageCtrl.text.trim()),
        translator: Value(_translatorCtrl.text.trim().isEmpty ? null : _translatorCtrl.text.trim()),
        publisher: Value(_publisherCtrl.text.trim().isEmpty ? null : _publisherCtrl.text.trim()),
        totalPages: Value(int.tryParse(_totalPagesCtrl.text)),
        currentPage: Value(newPage),
        status: _status,
        bookFormat: Value(_format),
        rating: Value(_rating),
        notes: Value(_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
        description: Value(_descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim()),
        coverPath: Value(_coverPath),
        collectionName: Value(_collectionNameCtrl.text.trim().isEmpty ? null : _collectionNameCtrl.text.trim()),
        collectionNumber: Value(int.tryParse(_collectionNumberCtrl.text)),
        publishYear: Value(int.tryParse(_publishYearCtrl.text)),
        startedAt: Value(_startedAt),
        finishedAt: Value(_finishedAt),
      );
      await db.updateBook(updated);

      if (newPage > oldPage) {
        await ref.read(readingLogControllerProvider.notifier).logPages(widget.existingBook!.id, newPage - oldPage);
      }
      
      final existingIds = _selectedTags.map((t) => t.id).toList();
      await db.setBookTags(widget.existingBook!.id, existingIds);
      await db.setBookImprint(widget.existingBook!.id, _selectedImprint?.id);
      await db.pruneOrphanTags();
    } else {
      // Insert new record
      final newPage = int.tryParse(_currentPageCtrl.text) ?? 0;
      final companion = BooksCompanion.insert(
        title: _titleCtrl.text.trim(),
        subtitle: Value(_subtitleCtrl.text.trim().isEmpty ? null : _subtitleCtrl.text.trim()),
        author: _authorCtrl.text.trim(),
        isbn: Value(_isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim()),
        language: Value(_languageCtrl.text.trim().isEmpty ? null : _languageCtrl.text.trim()),
        translator: Value(_languageCtrl.text.trim().isEmpty ? null : _translatorCtrl.text.trim()),
        publisher: Value(_publisherCtrl.text.trim().isEmpty ? null : _publisherCtrl.text.trim()),
        totalPages: Value(int.tryParse(_totalPagesCtrl.text)),
        currentPage: Value(newPage),
        status: _status,
        bookFormat: Value<BookFormat?>(_format),
        rating: Value(_rating),
        notes: Value(_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
        description: Value(_descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim()),
        coverPath: Value(_coverPath),
        collectionName: Value(_collectionNameCtrl.text.trim().isEmpty ? null : _collectionNameCtrl.text.trim()),
        collectionNumber: Value(int.tryParse(_collectionNumberCtrl.text)),
        publishYear: Value(int.tryParse(_publishYearCtrl.text)),
        startedAt: Value(_startedAt),
        finishedAt: Value(_finishedAt),
      );
      final newId = await db.insertBook(companion);

      if (newPage > 0) {
        await ref.read(readingLogControllerProvider.notifier).logPages(newId, newPage);
      }
      
      final existingIds = _selectedTags.map((t) => t.id).toList();
      await db.setBookTags(newId, existingIds);
      await db.setBookImprint(newId, _selectedImprint?.id);
    }

    // Auto-create collection tag if name provided
    final collectionName = _collectionNameCtrl.text.trim();
    if (collectionName.isNotEmpty) {
      await db.getOrCreateCollection(collectionName);
    }

    // Trigger shelf automation check
    ref.read(shelfAutomationProvider.notifier).checkNoCoverShelf();

    if (mounted) Navigator.pop(context);
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
      setState(() {
        final oldStatus = _status;
        _status = newStatus;
        if (newStatus == ReadingStatus.read) {
          _finishedAt ??= DateTime.now();
        } else if (newStatus == ReadingStatus.reading || newStatus == ReadingStatus.wantToRead) {
          _finishedAt = null;
        }

        if (newStatus == ReadingStatus.reading && oldStatus == ReadingStatus.wantToRead) {
          _startedAt ??= DateTime.now();
        }
      });
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
              descriptionCtrl: _descriptionCtrl,
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
              onTakePhoto: _takePhoto,
              selectedTags: _selectedTags,
              onAddTag: (tag) => setState(() {
                if (!_selectedTags.any((t) => t.id == tag.id)) {
                  _selectedTags = [..._selectedTags, tag];
                }
              }),
              onRemoveTag: (tag) => setState(() {
                _selectedTags = _selectedTags.where((t) => t.id != tag.id).toList();
              }),
              onPickCoverFromUrl: _pickCoverFromUrl,
              onSearchCovers: _searchCovers,
            ),
            _DetailsTab(
              notesCtrl: _notesCtrl,
              isbnCtrl: _isbnCtrl,
              languageCtrl: _languageCtrl,
              publishYearCtrl: _publishYearCtrl,
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
  final TextEditingController descriptionCtrl;
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
  final VoidCallback onTakePhoto;
  final List<Tag> selectedTags;
  final ValueChanged<Tag> onAddTag;
  final ValueChanged<Tag> onRemoveTag;
  final VoidCallback onPickCoverFromUrl;
  final VoidCallback onSearchCovers;

  const _MainTab({
    required this.titleCtrl,
    required this.subtitleCtrl,
    required this.authorCtrl,
    required this.descriptionCtrl,
    required this.publisherCtrl,
    required this.totalPagesCtrl,
    required this.currentPageCtrl,
    required this.status,
    required this.format,
    required this.rating,
    this.coverPath,
    required this.onStatusChanged,
    required this.onFormatChanged,
    required this.onRatingChanged,
    required this.onPickCover,
    required this.onTakePhoto,
    required this.selectedTags,
    required this.onAddTag,
    required this.onRemoveTag,
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
          controller: descriptionCtrl,
          label: context.l10n.fieldDescription,
          icon: Icons.description_outlined,
          maxLines: 5,
        ),
        const SizedBox(height: 24),


        EntityFieldSelector(
          selected: selectedTags,
          onChanged: (list) {
            // Update selected tags
            final current = List<Tag>.from(selectedTags);
            for (final tag in list) {
              if (!current.any((t) => t.id == tag.id)) {
                onAddTag(tag);
              }
            }
            // Handle removal
            for (final tag in current) {
              if (!list.any((t) => t.id == tag.id)) {
                onRemoveTag(tag);
              }
            }
          },
          type: 'tag',
          label: context.l10n.tagSearchOrCreate,
          icon: Icons.label_outline,
          trailing: TagGridSelector(
            selected: selectedTags,
            type: 'tag',
            onChanged: (list) {
               // Sync back
               final current = List<Tag>.from(selectedTags);
               for (final tag in list) {
                 if (!current.any((t) => t.id == tag.id)) {
                   onAddTag(tag);
                 }
               }
               for (final tag in current) {
                 if (!list.any((t) => t.id == tag.id)) {
                   onRemoveTag(tag);
                 }
               }
            },
          ),
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
  final TextEditingController isbnCtrl;
  final TextEditingController languageCtrl;
  final TextEditingController publishYearCtrl;
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
    required this.isbnCtrl,
    required this.languageCtrl,
    required this.publishYearCtrl,
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
        _SectionHeader(label: context.l10n.sectionBasicInfo),
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

        _SectionHeader(label: context.l10n.fieldCollection),
        const SizedBox(height: 12),
        EntityFieldSelector(
          selected: collectionNameCtrl.text.isNotEmpty 
              ? [Tag(id: -1, name: collectionNameCtrl.text, type: 'collection')] 
              : [],
          onChanged: (list) {
            if (list.isNotEmpty) {
              collectionNameCtrl.text = list.first.name;
            } else {
              collectionNameCtrl.text = '';
            }
          },
          type: 'collection',
          label: context.l10n.fieldCollection,
          icon: Icons.collections_bookmark_outlined,
          multiSelection: false,
        ),
        const SizedBox(height: 12),
        _FormField(
          controller: collectionNumberCtrl,
          label: context.l10n.fieldCollectionNumber,
          icon: Icons.tag,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),

        _SectionHeader(label: context.l10n.sectionImprint),
        const SizedBox(height: 12),
        EntityFieldSelector(
          selected: selectedImprint != null ? [selectedImprint!] : [],
          onChanged: (list) {
            if (list.isNotEmpty) {
              onSelectImprint(list.first);
            } else {
              onClearImprint();
            }
          },
          type: 'imprint',
          label: context.l10n.imprintSearch,
          icon: Icons.business_outlined,
          multiSelection: false,
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
