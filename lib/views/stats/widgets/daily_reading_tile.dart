import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../controllers/reading_log_controller.dart';
import '../../../models/stats_widget.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../services/database.dart';
import 'widget_header.dart';

/// Daily activity bars: pages read, or (for [ReadingMedium.audio]) hours listened.
class DailyReadingTile extends ConsumerWidget {
  final StatWidgetSize size;
  final ReadingMedium medium;
  const DailyReadingTile({super.key, required this.size, this.medium = ReadingMedium.text});

  bool get _audio => medium == ReadingMedium.audio;

  /// Bar height: pages, or seconds shown as hours.
  double _value(int raw) => _audio ? raw / 3600 : raw.toDouble();

  String _axisLabel(double v) {
    if (!_audio) return v.toInt().toString();
    return '${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1)}h';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(_audio ? dailyListeningProvider : dailyReadingProvider);
    final showLabels = size != StatWidgetSize.s1x1;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetHeader(
            title: _audio ? context.l10n.statsDailyListeningTitle : context.l10n.statsDailyReadingTitle,
            icon: _audio ? Icons.headphones : Icons.bar_chart,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: dailyAsync.maybeWhen(
              data: (dailyData) {
                if (dailyData.isEmpty) {
                  return Center(
                    child: Text(
                      context.l10n.statsAddedNoData, 
                      style: const TextStyle(fontSize: 10)
                    )
                  );
                }
                
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                
                // Show last 7 or 14 days based on size
                final daysToShow = size == StatWidgetSize.s1x1 ? 7 : 14;
                final sortedDays = List.generate(daysToShow, (i) {
                  return today.subtract(Duration(days: daysToShow - 1 - i));
                });
                
                final maxValue = sortedDays.fold<double>(0, (m, day) => max(m, _value(dailyData[day] ?? 0)));
                
                final barGroups = sortedDays.asMap().entries.map((e) {
                  final value = _value(dailyData[e.value] ?? 0);
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: Theme.of(context).colorScheme.primary,
                        width: size == StatWidgetSize.s1x1 ? 8 : 12,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      )
                    ],
                  );
                }).toList();

                return BarChart(
                  BarChartData(
                    barGroups: barGroups,
                    maxY: maxValue == 0 ? (_audio ? 1 : 10) : maxValue * 1.2,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: showLabels,
                          reservedSize: 28,
                          getTitlesWidget: (val, meta) => Text(
                            _axisLabel(val),
                            style: const TextStyle(fontSize: 8, color: Colors.grey)
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (val, meta) {
                            int idx = val.toInt();
                            if (idx < 0 || idx >= sortedDays.length) return const SizedBox.shrink();
                            
                            // Show only some labels in 1x1
                            if (size == StatWidgetSize.s1x1 && idx % 2 != 0) return const SizedBox.shrink();
                            
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                DateFormat('E').format(sortedDays[idx]).substring(0, 1), 
                                style: const TextStyle(fontSize: 9, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: showLabels,
                      drawHorizontalLine: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (val) => const FlLine(color: Colors.white10, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                );
              },
              orElse: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
