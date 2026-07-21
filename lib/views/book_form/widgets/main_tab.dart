import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../widgets/entity_field_selector.dart';
import '../../../widgets/tag_grid_selector.dart';
import '../../../models/tag_type.dart';
import '../advanced_pagination_view.dart';
import 'form_components.dart';

class MainTab extends ConsumerWidget {
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
  final ValueChanged<List<Tag>> onTagsChanged;
  final VoidCallback onPickCoverFromUrl;
  final VoidCallback onSearchCovers;
  final PaginationConfig? paginationConfig;
  final ValueChanged<PaginationConfig> onPaginationConfigChanged;

  const MainTab({
    super.key,
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
    required this.onTagsChanged,
    required this.onPickCoverFromUrl,
    required this.onSearchCovers,
    required this.onPaginationConfigChanged,
    this.paginationConfig,
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
                        errorBuilder: (context, error, stackTrace) => const CoverPlaceholder(width: 100, height: 150, iconSize: 48),
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
        SectionHeader(label: context.l10n.sectionBasicInfo),
        const SizedBox(height: 12),
        FormFieldWidget(
            controller: titleCtrl, label: context.l10n.fieldTitle, required: true,
            icon: Icons.title),
        const SizedBox(height: 12),
        FormFieldWidget(
            controller: subtitleCtrl, label: context.l10n.fieldSubtitle,
            icon: Icons.subtitles_outlined),
        const SizedBox(height: 12),
        FormFieldWidget(
            controller: authorCtrl, label: context.l10n.fieldAuthor, required: true,
            icon: Icons.person_outline),
        const SizedBox(height: 12),
        FormFieldWidget(
            controller: publisherCtrl,
            label: context.l10n.fieldPublisher,
            icon: Icons.business_outlined),
        const SizedBox(height: 12),
        FormFieldWidget(
          controller: descriptionCtrl,
          label: context.l10n.fieldDescription,
          icon: Icons.description_outlined,
          maxLines: 5,
        ),
        const SizedBox(height: 24),


        EntityFieldSelector(
          selected: selectedTags,
          onChanged: onTagsChanged,
          type: TagType.tag,
          label: context.l10n.tagSearchOrCreate,
          icon: Icons.label_outline,
          trailing: TagGridSelector(
            selected: selectedTags,
            type: TagType.tag,
            onChanged: onTagsChanged,
          ),
        ),

        const SizedBox(height: 24),

        // --- Reading Progress Section ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionHeader(label: context.l10n.fieldReadingProgress),
            TextButton.icon(
              onPressed: () {
                final total = int.tryParse(totalPagesCtrl.text) ?? 0;
                if (total <= 0) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdvancedPaginationView(
                      initialConfig: paginationConfig ?? PaginationConfig(),
                      totalPages: total,
                      onSave: onPaginationConfigChanged,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              icon: const Icon(Icons.settings_suggest_outlined, size: 16),
              label: Text(context.l10n.paginationAdvancedButton, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FormFieldWidget(
                controller: totalPagesCtrl,
                label: context.l10n.fieldTotalPages,
                icon: Icons.menu_book_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormFieldWidget(
                controller: currentPageCtrl,
                label: context.l10n.fieldCurrentPage,
                icon: Icons.bookmark_outline,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        // --- Status Section ---
        const SizedBox(height: 24),
        SectionHeader(label: context.l10n.sectionReadingStatus),
        const SizedBox(height: 12),
        StatusSelector(selected: status, onChanged: onStatusChanged),
        const SizedBox(height: 24),

        // --- Format Section ---
        SectionHeader(label: context.l10n.sectionFormat),
        const SizedBox(height: 12),
        FormatSelector(selected: format, onChanged: onFormatChanged),
        const SizedBox(height: 24),

        // --- Rating Section ---
        SectionHeader(label: context.l10n.sectionRating),
        const SizedBox(height: 12),
        RatingSelector(rating: rating, onChanged: onRatingChanged),
        const SizedBox(height: 32),
      ],
    );
  }
}
