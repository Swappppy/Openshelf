import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../services/database.dart';
import '../../services/daos/book_dao.dart';
import '../../controllers/database_provider.dart';
import '../../controllers/book_selection_controller.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/entity_field_selector.dart';
import 'widgets/form_components.dart';
import 'widgets/padlock_field_wrapper.dart';

/// Form for bulk editing common attributes across multiple selected books.
/// Applies the Padlock UI pattern: fields start locked by default and only
/// unlocked fields are updated across all selected items upon save.
class BulkEditView extends ConsumerStatefulWidget {
  final List<int> selectedBookIds;

  const BulkEditView({
    super.key,
    required this.selectedBookIds,
  });

  @override
  ConsumerState<BulkEditView> createState() => _BulkEditViewState();
}

class _BulkEditViewState extends ConsumerState<BulkEditView> {
  final _formKey = GlobalKey<FormState>();

  // Lock States (All locked by default)
  bool _isStatusLocked = true;
  bool _isOwnershipLocked = true;
  bool _isFormatLocked = true;
  bool _isRatingLocked = true;
  bool _isAuthorLocked = true;
  bool _isPublisherLocked = true;
  bool _isLanguageLocked = true;
  bool _isYearLocked = true;
  bool _isTranslatorLocked = true;
  bool _isTagsLocked = true;
  bool _isImprintLocked = true;
  bool _isCollectionsLocked = true;
  bool _isNotesLocked = true;
  bool _isCopiesLocked = true;

  // Form Values
  ReadingStatus _status = ReadingStatus.wantToRead;
  OwnershipStatus? _ownershipStatus;
  BookFormat? _format;
  double? _rating;

  late final TextEditingController _authorCtrl;
  late final TextEditingController _publisherCtrl;
  late final TextEditingController _languageCtrl;
  late final TextEditingController _publishYearCtrl;
  late final TextEditingController _translatorCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _copiesCtrl;

  List<Tag> _selectedTags = [];
  Tag? _selectedImprint;
  List<(Tag, int?)> _selectedCollections = [];
  bool _appendNotes = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _authorCtrl = TextEditingController();
    _publisherCtrl = TextEditingController();
    _languageCtrl = TextEditingController();
    _publishYearCtrl = TextEditingController();
    _translatorCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
    _copiesCtrl = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _authorCtrl.dispose();
    _publisherCtrl.dispose();
    _languageCtrl.dispose();
    _publishYearCtrl.dispose();
    _translatorCtrl.dispose();
    _notesCtrl.dispose();
    _copiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Check if any field is unlocked
    final hasAnyUnlocked = !_isStatusLocked ||
        !_isOwnershipLocked ||
        !_isFormatLocked ||
        !_isRatingLocked ||
        !_isAuthorLocked ||
        !_isPublisherLocked ||
        !_isLanguageLocked ||
        !_isYearLocked ||
        !_isTranslatorLocked ||
        !_isTagsLocked ||
        !_isImprintLocked ||
        !_isCollectionsLocked ||
        !_isNotesLocked ||
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

