import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../widgets/entity_field_selector.dart';
import '../../../widgets/imprint_placeholder.dart';
import '../../../widgets/date_picker_field.dart';
import '../../../models/tag_type.dart';
import 'form_components.dart';

class DetailsTab extends ConsumerWidget {
  final TextEditingController notesCtrl;
  final TextEditingController isbnCtrl;
  final TextEditingController languageCtrl;
  final TextEditingController originalTitleCtrl;
  final TextEditingController originalLanguageCtrl;
  final TextEditingController publishYearCtrl;
  final TextEditingController translatorCtrl;
  final bool isTranslation;
  final ValueChanged<bool> onIsTranslationChanged;
  final OwnershipStatus? ownershipStatus;
  final ValueChanged<OwnershipStatus?> onOwnershipStatusChanged;
  final TextEditingController personNameCtrl;
  final List<(Tag, int?)> selectedCollections;
  final Tag? selectedImprint;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final ValueChanged<DateTime?> onStartedAtChanged;
  final ValueChanged<DateTime?> onFinishedAtChanged;
  final ValueChanged<List<(Tag, int?)>> onCollectionsChanged;
  final ValueChanged<Tag?> onImprintChanged;
  final TextEditingController copiesCtrl;

  const DetailsTab({
    super.key,
    required this.notesCtrl,
    required this.isbnCtrl,
    required this.languageCtrl,
    required this.originalTitleCtrl,
    required this.originalLanguageCtrl,
    required this.publishYearCtrl,
    required this.translatorCtrl,
    required this.isTranslation,
    required this.onIsTranslationChanged,
    this.ownershipStatus,
    required this.onOwnershipStatusChanged,
    required this.personNameCtrl,
    required this.selectedCollections,
    required this.selectedImprint,
    this.startedAt,
    this.finishedAt,
    required this.onStartedAtChanged,
    required this.onFinishedAtChanged,
    required this.onCollectionsChanged,
    required this.onImprintChanged,
    required this.copiesCtrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(label: context.l10n.sectionBasicInfo),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FormFieldWidget(
                controller: isbnCtrl,
                label: context.l10n.fieldIsbn,
                icon: Icons.barcode_reader,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormFieldWidget(
                controller: publishYearCtrl,
                label: context.l10n.fieldYear,
                icon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FormFieldWidget(
                controller: languageCtrl,
                label: context.l10n.fieldLanguage,
                icon: Icons.language_outlined,
              ),
            ),
            if (isTranslation) ...[
              const SizedBox(width: 12),
              Expanded(
                child: FormFieldWidget(
                  controller: originalLanguageCtrl,
                  label: context.l10n.fieldOriginalLanguage,
                  icon: Icons.language_outlined,
                ),
              ),
            ],
            const SizedBox(width: 12),
            SquareActionButton(
              icon: isTranslation ? Icons.translate : Icons.translate_outlined,
              isActive: isTranslation,
              onPressed: () => onIsTranslationChanged(!isTranslation),
              tooltip: context.l10n.fieldIsTranslation,
            ),
          ],
        ),
        if (isTranslation) ...[
          const SizedBox(height: 12),
          FormFieldWidget(
            controller: originalTitleCtrl,
            label: context.l10n.fieldOriginalTitle,
            icon: Icons.title_outlined,
          ),
          const SizedBox(height: 12),
          FormFieldWidget(
            controller: translatorCtrl,
            label: context.l10n.fieldTranslator,
            icon: Icons.translate_outlined,
          ),
        ],
        const SizedBox(height: 24),

        SectionHeader(label: context.l10n.fieldOwnershipStatus),
        const SizedBox(height: 12),
        OwnershipStatusSelector(
          selected: ownershipStatus,
          onChanged: onOwnershipStatusChanged,
        ),
        if (ownershipStatus == OwnershipStatus.borrowed || ownershipStatus == OwnershipStatus.gifted) ...[
          const SizedBox(height: 12),
          FormFieldWidget(
            controller: personNameCtrl,
            label: context.l10n.ownershipEventPerson,
            icon: Icons.person_outline,
          ),
        ],
        const SizedBox(height: 24),

        SectionHeader(label: context.l10n.fieldCollection),
        const SizedBox(height: 12),
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
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
          label: context.l10n.fieldCollection,
          icon: Icons.layers_outlined,
          multiSelection: true,
          useSquareButton: true,
        ),
        const SizedBox(height: 24),

        SectionHeader(label: context.l10n.sectionImprint),
        const SizedBox(height: 12),
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
          selected: const [],
          onChanged: (list) {
            onImprintChanged(list.firstOrNull);
          },
          type: TagType.imprint,
          label: context.l10n.imprintSearch,
          icon: Icons.business_outlined,
          multiSelection: false,
          useSquareButton: true,
        ),
        const SizedBox(height: 24),

        SectionHeader(label: context.l10n.bookDetailNotesTitle),
        const SizedBox(height: 12),
        FormFieldWidget(
          controller: notesCtrl,
          label: context.l10n.fieldNotes,
          icon: Icons.notes_outlined,
          maxLines: 6,
        ),
        const SizedBox(height: 24),

        SectionHeader(label: context.l10n.tabDetails),
        const SizedBox(height: 12),
        DatePickerField(
          label: context.l10n.bookDetailFieldStarted,
          value: startedAt,
          onChanged: onStartedAtChanged,
          icon: Icons.play_circle_outline,
        ),
        const SizedBox(height: 12),
        DatePickerField(
          label: context.l10n.bookDetailFieldFinished,
          value: finishedAt,
          onChanged: onFinishedAtChanged,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: FormFieldWidget(
                controller: copiesCtrl,
                label: context.l10n.fieldCopies,
                icon: Icons.copy,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
