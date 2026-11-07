import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database.dart';
import '../../../services/daos/book_dao.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../widgets/entity_field_selector.dart';
import '../../../widgets/imprint_placeholder.dart';
import '../../../widgets/date_picker_field.dart';
import 'form_components.dart';
import 'padlock_field_wrapper.dart';
import 'bulk_form_components.dart';

class BulkDetailsTab extends ConsumerWidget {
  final bool isYearLocked;
  final ValueChanged<bool> onYearLockChanged;
  final TextEditingController publishYearCtrl;

  final bool isLanguageLocked;
  final ValueChanged<bool> onLanguageLockChanged;
  final TextEditingController languageCtrl;

  final bool isTranslationLocked;
  final ValueChanged<bool> onTranslationLockChanged;
  final bool isTranslation;
  final ValueChanged<bool> onIsTranslationChanged;

  final bool isOriginalLanguageLocked;
  final ValueChanged<bool> onOriginalLanguageLockChanged;
  final TextEditingController originalLanguageCtrl;

  final bool isOriginalTitleLocked;
  final ValueChanged<bool> onOriginalTitleLockChanged;
  final TextEditingController originalTitleCtrl;

  final bool isTranslatorLocked;
  final ValueChanged<bool> onTranslatorLockChanged;
  final TextEditingController translatorCtrl;

  final bool isOwnershipLocked;
  final ValueChanged<bool> onOwnershipLockChanged;
  final OwnershipStatus? ownershipStatus;
  final ValueChanged<OwnershipStatus?> onOwnershipStatusChanged;
  final TextEditingController personNameCtrl;

  final bool isCollectionsLocked;
  final ValueChanged<bool> onCollectionsLockChanged;
  final List<(Tag, int?)> selectedCollections;
  final ValueChanged<List<(Tag, int?)>> onCollectionsChanged;

  final bool isImprintLocked;
  final ValueChanged<bool> onImprintLockChanged;
  final Tag? selectedImprint;
  final ValueChanged<Tag?> onImprintChanged;

  final bool isNotesLocked;
  final ValueChanged<bool> onNotesLockChanged;
  final TextEditingController notesCtrl;
  final bool appendNotes;
  final ValueChanged<bool> onAppendNotesChanged;

  final bool isDatesLocked;
  final ValueChanged<bool> onDatesLockChanged;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final ValueChanged<DateTime?> onStartedAtChanged;
  final ValueChanged<DateTime?> onFinishedAtChanged;

  final bool isCopiesLocked;
  final ValueChanged<bool> onCopiesLockChanged;
  final TextEditingController copiesCtrl;

  final BookDao bookDao;

