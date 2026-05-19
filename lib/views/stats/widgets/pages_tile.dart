import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/reading_log_controller.dart';
import 'widget_header.dart';

class PagesTile extends ConsumerWidget {
  const PagesTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pagesAsync = ref.watch(totalPagesReadProvider);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WidgetHeader(title: 'PÁGINAS', icon: Icons.menu_book),
          const Spacer(),
          Text(
            pagesAsync.maybeWhen(data: (v) => _formatNumber(v), orElse: () => '0'), 
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)
          ),
          Text(
            'páginas leídas', 
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, fontSize: 10)
          ),
          const Spacer(),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}
