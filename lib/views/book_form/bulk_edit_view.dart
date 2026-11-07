import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database.dart';
import '../../services/daos/book_dao.dart';
import '../../controllers/database_provider.dart';
import '../../controllers/book_selection_controller.dart';
import '../../controllers/book_form_controller.dart';
import '../../l10n/l10n_extension.dart';
import 'cover_picker_sheet.dart';
import 'widgets/bulk_main_tab.dart';
import 'widgets/bulk_details_tab.dart';

/// Form for bulk editing common attributes across multiple selected books.
/// Replicates the tabbed structure of BookFormView while allowing padlock toggles.
/// Unalterable unique properties (ISBN, page progress, rating) are clearly marked and disabled.
class BulkEditView extends ConsumerStatefulWidget {
  final List<int> selectedBookIds;

  const BulkEditView({
    super.key,
    required this.selectedBookIds,
  });

  @override
  ConsumerState<BulkEditView> createState() => _BulkEditViewState();
}

class _BulkEditViewState extends ConsumerState<BulkEditView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TabController _tabController;

  // --- Lock States (All locked by default) ---
  bool _isCoverLocked = true;
  bool _isTitleLocked = true;
  bool _isSubtitleLocked = true;
  bool _isAuthorLocked = true;
  bool _isPublisherLocked = true;
  bool _isDescriptionLocked = true;
  bool _isTagsLocked = true;
  bool _isStatusLocked = true;
  bool _isFormatLocked = true;

  bool _isYearLocked = true;
  bool _isLanguageLocked = true;
  bool _isOriginalLanguageLocked = true;
  bool _isTranslationLocked = true;
  bool _isOriginalTitleLocked = true;
  bool _isTranslatorLocked = true;
  bool _isOwnershipLocked = true;
  bool _isCollectionsLocked = true;
  bool _isImprintLocked = true;
  bool _isNotesLocked = true;
  bool _isDatesLocked = true;
  bool _isCopiesLocked = true;

  // --- Controllers & Form Values ---
  String? _coverPath;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _publisherCtrl;
  late final TextEditingController _descriptionCtrl;
  List<Tag> _selectedTags = [];
  ReadingStatus _status = ReadingStatus.wantToRead;
  BookFormat? _format;

  late final TextEditingController _publishYearCtrl;
  late final TextEditingController _languageCtrl;
  late final TextEditingController _originalLanguageCtrl;
  bool _isTranslation = false;
  late final TextEditingController _originalTitleCtrl;
  late final TextEditingController _translatorCtrl;
  OwnershipStatus? _ownershipStatus;
  late final TextEditingController _personNameCtrl;
  List<(Tag, int?)> _selectedCollections = [];
  Tag? _selectedImprint;
  late final TextEditingController _notesCtrl;
  bool _appendNotes = false;
  DateTime? _startedAt;
  DateTime? _finishedAt;
  late final TextEditingController _copiesCtrl;

  bool _isSaving = false;
  final bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _titleCtrl = TextEditingController();
    _subtitleCtrl = TextEditingController();
    _authorCtrl = TextEditingController();
    _publisherCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();

    _publishYearCtrl = TextEditingController();
    _languageCtrl = TextEditingController();
    _originalLanguageCtrl = TextEditingController();
    _originalTitleCtrl = TextEditingController();
    _translatorCtrl = TextEditingController();
    _personNameCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
    _copiesCtrl = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _authorCtrl.dispose();
    _publisherCtrl.dispose();
    _descriptionCtrl.dispose();

    _publishYearCtrl.dispose();
    _languageCtrl.dispose();
    _originalLanguageCtrl.dispose();
    _originalTitleCtrl.dispose();
    _translatorCtrl.dispose();
    _personNameCtrl.dispose();
    _notesCtrl.dispose();
    _copiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleLock({
    required bool currentLocked,
    required ValueChanged<bool> setLocked,
    required bool isModified,
    required VoidCallback onClearContent,
  }) async {
    if (currentLocked) {
      setLocked(false);
    } else {
      if (isModified) {
        final l10n = context.l10n;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.padlockResetTitle),
            content: Text(l10n.padlockResetContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.yes),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          onClearContent();
          setLocked(true);
        }
      } else {
        setLocked(true);
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_isProcessingImage) return;
    final l10n = context.l10n;
    try {
      final saved = await ref.read(bookFormControllerProvider).takePhoto(
        cropTitle: l10n.cropCoverTitle,
        doneTitle: l10n.done,
        cancelTitle: l10n.cancel,
      );
      if (mounted && saved != null) {
        setState(() {
          _coverPath = saved;
          _isCoverLocked = false;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickCoverFromUrl() async {
    final l10n = context.l10n;
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
    if (url == null || url.isEmpty || !mounted) return;

    try {
      final saved = await ref.read(bookFormControllerProvider).downloadCover(
        url,
        cropTitle: l10n.cropCoverTitle,
        doneTitle: l10n.done,
        cancelTitle: l10n.cancel,
      );
      if (mounted && saved != null) {
        setState(() {
          _coverPath = saved;
          _isCoverLocked = false;
        });
      }
    } catch (_) {}
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
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        author: _authorCtrl.text.trim().isEmpty ? null : _authorCtrl.text.trim(),
        publisher: _publisherCtrl.text.trim().isEmpty ? null : _publisherCtrl.text.trim(),
        onCoverSelected: (path) => setState(() {
          _coverPath = path;
          _isCoverLocked = false;
        }),
      ),
    );
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Check if any field is unlocked
    final hasAnyUnlocked = !_isCoverLocked ||
        !_isTitleLocked ||
        !_isSubtitleLocked ||
        !_isAuthorLocked ||
        !_isPublisherLocked ||
        !_isDescriptionLocked ||
        !_isTagsLocked ||
        !_isStatusLocked ||
        !_isFormatLocked ||
        !_isYearLocked ||
        !_isLanguageLocked ||
        !_isOriginalLanguageLocked ||
        !_isTranslationLocked ||
        !_isOriginalTitleLocked ||
        !_isTranslatorLocked ||
        !_isOwnershipLocked ||
        !_isCollectionsLocked ||
        !_isImprintLocked ||
        !_isNotesLocked ||
        !_isDatesLocked ||
        !_isCopiesLocked;

    if (!hasAnyUnlocked) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.bulkEditNoFieldsUnlocked)),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final db = ref.read(databaseProvider);

      // Tags
      final List<int> tagIds = [];
      if (!_isTagsLocked) {
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
      }

      // Collections
      final List<(int, int?)> collections = [];
      if (!_isCollectionsLocked) {
        for (final col in _selectedCollections) {
          int tagId = col.$1.id;
          if (tagId < 0) {
            tagId = await db.tagDao.getOrCreateCollection(col.$1.name);
          }
          collections.add((tagId, col.$2));
        }
      }

      // Imprint
      int? imprintId;
      if (!_isImprintLocked && _selectedImprint != null) {
        if (_selectedImprint!.id < 0) {
          imprintId = await db.tagDao.insertTag(TagsCompanion.insert(
            name: _selectedImprint!.name,
            type: const Value(TagType.imprint),
          ));
        } else {
          imprintId = _selectedImprint!.id;
        }
      }

      final bulkData = BulkEditData(
        updateCoverPath: !_isCoverLocked,
        coverPath: _coverPath,
        updateTitle: !_isTitleLocked,
        title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : null,
        updateSubtitle: !_isSubtitleLocked,
        subtitle: _subtitleCtrl.text.trim().isNotEmpty ? _subtitleCtrl.text.trim() : null,
        updateAuthor: !_isAuthorLocked,
        author: _authorCtrl.text.trim().isNotEmpty ? _authorCtrl.text.trim() : null,
        updatePublisher: !_isPublisherLocked,
        publisher: _publisherCtrl.text.trim().isNotEmpty ? _publisherCtrl.text.trim() : null,
        updateDescription: !_isDescriptionLocked,
        description: _descriptionCtrl.text.trim().isNotEmpty ? _descriptionCtrl.text.trim() : null,
        updateTags: !_isTagsLocked,
        tagIds: tagIds,
        updateStatus: !_isStatusLocked,
        status: _status,
        updateFormat: !_isFormatLocked,
        format: _format,
        updatePublishYear: !_isYearLocked,
        publishYear: int.tryParse(_publishYearCtrl.text),
        updateLanguage: !_isLanguageLocked,
        language: _languageCtrl.text.trim().isNotEmpty ? _languageCtrl.text.trim() : null,
        updateOriginalLanguage: !_isOriginalLanguageLocked,
        originalLanguage: _originalLanguageCtrl.text.trim().isNotEmpty ? _originalLanguageCtrl.text.trim() : null,
        updateOriginalTitle: !_isOriginalTitleLocked,
        originalTitle: _originalTitleCtrl.text.trim().isNotEmpty ? _originalTitleCtrl.text.trim() : null,
        updateTranslator: !_isTranslatorLocked,
        translator: _translatorCtrl.text.trim().isNotEmpty ? _translatorCtrl.text.trim() : null,
        updateOwnership: !_isOwnershipLocked,
        ownershipStatus: _ownershipStatus,
        updatePersonName: !_isOwnershipLocked,
        personName: _personNameCtrl.text.trim().isNotEmpty ? _personNameCtrl.text.trim() : null,
        updateCollections: !_isCollectionsLocked,
        collections: collections,
        updateImprint: !_isImprintLocked,
        imprintId: imprintId,
        updateNotes: !_isNotesLocked,
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        appendNotes: _appendNotes,
        updateStartedAt: !_isDatesLocked,
        startedAt: _startedAt,
        updateFinishedAt: !_isDatesLocked,
        finishedAt: _finishedAt,
        updateCopies: !_isCopiesLocked,
        copies: int.tryParse(_copiesCtrl.text) ?? 1,
      );

      await db.bookDao.bulkUpdateBooks(widget.selectedBookIds, bulkData);

      // Clear selection
      ref.read(bookSelectionProvider.notifier).clear();

      if (mounted) {
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.bulkEditSaveSuccess(widget.selectedBookIds.length))),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bookDao = ref.read(databaseProvider).bookDao;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bulkEditTitle(widget.selectedBookIds.length)),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    l10n.save,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.menu_book_outlined), text: l10n.tabMain),
            Tab(icon: const Icon(Icons.label_outline), text: l10n.tabDetails),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            BulkMainTab(
              isCoverLocked: _isCoverLocked,
              onCoverLockChanged: (_) => _toggleLock(
                currentLocked: _isCoverLocked,
                setLocked: (v) => setState(() => _isCoverLocked = v),
                isModified: _coverPath != null,
                onClearContent: () => _coverPath = null,
              ),
              coverPath: _coverPath,
              onPickCover: _takePhoto,
              onTakePhoto: _takePhoto,
              onPickCoverFromUrl: _pickCoverFromUrl,
              onSearchCovers: _searchCovers,
              isTitleLocked: _isTitleLocked,
              onTitleLockChanged: (_) => _toggleLock(
                currentLocked: _isTitleLocked,
                setLocked: (v) => setState(() => _isTitleLocked = v),
                isModified: _titleCtrl.text.isNotEmpty,
                onClearContent: () => _titleCtrl.clear(),
              ),
              titleCtrl: _titleCtrl,
              isSubtitleLocked: _isSubtitleLocked,
              onSubtitleLockChanged: (_) => _toggleLock(
                currentLocked: _isSubtitleLocked,
                setLocked: (v) => setState(() => _isSubtitleLocked = v),
                isModified: _subtitleCtrl.text.isNotEmpty,
                onClearContent: () => _subtitleCtrl.clear(),
              ),
              subtitleCtrl: _subtitleCtrl,
              isAuthorLocked: _isAuthorLocked,
              onAuthorLockChanged: (_) => _toggleLock(
                currentLocked: _isAuthorLocked,
                setLocked: (v) => setState(() => _isAuthorLocked = v),
                isModified: _authorCtrl.text.isNotEmpty,
                onClearContent: () => _authorCtrl.clear(),
              ),
              authorCtrl: _authorCtrl,
              isPublisherLocked: _isPublisherLocked,
              onPublisherLockChanged: (_) => _toggleLock(
                currentLocked: _isPublisherLocked,
                setLocked: (v) => setState(() => _isPublisherLocked = v),
                isModified: _publisherCtrl.text.isNotEmpty,
                onClearContent: () => _publisherCtrl.clear(),
              ),
              publisherCtrl: _publisherCtrl,
              isDescriptionLocked: _isDescriptionLocked,
              onDescriptionLockChanged: (_) => _toggleLock(
                currentLocked: _isDescriptionLocked,
                setLocked: (v) => setState(() => _isDescriptionLocked = v),
                isModified: _descriptionCtrl.text.isNotEmpty,
                onClearContent: () => _descriptionCtrl.clear(),
              ),
              descriptionCtrl: _descriptionCtrl,
              isTagsLocked: _isTagsLocked,
              onTagsLockChanged: (_) => _toggleLock(
                currentLocked: _isTagsLocked,
                setLocked: (v) => setState(() => _isTagsLocked = v),
                isModified: _selectedTags.isNotEmpty,
                onClearContent: () => _selectedTags = [],
              ),
              selectedTags: _selectedTags,
              onTagsChanged: (list) => setState(() => _selectedTags = list),
              isStatusLocked: _isStatusLocked,
              onStatusLockChanged: (_) => _toggleLock(
                currentLocked: _isStatusLocked,
                setLocked: (v) => setState(() => _isStatusLocked = v),
                isModified: _status != ReadingStatus.wantToRead,
                onClearContent: () => _status = ReadingStatus.wantToRead,
              ),
              status: _status,
              onStatusChanged: (s) => setState(() => _status = s),
              isFormatLocked: _isFormatLocked,
              onFormatLockChanged: (_) => _toggleLock(
                currentLocked: _isFormatLocked,
                setLocked: (v) => setState(() => _isFormatLocked = v),
                isModified: _format != null,
                onClearContent: () => _format = null,
              ),
              format: _format,
              onFormatChanged: (f) => setState(() => _format = f),
              bookDao: bookDao,
            ),
            BulkDetailsTab(
              isYearLocked: _isYearLocked,
              onYearLockChanged: (_) => _toggleLock(
                currentLocked: _isYearLocked,
                setLocked: (v) => setState(() => _isYearLocked = v),
                isModified: _publishYearCtrl.text.isNotEmpty,
                onClearContent: () => _publishYearCtrl.clear(),
              ),
              publishYearCtrl: _publishYearCtrl,
              isLanguageLocked: _isLanguageLocked,
              onLanguageLockChanged: (_) => _toggleLock(
                currentLocked: _isLanguageLocked,
                setLocked: (v) => setState(() => _isLanguageLocked = v),
                isModified: _languageCtrl.text.isNotEmpty,
                onClearContent: () => _languageCtrl.clear(),
              ),
              languageCtrl: _languageCtrl,
              isTranslationLocked: _isTranslationLocked,
              onTranslationLockChanged: (_) => _toggleLock(
                currentLocked: _isTranslationLocked,
                setLocked: (v) => setState(() => _isTranslationLocked = v),
                isModified: _isTranslation,
                onClearContent: () => _isTranslation = false,
              ),
              isTranslation: _isTranslation,
              onIsTranslationChanged: (v) => setState(() => _isTranslation = v),
              isOriginalLanguageLocked: _isOriginalLanguageLocked,
              onOriginalLanguageLockChanged: (_) => _toggleLock(
                currentLocked: _isOriginalLanguageLocked,
                setLocked: (v) => setState(() => _isOriginalLanguageLocked = v),
                isModified: _originalLanguageCtrl.text.isNotEmpty,
                onClearContent: () => _originalLanguageCtrl.clear(),
              ),
              originalLanguageCtrl: _originalLanguageCtrl,
              isOriginalTitleLocked: _isOriginalTitleLocked,
              onOriginalTitleLockChanged: (_) => _toggleLock(
                currentLocked: _isOriginalTitleLocked,
                setLocked: (v) => setState(() => _isOriginalTitleLocked = v),
                isModified: _originalTitleCtrl.text.isNotEmpty,
                onClearContent: () => _originalTitleCtrl.clear(),
              ),
              originalTitleCtrl: _originalTitleCtrl,
              isTranslatorLocked: _isTranslatorLocked,
              onTranslatorLockChanged: (_) => _toggleLock(
                currentLocked: _isTranslatorLocked,
                setLocked: (v) => setState(() => _isTranslatorLocked = v),
                isModified: _translatorCtrl.text.isNotEmpty,
                onClearContent: () => _translatorCtrl.clear(),
              ),
              translatorCtrl: _translatorCtrl,
              isOwnershipLocked: _isOwnershipLocked,
              onOwnershipLockChanged: (_) => _toggleLock(
                currentLocked: _isOwnershipLocked,
                setLocked: (v) => setState(() => _isOwnershipLocked = v),
                isModified: _ownershipStatus != null || _personNameCtrl.text.isNotEmpty,
                onClearContent: () {
                  _ownershipStatus = null;
                  _personNameCtrl.clear();
                },
              ),
              ownershipStatus: _ownershipStatus,
              onOwnershipStatusChanged: (s) => setState(() => _ownershipStatus = s),
              personNameCtrl: _personNameCtrl,
              isCollectionsLocked: _isCollectionsLocked,
              onCollectionsLockChanged: (_) => _toggleLock(
                currentLocked: _isCollectionsLocked,
                setLocked: (v) => setState(() => _isCollectionsLocked = v),
                isModified: _selectedCollections.isNotEmpty,
                onClearContent: () => _selectedCollections = [],
              ),
              selectedCollections: _selectedCollections,
              onCollectionsChanged: (list) => setState(() => _selectedCollections = list),
              isImprintLocked: _isImprintLocked,
              onImprintLockChanged: (_) => _toggleLock(
                currentLocked: _isImprintLocked,
                setLocked: (v) => setState(() => _isImprintLocked = v),
                isModified: _selectedImprint != null,
                onClearContent: () => _selectedImprint = null,
              ),
              selectedImprint: _selectedImprint,
              onImprintChanged: (imprint) => setState(() => _selectedImprint = imprint),
              isNotesLocked: _isNotesLocked,
              onNotesLockChanged: (_) => _toggleLock(
                currentLocked: _isNotesLocked,
                setLocked: (v) => setState(() => _isNotesLocked = v),
                isModified: _notesCtrl.text.isNotEmpty,
                onClearContent: () {
                  _notesCtrl.clear();
                  _appendNotes = false;
                },
              ),
              notesCtrl: _notesCtrl,
              appendNotes: _appendNotes,
              onAppendNotesChanged: (append) => setState(() => _appendNotes = append),
              isDatesLocked: _isDatesLocked,
              onDatesLockChanged: (_) => _toggleLock(
                currentLocked: _isDatesLocked,
                setLocked: (v) => setState(() => _isDatesLocked = v),
                isModified: _startedAt != null || _finishedAt != null,
                onClearContent: () {
                  _startedAt = null;
                  _finishedAt = null;
                },
              ),
              startedAt: _startedAt,
              finishedAt: _finishedAt,
              onStartedAtChanged: (d) => setState(() => _startedAt = d),
              onFinishedAtChanged: (d) => setState(() => _finishedAt = d),
              isCopiesLocked: _isCopiesLocked,
              onCopiesLockChanged: (_) => _toggleLock(
                currentLocked: _isCopiesLocked,
                setLocked: (v) => setState(() => _isCopiesLocked = v),
                isModified: _copiesCtrl.text != '1',
                onClearContent: () => _copiesCtrl.text = '1',
              ),
              copiesCtrl: _copiesCtrl,
              bookDao: bookDao,
            ),
          ],
        ),
      ),
    );
  }
}
