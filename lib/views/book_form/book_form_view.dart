import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database.dart';
import '../../controllers/database_provider.dart';
import '../../controllers/book_form_controller.dart';
import '../../models/book_search_result.dart';
import '../../models/tag_type.dart';
import '../../l10n/l10n_extension.dart';
import 'cover_picker_sheet.dart';
import 'widgets/main_tab.dart';
import 'widgets/details_tab.dart';

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
  late final TextEditingController _copiesCtrl;

  ReadingStatus _status = ReadingStatus.wantToRead;
  BookFormat? _format;
  double? _rating;
  bool _isSaving = false;
  String? _coverPath;
  DateTime? _startedAt;
  DateTime? _finishedAt;
  List<Tag> _selectedTags = [];        
  List<Tag> _selectedCollections = [];
  Tag? _selectedImprint;
  PaginationConfig? _paginationConfig;
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
    _copiesCtrl = TextEditingController(text: b?.copies.toString() ?? '1');
        
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
      _loadExistingCollection(b.id, b.collectionId, b.collectionName);
      _paginationConfig = b.paginationConfig;
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
    _copiesCtrl.dispose();
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
    final saved = await ref.read(bookFormControllerProvider).downloadCover(
      url,
      cropTitle: context.l10n.cropCoverTitle,
      doneTitle: context.l10n.done,
      cancelTitle: context.l10n.cancel,
    );
    if (saved != null && mounted) {
      setState(() => _coverPath = saved);
    }
  }

  Future<void> _pickCover() async {
    final saved = await ref.read(bookFormControllerProvider).pickCoverFromGallery(
      cropTitle: context.l10n.cropCoverTitle,
      doneTitle: context.l10n.done,
      cancelTitle: context.l10n.cancel,
    );
    if (saved != null && mounted) {
      setState(() => _coverPath = saved);
    }
  }

  Future<void> _takePhoto() async {
    final saved = await ref.read(bookFormControllerProvider).takePhoto(
      cropTitle: context.l10n.cropCoverTitle,
      doneTitle: context.l10n.done,
      cancelTitle: context.l10n.cancel,
    );
    if (saved != null && mounted) {
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
    final saved = await ref.read(bookFormControllerProvider).downloadCover(
      url,
      cropTitle: context.l10n.cropCoverTitle,
      doneTitle: context.l10n.done,
      cancelTitle: context.l10n.cancel,
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (saved != null) _coverPath = saved;
    });
    if (saved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.coverDownloadError)),
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
      final existing = await db.bookDao.getBookByIsbn(isbn);
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
    if (!mounted) return;

    setState(() => _isSaving = true);

    final newPage = int.tryParse(_currentPageCtrl.text) ?? 0;
    final collectionId = _selectedCollections.firstOrNull?.id;
    final collectionName = _selectedCollections.firstOrNull?.name;
    final imprintId = _selectedImprint?.id;
    final total = int.tryParse(_totalPagesCtrl.text) ?? 0;
    
    // Auto-adjust and sanitize pagination config if total pages changed
    PaginationConfig? finalConfig = _paginationConfig;
    if (finalConfig != null && finalConfig.segments.isNotEmpty) {
      final List<PaginationSegment> sanitizedSegments = [];
      for (final s in finalConfig.segments) {
        if (s.startPhysical > total) continue; // Remove segments starting after the book ends
        
        sanitizedSegments.add(s.copyWith(
          endPhysical: s.endPhysical > total ? total : s.endPhysical,
        ));
        
        if (sanitizedSegments.last.endPhysical == total) break;
      }

      // If we finished and the last segment doesn't reach the new total, extend it
      if (sanitizedSegments.isNotEmpty && sanitizedSegments.last.endPhysical < total) {
        final last = sanitizedSegments.removeLast();
        sanitizedSegments.add(last.copyWith(endPhysical: total));
      }
      
      finalConfig = PaginationConfig(
        segments: sanitizedSegments, 
        markers: finalConfig.markers.where((m) => m.physicalPage <= total).toList(),
      );
    }

    final companion = BooksCompanion(
      title: Value(_titleCtrl.text.trim()),
      subtitle: Value(_subtitleCtrl.text.trim().isEmpty ? null : _subtitleCtrl.text.trim()),
      author: Value(_authorCtrl.text.trim().isEmpty ? context.l10n.unknownAuthor : _authorCtrl.text.trim()),
      isbn: Value(_isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim()),
      language: Value(_languageCtrl.text.trim().isEmpty ? null : _languageCtrl.text.trim()),
      translator: Value(_translatorCtrl.text.trim().isEmpty ? null : _translatorCtrl.text.trim()),
      publisher: Value(_publisherCtrl.text.trim().isEmpty ? null : _publisherCtrl.text.trim()),
      totalPages: Value(total),
      currentPage: Value(newPage),
      status: Value(_status),
      bookFormat: Value(_format),
      rating: Value(_rating),
      notes: Value(_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
      description: Value(_descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim()),
      coverPath: Value(_coverPath),
      collectionName: Value(collectionName),
      collectionId: Value(collectionId != null && collectionId > 0 ? collectionId : null),
      collectionNumber: Value(int.tryParse(_collectionNumberCtrl.text)),
      publishYear: Value(int.tryParse(_publishYearCtrl.text)),
      copies: Value(int.tryParse(_copiesCtrl.text) ?? 1),
      paginationConfig: Value(finalConfig),
      startedAt: Value(_startedAt),
      finishedAt: Value(_finishedAt),
      imprintId: Value(imprintId != null && imprintId > 0 ? imprintId : null),
    );

    final tagIds = _selectedTags.map((t) => t.id).toList();

    await ref.read(bookFormControllerProvider).saveBook(
      existingBook: widget.existingBook,
      companion: companion,
      tagIds: tagIds,
      newPage: newPage,
      oldPage: widget.existingBook?.currentPage,
      status: _status,
      totalPages: total,
      startedAt: _startedAt,
      finishedAt: _finishedAt,
    );

    if (mounted) Navigator.pop(context);
  }

  Future<void> _loadExistingTags(int bookId) async {
    final db = ref.read(databaseProvider);
    final existing = await db.tagDao.watchTagsForBook(bookId).first;
    if (!mounted) return;
    setState(() => _selectedTags = existing);
  }

  Future<void> _loadExistingImprint(int bookId) async {
    final db = ref.read(databaseProvider);
    final existing = await db.tagDao.watchImprintForBook(bookId).first;
    if (!mounted) return;
    setState(() => _selectedImprint = existing);
  }

  Future<void> _loadExistingCollection(int bookId, int? collectionId, String? collectionName) async {
    final db = ref.read(databaseProvider);
    
    // First, try to load by ID (source of truth)
    if (collectionId != null) {
      final col = await (db.tagDao.select(db.tagDao.tags)..where((t) => t.id.equals(collectionId))).getSingleOrNull();
      if (col != null) {
        setState(() => _selectedCollections = [col]);
        return;
      }
    }

    // Fallback: search by name if ID was null or missing
    if (collectionName != null && collectionName.isNotEmpty) {
      final col = await (db.tagDao.select(db.tagDao.tags)
        ..where((t) => t.name.equals(collectionName) & t.type.equalsValue(TagType.collection))
      ).getSingleOrNull();
      
      if (col != null) {
        setState(() => _selectedCollections = [col]);
      } else {
        // Handle legacy case where the tag might have been deleted but the name remains
        setState(() => _selectedCollections = [Tag(id: -1, name: collectionName, type: TagType.collection)]);
      }
    }
  }

  void _updateStatusFromPages() {
    if (_isInitializing) return;
    
    final current = int.tryParse(_currentPageCtrl.text);
    final total = int.tryParse(_totalPagesCtrl.text);
    if (current == null || total == null || total == 0) return;

    // Do not auto-update if status is terminal or paused
    if (_status == ReadingStatus.abandoned || _status == ReadingStatus.paused) return;

    ReadingStatus newStatus = _status;

    if (current >= total) {
      if (_status != ReadingStatus.read) {
        newStatus = ReadingStatus.read;
        // Sync current page to total if exceeded
        if (current > total) {
          _currentPageCtrl.text = total.toString();
          _currentPageCtrl.selection = TextSelection.fromPosition(
            TextPosition(offset: _currentPageCtrl.text.length),
          );
        }
      }
    } else if (current < total) {
      if (_status == ReadingStatus.read) {
        newStatus = ReadingStatus.reading;
      } else if (current == 0) {
        newStatus = ReadingStatus.wantToRead;
      } else {
        newStatus = ReadingStatus.reading;
      }
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
            MainTab(
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
              onTagsChanged: (list) => setState(() => _selectedTags = list),
              onPickCoverFromUrl: _pickCoverFromUrl,
              onSearchCovers: _searchCovers,
              paginationConfig: _paginationConfig,
              onPaginationConfigChanged: (cfg) => setState(() => _paginationConfig = cfg),
            ),
            DetailsTab(
              notesCtrl: _notesCtrl,
              isbnCtrl: _isbnCtrl,
              languageCtrl: _languageCtrl,
              publishYearCtrl: _publishYearCtrl,
              translatorCtrl: _translatorCtrl,
              selectedCollections: _selectedCollections,
              selectedImprint: _selectedImprint,
              startedAt: _startedAt,
              finishedAt: _finishedAt,
              onStartedAtChanged: (d) => setState(() => _startedAt = d),
              onFinishedAtChanged: (d) => setState(() => _finishedAt = d),
              onCollectionsChanged: (list) => setState(() => _selectedCollections = list),
              onImprintChanged: (tag) => setState(() => _selectedImprint = tag),
              copiesCtrl: _copiesCtrl,
            ),
          ],
        ),
      ),
    );
  }
}
