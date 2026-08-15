import 'package:drift/drift.dart' hide Column;
import 'package:collection/collection.dart';
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
import 'package:openshelf/utils/pagination_helper.dart';

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
  late final TextEditingController _originalTitleCtrl;
  late final TextEditingController _originalLanguageCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _languageCtrl;
  late final TextEditingController _translatorCtrl;
  late final TextEditingController _publisherCtrl;
  late final TextEditingController _totalPagesCtrl;
  late final TextEditingController _currentPageCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _publishYearCtrl;
  late final TextEditingController _copiesCtrl;
  late final TextEditingController _personNameCtrl;

  ReadingStatus _status = ReadingStatus.wantToRead;
  OwnershipStatus? _ownershipStatus;
  BookFormat? _format;
  double? _rating;
  bool _isSaving = false;
  String? _coverPath;
  DateTime? _startedAt;
  DateTime? _finishedAt;
  bool _isTranslation = false;
  List<Tag> _selectedTags = [];        
  List<(Tag, int?)> _selectedCollections = [];
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
    _originalTitleCtrl = TextEditingController(text: b?.originalTitle ?? pre?.originalTitle ?? '');
    _originalLanguageCtrl = TextEditingController(text: b?.originalLanguage ?? pre?.originalLanguage ?? '');
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
    _publishYearCtrl = TextEditingController(
        text: b?.publishYear?.toString() ?? pre?.publishYear?.toString() ?? '');
    _copiesCtrl = TextEditingController(text: b?.copies.toString() ?? '1');
    _personNameCtrl = TextEditingController(text: '');
        
    if (b != null) {
      _status = b.status;
      _ownershipStatus = b.ownershipStatus;
      _format = b.bookFormat;
      _rating = b.rating;
      _coverPath = b.coverPath;
      _startedAt = b.startedAt;
      _finishedAt = b.finishedAt;
      _paginationConfig = b.paginationConfig;
      _isTranslation = b.translator != null || b.originalTitle != null || b.originalLanguage != null;
      
      final useVisual = _paginationConfig?.useVisualMode ?? false;
      if (useVisual) {
        _currentPageCtrl.text = PaginationHelper.getVisualPage(b.currentPage ?? 0, _paginationConfig);
      } else {
        _currentPageCtrl.text = b.currentPage?.toString() ?? '0';
      }
      
      _loadInitialData(b.id);
    } else if (pre?.coverUrl != null) {
      _prefillCoverFromUrl(pre!.coverUrl!);
    }
    
    _currentPageCtrl.addListener(_updateStatusFromPages);
    _totalPagesCtrl.addListener(_updateStatusFromPages);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isInitializing = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _originalTitleCtrl.dispose();
    _originalLanguageCtrl.dispose();
    _authorCtrl.dispose();
    _isbnCtrl.dispose();
    _languageCtrl.dispose();
    _translatorCtrl.dispose();
    _publisherCtrl.dispose();
    _totalPagesCtrl.dispose();
    _currentPageCtrl.dispose();
    _notesCtrl.dispose();
    _descriptionCtrl.dispose();
    _publishYearCtrl.dispose();
    _currentPageCtrl.removeListener(_updateStatusFromPages);
    _totalPagesCtrl.removeListener(_updateStatusFromPages);
    _copiesCtrl.dispose();
    _personNameCtrl.dispose();
    super.dispose();
  }

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
    final useVisual = _paginationConfig?.useVisualMode ?? false;

    switch (s) {
      case ReadingStatus.wantToRead:
        _currentPageCtrl.text = '0';
        break;
      case ReadingStatus.reading:
        if (_currentPageCtrl.text == '0') {
           _currentPageCtrl.text = useVisual ? PaginationHelper.getVisualPage(1, _paginationConfig) : '1';
        }
        break;
      case ReadingStatus.read:
        if (total != null) {
           _currentPageCtrl.text = useVisual ? PaginationHelper.getVisualPage(total, _paginationConfig) : total.toString();
        }
        break;
      case ReadingStatus.abandoned:
      case ReadingStatus.paused:
        break;
    }
  }

  Future<void> _prefillCoverFromUrl(String url) async {
    final l10n = context.l10n;
    final saved = await ref.read(bookFormControllerProvider).downloadCover(
      url,
      cropTitle: l10n.cropCoverTitle,
      doneTitle: l10n.done,
      cancelTitle: l10n.cancel,
    );
    if (saved != null && mounted) {
      setState(() => _coverPath = saved);
    }
  }

  Future<void> _pickCover() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final saved = await ref.read(bookFormControllerProvider).pickCoverFromGallery(
        cropTitle: l10n.cropCoverTitle,
        doneTitle: l10n.done,
        cancelTitle: l10n.cancel,
      );
      if (saved != null && mounted) {
        setState(() => _coverPath = saved);
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.imageProcessError)),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final saved = await ref.read(bookFormControllerProvider).takePhoto(
        cropTitle: l10n.cropCoverTitle,
        doneTitle: l10n.done,
        cancelTitle: l10n.cancel,
      );
      if (saved != null && mounted) {
        setState(() => _coverPath = saved);
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.imageProcessError)),
        );
      }
    }
  }

  Future<void> _pickCoverFromUrl() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ctrl = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.coverUrlDialogTitle),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: l10n.coverUrlHint,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(l10n.download),
          ),
        ],
      ),
    );
    if (url == null || url.isEmpty) return;
    if (!mounted) return;
    
    setState(() => _isSaving = true);
    try {
      final saved = await ref.read(bookFormControllerProvider).downloadCover(
        url,
        cropTitle: l10n.cropCoverTitle,
        doneTitle: l10n.done,
        cancelTitle: l10n.cancel,
      );
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        if (saved != null) _coverPath = saved;
      });
      if (saved == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.coverDownloadError)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.imageProcessError)),
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

  Future<void> _save() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    final db = ref.read(databaseProvider);
    final isbn = _isbnCtrl.text.trim();

    if (widget.existingBook == null && isbn.isNotEmpty) {
      final existing = await db.bookDao.getBookByIsbn(isbn);
      if (existing != null && mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.bookDuplicateTitle),
            content: Text(l10n.bookDuplicateContent(isbn)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.addBook)),
            ],
          ),
        );
        if (confirmed != true) return;
      }
    }
    if (!mounted) return;

    setState(() => _isSaving = true);

    try {
      final rawPageText = _currentPageCtrl.text.trim();
      final total = int.tryParse(_totalPagesCtrl.text) ?? 0;
      int newPage = 0;
      if (_paginationConfig?.useVisualMode == true) {
        newPage = PaginationHelper.getPhysicalFromVisual(rawPageText, _paginationConfig!);
      } else {
        newPage = int.tryParse(rawPageText) ?? 0;
      }

      final List<int> tagIds = [];
      for (final tag in _selectedTags) {
        if (tag.id < 0) {
          tagIds.add(await db.tagDao.insertTag(TagsCompanion.insert(
            name: tag.name,
            type: const Value(TagType.tag),
          )));
        } else {
          tagIds.add(tag.id);
        }
      }

      final List<(int, int?)> collections = [];
      for (final col in _selectedCollections) {
        int tagId = col.$1.id;
        if (tagId < 0) {
          tagId = await db.tagDao.getOrCreateCollection(col.$1.name);
        }
        collections.add((tagId, col.$2));
      }

      await ref.read(bookFormControllerProvider).saveBook(
        existingBook: widget.existingBook,
        title: _titleCtrl.text.trim(),
        subtitle: _subtitleCtrl.text.trim().isEmpty ? null : _subtitleCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        isbn: _isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim(),
        publisher: _publisherCtrl.text.trim().isEmpty ? null : _publisherCtrl.text.trim(),
        totalPages: total,
        currentPage: newPage,
        status: _status,
        ownershipStatus: _ownershipStatus,
        format: _format,
        rating: _rating,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
        coverPath: _coverPath,
        collectionId: _selectedCollections.firstOrNull?.$1.id,
        collectionName: _selectedCollections.firstOrNull?.$1.name,
        collectionNumber: _selectedCollections.firstOrNull?.$2,
        publishYear: int.tryParse(_publishYearCtrl.text),
        copies: int.tryParse(_copiesCtrl.text) ?? 1,
        paginationConfig: _paginationConfig,
        startedAt: _startedAt,
        finishedAt: _finishedAt,
        imprintId: _selectedImprint?.id,
        tagIds: tagIds,
        collections: collections,
        personName: _personNameCtrl.text.trim().isNotEmpty ? _personNameCtrl.text.trim() : null,
        unknownAuthorLabel: l10n.unknownAuthor,
      );

      if (mounted) navigator.pop();
    } catch (e) {
      debugPrint('Error saving book: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric(e.toString()))),
        );
      }
    }
  }

  Future<void> _loadInitialData(int bookId) async {
    final db = ref.read(databaseProvider);
    final tags = await db.tagDao.watchTagsForBook(bookId).first;
    final imprint = await db.tagDao.watchImprintForBook(bookId).first;
    final collections = await db.tagDao.watchCollectionsForBook(bookId).first;
    
    if (!mounted) return;
    setState(() {
      _selectedTags = tags;
      _selectedImprint = imprint;
      _selectedCollections = collections;
    });
  }

  void _updateStatusFromPages() {
    if (_isInitializing) return;
    final rawPageText = _currentPageCtrl.text.trim();
    final total = int.tryParse(_totalPagesCtrl.text);
    if (rawPageText.isEmpty || total == null || total == 0) return;

    int current = 0;
    if (_paginationConfig?.useVisualMode == true) {
       current = PaginationHelper.getPhysicalFromVisual(rawPageText, _paginationConfig!);
    } else {
       current = int.tryParse(rawPageText) ?? 0;
    }

    if (_status == ReadingStatus.abandoned || _status == ReadingStatus.paused) return;

    ReadingStatus newStatus = _status;
    if (current >= total) {
      if (_status != ReadingStatus.read) {
        newStatus = ReadingStatus.read;
        if (current > total) {
          _currentPageCtrl.text = total.toString();
          _currentPageCtrl.selection = TextSelection.fromPosition(TextPosition(offset: _currentPageCtrl.text.length));
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
        title: Text(widget.existingBook != null ? context.l10n.bookFormEditTitle : context.l10n.bookFormNewTitle),
        toolbarHeight: 40,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
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
              onPaginationConfigChanged: (cfg) {
                setState(() => _paginationConfig = cfg);
                final newTotal = PaginationHelper.calculateTotalPhysicalPages(cfg);
                if (newTotal > 0) _totalPagesCtrl.text = newTotal.toString();
              },
            ),
            DetailsTab(
              notesCtrl: _notesCtrl,
              isbnCtrl: _isbnCtrl,
              languageCtrl: _languageCtrl,
              publishYearCtrl: _publishYearCtrl,
              translatorCtrl: _translatorCtrl,
              originalTitleCtrl: _originalTitleCtrl,
              originalLanguageCtrl: _originalLanguageCtrl,
              isTranslation: _isTranslation,
              onIsTranslationChanged: (v) => setState(() => _isTranslation = v),
              ownershipStatus: _ownershipStatus,
              onOwnershipStatusChanged: (s) => setState(() => _ownershipStatus = s),
              personNameCtrl: _personNameCtrl,
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
