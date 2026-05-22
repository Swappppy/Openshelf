import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/books_controller.dart';
import '../../../services/database.dart';
import 'widget_header.dart';
import '../../../l10n/l10n_extension.dart';

class AvgCompletionTimeTile extends ConsumerWidget {
  const AvgCompletionTimeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(allBooksProvider);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetHeader(
            title: context.l10n.statsOptAvgCompletionTitle,
            icon: Icons.timer_outlined,
          ),
          const Spacer(),
          booksAsync.maybeWhen(
            data: (books) {
              final readBooks = books.where((b) => 
                b.status == ReadingStatus.read && 
                b.startedAt != null && 
                b.finishedAt != null
              ).toList();

              if (readBooks.isEmpty) {
                return Center(
                  child: Text(
                    context.l10n.statsAddedNoData,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              }

              final totalDays = readBooks.fold<int>(0, (sum, b) {
                return sum + b.finishedAt!.difference(b.startedAt!).inDays;
              });
              
              final avg = (totalDays / readBooks.length).round();

              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      avg.toString(),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      context.l10n.statsAvgCompletionValue(avg.toString()).split(' ').last.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            },
            orElse: () => const Center(child: CircularProgressIndicator()),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
