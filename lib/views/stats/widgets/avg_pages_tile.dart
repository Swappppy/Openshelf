import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/books_controller.dart';
import 'widget_header.dart';
import '../../../l10n/l10n_extension.dart';

class AvgPagesTile extends ConsumerWidget {
  const AvgPagesTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final booksAsync = ref.watch(allBooksProvider);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetHeader(title: context.l10n.statsAvgPagesTitle, icon: Icons.analytics),
          const Spacer(),
          booksAsync.maybeWhen(
            data: (books) {
              final booksWithPages = books.where((b) => (b.totalPages ?? 0) > 0).toList();
              if (booksWithPages.isEmpty) return const Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
              
              final total = booksWithPages.fold<int>(0, (sum, b) => sum + b.totalPages!);
              final avg = (total / booksWithPages.length).round();
              
              return Text(
                avg.toString(), 
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)
              );
            },
            orElse: () => const Text('...', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Text(
            context.l10n.statsAvgPagesSub, 
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, fontSize: 10)
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
