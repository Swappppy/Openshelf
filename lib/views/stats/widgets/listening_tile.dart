import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/reading_log_controller.dart';
import '../../../utils/media_progress.dart';
import 'widget_header.dart';
import 'stats_scale_helper.dart';
import '../../../l10n/l10n_extension.dart';

/// Total time listened, the audio counterpart of [PagesTile].
class ListeningTile extends ConsumerWidget {
  const ListeningTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final seconds = ref.watch(totalListeningSecondsProvider).value ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = StatsScaleHelper.getScale(constraints);

        return Padding(
          padding: EdgeInsets.all(12 * scale.clamp(1.0, 1.5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetHeader(title: context.l10n.statsListeningTitle, icon: Icons.headphones),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    text: formatDuration(seconds),
                    children: [
                      TextSpan(
                        text: ' $durationUnit',
                        style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 28 * scale,
                  ),
                ),
              ),
              Text(
                context.l10n.statsListeningSub,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontSize: 10 * scale,
                ),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
