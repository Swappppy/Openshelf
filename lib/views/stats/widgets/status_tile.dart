import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/books_controller.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import 'widget_header.dart';
import 'stats_scale_helper.dart';

class StatusDistributionTile extends ConsumerWidget {
  const StatusDistributionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(allBooksProvider);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = StatsScaleHelper.getScale(constraints);
        
        return booksAsync.maybeWhen(
          data: (books) {
            final counts = <ReadingStatus, int>{};
            for (var b in books) {
              counts[b.status] = (counts[b.status] ?? 0) + 1;
            }
            
            return Padding(
              padding: EdgeInsets.all(12 * scale.clamp(1.0, 1.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetHeader(title: context.l10n.statsStatusTitle, icon: Icons.pie_chart_outline),
                  const Spacer(),
                  ...ReadingStatus.values.map((s) => Padding(
                    padding: EdgeInsets.only(bottom: 2 * scale),
                    child: Row(
                      children: [
                        Container(
                          width: 6 * scale, 
                          height: 6 * scale, 
                          decoration: BoxDecoration(color: _getStatusColor(s), shape: BoxShape.circle)
                        ),
                        SizedBox(width: 6 * scale),
                        Expanded(
                          child: Text(
                            _getStatusLabel(context, s), 
                            style: TextStyle(fontSize: 10 * scale), 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis
                          )
                        ),
                        Text(
                          '${counts[s] ?? 0}', 
                          style: TextStyle(fontSize: 10 * scale, fontWeight: FontWeight.bold)
                        ),
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