      // Handle tag creation for negative IDs if any
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
        updateStatus: !_isStatusLocked,
        status: _status,
        updateOwnership: !_isOwnershipLocked,
        ownershipStatus: _ownershipStatus,
        updateFormat: !_isFormatLocked,
        format: _format,
        updateRating: !_isRatingLocked,
        rating: _rating,
        updateAuthor: !_isAuthorLocked,
        author: _authorCtrl.text.trim().isNotEmpty ? _authorCtrl.text.trim() : null,
        updatePublisher: !_isPublisherLocked,
        publisher: _publisherCtrl.text.trim().isNotEmpty ? _publisherCtrl.text.trim() : null,
        updateLanguage: !_isLanguageLocked,
        language: _languageCtrl.text.trim().isNotEmpty ? _languageCtrl.text.trim() : null,
        updatePublishYear: !_isYearLocked,
        publishYear: int.tryParse(_publishYearCtrl.text),
        updateTranslator: !_isTranslatorLocked,
        translator: _translatorCtrl.text.trim().isNotEmpty ? _translatorCtrl.text.trim() : null,
        updateTags: !_isTagsLocked,
        tagIds: tagIds,
        updateImprint: !_isImprintLocked,
        imprintId: imprintId,
        updateCollections: !_isCollectionsLocked,
        collections: collections,
        updateNotes: !_isNotesLocked,
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        appendNotes: _appendNotes,
        updateCopies: !_isCopiesLocked,
        copies: int.tryParse(_copiesCtrl.text) ?? 1,
      );

      await db.bookDao.bulkUpdateBooks(widget.selectedBookIds, bulkData);

      // Clear multi-select state
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
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informational Card
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.padlockLockedHint,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reading Status
            PadlockFieldWrapper(
              label: l10n.sectionReadingStatus,
              isLocked: _isStatusLocked,
              onLockChanged: (v) => setState(() => _isStatusLocked = v),
              child: StatusSelector(
                selected: _status,
                onChanged: (s) => setState(() => _status = s),
              ),
            ),

            // Ownership Status
            PadlockFieldWrapper(
              label: l10n.fieldOwnershipStatus,
              isLocked: _isOwnershipLocked,
              onLockChanged: (v) => setState(() => _isOwnershipLocked = v),
              child: OwnershipStatusSelector(
                selected: _ownershipStatus,
                onChanged: (s) => setState(() => _ownershipStatus = s),
              ),
            ),

            // Book Format
            PadlockFieldWrapper(
              label: l10n.sectionFormat,
              isLocked: _isFormatLocked,
              onLockChanged: (v) => setState(() => _isFormatLocked = v),
              child: FormatSelector(
                selected: _format,
                onChanged: (f) => setState(() => _format = f),
              ),
            ),

            // Rating
            PadlockFieldWrapper(
              label: l10n.fieldRating,
              isLocked: _isRatingLocked,
              onLockChanged: (v) => setState(() => _isRatingLocked = v),
              child: RatingSelector(
                rating: _rating,
                onChanged: (r) => setState(() => _rating = r),
              ),
            ),

            // Author (Autocomplete)
            PadlockFieldWrapper(
              isLocked: _isAuthorLocked,
              onLockChanged: (v) => setState(() => _isAuthorLocked = v),
              child: _AutocompleteFormField(
                controller: _authorCtrl,
                label: l10n.fieldAuthor,
                icon: Icons.person_outlined,
                optionsBuilder: (q) => bookDao.getDistinctAuthors(q),
              ),
            ),

            // Publisher (Autocomplete)
            PadlockFieldWrapper(
              isLocked: _isPublisherLocked,
              onLockChanged: (v) => setState(() => _isPublisherLocked = v),
              child: _AutocompleteFormField(
                controller: _publisherCtrl,
                label: l10n.fieldPublisher,
                icon: Icons.business_outlined,
                optionsBuilder: (q) => bookDao.getDistinctPublishers(q),
              ),
            ),

            // Language (Autocomplete)
            PadlockFieldWrapper(
              isLocked: _isLanguageLocked,
              onLockChanged: (v) => setState(() => _isLanguageLocked = v),
              child: _AutocompleteFormField(
                controller: _languageCtrl,
                label: l10n.fieldLanguage,
                icon: Icons.language_outlined,
                optionsBuilder: (q) => bookDao.getDistinctLanguages(q),
              ),
            ),

            // Publish Year
            PadlockFieldWrapper(
              isLocked: _isYearLocked,
              onLockChanged: (v) => setState(() => _isYearLocked = v),
              child: FormFieldWidget(
                controller: _publishYearCtrl,
                label: l10n.fieldYear,
                icon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
              ),
            ),

            // Translator (Autocomplete)
            PadlockFieldWrapper(
              isLocked: _isTranslatorLocked,
              onLockChanged: (v) => setState(() => _isTranslatorLocked = v),
              child: _AutocompleteFormField(
                controller: _translatorCtrl,
                label: l10n.fieldTranslator,
                icon: Icons.translate_outlined,
                optionsBuilder: (q) => bookDao.getDistinctTranslators(q),
              ),
            ),

            // Categories / Tags
            PadlockFieldWrapper(
              isLocked: _isTagsLocked,
              onLockChanged: (v) => setState(() => _isTagsLocked = v),
              child: EntityFieldSelector(
                selected: _selectedTags,
                onChanged: (list) => setState(() => _selectedTags = list),
                type: TagType.tag,
                label: l10n.managementCategories,
                icon: Icons.label_outline,
              ),
            ),

            // Imprint
            PadlockFieldWrapper(
              isLocked: _isImprintLocked,
              onLockChanged: (v) => setState(() => _isImprintLocked = v),
              child: EntityFieldSelector(
                selected: _selectedImprint != null ? [_selectedImprint!] : [],
                onChanged: (list) => setState(() => _selectedImprint = list.firstOrNull),
                type: TagType.imprint,
                label: l10n.managementImprints,
                icon: Icons.domain_outlined,
                multiSelection: false,
              ),
            ),

            // Collections
            PadlockFieldWrapper(
              isLocked: _isCollectionsLocked,
              onLockChanged: (v) => setState(() => _isCollectionsLocked = v),
              child: EntityFieldSelector(
                selected: _selectedCollections.map((c) => c.$1).toList(),
                onChanged: (list) => setState(() {
                  _selectedCollections = list.map((t) => (t, null)).toList();
                }),
                type: TagType.collection,
                label: l10n.managementCollections,
                icon: Icons.collections_bookmark_outlined,
              ),
            ),

            // Personal Notes
            PadlockFieldWrapper(
              isLocked: _isNotesLocked,
              onLockChanged: (v) => setState(() => _isNotesLocked = v),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormFieldWidget(
                    controller: _notesCtrl,
                    label: l10n.fieldNotes,
                    icon: Icons.note_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        l10n.bulkNotesMode,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(l10n.bulkNotesModeOverwrite),
                        selected: !_appendNotes,
                        onSelected: (selected) {
                          if (selected) setState(() => _appendNotes = false);
                        },
                      ),
                      const SizedBox(width: 6),
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

            // Copies
            PadlockFieldWrapper(
              isLocked: _isCopiesLocked,
              onLockChanged: (v) => setState(() => _isCopiesLocked = v),
              child: FormFieldWidget(
                controller: _copiesCtrl,
                label: l10n.fieldCopies,
                icon: Icons.copy_outlined,
                keyboardType: TextInputType.number,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _AutocompleteFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Future<List<String>> Function(String query) optionsBuilder;

  const _AutocompleteFormField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.optionsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      displayStringForOption: (option) => option,
      optionsBuilder: (textEditingValue) async {
        final text = textEditingValue.text.trim();
        if (text.isEmpty) return const [];
        return await optionsBuilder(text);
      },
      onSelected: (selection) {
        controller.text = selection;
      },
      fieldViewBuilder: (ctx, textCtrl, focusNode, onSubmitted) {
        if (textCtrl.text != controller.text && textCtrl.text.isEmpty && controller.text.isNotEmpty) {
          textCtrl.text = controller.text;
        }

        return TextField(
          controller: textCtrl,
          focusNode: focusNode,
          onChanged: (val) => controller.text = val,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => onSubmitted(),
        );
      },
    );
  }
}
