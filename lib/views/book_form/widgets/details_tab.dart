import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../widgets/entity_field_selector.dart';
import '../../../models/tag_type.dart';
import 'form_components.dart';

class DetailsTab extends ConsumerWidget {
  final TextEditingController notesCtrl;
  final TextEditingController isbnCtrl;
  final TextEditingController languageCtrl;
  final TextEditingController publishYearCtrl;
  final TextEditingController translatorCtrl;
  final List<Tag> selectedCollections;
  final Tag? selectedImprint;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final ValueChanged<DateTime?> onStartedAtChanged;
  final ValueChanged<DateTime?> onFinishedAtChanged;
  final ValueChanged<List<Tag>> onCollectionsChanged;
  final ValueChanged<Tag?> onImprintChanged;
  final TextEditingController copiesCtrl;

  const DetailsTab({
    super.key,
    required this.notesCtrl,
    required this.isbnCtrl,
    required this.languageCtrl,
    required this.publishYearCtrl,
    required this.translatorCtrl,
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(label: context.l10n.sectionBasicInfo),
        const SizedBox(height: 12),
        FormFieldWidget(
          controller: publishYearCtrl,
          label: context.l10n.fieldYear,
          icon: Icons.calendar_today_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        FormFieldWidget(
            controller: isbnCtrl,
            label: context.l10n.fieldIsbn,
            icon: Icons.barcode_reader,
            keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        FormFieldWidget(
            controller: languageCtrl,
            label: context.l10n.fieldLanguage,
            icon: Icons.language_outlined),
        const SizedBox(height: 24),

        SectionHeader(label: context.l10n.fieldCollection),
        const SizedBox(height: 12),
        EntityFieldSelector(
          selected: selectedCollections,
          onChanged: onCollectionsChanged,
          type: TagType.collection,
          label: context.l10n.fieldCollection,
          icon: Icons.collections_bookmark_outlined,
          multiSelection: false,
        ),
        const SizedBox(height: 24),

        SectionHeader(label: context.l10n.sectionImprint),
        const SizedBox(height: 12),
        EntityFieldSelector(
          selected: selectedImprint != null ? [selectedImprint!] : [],
          onChanged: (list) {
            onImprintChanged(list.firstOrNull);
          },
          type: TagType.imprint,
          label: context.l10n.imprintSearch,
          icon: Icons.business_outlined,
          multiSelection: false,
        ),
        const SizedBox(height: 24),

        SectionHeader(label: context.l10n.fieldTranslator),
        const SizedBox(height: 12),
        FormFieldWidget(
          controller: translatorCtrl,
          label: context.l10n.fieldTranslator,
          icon: Icons.translate_outlined,
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
