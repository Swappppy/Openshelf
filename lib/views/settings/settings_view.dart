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
          const SizedBox(height: 12),

          // --- Google Books API key ---
          _GoogleBooksApiKeyCard(
            currentKey: settings.googleBooksApiKey,
            onSave: (key) => controller.setGoogleBooksApiKey(key),
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
      const SnackBar(content: Text('Clave guardada')),
    );
  }

  void _showInstructions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        builder: (_, scroll) => ListView(
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
              'Cómo obtener una clave de Google Books',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _Step(
              number: '1',
              text:
              'Abre console.cloud.google.com e inicia sesión con tu cuenta de Google.',
            ),
            _Step(
              number: '2',
              text:
              'Crea un proyecto nuevo (el nombre es indiferente).',
            ),
            _Step(
              number: '3',
              text:
              'Ve a APIs y servicios → Biblioteca, busca "Books API" y actívala.',
            ),
            _Step(
              number: '4',
              text:
              'Ve a APIs y servicios → Credenciales → Crear credenciales → Clave de API.',
            ),
            _Step(
              number: '5',
              text:
              'Opcional pero recomendado: restringe la clave a la Books API únicamente.',
            ),
            _Step(
              number: '6',
              text:
              'Copia la clave resultante (empieza por "AIza...") y pégala en el campo de arriba.',
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
                'La clave es gratuita y permite hasta 1.000 búsquedas diarias. '
                    'No se comparte con nadie: se guarda solo en este dispositivo.',
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
                Text('Google Books API key',
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.help_outline, size: 16),
                  label: const Text('Cómo obtenerla'),
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
                  ? 'Clave configurada. Google Books está disponible.'
                  : 'Sin clave, Google Books usará Open Library como alternativa.',
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
                hintText: 'AIza...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                      tooltip: _obscure ? 'Mostrar' : 'Ocultar',
                    ),
                    if (_ctrl.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _ctrl.clear();
                          widget.onSave(null);
                          setState(() => _dirty = false);
                        },
                        tooltip: 'Borrar clave',
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
                  child: const Text('Guardar clave'),
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