import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/books_controller.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import 'widget_header.dart';

class StatusDistributionTile extends ConsumerWidget {
  const StatusDistributionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(allBooksProvider);
    return booksAsync.maybeWhen(
      data: (books) {
        final counts = <ReadingStatus, int>{};
        for (var b in books) {
          counts[b.status] = (counts[b.status] ?? 0) + 1;
        }
        
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WidgetHeader(title: 'ESTADOS', icon: Icons.pie_chart_outline),
              const Spacer(),
              ...ReadingStatus.values.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: _getStatusColor(s), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(_getStatusLabel(context, s), style: const TextStyle(fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text('${counts[s] ?? 0}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
              const Spacer(),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Color _getStatusColor(ReadingStatus s) {
    switch (s) {
      case ReadingStatus.wantToRead: return Colors.orange;
      case ReadingStatus.reading: return Colors.blue;
      case ReadingStatus.read: return Colors.green;
      case ReadingStatus.abandoned: return Colors.red;
      case ReadingStatus.paused: return Colors.purple;
    }
  }

  String _getStatusLabel(BuildContext context, ReadingStatus s) {
    switch (s) {
      case ReadingStatus.wantToRead: return context.l10n.statusWantToRead;
      case ReadingStatus.reading: return context.l10n.statusReading;
      case ReadingStatus.read: return context.l10n.statusRead;
      case ReadingStatus.abandoned: return context.l10n.statusAbandoned;
      case ReadingStatus.paused: return context.l10n.statusPaused;
    }
  }
}
