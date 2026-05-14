import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../controllers/app_settings_controller.dart';
import '../../models/app_settings.dart';
import '../../l10n/l10n_extension.dart';

/// Main settings view for global application configuration.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsTitle),
        toolbarHeight: 40,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _AppearanceSection(),
          SizedBox(height: 24),
          _StorageSection(),
          SizedBox(height: 24),
          _SearchSection(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeCode = ref.watch(appSettingsProvider.select((s) => s.locale?.languageCode));
    final themeMode = ref.watch(appSettingsProvider.select((s) => s.themeMode));
    final seedColor = ref.watch(appSettingsProvider.select((s) => s.seedColor));
    final controller = ref.read(appSettingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(context.l10n.settingsSectionAppearance),
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
                    const DropdownMenuItem(
                      value: 'es',
                      child: Text('Español'),
                    ),
                    const DropdownMenuItem(
                      value: 'en',
                      child: Text('English'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.settingsThemeMode,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
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
                Text(context.l10n.settingsAccentColor,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  context.l10n.settingsAccentColorHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 16),
                _ColorPicker(
                  current: seedColor,
                  onSelected: controller.setSeedColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StorageSection extends ConsumerWidget {
  const _StorageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coversPath = ref.watch(appSettingsProvider.select((s) => s.coversPath));
    final dbPath = ref.watch(appSettingsProvider.select((s) => s.dbPath));
    final controller = ref.read(appSettingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(context.l10n.settingsSectionStorage),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _PathTile(
                icon: Icons.image_outlined,
                label: context.l10n.settingsCoversFolder,
                path: coversPath,
                onTap: () async {
                  final result = await FilePicker.getDirectoryPath();
                  if (result == null) return;
                  await _StorageMigrationHelper.migrateCovers(coversPath, result);
                  await controller.setCoversPath(result);
                },
              ),
              const Divider(height: 1, indent: 56),
              _PathTile(
                icon: Icons.storage_outlined,
                label: context.l10n.settingsDatabase,
                path: dbPath,
                onTap: () async {
                  final result = await FilePicker.getDirectoryPath();
                  if (result == null) return;
                  if (context.mounted) {
                    _StorageMigrationHelper.showDbMoveWarning(context, ref, result);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchSection extends ConsumerWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchServers = ref.watch(appSettingsProvider.select((s) => s.searchServers));
    final googleBooksApiKey = ref.watch(appSettingsProvider.select((s) => s.googleBooksApiKey));
    final controller = ref.read(appSettingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(context.l10n.settingsSectionSearch),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.settingsSearchServer,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  context.l10n.settingsSearchServerHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 12),
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: (oldIndex, newIndex) {
                    final list = List<BookSearchServer>.from(searchServers);
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = list.removeAt(oldIndex);
                    list.insert(newIndex, item);
                    controller.setSearchServers(list);
                  },
                  children: searchServers.map((server) => ListTile(
                    key: ValueKey(server),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.drag_handle),
                    title: Text(_SearchServerHelper.label(context, server)),
                    subtitle: Text(_SearchServerHelper.url(server),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colorScheme.outline)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _GoogleBooksApiKeyCard(
          currentKey: googleBooksApiKey,
          onSave: (key) => controller.setGoogleBooksApiKey(key),
        ),
      ],
    );
  }
}

class _SearchServerHelper {
  static String label(BuildContext context, BookSearchServer server) {
    switch (server) {
      case BookSearchServer.openLibrary:
        return 'Open Library';
      case BookSearchServer.googleBooks:
        return 'Google Books';
      case BookSearchServer.inventaire:
        return 'Inventaire.io';
    }
  }

  static String url(BookSearchServer server) {
    switch (server) {
      case BookSearchServer.openLibrary:
        return 'openlibrary.org';
      case BookSearchServer.googleBooks:
        return 'books.googleapis.com';
      case BookSearchServer.inventaire:
        return 'inventaire.io';
    }
  }
}

class _StorageMigrationHelper {
  /// Migrates cover images to a new directory.
  static Future<void> migrateCovers(String? oldPath, String newPath) async {
    final sourceDir = oldPath != null
        ? Directory(oldPath)
        : Directory(p.join(
        (await getApplicationDocumentsDirectory()).path, 'covers'));
    if (!await sourceDir.exists()) return;
    final destDir = Directory(newPath);
    if (!await destDir.exists()) await destDir.create(recursive: true);
    await for (final file in sourceDir.list()) {
      if (file is File) {
        final dest = File(p.join(newPath, p.basename(file.path)));
        await file.copy(dest.path);
        await file.delete();
      }
    }
  }

  static void showDbMoveWarning(
      BuildContext context, WidgetRef ref, String newPath) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.settingsDbMoveTitle),
        content: Text(context.l10n.settingsDbMoveContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await migrateDb(ref, newPath);
            },
            child: Text(context.l10n.settingsDbMoveConfirm),
          ),
        ],
      ),
    );
  }

  /// Moves the SQLite database file to a new location.
  static Future<void> migrateDb(WidgetRef ref, String newPath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final currentDb = File(p.join(appDir.path, 'openshelf_db.sqlite'));
    if (await currentDb.exists()) {
      final dest = File(p.join(newPath, 'openshelf_db.sqlite'));
      await currentDb.copy(dest.path);
      await currentDb.delete();
    }
    await ref.read(appSettingsProvider.notifier).setDbPath(newPath);
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _PathTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? path;
  final VoidCallback onTap;

  const _PathTile({
    required this.icon,
    required this.label,
    required this.path,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        path ?? context.l10n.settingsDefaultDir,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final Color current;
  final ValueChanged<Color> onSelected;

  const _ColorPicker({required this.current, required this.onSelected});

  static const _colors = [
    Color(0xFF6B4E3D), // Warm Brown
    Color(0xFF1565C0), // Blue
    Color(0xFF2E7D32), // Green
    Color(0xFF6A1B9A), // Purple
    Color(0xFFC62828), // Red
    Color(0xFF00695C), // Teal
    Color(0xFFE65100), // Orange
    Color(0xFF37474F), // Blue Grey
    Color(0xFFAD1457), // Pink
    Color(0xFF4527A0), // Indigo
    Color(0xFF558B2F), // Olive
    Color(0xFF4E342E), // Dark Brown
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _colors.map((color) {
        final isSelected = current.toARGB32() == color.toARGB32();
        return GestureDetector(
          onTap: () => onSelected(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 8,
                )
              ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _GoogleBooksApiKeyCard extends StatefulWidget {
  final String? currentKey;
  final ValueChanged<String?> onSave;

  const _GoogleBooksApiKeyCard({
    required this.currentKey,
    required this.onSave,
  });

  @override
  State<_GoogleBooksApiKeyCard> createState() => _GoogleBooksApiKeyCardState();
}

class _GoogleBooksApiKeyCardState extends State<_GoogleBooksApiKeyCard> {
  late final TextEditingController _ctrl;
  bool _obscure = true;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentKey ?? '');
    _ctrl.addListener(() {
      final changed = _ctrl.text.trim() != (widget.currentKey ?? '');
      if (changed != _dirty) setState(() => _dirty = changed);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final value = _ctrl.text.trim().isEmpty ? null : _ctrl.text.trim();
    widget.onSave(value);
    setState(() => _dirty = false);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.settingsApiKeySaved)),
    );
  }

  void _showInstructions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        builder: (context, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              context.l10n.settingsApiKeyInstructionsTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _Step(
              number: '1',
              text: context.l10n.settingsApiKeyStep1,
            ),
            _Step(
              number: '2',
              text: context.l10n.settingsApiKeyStep2,
            ),
            _Step(
              number: '3',
              text: context.l10n.settingsApiKeyStep3,
            ),
            _Step(
              number: '4',
              text: context.l10n.settingsApiKeyStep4,
            ),
            _Step(
              number: '5',
              text: context.l10n.settingsApiKeyStep5,
            ),
            _Step(
              number: '6',
              text: context.l10n.settingsApiKeyStep6,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.l10n.settingsApiKeyNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasKey = widget.currentKey != null && widget.currentKey!.isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(context.l10n.settingsApiKeyTitle,
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.help_outline, size: 16),
                  label: Text(context.l10n.settingsApiKeyHowTo),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: _showInstructions,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              hasKey
                  ? context.l10n.settingsApiKeyConfigured
                  : context.l10n.settingsApiKeyMissing,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: hasKey
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: context.l10n.settingsApiKeyHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                      tooltip: _obscure ? context.l10n.settingsApiKeyShow : context.l10n.settingsApiKeyHide,
                    ),
                    if (_ctrl.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _ctrl.clear();
                          widget.onSave(null);
                          if (mounted) setState(() => _dirty = false);
                        },
                        tooltip: context.l10n.settingsApiKeyClear,
                      ),
                  ],
                ),
              ),
            ),
            if (_dirty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(context.l10n.settingsApiKeySave),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 12, top: 1),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
