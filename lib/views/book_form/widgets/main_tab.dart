import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database.dart';
import '../../../controllers/database_provider.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../widgets/entity_field_selector.dart';
import '../../../widgets/tag_grid_selector.dart';

import '../advanced_pagination_view.dart';
import '../../../widgets/cover_placeholder.dart';
import '../../../widgets/book_cover.dart';
import 'form_components.dart';
import '../../../utils/media_progress.dart';

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
  final Map<int, int>? initialSegmentProgress;
  final OnSavePaginationConfig onPaginationConfigChanged;
  final MediaType mediaType;
  final ValueChanged<MediaType> onMediaTypeChanged;
  final TextEditingController narratorCtrl;
  final TextEditingController platformCtrl;
  final TextEditingController durationCtrl;
  final TextEditingController audioPositionCtrl;
  final TextEditingController audioPublisherCtrl;
  final TextEditingController audioIdentifierCtrl;

  /// Own sections/markers of a plain audiobook (edited in time mode).
  final PaginationConfig? audioPaginationConfig;
  final ValueChanged<PaginationConfig> onAudioPaginationChanged;

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
    this.initialSegmentProgress,
    required this.mediaType,
    required this.onMediaTypeChanged,
    required this.narratorCtrl,
    required this.platformCtrl,
    required this.durationCtrl,
    required this.audioPositionCtrl,
    required this.audioPublisherCtrl,
    required this.audioIdentifierCtrl,
    this.audioPaginationConfig,
    required this.onAudioPaginationChanged,
  });

  /// Page fields apply to reading and mixed books; audio fields to audio and
  /// mixed ones. Hidden fields keep their values.
  bool get _showPages => mediaType != MediaType.audio;
  bool get _showAudio => mediaType != MediaType.reading;
  bool get _isMixed => mediaType == MediaType.both;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookDao = ref.read(databaseProvider).bookDao;
    final audioDao = ref.read(databaseProvider).audiobookInfoDao;
    final l10n = context.l10n;

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
                          ? Container(
                        width: 100,
                        height: 150,
                        color: colorScheme.surfaceContainerHighest,
                        child: AdaptiveCoverImage(
                          image: FileImage(File(coverPath!)),
                          width: 100,
                          height: 150,
                          errorBuilder: (context, error, stackTrace) => const CoverPlaceholder(width: 100, height: 150, iconSize: 48),
                        ),
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
        DelimitedAutocompleteFormField(
          controller: authorCtrl,
          label: l10n.fieldAuthor,
          required: true,
          icon: Icons.person_outline,
          optionsBuilder: (q) => bookDao.getDistinctAuthors(q),
          showHelp: true,
          helpTitle: l10n.authorMultiHelpTitle,
          helpContent: l10n.authorMultiHelpContent,
        ),
        const SizedBox(height: 12),
        DelimitedAutocompleteFormField(
          controller: publisherCtrl,
          label: l10n.fieldPublisher,
          icon: Icons.business_outlined,
          optionsBuilder: (q) => bookDao.getDistinctPublishers(q),
        ),
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
        // Audio books track time instead of pages. The page fields stay in
        // the form state (hidden, not cleared) so switching back keeps them.
        if (_showPages) ...[
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
                        initialSegmentProgress: initialSegmentProgress,
                        totalPages: total,
                        onSave: onPaginationConfigChanged,
                        // Mixed books edit the audio positions of the same sections.
                        audioDuration: _isMixed ? parseDuration(durationCtrl.text) : null,
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
                  keyboardType: paginationConfig?.useVisualMode == true ? TextInputType.text : TextInputType.number,
                ),
              ),
            ],
          ),
        ],
        if (_showAudio) ...[
          if (_isMixed) const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SectionHeader(label: _isMixed ? context.l10n.audioProgressTitle : context.l10n.fieldReadingProgress),
              // Plain audiobooks have their own sections (mixed books share
              // the page ones, edited with the page pagination).
              if (!_isMixed)
                TextButton.icon(
                  onPressed: () {
                    final duration = parseDuration(durationCtrl.text) ?? 0;
                    if (duration <= 0) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdvancedPaginationView(
                          initialConfig: audioPaginationConfig ?? PaginationConfig(),
                          totalPages: duration,
                          timeMode: true,
                          onSave: (cfg, _) => onAudioPaginationChanged(cfg),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DurationFormField(
                  controller: durationCtrl,
                  label: context.l10n.fieldDuration,
                  icon: Icons.timer_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DurationFormField(
                  controller: audioPositionCtrl,
                  label: context.l10n.fieldAudioPosition,
                  icon: Icons.headphones_outlined,
                  extraValidator: (seconds) {
                    final total = parseDuration(durationCtrl.text);
                    return total != null && seconds > total ? context.l10n.audioPositionBeyondDuration : null;
                  },
                ),
              ),
            ],
          ),
        ],
        // --- Status Section ---
        const SizedBox(height: 24),
        SectionHeader(label: context.l10n.sectionReadingStatus),
        const SizedBox(height: 12),
        StatusSelector(selected: status, onChanged: onStatusChanged),
        const SizedBox(height: 24),

        // --- Format Section ---
        SectionHeader(label: context.l10n.sectionFormat),
        const SizedBox(height: 12),
        MediaTypeSelector(selected: mediaType, onChanged: onMediaTypeChanged),
        const SizedBox(height: 12),
        if (_showPages) FormatSelector(selected: format, onChanged: onFormatChanged),
        if (_showAudio) ...[
          if (_showPages) const SizedBox(height: 16),
          DelimitedAutocompleteFormField(
            controller: narratorCtrl,
            label: context.l10n.fieldNarrator,
            icon: Icons.record_voice_over_outlined,
            optionsBuilder: (q) => audioDao.getDistinctNarrators(q),
            showHelp: true,
            helpTitle: l10n.narratorMultiHelpTitle,
            helpContent: l10n.narratorMultiHelpContent,
          ),
          const SizedBox(height: 12),
          DelimitedAutocompleteFormField(
            controller: platformCtrl,
            label: context.l10n.fieldPlatform,
            icon: Icons.apps_outlined,
            optionsBuilder: (q) => audioDao.getDistinctPlatforms(q),
          ),
          // In mixed mode the main publisher/ISBN describe the reading
          // edition; these describe the audio one.
          if (_isMixed) ...[
            const SizedBox(height: 12),
            DelimitedAutocompleteFormField(
              controller: audioPublisherCtrl,
              label: context.l10n.fieldAudioPublisher,
              icon: Icons.business_outlined,
              optionsBuilder: (q) => bookDao.getDistinctPublishers(q),
            ),
            const SizedBox(height: 12),
            FormFieldWidget(
              controller: audioIdentifierCtrl,
              label: context.l10n.fieldAudioIdentifier,
              icon: Icons.qr_code_outlined,
            ),
          ],
        ],
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
