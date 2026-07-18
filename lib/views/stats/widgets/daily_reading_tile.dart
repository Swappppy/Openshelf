import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../controllers/reading_log_controller.dart';
import '../../../models/stats_widget.dart';
import '../../../l10n/l10n_extension.dart';
import 'widget_header.dart';

class DailyReadingTile extends ConsumerWidget {
  final StatWidgetSize size;
  const DailyReadingTile({super.key, required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(dailyReadingProvider);
    final showLabels = size != StatWidgetSize.s1x1;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetHeader(title: context.l10n.statsDailyReadingTitle, icon: Icons.bar_chart),
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
                
                final maxPages = sortedDays.fold<int>(0, (m, day) => max(m, dailyData[day] ?? 0));
                
                final barGroups = sortedDays.asMap().entries.map((e) {
                  final pages = dailyData[e.value] ?? 0;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: pages.toDouble(),
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
                    maxY: maxPages == 0 ? 10 : maxPages.toDouble() * 1.2,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: showLabels,
                          reservedSize: 28,
                          getTitlesWidget: (val, meta) => Text(
                            val.toInt().toString(), 
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
