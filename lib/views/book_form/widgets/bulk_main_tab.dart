import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database.dart';
import '../../../services/daos/book_dao.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../widgets/entity_field_selector.dart';
import '../../../widgets/cover_placeholder.dart';
import 'form_components.dart';
import 'padlock_field_wrapper.dart';
import 'bulk_form_components.dart';

class BulkMainTab extends ConsumerWidget {
  final bool isCoverLocked;
  final ValueChanged<bool> onCoverLockChanged;
  final String? coverPath;
  final VoidCallback onPickCover;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickCoverFromUrl;
  final VoidCallback onSearchCovers;

  final bool isTitleLocked;
  final ValueChanged<bool> onTitleLockChanged;
  final TextEditingController titleCtrl;

  final bool isSubtitleLocked;
  final ValueChanged<bool> onSubtitleLockChanged;
  final TextEditingController subtitleCtrl;

  final bool isAuthorLocked;
  final ValueChanged<bool> onAuthorLockChanged;
  final TextEditingController authorCtrl;

  final bool isPublisherLocked;
  final ValueChanged<bool> onPublisherLockChanged;
  final TextEditingController publisherCtrl;

  final bool isDescriptionLocked;
  final ValueChanged<bool> onDescriptionLockChanged;
  final TextEditingController descriptionCtrl;

  final bool isTagsLocked;
  final ValueChanged<bool> onTagsLockChanged;
  final List<Tag> selectedTags;
  final ValueChanged<List<Tag>> onTagsChanged;

  final bool isStatusLocked;
  final ValueChanged<bool> onStatusLockChanged;
  final ReadingStatus status;
  final ValueChanged<ReadingStatus> onStatusChanged;

  final bool isFormatLocked;
  final ValueChanged<bool> onFormatLockChanged;
  final BookFormat? format;
  final ValueChanged<BookFormat?> onFormatChanged;

  final BookDao bookDao;

  const BulkMainTab({
    super.key,
    required this.isCoverLocked,
    required this.onCoverLockChanged,
    this.coverPath,
    required this.onPickCover,
    required this.onTakePhoto,
    required this.onPickCoverFromUrl,
    required this.onSearchCovers,
    required this.isTitleLocked,
    required this.onTitleLockChanged,
    required this.titleCtrl,
    required this.isSubtitleLocked,
    required this.onSubtitleLockChanged,
    required this.subtitleCtrl,
    required this.isAuthorLocked,
    required this.onAuthorLockChanged,
    required this.authorCtrl,
    required this.isPublisherLocked,
    required this.onPublisherLockChanged,
    required this.publisherCtrl,
    required this.isDescriptionLocked,
    required this.onDescriptionLockChanged,
    required this.descriptionCtrl,
    required this.isTagsLocked,
    required this.onTagsLockChanged,
    required this.selectedTags,
    required this.onTagsChanged,
    required this.isStatusLocked,
    required this.onStatusLockChanged,
    required this.status,
    required this.onStatusChanged,
    required this.isFormatLocked,
    required this.onFormatLockChanged,
    required this.format,
    required this.onFormatChanged,
    required this.bookDao,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Cover Picker with Padlock
        PadlockFieldWrapper(
          centerChild: true,
          isLocked: isCoverLocked,
          onLockChanged: onCoverLockChanged,
          child: Center(
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
                      onPressed: onTakePhoto,
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      icon: const Icon(Icons.link, size: 16),
                      label: Text(l10n.url),
                      onPressed: onPickCoverFromUrl,
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      icon: const Icon(Icons.image_search, size: 16),
                      label: Text(l10n.coverSearch),
                      onPressed: onSearchCovers,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Basic Info
        BulkSectionHeader(label: l10n.sectionBasicInfo),
        const SizedBox(height: 12),

        PadlockFieldWrapper(
          isLocked: isTitleLocked,
          onLockChanged: onTitleLockChanged,
          child: FormFieldWidget(
            controller: titleCtrl,
            label: l10n.fieldTitle,
            icon: Icons.title,
          ),
        ),

        PadlockFieldWrapper(
          isLocked: isSubtitleLocked,
          onLockChanged: onSubtitleLockChanged,
          child: FormFieldWidget(
            controller: subtitleCtrl,
            label: l10n.fieldSubtitle,
            icon: Icons.subtitles_outlined,
          ),
        ),

        PadlockFieldWrapper(
          isLocked: isAuthorLocked,
          onLockChanged: onAuthorLockChanged,
          child: DelimitedAutocompleteFormField(
            controller: authorCtrl,
            label: l10n.fieldAuthor,
            icon: Icons.person_outline,
            optionsBuilder: (q) => bookDao.getDistinctAuthors(q),
            showHelp: true,
            helpTitle: l10n.authorMultiHelpTitle,
            helpContent: l10n.authorMultiHelpContent,
          ),
        ),

        PadlockFieldWrapper(
          isLocked: isPublisherLocked,
          onLockChanged: onPublisherLockChanged,
          child: DelimitedAutocompleteFormField(
            controller: publisherCtrl,
            label: l10n.fieldPublisher,
            icon: Icons.business_outlined,
            optionsBuilder: (q) => bookDao.getDistinctPublishers(q),
          ),
        ),

        PadlockFieldWrapper(
          isLocked: isDescriptionLocked,
          onLockChanged: onDescriptionLockChanged,
          child: FormFieldWidget(
            controller: descriptionCtrl,
            label: l10n.fieldDescription,
            icon: Icons.description_outlined,
            maxLines: 5,
          ),
        ),
        const SizedBox(height: 24),

        // Categories / Tags
        PadlockFieldWrapper(
          isLocked: isTagsLocked,
          onLockChanged: onTagsLockChanged,
          child: EntityFieldSelector(
            selected: selectedTags,
            onChanged: onTagsChanged,
            type: TagType.tag,
            label: l10n.tagSearchOrCreate,
            icon: Icons.label_outline,
          ),
        ),
        const SizedBox(height: 24),

        // Unalterable Property Notice: Pages
        const UnalterablePropertyCard(
          title: "Progreso de lectura",
          icon: Icons.menu_book_outlined,
          message: "Las páginas y el progreso de lectura son específicos de cada libro y no se alteran en masa.",
        ),
        const SizedBox(height: 24),

        // Status Section
        BulkSectionHeader(label: l10n.sectionReadingStatus),
        const SizedBox(height: 12),
        PadlockFieldWrapper(
          isLocked: isStatusLocked,
          onLockChanged: onStatusLockChanged,
          child: StatusSelector(
            selected: status,
            onChanged: onStatusChanged,
          ),
        ),
        const SizedBox(height: 24),

        // Format Section
        BulkSectionHeader(label: l10n.sectionFormat),
        const SizedBox(height: 12),
        PadlockFieldWrapper(
          isLocked: isFormatLocked,
          onLockChanged: onFormatLockChanged,
          child: FormatSelector(
            selected: format,
            onChanged: onFormatChanged,
          ),
        ),
        const SizedBox(height: 24),

        // Unalterable Property Notice: Rating
        const UnalterablePropertyCard(
          title: "Puntuación",
          icon: Icons.star_outline,
          message: "La puntuación es individual para cada libro y no se altera en masa.",
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
