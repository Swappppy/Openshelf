import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database.dart';
import '../../services/daos/book_dao.dart';
import '../../controllers/database_provider.dart';
import '../../controllers/book_selection_controller.dart';
import '../../controllers/book_form_controller.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/entity_field_selector.dart';
import '../../widgets/imprint_placeholder.dart';
import '../../widgets/cover_placeholder.dart';
import '../../widgets/date_picker_field.dart';
import 'cover_picker_sheet.dart';
import 'widgets/form_components.dart';
import 'widgets/padlock_field_wrapper.dart';

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
                child: Text(l10n.delete),
              ),
            ],
          ),
        );

        if (confirmed == true && mounted) {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            onClearContent();
            setLocked(true);
          });
        }
      } else {
        FocusManager.instance.primaryFocus?.unfocus();
        setLocked(true);
      }
    }
  }

  // --- Cover Actions ---
  Future<void> _pickCover() async {
    if (_isProcessingImage) return;
    final l10n = context.l10n;
    try {
      final saved = await ref.read(bookFormControllerProvider).pickCoverFromGallery(
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
            // --- TAB 1: MAIN ---
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Cover Picker with Padlock
                PadlockFieldWrapper(
                  centerChild: true,
                  isLocked: _isCoverLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isCoverLocked,
                    setLocked: (v) => setState(() => _isCoverLocked = v),
                    isModified: _coverPath != null,
                    onClearContent: () => _coverPath = null,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickCover,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _coverPath != null
                                    ? Image.file(
                                        File(_coverPath!),
                                        width: 100,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const CoverPlaceholder(width: 100, height: 150, iconSize: 48),
                                      )
                                    : const CoverPlaceholder(width: 100, height: 150, iconSize: 48),
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
                                    color: colorScheme.onPrimary,
                                  ),
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
                              label: Text(l10n.photo),
                              onPressed: _takePhoto,
                            ),
                            const SizedBox(width: 4),
                            TextButton.icon(
                              icon: const Icon(Icons.link, size: 16),
                              label: Text(l10n.url),
                              onPressed: _pickCoverFromUrl,
                            ),
                            const SizedBox(width: 4),
                            TextButton.icon(
                              icon: const Icon(Icons.image_search, size: 16),
                              label: Text(l10n.coverSearch),
                              onPressed: _searchCovers,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Basic Info
                SectionHeader(label: l10n.sectionBasicInfo),
                const SizedBox(height: 12),

                PadlockFieldWrapper(
                  isLocked: _isTitleLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isTitleLocked,
                    setLocked: (v) => setState(() => _isTitleLocked = v),
                    isModified: _titleCtrl.text.isNotEmpty,
                    onClearContent: () => _titleCtrl.clear(),
                  ),
                  child: FormFieldWidget(
                    controller: _titleCtrl,
                    label: l10n.fieldTitle,
                    icon: Icons.title,
                  ),
                ),

                PadlockFieldWrapper(
                  isLocked: _isSubtitleLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isSubtitleLocked,
                    setLocked: (v) => setState(() => _isSubtitleLocked = v),
                    isModified: _subtitleCtrl.text.isNotEmpty,
                    onClearContent: () => _subtitleCtrl.clear(),
                  ),
                  child: FormFieldWidget(
                    controller: _subtitleCtrl,
                    label: l10n.fieldSubtitle,
                    icon: Icons.subtitles_outlined,
                  ),
                ),

                PadlockFieldWrapper(
                  isLocked: _isAuthorLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isAuthorLocked,
                    setLocked: (v) => setState(() => _isAuthorLocked = v),
                    isModified: _authorCtrl.text.isNotEmpty,
                    onClearContent: () => _authorCtrl.clear(),
                  ),
                  child: DelimitedAutocompleteFormField(
                    controller: _authorCtrl,
                    label: l10n.fieldAuthor,
                    icon: Icons.person_outline,
                    optionsBuilder: (q) => bookDao.getDistinctAuthors(q),
                    showHelp: true,
                    helpTitle: l10n.authorMultiHelpTitle,
                    helpContent: l10n.authorMultiHelpContent,
                  ),
                ),

                PadlockFieldWrapper(
                  isLocked: _isPublisherLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isPublisherLocked,
                    setLocked: (v) => setState(() => _isPublisherLocked = v),
                    isModified: _publisherCtrl.text.isNotEmpty,
                    onClearContent: () => _publisherCtrl.clear(),
                  ),
                  child: DelimitedAutocompleteFormField(
                    controller: _publisherCtrl,
                    label: l10n.fieldPublisher,
                    icon: Icons.business_outlined,
                    optionsBuilder: (q) => bookDao.getDistinctPublishers(q),
                  ),
                ),

                PadlockFieldWrapper(
                  isLocked: _isDescriptionLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isDescriptionLocked,
                    setLocked: (v) => setState(() => _isDescriptionLocked = v),
                    isModified: _descriptionCtrl.text.isNotEmpty,
                    onClearContent: () => _descriptionCtrl.clear(),
                  ),
                  child: FormFieldWidget(
                    controller: _descriptionCtrl,
                    label: l10n.fieldDescription,
                    icon: Icons.description_outlined,
                    maxLines: 5,
                  ),
                ),
                const SizedBox(height: 24),

                // Categories / Tags
                PadlockFieldWrapper(
                  isLocked: _isTagsLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isTagsLocked,
                    setLocked: (v) => setState(() => _isTagsLocked = v),
                    isModified: _selectedTags.isNotEmpty,
                    onClearContent: () => _selectedTags = [],
                  ),
                  child: EntityFieldSelector(
                    selected: _selectedTags,
                    onChanged: (list) => setState(() => _selectedTags = list),
                    type: TagType.tag,
                    label: l10n.tagSearchOrCreate,
                    icon: Icons.label_outline,
                  ),
                ),
                const SizedBox(height: 24),

                // Unalterable Property Notice: Pages
                _UnalterablePropertyCard(
                  title: l10n.fieldReadingProgress,
                  icon: Icons.menu_book_outlined,
                  message: "Las páginas y el progreso de lectura son específicos de cada libro y no se alteran en masa.",
                ),
                const SizedBox(height: 24),

                // Status Section
                SectionHeader(label: l10n.sectionReadingStatus),
                const SizedBox(height: 12),
                PadlockFieldWrapper(
                  isLocked: _isStatusLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isStatusLocked,
                    setLocked: (v) => setState(() => _isStatusLocked = v),
                    isModified: _status != ReadingStatus.wantToRead,
                    onClearContent: () => _status = ReadingStatus.wantToRead,
                  ),
                  child: StatusSelector(
                    selected: _status,
                    onChanged: (s) => setState(() => _status = s),
                  ),
                ),
                const SizedBox(height: 24),

                // Format Section
                SectionHeader(label: l10n.sectionFormat),
                const SizedBox(height: 12),
                PadlockFieldWrapper(
                  isLocked: _isFormatLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isFormatLocked,
                    setLocked: (v) => setState(() => _isFormatLocked = v),
                    isModified: _format != null,
                    onClearContent: () => _format = null,
                  ),
                  child: FormatSelector(
                    selected: _format,
                    onChanged: (f) => setState(() => _format = f),
                  ),
                ),
                const SizedBox(height: 24),

                // Unalterable Property Notice: Rating
                _UnalterablePropertyCard(
                  title: l10n.sectionRating,
                  icon: Icons.star_outline,
                  message: "La puntuación es individual para cada libro y no se altera en masa.",
                ),
                const SizedBox(height: 32),
              ],
            ),

            // --- TAB 2: DETAILS ---
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionHeader(label: l10n.sectionBasicInfo),
                const SizedBox(height: 12),

                // Unalterable Property Notice: ISBN
                _UnalterablePropertyCard(
                  title: l10n.fieldIsbn,
                  icon: Icons.barcode_reader,
                  message: "El código ISBN es único para cada libro y no se altera en masa.",
                ),
                const SizedBox(height: 16),

                PadlockFieldWrapper(
                  label: l10n.fieldYear,
                  isLocked: _isYearLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isYearLocked,
                    setLocked: (v) => setState(() => _isYearLocked = v),
                    isModified: _publishYearCtrl.text.isNotEmpty,
                    onClearContent: () => _publishYearCtrl.clear(),
                  ),
                  child: FormFieldWidget(
                    controller: _publishYearCtrl,
                    label: l10n.fieldYear,
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),

                PadlockFieldWrapper(
                  label: l10n.fieldLanguage,
                  isLocked: _isLanguageLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isLanguageLocked,
                    setLocked: (v) => setState(() => _isLanguageLocked = v),
                    isModified: _languageCtrl.text.isNotEmpty,
                    onClearContent: () => _languageCtrl.clear(),
                  ),
                  child: DelimitedAutocompleteFormField(
                    controller: _languageCtrl,
                    label: l10n.fieldLanguage,
                    icon: Icons.language_outlined,
                    optionsBuilder: (q) => bookDao.getDistinctLanguages(q),
                  ),
                ),

                PadlockFieldWrapper(
                  label: l10n.fieldIsTranslation,
                  isLocked: _isTranslationLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isTranslationLocked,
                    setLocked: (v) => setState(() => _isTranslationLocked = v),
                    isModified: _isTranslation,
                    onClearContent: () => _isTranslation = false,
                  ),
                  child: Row(
                    children: [
                      Text(l10n.fieldIsTranslation),
                      const Spacer(),
                      Switch(
                        value: _isTranslation,
                        onChanged: (v) => setState(() => _isTranslation = v),
                      ),
                    ],
                  ),
                ),

                if (_isTranslation) ...[
                  PadlockFieldWrapper(
                    isLocked: _isOriginalLanguageLocked,
                    onLockChanged: (_) => _toggleLock(
                      currentLocked: _isOriginalLanguageLocked,
                      setLocked: (v) => setState(() => _isOriginalLanguageLocked = v),
                      isModified: _originalLanguageCtrl.text.isNotEmpty,
                      onClearContent: () => _originalLanguageCtrl.clear(),
                    ),
                    child: DelimitedAutocompleteFormField(
                      controller: _originalLanguageCtrl,
                      label: l10n.fieldOriginalLanguage,
                      icon: Icons.language_outlined,
                      optionsBuilder: (q) => bookDao.getDistinctLanguages(q),
                    ),
                  ),
                  PadlockFieldWrapper(
                    isLocked: _isOriginalTitleLocked,
                    onLockChanged: (_) => _toggleLock(
                      currentLocked: _isOriginalTitleLocked,
                      setLocked: (v) => setState(() => _isOriginalTitleLocked = v),
                      isModified: _originalTitleCtrl.text.isNotEmpty,
                      onClearContent: () => _originalTitleCtrl.clear(),
                    ),
                    child: FormFieldWidget(
                      controller: _originalTitleCtrl,
                      label: l10n.fieldOriginalTitle,
                      icon: Icons.title_outlined,
                    ),
                  ),
                  PadlockFieldWrapper(
                    isLocked: _isTranslatorLocked,
                    onLockChanged: (_) => _toggleLock(
                      currentLocked: _isTranslatorLocked,
                      setLocked: (v) => setState(() => _isTranslatorLocked = v),
                      isModified: _translatorCtrl.text.isNotEmpty,
                      onClearContent: () => _translatorCtrl.clear(),
                    ),
                    child: DelimitedAutocompleteFormField(
                      controller: _translatorCtrl,
                      label: l10n.fieldTranslator,
                      icon: Icons.translate_outlined,
                      optionsBuilder: (q) => bookDao.getDistinctTranslators(q),
                      showHelp: true,
                      helpTitle: l10n.translatorMultiHelpTitle,
                      helpContent: l10n.translatorMultiHelpContent,
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Ownership Status
                SectionHeader(label: l10n.fieldOwnershipStatus),
                const SizedBox(height: 12),
                PadlockFieldWrapper(
                  isLocked: _isOwnershipLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isOwnershipLocked,
                    setLocked: (v) => setState(() => _isOwnershipLocked = v),
                    isModified: _ownershipStatus != null || _personNameCtrl.text.isNotEmpty,
                    onClearContent: () {
                      _ownershipStatus = null;
                      _personNameCtrl.clear();
                    },
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OwnershipStatusSelector(
                        selected: _ownershipStatus,
                        onChanged: (s) => setState(() => _ownershipStatus = s),
                      ),
                      if (_ownershipStatus == OwnershipStatus.borrowed ||
                          _ownershipStatus == OwnershipStatus.gifted) ...[
                        const SizedBox(height: 12),
                        FormFieldWidget(
                          controller: _personNameCtrl,
                          label: l10n.ownershipEventPerson,
                          icon: Icons.person_outline,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Collections
                SectionHeader(label: l10n.fieldCollection),
                const SizedBox(height: 12),
                PadlockFieldWrapper(
                  isLocked: _isCollectionsLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isCollectionsLocked,
                    setLocked: (v) => setState(() => _isCollectionsLocked = v),
                    isModified: _selectedCollections.isNotEmpty,
                    onClearContent: () => _selectedCollections = [],
                  ),
                  child: Column(
                    children: [
                      ..._selectedCollections.asMap().entries.map((entry) {
                        final index = entry.key;
                        final col = entry.value.$1;
                        final number = entry.value.$2;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.collections_bookmark_outlined, size: 20, color: colorScheme.primary),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          col.name,
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 72,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      prefix: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(
                                          '#',
                                          style: TextStyle(
                                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                      isDense: true,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    keyboardType: TextInputType.number,
                                    controller: TextEditingController(text: number?.toString() ?? '')
                                      ..selection = TextSelection.fromPosition(
                                        TextPosition(offset: (number?.toString() ?? '').length),
                                      ),
                                    onChanged: (value) {
                                      final newNumber = int.tryParse(value);
                                      final newList = List<(Tag, int?)>.from(_selectedCollections);
                                      newList[index] = (col, newNumber);
                                      setState(() => _selectedCollections = newList);
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () {
                                    final newList = List<(Tag, int?)>.from(_selectedCollections);
                                    newList.removeAt(index);
                                    setState(() => _selectedCollections = newList);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      EntityFieldSelector(
                        key: const ValueKey('bulk_collection_selector'),
                        selected: const [],
                        onChanged: (list) {
                          if (list.isNotEmpty) {
                            final newTag = list.last;
                            if (!_selectedCollections.any((c) => c.$1.id == newTag.id)) {
                              setState(() {
                                _selectedCollections = [..._selectedCollections, (newTag, null)];
                              });
                            }
                          }
                        },
                        type: TagType.collection,
                        label: l10n.fieldCollection,
                        icon: Icons.layers_outlined,
                        multiSelection: true,
                        useSquareButton: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Imprint
                SectionHeader(label: l10n.sectionImprint),
                const SizedBox(height: 12),
                PadlockFieldWrapper(
                  isLocked: _isImprintLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isImprintLocked,
                    setLocked: (v) => setState(() => _isImprintLocked = v),
                    isModified: _selectedImprint != null,
                    onClearContent: () => _selectedImprint = null,
                  ),
                  child: Column(
                    children: [
                      if (_selectedImprint != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _selectedImprint!.imagePath != null
                                      ? Image.file(
                                          File(_selectedImprint!.imagePath!),
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.topCenter,
                                          errorBuilder: (context, error, stackTrace) =>
                                              ImprintPlaceholder(size: 40, iconSize: 20, name: _selectedImprint!.name),
                                        )
                                      : ImprintPlaceholder(size: 40, iconSize: 20, name: _selectedImprint!.name),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedImprint!.name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => setState(() => _selectedImprint = null),
                                ),
                              ],
                            ),
                          ),
                        ),
                      EntityFieldSelector(
                        key: const ValueKey('bulk_imprint_selector'),
                        selected: const [],
                        onChanged: (list) {
                          setState(() => _selectedImprint = list.firstOrNull);
                        },
                        type: TagType.imprint,
                        label: l10n.imprintSearch,
                        icon: Icons.business_outlined,
                        multiSelection: false,
                        useSquareButton: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Personal Notes
                SectionHeader(label: l10n.bookDetailNotesTitle),
                const SizedBox(height: 12),
                PadlockFieldWrapper(
                  isLocked: _isNotesLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isNotesLocked,
                    setLocked: (v) => setState(() => _isNotesLocked = v),
                    isModified: _notesCtrl.text.isNotEmpty,
                    onClearContent: () {
                      _notesCtrl.clear();
                      _appendNotes = false;
                    },
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormFieldWidget(
                        controller: _notesCtrl,
                        label: l10n.fieldNotes,
                        icon: Icons.notes_outlined,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Text(
                            l10n.bulkNotesMode,
                            style: theme.textTheme.bodySmall,
                          ),
                          ChoiceChip(
                            label: Text(l10n.bulkNotesModeOverwrite),
                            selected: !_appendNotes,
                            onSelected: (selected) {
                              if (selected) setState(() => _appendNotes = false);
                            },
                          ),
                          ChoiceChip(
                            label: Text(l10n.bulkNotesModeAppend),
                            selected: _appendNotes,
                            onSelected: (selected) {
                              if (selected) setState(() => _appendNotes = true);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Reading Dates
                SectionHeader(label: l10n.tabDetails),
                const SizedBox(height: 12),
                PadlockFieldWrapper(
                  isLocked: _isDatesLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isDatesLocked,
                    setLocked: (v) => setState(() => _isDatesLocked = v),
                    isModified: _startedAt != null || _finishedAt != null,
                    onClearContent: () {
                      _startedAt = null;
                      _finishedAt = null;
                    },
                  ),
                  child: Column(
                    children: [
                      DatePickerField(
                        label: l10n.bookDetailFieldStarted,
                        value: _startedAt,
                        onChanged: (d) => setState(() => _startedAt = d),
                        icon: Icons.play_circle_outline,
                      ),
                      const SizedBox(height: 12),
                      DatePickerField(
                        label: l10n.bookDetailFieldFinished,
                        value: _finishedAt,
                        onChanged: (d) => setState(() => _finishedAt = d),
                        icon: Icons.check_circle_outline,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Copies
                PadlockFieldWrapper(
                  isLocked: _isCopiesLocked,
                  onLockChanged: (_) => _toggleLock(
                    currentLocked: _isCopiesLocked,
                    setLocked: (v) => setState(() => _isCopiesLocked = v),
                    isModified: _copiesCtrl.text != '1',
                    onClearContent: () => _copiesCtrl.text = '1',
                  ),
                  child: FormFieldWidget(
                    controller: _copiesCtrl,
                    label: l10n.fieldCopies,
                    icon: Icons.copy,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnalterablePropertyCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const _UnalterablePropertyCard({
    required this.title,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: "Campo inalterable en edición masiva",
            child: Icon(Icons.lock_outline, color: colorScheme.outline, size: 20),
          ),
        ],
      ),
    );
  }
}
