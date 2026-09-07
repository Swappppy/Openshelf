import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/app_settings_controller.dart';
import '../../../controllers/database_provider.dart';
import '../../../controllers/books_controller.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../widgets/tag_grid_selector.dart';
import '../widgets/section_header.dart';

class AutomationSection extends ConsumerWidget {
  const AutomationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final controller = ref.read(appSettingsProvider.notifier);
    final allTagsAsync = ref.watch(allTagsProvider);

    final excludedTags = allTagsAsync.maybeWhen(
      data: (tags) => tags.where((t) => settings.excludedCategoriesFromPruning.contains(t.id)).toList(),
      orElse: () => <Tag>[],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(context.l10n.settingsAutomationTitle),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.cleaning_services_outlined),
                title: Text(context.l10n.settingsAutoPruneTagsTitle),
                subtitle: Text(context.l10n.settingsAutoPruneTagsSub),
                value: settings.pruneOrphanCategories,
                onChanged: (val) => _handleTogglePruning(context, ref, val),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: Text(context.l10n.settingsExcludedPruneTagsTitle),
                subtitle: Text(context.l10n.settingsExcludedPruneTagsSub(settings.excludedCategoriesFromPruning.length)),
                trailing: TagGridSelector(
                  selected: excludedTags,
                  type: TagType.tag,
                  onChanged: (tags) {
                    controller.setExcludedCategoriesFromPruning(tags.map((t) => t.id).toList());
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleTogglePruning(BuildContext context, WidgetRef ref, bool value) async {
    final controller = ref.read(appSettingsProvider.notifier);
    final db = ref.read(databaseProvider);
    final settings = ref.read(appSettingsProvider);

    if (value) {
      // If turning ON, check for orphans
      final orphans = await db.tagDao.getOrphanTags(
        excludedIds: settings.excludedCategoriesFromPruning,
      );

      if (orphans.isNotEmpty && context.mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.settingsPruneWarningTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.settingsPruneWarningContent),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: orphans.map((t) => Chip(
                        label: Text(t.name),
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.l10n.done),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await db.tagDao.pruneOrphanTags(
            enabled: true,
            excludedIds: settings.excludedCategoriesFromPruning,
          );
          controller.setPruneOrphanCategories(true);
        }
      } else {
        controller.setPruneOrphanCategories(true);
      }
    } else {
      controller.setPruneOrphanCategories(false);
    }
  }
}
