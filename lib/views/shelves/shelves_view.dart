import 'package:flutter/material.dart';

class ShelvesScreen extends StatelessWidget {
  const ShelvesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          // --- Estanterías por defecto ---
          Text(
            'Por estado',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          _DefaultShelfTile(
            icon: Icons.menu_book,
            label: 'Todos los libros',
            color: colorScheme.primary,
            count: 0,
          ),
          _DefaultShelfTile(
            icon: Icons.auto_stories,
            label: 'Leyendo',
            color: Colors.blue,
            count: 0,
          ),
          _DefaultShelfTile(
            icon: Icons.check_circle_outline,
            label: 'Leídos',
            color: Colors.green,
            count: 0,
          ),
          _DefaultShelfTile(
            icon: Icons.bookmark_outline,
            label: 'Por leer',
            color: Colors.orange,
            count: 0,
          ),
          _DefaultShelfTile(
            icon: Icons.close,
            label: 'Abandonados',
            color: Colors.red,
            count: 0,
          ),

          const SizedBox(height: 24),

          // --- Estanterías personalizadas ---
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

          // Placeholder vacío
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

class _DefaultShelfTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int count;

  const _DefaultShelfTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
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