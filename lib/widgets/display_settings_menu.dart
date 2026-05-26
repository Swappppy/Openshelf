import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/display_preferences_controller.dart';
import '../l10n/l10n_extension.dart';
import '../views/settings/settings_view.dart';

class DisplaySettingsMenu extends ConsumerWidget {
  const DisplaySettingsMenu({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const DisplaySettingsMenu(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = ref.watch(displayPreferencesProvider);
    final controller = ref.read(displayPreferencesProvider.notifier);

    final fieldLabels = {
      'info': 'Info',
      'rating': l10n.fieldRating,
      'tags': l10n.fieldTags,
      'spacer': '—',
    };

    final fieldToggles = {
      'info': (bool v) {},
      'rating': (bool v) => controller.toggleShowRating(),
      'tags': (bool v) => controller.toggleShowTags(),
      'spacer': (bool v) => controller.toggleShowSpacer(),
    };

    final fieldValues = {
      'info': true,
      'rating': p.showRating,
      'tags': p.showTags,
      'spacer': p.showSpacer,
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReorderableListView(
                    onReorderItem: (oldIndex, newIndex) {
                      HapticFeedback.lightImpact();
                      controller.reorderFields(oldIndex, newIndex);
                    },
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: p.fieldOrder.map((field) {
                      return ListTile(
                        key: ValueKey(field),
                        leading: ReorderableDragStartListener(
                          index: p.fieldOrder.indexOf(field),
                          child: const Icon(Icons.drag_handle),
                        ),
                        title: Text(fieldLabels[field] ?? field),
                        trailing: Switch(
                          value: fieldValues[field] ?? false,
                          onChanged: fieldToggles[field],
                        ),
                      );
                    }).toList(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.drag_handle, color: Colors.transparent),
                    title: Text(l10n.fieldReadingProgress),
                    trailing: Switch(
                      value: p.showProgress,
                      onChanged: (_) => controller.toggleShowProgress(),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.drag_handle, color: Colors.transparent),
                    title: Text(l10n.fieldStatusChip),
                    trailing: Switch(
                      value: p.showStatusChip,
                      onChanged: (_) => controller.toggleShowStatusChip(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