  const BulkDetailsTab({
    super.key,
    required this.isYearLocked,
    required this.onYearLockChanged,
    required this.publishYearCtrl,
    required this.isLanguageLocked,
    required this.onLanguageLockChanged,
    required this.languageCtrl,
    required this.isTranslationLocked,
    required this.onTranslationLockChanged,
    required this.isTranslation,
    required this.onIsTranslationChanged,
    required this.isOriginalLanguageLocked,
    required this.onOriginalLanguageLockChanged,
    required this.originalLanguageCtrl,
    required this.isOriginalTitleLocked,
    required this.onOriginalTitleLockChanged,
    required this.originalTitleCtrl,
    required this.isTranslatorLocked,
    required this.onTranslatorLockChanged,
    required this.translatorCtrl,
    required this.isOwnershipLocked,
    required this.onOwnershipLockChanged,
    required this.ownershipStatus,
    required this.onOwnershipStatusChanged,
    required this.personNameCtrl,
    required this.isCollectionsLocked,
    required this.onCollectionsLockChanged,
    required this.selectedCollections,
    required this.onCollectionsChanged,
    required this.isImprintLocked,
    required this.onImprintLockChanged,
    required this.selectedImprint,
    required this.onImprintChanged,
    required this.isNotesLocked,
    required this.onNotesLockChanged,
    required this.notesCtrl,
    required this.appendNotes,
    required this.onAppendNotesChanged,
    required this.isDatesLocked,
    required this.onDatesLockChanged,
    this.startedAt,
    this.finishedAt,
    required this.onStartedAtChanged,
    required this.onFinishedAtChanged,
    required this.isCopiesLocked,
    required this.onCopiesLockChanged,
    required this.copiesCtrl,
    required this.bookDao,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BulkSectionHeader(label: l10n.sectionBasicInfo),
        const SizedBox(height: 12),

        // Unalterable Property Notice: ISBN
        const UnalterablePropertyCard(
          title: "ISBN",
          icon: Icons.barcode_reader,
          message: "El código ISBN es único para cada libro y no se altera en masa.",
        ),
        const SizedBox(height: 16),

        PadlockFieldWrapper(
          label: l10n.fieldYear,
          isLocked: isYearLocked,
          onLockChanged: onYearLockChanged,
          child: FormFieldWidget(
            controller: publishYearCtrl,
            label: l10n.fieldYear,
            icon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
          ),
        ),

        PadlockFieldWrapper(
          label: l10n.fieldLanguage,
          isLocked: isLanguageLocked,
          onLockChanged: onLanguageLockChanged,
          child: DelimitedAutocompleteFormField(
            controller: languageCtrl,
            label: l10n.fieldLanguage,
            icon: Icons.language_outlined,
            optionsBuilder: (q) => bookDao.getDistinctLanguages(q),
          ),
        ),

        PadlockFieldWrapper(
          label: l10n.fieldIsTranslation,
          isLocked: isTranslationLocked,
          onLockChanged: onTranslationLockChanged,
          child: Row(
            children: [
              Text(l10n.fieldIsTranslation),
              const Spacer(),
              Switch(
                value: isTranslation,
                onChanged: onIsTranslationChanged,
              ),
            ],
          ),
        ),

        if (isTranslation) ...[
          PadlockFieldWrapper(
            isLocked: isOriginalLanguageLocked,
            onLockChanged: onOriginalLanguageLockChanged,
            child: DelimitedAutocompleteFormField(
              controller: originalLanguageCtrl,
              label: l10n.fieldOriginalLanguage,
              icon: Icons.language_outlined,
              optionsBuilder: (q) => bookDao.getDistinctLanguages(q),
            ),
          ),
          PadlockFieldWrapper(
            isLocked: isOriginalTitleLocked,
            onLockChanged: onOriginalTitleLockChanged,
            child: FormFieldWidget(
              controller: originalTitleCtrl,
              label: l10n.fieldOriginalTitle,
              icon: Icons.title_outlined,
            ),
          ),
          PadlockFieldWrapper(
            isLocked: isTranslatorLocked,
            onLockChanged: onTranslatorLockChanged,
            child: DelimitedAutocompleteFormField(
              controller: translatorCtrl,
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
        BulkSectionHeader(label: l10n.fieldOwnershipStatus),
        const SizedBox(height: 12),
        PadlockFieldWrapper(
          isLocked: isOwnershipLocked,
          onLockChanged: onOwnershipLockChanged,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OwnershipStatusSelector(
                selected: ownershipStatus,
                onChanged: onOwnershipStatusChanged,
              ),
              if (ownershipStatus == OwnershipStatus.borrowed ||
                  ownershipStatus == OwnershipStatus.gifted) ...[
                const SizedBox(height: 12),
                FormFieldWidget(
                  controller: personNameCtrl,
                  label: l10n.ownershipEventPerson,
                  icon: Icons.person_outline,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Collections
        BulkSectionHeader(label: l10n.fieldCollection),
        const SizedBox(height: 12),
        PadlockFieldWrapper(
          isLocked: isCollectionsLocked,
          onLockChanged: onCollectionsLockChanged,
          child: Column(
            children: [
              ...selectedCollections.asMap().entries.map((entry) {
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
                              final newList = List<(Tag, int?)>.from(selectedCollections);
                              newList[index] = (col, newNumber);
                              onCollectionsChanged(newList);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            final newList = List<(Tag, int?)>.from(selectedCollections);
                            newList.removeAt(index);
                            onCollectionsChanged(newList);
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
                    if (!selectedCollections.any((c) => c.$1.id == newTag.id)) {
                      onCollectionsChanged([...selectedCollections, (newTag, null)]);
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
        BulkSectionHeader(label: l10n.sectionImprint),
        const SizedBox(height: 12),
        PadlockFieldWrapper(
          isLocked: isImprintLocked,
          onLockChanged: onImprintLockChanged,
          child: Column(
            children: [
              if (selectedImprint != null)
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
                          child: selectedImprint!.imagePath != null
                              ? Image.file(
                                  File(selectedImprint!.imagePath!),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                  errorBuilder: (context, error, stackTrace) =>
                                      ImprintPlaceholder(size: 40, iconSize: 20, name: selectedImprint!.name),
                                )
                              : ImprintPlaceholder(size: 40, iconSize: 20, name: selectedImprint!.name),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedImprint!.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => onImprintChanged(null),
                        ),
                      ],
                    ),
                  ),
                ),
              EntityFieldSelector(
                key: const ValueKey('bulk_imprint_selector'),
                selected: const [],
                onChanged: (list) {
                  onImprintChanged(list.firstOrNull);
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
        BulkSectionHeader(label: l10n.bookDetailNotesTitle),
        const SizedBox(height: 12),
        PadlockFieldWrapper(
          isLocked: isNotesLocked,
          onLockChanged: onNotesLockChanged,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormFieldWidget(
                controller: notesCtrl,
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
                    selected: !appendNotes,
                    onSelected: (selected) {
                      if (selected) onAppendNotesChanged(false);
                    },
                  ),
                  ChoiceChip(
                    label: Text(l10n.bulkNotesModeAppend),
                    selected: appendNotes,
                    onSelected: (selected) {
                      if (selected) onAppendNotesChanged(true);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Reading Dates
        BulkSectionHeader(label: l10n.tabDetails),
        const SizedBox(height: 12),
        PadlockFieldWrapper(
          isLocked: isDatesLocked,
          onLockChanged: onDatesLockChanged,
          child: Column(
            children: [
              DatePickerField(
                label: l10n.bookDetailFieldStarted,
                value: startedAt,
                onChanged: onStartedAtChanged,
                icon: Icons.play_circle_outline,
              ),
              const SizedBox(height: 12),
              DatePickerField(
                label: l10n.bookDetailFieldFinished,
                value: finishedAt,
                onChanged: onFinishedAtChanged,
                icon: Icons.check_circle_outline,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Copies
        PadlockFieldWrapper(
          isLocked: isCopiesLocked,
          onLockChanged: onCopiesLockChanged,
          child: FormFieldWidget(
            controller: copiesCtrl,
            label: l10n.fieldCopies,
            icon: Icons.copy,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
