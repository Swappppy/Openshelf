import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../controllers/app_settings_controller.dart';
import '../../models/app_settings.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return settingsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (settings) => _SettingsBody(settings: settings),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  final AppSettings settings;
  const _SettingsBody({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(appSettingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        toolbarHeight: 40,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // --- Apariencia ---
          _SectionHeader('Apariencia'),
          const SizedBox(height: 12),

          // Modo de tema
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Modo de tema',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Claro'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('Sistema'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Oscuro'),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (s) =>
                        controller.setThemeMode(s.first),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Color de acento
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Color de acento',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Toca un color para aplicarlo',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ColorPicker(
                    current: settings.seedColor,
                    onSelected: controller.setSeedColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- Almacenamiento ---
          _SectionHeader('Almacenamiento'),
          const SizedBox(height: 12),

          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _PathTile(
                  icon: Icons.image_outlined,
                  label: 'Carpeta de portadas',
                  path: settings.coversPath,
                  onTap: () async {
                    final result =
                    await FilePicker.getDirectoryPath();
                    if (result == null) return;
                    await _migrateCovers(settings.coversPath, result);
                    await controller.setCoversPath(result);
                  },
                ),
                const Divider(height: 1, indent: 56),
                _PathTile(
                  icon: Icons.storage_outlined,
                  label: 'Base de datos',
                  path: settings.dbPath,
                  onTap: () async {
                    final result =
                    await FilePicker.getDirectoryPath();
                    if (result == null) return;
                    if (context.mounted) {
                      _showDbMoveWarning(context, ref, result);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- Búsqueda ---
          _SectionHeader('Búsqueda de libros'),
          const SizedBox(height: 12),

          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Servidor',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Se usará para buscar libros por ISBN o título',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RadioGroup<BookSearchServer>(
                    groupValue: settings.searchServer,
                    onChanged: (v) {
                      if (v != null) controller.setSearchServer(v);
                    },
                    child: Column(
                      children: BookSearchServer.values.map((server) => RadioListTile(
                        value: server,
                        title: Text(_serverLabel(server)),
                        subtitle: Text(_serverUrl(server),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: colorScheme.outline)),
                        contentPadding: EdgeInsets.zero,
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _serverLabel(BookSearchServer server) {
    switch (server) {
      case BookSearchServer.openLibrary:
        return 'Open Library';
      case BookSearchServer.googleBooks:
        return 'Google Books';
    }
  }

  String _serverUrl(BookSearchServer server) {
    switch (server) {
      case BookSearchServer.openLibrary:
        return 'openlibrary.org';
      case BookSearchServer.googleBooks:
        return 'books.googleapis.com';
    }
  }

  Future<void> _migrateCovers(String? oldPath, String newPath) async {
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

  void _showDbMoveWarning(
      BuildContext context, WidgetRef ref, String newPath) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mover base de datos'),
        content: const Text(
          'Mover la base de datos requiere reiniciar la app. '
              'Los datos se copiarán al nuevo directorio. ¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _migrateDb(ref, newPath);
            },
            child: const Text('Mover y reiniciar'),
          ),
        ],
      ),
    );
  }

  Future<void> _migrateDb(WidgetRef ref, String newPath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final currentDb =
    File(p.join(appDir.path, 'openshelf_db.sqlite'));
    if (await currentDb.exists()) {
      final dest =
      File(p.join(newPath, 'openshelf_db.sqlite'));
      await currentDb.copy(dest.path);
      await currentDb.delete();
    }
    await ref.read(appSettingsProvider.notifier).setDbPath(newPath);
  }
}

// -------------------------------------------------------
// Widgets auxiliares
// -------------------------------------------------------

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
        path ?? 'Directorio por defecto',
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
    Color(0xFF6B4E3D), // Marrón cálido — defecto
    Color(0xFF1565C0), // Azul
    Color(0xFF2E7D32), // Verde
    Color(0xFF6A1B9A), // Morado
    Color(0xFFC62828), // Rojo
    Color(0xFF00695C), // Teal
    Color(0xFFE65100), // Naranja
    Color(0xFF37474F), // Gris azulado
    Color(0xFFAD1457), // Rosa oscuro
    Color(0xFF4527A0), // Índigo
    Color(0xFF558B2F), // Verde oliva
    Color(0xFF4E342E), // Marrón oscuro
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