import 'dart:convert';
import 'dart:math' show max, min;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';
import '../../../controllers/reading_log_controller.dart';
import '../../../controllers/stats_controller.dart';
import '../../../models/stats_widget.dart';
import '../../../services/database.dart';
import '../../../utils/media_progress.dart';
import '../../../l10n/l10n_extension.dart';
import 'widget_header.dart';

/// What the heatmap measures. Pages and seconds don't share a unit, so
/// [all] colours each day by the larger of its two relative intensities
/// (same max() rule as the combined card progress).
enum _HeatmapMetric { all, pages, listening }

/// GitHub-style calendar of reading activity (issue #56): one cell per day,
/// one column per week, newest week on the right. Purely descriptive.
class HeatmapTile extends ConsumerWidget {
  final StatWidgetConfig config;
  final StatWidgetSize size;
  const HeatmapTile({super.key, required this.config, required this.size});

  static const double _gap = 2;
  static const double _maxCell = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveConfig = ref.watch(statWidgetConfigProvider(config.id)).value ?? config;
    final metric = _metricOf(liveConfig.config);
    final daily = ref.watch(dailyActivityProvider).value ?? const {};
    final compact = size == StatWidgetSize.s1x1;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: WidgetHeader(
                  title: context.l10n.statsHeatmapTitle,
                  icon: metric == _HeatmapMetric.listening ? Icons.headphones : Icons.grid_on,
                ),
              ),
              _metricMenu(context, ref, liveConfig, metric),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => _grid(context, constraints, daily, metric, compact),
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(
    BuildContext context,
    BoxConstraints constraints,
    Map<DateTime, ({int pages, int seconds})> daily,
    _HeatmapMetric metric,
    bool compact,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final monthLabelHeight = compact ? 0.0 : 12.0;
    final footerHeight = compact ? 0.0 : 14.0;

    final usable = constraints.maxHeight - monthLabelHeight - footerHeight;
    final cell = min((usable - _gap * 6) / 7, _maxCell);
    if (cell <= 2) return const SizedBox.shrink();
    final columns = max(1, ((constraints.maxWidth + _gap) / (cell + _gap)).floor());

    // Weeks start on the locale's first weekday; the last column is this week.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstWeekday = MaterialLocalizations.of(context).firstDayOfWeekIndex; // 0 = Sunday
    final offset = (today.weekday % 7 - firstWeekday + 7) % 7;
    final lastWeekStart = DateTime(today.year, today.month, today.day - offset);
    DateTime dayAt(int col, int row) =>
        DateTime(lastWeekStart.year, lastWeekStart.month, lastWeekStart.day - (columns - 1 - col) * 7 + row);

    // Intensities are relative to the busiest visible day of each medium.
    var maxPages = 0, maxSeconds = 0, activeDays = 0;
    for (var c = 0; c < columns; c++) {
      for (var r = 0; r < 7; r++) {
        final d = daily[dayAt(c, r)];
        if (d == null) continue;
        maxPages = max(maxPages, d.pages);
        maxSeconds = max(maxSeconds, d.seconds);
        if (_counts(d, metric)) activeDays++;
      }
    }
    double intensity(({int pages, int seconds})? d) {
      if (d == null) return 0;
      final p = maxPages > 0 ? d.pages / maxPages : 0.0;
      final s = maxSeconds > 0 ? d.seconds / maxSeconds : 0.0;
      return switch (metric) {
        _HeatmapMetric.pages => p,
        _HeatmapMetric.listening => s,
        _HeatmapMetric.all => max(p, s),
      };
    }

    Color colorFor(double v) {
      if (v <= 0) return colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
      final level = (v * 4).ceil().clamp(1, 4);
      return colorScheme.primary.withValues(alpha: const [0.25, 0.45, 0.7, 1.0][level - 1]);
    }

    String tooltip(DateTime day, ({int pages, int seconds})? d) {
      final parts = <String>[
        if (d != null && d.pages > 0 && metric != _HeatmapMetric.listening)
          '${d.pages} ${context.l10n.statsGoalUnitPages}',
        if (d != null && d.seconds > 0 && metric != _HeatmapMetric.pages)
          '${formatDuration(d.seconds)} $durationUnit',
      ];
      return '${DateFormat.yMMMd(locale).format(day)}\n${parts.isEmpty ? '—' : parts.join(' · ')}';
    }

    // Month labels where a column starts a new month, skipping crowded ones.
    final monthLabels = <Widget>[];
    if (!compact) {
      var lastLabelCol = -10;
      for (var c = 0; c < columns; c++) {
        final first = dayAt(c, 0);
        final prev = dayAt(c - 1, 0);
        if ((c == 0 || first.month != prev.month) && c - lastLabelCol >= 3) {
          lastLabelCol = c;
          monthLabels.add(Positioned(
            left: c * (cell + _gap),
            child: Text(
              DateFormat.MMM(locale).format(first.month != prev.month ? first : dayAt(c, 6)),
              style: TextStyle(fontSize: 8, color: colorScheme.outline),
            ),
          ));
        }
      }
    }

    final gridWidth = columns * cell + (columns - 1) * _gap;
    return Align(
      alignment: Alignment.topRight,
      child: SizedBox(
        width: gridWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!compact) SizedBox(height: monthLabelHeight, child: Stack(clipBehavior: Clip.none, children: monthLabels)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var c = 0; c < columns; c++) ...[
                  if (c > 0) const SizedBox(width: _gap),
                  Column(
                    children: [
                      for (var r = 0; r < 7; r++) ...[
                        if (r > 0) const SizedBox(height: _gap),
                        _cell(dayAt(c, r), today, daily, cell, colorFor, intensity, tooltip),
                      ],
                    ],
                  ),
                ],
              ],
            ),
            if (!compact)
              SizedBox(
                height: footerHeight,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    context.l10n.statsHeatmapActiveDays(activeDays),
                    style: TextStyle(fontSize: 8, color: colorScheme.outline),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cell(
    DateTime day,
    DateTime today,
    Map<DateTime, ({int pages, int seconds})> daily,
    double size,
    Color Function(double) colorFor,
    double Function(({int pages, int seconds})?) intensity,
    String Function(DateTime, ({int pages, int seconds})?) tooltip,
  ) {
    // Days after today (rest of the current week) stay empty.
    if (day.isAfter(today)) return SizedBox(width: size, height: size);
    final d = daily[day];
    final box = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorFor(intensity(d)),
        borderRadius: BorderRadius.circular(size / 5),
        border: day == today ? Border.all(color: Colors.white54, width: 1) : null,
      ),
    );
    // Tap, not long press: long press reorders the stats grid.
    return Tooltip(
      message: tooltip(day, d),
      triggerMode: TooltipTriggerMode.tap,
      textAlign: TextAlign.center,
      child: box,
    );
  }

  static bool _counts(({int pages, int seconds}) d, _HeatmapMetric metric) => switch (metric) {
        _HeatmapMetric.pages => d.pages > 0,
        _HeatmapMetric.listening => d.seconds > 0,
        _HeatmapMetric.all => d.pages > 0 || d.seconds > 0,
      };

  static _HeatmapMetric _metricOf(String? configStr) {
    if (configStr == null) return _HeatmapMetric.all;
    try {
      final name = (jsonDecode(configStr) as Map<String, dynamic>)['metric'];
      return _HeatmapMetric.values.firstWhere((m) => m.name == name, orElse: () => _HeatmapMetric.all);
    } catch (_) {
      return _HeatmapMetric.all;
    }
  }

  Widget _metricMenu(BuildContext context, WidgetRef ref, StatWidgetConfig liveConfig, _HeatmapMetric current) {
    String label(_HeatmapMetric m) => switch (m) {
          _HeatmapMetric.all => context.l10n.statsHeatmapAll,
          _HeatmapMetric.pages => context.l10n.statsHeatmapPages,
          _HeatmapMetric.listening => context.l10n.statsHeatmapListening,
        };
    return PopupMenuButton<_HeatmapMetric>(
      icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: (m) {
        final map = <String, dynamic>{};
        try {
          if (liveConfig.config != null) map.addAll(jsonDecode(liveConfig.config!) as Map<String, dynamic>);
        } catch (_) {}
        map['metric'] = m.name;
        ref.read(statsControllerProvider.notifier).updateWidgetConfig(
              liveConfig.copyWith(config: Value(jsonEncode(map))),
            );
      },
      itemBuilder: (context) => [
        for (final m in _HeatmapMetric.values)
          CheckedPopupMenuItem(value: m, checked: m == current, child: Text(label(m))),
      ],
    );
  }
}
