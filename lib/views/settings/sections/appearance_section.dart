import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/app_settings_controller.dart';
import '../../../controllers/app_icon_controller.dart';
import '../../../controllers/ui_tweaks_controller.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../widgets/app_color_picker.dart';
import '../../../widgets/bookshelf_icon.dart';
import '../widgets/section_header.dart';
import '../widgets/icon_apply_button.dart';

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeCode = ref.watch(appSettingsProvider.select((s) => s.locale?.languageCode));
    final themeMode = ref.watch(appSettingsProvider.select((s) => s.themeMode));
    final seedColor = ref.watch(appSettingsProvider.select((s) => s.seedColor));
    final dynamicIconEnabled = ref.watch(appSettingsProvider.select((s) => s.dynamicIconEnabled));
    final activeIconName = ref.watch(appSettingsProvider.select((s) => s.activeIconName));
    final gridColumns = ref.watch(appSettingsProvider.select((s) => s.libraryGridColumns));
    final autoNoCover = ref.watch(appSettingsProvider.select((s) => s.autoNoCoverShelf));
    final compressImages = ref.watch(appSettingsProvider.select((s) => s.compressImages));
    
    final controller = ref.read(appSettingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(context.l10n.settingsSectionAppearance),
        const SizedBox(height: 12),

        // Language Selection
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.settingsLanguage,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: localeCode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(context.l10n.settingsLanguageSystem),
                    ),
                    DropdownMenuItem(
                      value: 'es',
                      child: Text(context.l10n.settingsLanguageSpanish),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(context.l10n.settingsLanguageEnglish),
                    ),
                  ],
                  onChanged: (code) {
                    controller.setLocale(code != null ? Locale(code) : null);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Theme Mode
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(context.l10n.settingsThemeMode,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode_outlined),
                      label: Text(context.l10n.settingsThemeLight),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto_outlined),
                      label: Text(context.l10n.settingsThemeSystem),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_outlined),
                      label: Text(context.l10n.settingsThemeDark),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (s) =>
                      controller.setThemeMode(s.first),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Accent Color
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.settingsAccentColor,
                              style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.settingsAccentColorHint,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BookshelfIcon(size: 48, accentColor: seedColor),
                  ],
                ),
                const SizedBox(height: 16),
                AppColorPicker(
                  selectedColor: seedColor,
                  onColorSelected: (color) {
                    if (color != null) {
                      controller.setSeedColor(color);
                    }
                  },
                ),
                if (dynamicIconEnabled) ...[
                  const SizedBox(height: 16),
                  IconApplyButton(
                    currentColor: seedColor,
                    activeIconName: activeIconName,
                    onApply: () => ref.read(appIconProvider.notifier).updateIcon(seedColor),
                  ),
                ],
                const Divider(height: 32),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.star_outline),
                  title: Text(context.l10n.settingsDynamicIcon),
                  subtitle: Text(context.l10n.settingsDynamicIconSub),
                  value: dynamicIconEnabled,
                  onChanged: (val) => controller.setDynamicIconEnabled(val),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Grid Density & Maintenance
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.settingsLibraryColumns,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  context.l10n.settingsLibraryColumnsSub,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.grid_view, size: 20),
                    Expanded(
                      child: Slider(
                        value: gridColumns.toDouble().clamp(1, 3),
                        min: 1,
                        max: 3,
                        divisions: 2,
                        label: gridColumns.toString(),
                        onChanged: (val) => controller.setLibraryGridColumns(val.toInt()),
                      ),
                    ),
                    Text(
                      gridColumns.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.no_photography_outlined, size: 20),
                  title: Text(context.l10n.settingsAutoNoCoverTitle),
                  subtitle: Text(context.l10n.settingsAutoNoCoverSub),
                  value: autoNoCover,
                  onChanged: (val) {
                    controller.setAutoNoCoverShelf(val);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.photo_size_select_small, size: 20),
                  title: Text(context.l10n.settingsCompressImagesTitle),
                  subtitle: Text(context.l10n.settingsCompressImagesSub),
                  value: compressImages,
                  onChanged: (val) => controller.setCompressImages(val),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.high_quality_outlined, size: 20),
                  title: Text(context.l10n.settingsBatchCompressTitle),
                  subtitle: Text(context.l10n.settingsBatchCompressSub),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () async {
                    final count = await UiTweaksController.optimizeImages(ref);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.l10n.settingsBatchCompressSuccess(count))),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
