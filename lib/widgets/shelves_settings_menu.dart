import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/display_preferences_controller.dart';
import '../l10n/l10n_extension.dart';
import '../views/settings/settings_view.dart';

class ShelvesSettingsMenu extends ConsumerWidget {
  const ShelvesSettingsMenu({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ShelvesSettingsMenu(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = ref.watch(displayPreferencesProvider);
    final controller = ref.read(displayPreferencesProvider.notifier);

    final sectionLabels = {
      'shelves': l10n.shelvesSectionMine,
      'categories': l10n.managementCategories,
      'imprints': l10n.managementImprints,
      'collections': l10n.managementCollections,
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16, 16, 16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.displaySettings,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 18),
                onPressed: () {
                  Navigator.pop(context);
                  SettingsView.show(context);
                },
                tooltip: l10n.settingsButton,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.displaySettingsDragHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ReorderableListView(
              onReorderStart: (index) => HapticFeedback.mediumImpact(),
              onReorderItem: (oldIndex, newIndex) {
                controller.reorderShelvesSections(oldIndex, newIndex);
              },
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: p.shelvesSectionOrder.map((section) {
                return ListTile(
                  key: ValueKey(section),
                  leading: const Icon(Icons.drag_handle),
                  title: Text(sectionLabels[section] ?? section),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
