import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/reading_log_controller.dart';
import 'widget_header.dart';
import '../../../l10n/l10n_extension.dart';

class StreakTile extends ConsumerWidget {
  const StreakTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final streakAsync = ref.watch(readingStreakProvider);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetHeader(title: context.l10n.statsStreakTitle, icon: Icons.local_fire_department),
          const Spacer(),
          Text(
            streakAsync.maybeWhen(data: (v) => v.toString(), orElse: () => '...'), 
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)
          ),
          Text(
            context.l10n.statsStreakSub,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, fontSize: 10)
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
