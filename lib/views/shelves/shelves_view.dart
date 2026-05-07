import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/database_provider.dart';
import '../../services/database.dart';

class ShelvesScreen extends ConsumerWidget {
  const ShelvesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estanterías'),
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Por estado',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          _StatusShelfTile(
            icon: Icons.menu_book,
            label: 'Todos los libros',
            color: colorScheme.primary,
            status: null,
          ),
          _StatusShelfTile(
            icon: Icons.auto_stories,
            label: 'Leyendo',
            color: Colors.blue,
            status: ReadingStatus.reading,
          ),
          _StatusShelfTile(
            icon: Icons.check_circle_outline,
            label: 'Leídos',
            color: Colors.green,
            status: ReadingStatus.read,
          ),
          _StatusShelfTile(
            icon: Icons.bookmark_outline,
            label: 'Por leer',
            color: Colors.orange,
            status: ReadingStatus.wantToRead,
          ),
          _StatusShelfTile(
            icon: Icons.close,
            label: 'Abandonados',
            color: Colors.red,
            status: ReadingStatus.abandoned,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mis estanterías',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {},
                tooltip: 'Nueva estantería',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.bookmarks_outlined,
                    size: 48,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No tienes estanterías personalizadas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestión',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          const _ManagementSection(),
        ],
      ),
    );
  }
}

// -------------------------------------------------------
// Sección de gestión con tres paneles expandibles
// -------------------------------------------------------
class _ManagementSection extends ConsumerStatefulWidget {
  const _ManagementSection();

  @override
  ConsumerState<_ManagementSection> createState() => _ManagementSectionState();
}

class _ManagementSectionState extends ConsumerState<_ManagementSection> {
  bool _tagsExpanded = false;
  bool _imprintsExpanded = false;
  bool _collectionsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ExpandablePanel(
          icon: Icons.label_outline,
          label: 'Categorías',
          color: Theme.of(context).colorScheme.primary,
          expanded: _tagsExpanded,
          onTap: () => setState(() => _tagsExpanded = !_tagsExpanded),
          child: const _TagsManager(),
        ),
        const SizedBox(height: 8),
        _ExpandablePanel(
          icon: Icons.business_outlined,
          label: 'Sellos editoriales',
          color: Colors.deepPurple,
          expanded: _imprintsExpanded,
          onTap: () => setState(() => _imprintsExpanded = !_imprintsExpanded),
          child: const _ImprintsManager(),
        ),
        const SizedBox(height: 8),
        _ExpandablePanel(
          icon: Icons.collections_bookmark_outlined,
          label: 'Colecciones',
          color: Colors.teal,
          expanded: _collectionsExpanded,
          onTap: () => setState(
                  () => _collectionsExpanded = !_collectionsExpanded),
          child: const _CollectionsManager(),
        ),
      ],
    );
  }
}

class _ExpandablePanel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;

  const _ExpandablePanel({
    required this.icon,
    required this.label,
    required this.color,
    required this.expanded,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            title: Text(label),
            trailing: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: onTap,
          ),
          if (expanded) ...[
            const Divider(height: 1),
            child,
          ],
        ],
      ),
    );
  }
}

// -------------------------------------------------------
// Gestor de Categorías (tags)
// -------------------------------------------------------
class _TagsManager extends ConsumerWidget {
  const _TagsManager();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(allTagsProvider);

    return tagsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error: $e'),
      ),
      data: (tagList) => Column(
        children: [
          ...tagList.map((tag) => _TagTile(tag: tag)),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Nueva categoría'),
            onTap: () => _showCreateTagDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showCreateTagDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    String? selectedColor;

    final colors = [
      ('E53935', Colors.red),
      ('D81B60', Colors.pink),
      ('8E24AA', Colors.purple),
      ('3949AB', Colors.indigo),
      ('1E88E5', Colors.blue),
      ('00ACC1', Colors.cyan),
      ('00897B', Colors.teal),
      ('43A047', Colors.green),
      ('C0CA33', Colors.lime),
      ('FB8C00', Colors.orange),
      ('6D4C41', const Color(0xFF6D4C41)),
      ('757575', Colors.grey),
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Nueva categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Color'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colors.map((c) {
                  final (hex, color) = c;
                  final isSelected = selectedColor == hex;
                  return GestureDetector(
                    onTap: () => setStateDialog(() => selectedColor = hex),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [BoxShadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: 6,
                        )]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                          color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final name = ctrl.text.trim();
                if (name.isEmpty) return;
                await ref.read(databaseProvider).insertTag(
                  TagsCompanion(
                    name: Value(name),
                    type: const Value('tag'),
                    color: Value(selectedColor),
                  ),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagTile extends ConsumerWidget {
  final Tag tag;
  const _TagTile({required this.tag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = tag.color != null
        ? Color(int.parse('0xFF${tag.color!}'))
        : Theme.of(context).colorScheme.outline;

    return ListTile(
      leading: CircleAvatar(
        radius: 12,
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(Icons.circle, size: 14, color: color),
      ),
      title: Text(tag.name),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmDelete(context, ref),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('¿Eliminar "${tag.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await ref.read(databaseProvider).deleteTag(tag.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------
// Gestor de Sellos editoriales
// -------------------------------------------------------
class _ImprintsManager extends ConsumerWidget {
  const _ImprintsManager();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imprintsAsync = ref.watch(allImprintsProvider);

    return imprintsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error: $e'),
      ),
      data: (imprintList) => Column(
        children: [
          ...imprintList.map((imp) => _ImprintTile(imprint: imp)),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Nuevo sello'),
            onTap: () => _showCreateImprintDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showCreateImprintDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo sello editorial'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre del sello',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              await ref.read(databaseProvider).insertTag(
                TagsCompanion(
                  name: Value(name),
                  type: const Value('imprint'),
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
}

class _ImprintTile extends ConsumerWidget {
  final Tag imprint;
  const _ImprintTile({required this.imprint});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: imprint.imagePath != null
            ? Image.asset(
          imprint.imagePath!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        )
            : Container(
          width: 40,
          height: 40,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.business_outlined,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
      title: Text(imprint.name),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmDelete(context, ref),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar sello'),
        content: Text('¿Eliminar "${imprint.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await ref.read(databaseProvider).deleteTag(imprint.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------
// Gestor de Colecciones
// -------------------------------------------------------
class _CollectionsManager extends ConsumerWidget {
  const _CollectionsManager();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(allCollectionsProvider);

    return collectionsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error: $e'),
      ),
      data: (collectionList) => Column(
        children: [
          ...collectionList.map((col) => _CollectionTile(collection: col)),
          if (collectionList.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Las colecciones se crean al guardar un libro',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CollectionTile extends ConsumerWidget {
  final Tag collection;
  const _CollectionTile({required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
        Colors.teal.withValues(alpha: 0.15),
        child: const Icon(
          Icons.collections_bookmark_outlined,
          color: Colors.teal,
        ),
      ),
      title: Text(collection.name),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _confirmDelete(context, ref),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar colección'),
        content: Text('¿Eliminar "${collection.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await ref.read(databaseProvider).deleteTag(collection.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------
// Tile de estado
// -------------------------------------------------------
class _StatusShelfTile extends ConsumerWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ReadingStatus? status;

  const _StatusShelfTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = status == null
        ? ref.watch(allBooksProvider).whenData((b) => b.length)
        : ref.watch(bookCountByStatusProvider(status!));

    final count = countAsync.value ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}