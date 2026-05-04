import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/books_controller.dart';
import '../../services/database.dart';

class ShelvesScreen extends ConsumerWidget {
  const ShelvesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estanterías'),
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
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Icon(
                    Icons.bookmarks_outlined,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes estanterías personalizadas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pulsa + para crear una',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Nueva estantería'),
      ),
    );
  }
}

class _StatusShelfTile extends ConsumerWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ReadingStatus? status; // null = todos

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