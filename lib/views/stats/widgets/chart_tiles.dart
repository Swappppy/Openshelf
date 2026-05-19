import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../controllers/books_controller.dart';
import '../../../models/stats_widget.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import 'widget_header.dart';

class AddedOverTimeTile extends ConsumerWidget {
  final StatWidgetSize size;
  const AddedOverTimeTile({super.key, required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(allBooksProvider);
    final showLabels = size != StatWidgetSize.s1x1;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetHeader(title: context.l10n.statsAddedTitle, icon: Icons.timeline),
          const SizedBox(height: 12),
          Expanded(
            child: booksAsync.maybeWhen(
              data: (books) {
                if (books.isEmpty) return Center(child: Text(context.l10n.statsAddedNoData, style: const TextStyle(fontSize: 10)));
                
                final grouped = <DateTime, int>{};
                for (var b in books) {
                  final key = DateTime(b.createdAt.year, b.createdAt.month);
                  grouped[key] = (grouped[key] ?? 0) + 1;
                }
                
                final sortedKeys = grouped.keys.toList()..sort();
                final maxCount = grouped.values.isEmpty ? 1 : grouped.values.reduce(max);
                
                final spots = sortedKeys.asMap().entries.map((e) {
                  final count = grouped[e.value]!;
                  return ScatterSpot(
                    e.key.toDouble(), 
                    count.toDouble(),
                    dotPainter: FlDotCirclePainter(
                      radius: 6,
                      color: _getPointColor(count),
                    ),
                  );
                }).toList();

                return ScatterChart(
                  ScatterChartData(
                    scatterSpots: spots,
                    minY: 0,
                    maxY: maxCount.toDouble() + (maxCount * 0.1),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: showLabels,
                          reservedSize: 22,
                          getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 8, color: Colors.grey)),
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: showLabels,
                          reservedSize: 22,
                          getTitlesWidget: (val, meta) {
                            int idx = val.toInt();
                            if (idx < 0 || idx >= sortedKeys.length || (size == StatWidgetSize.s2x1 && idx % 2 != 0)) return const SizedBox.shrink();
                            return Text(DateFormat('MMM').format(sortedKeys[idx]), style: const TextStyle(fontSize: 8, color: Colors.grey));
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

  Color _getPointColor(int count) {
    if (count <= 2) return Colors.redAccent;
    if (count <= 5) return Colors.orangeAccent;
    if (count <= 10) return Colors.yellowAccent;
    return Colors.greenAccent;
  }
}

class CategoriesDistributionTile extends ConsumerWidget {
  final StatWidgetSize size;
  const CategoriesDistributionTile({super.key, required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(allTagsWithCountsProvider);
    final limit = (size == StatWidgetSize.s2x2 || size == StatWidgetSize.s1x2) ? 8 : 4;

    return tagsAsync.maybeWhen(
      data: (tags) {
        final sorted = List<(Tag, int)>.from(tags)..sort((a, b) => b.$2.compareTo(a.$2));
        final top = sorted.take(limit).toList();
        
        return Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetHeader(title: context.l10n.statsCategoriesTitle, icon: Icons.bar_chart),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: top.length,
                  itemBuilder: (context, i) {
                    final t = top[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(t.$1.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              Text('${t.$2}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: t.$2 / top.first.$2,
                              minHeight: 4,
                              color: t.$1.color != null ? Color(int.parse('0xFF${t.$1.color}')) : Theme.of(context).colorScheme.primary,
                              backgroundColor: Colors.grey[900],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class PublishYearTile extends ConsumerWidget {
  final StatWidgetSize size;
  const PublishYearTile({super.key, required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(allBooksProvider);
    final showLabels = size != StatWidgetSize.s1x1;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetHeader(title: context.l10n.statsYearsTitle, icon: Icons.history),
          const SizedBox(height: 12),
          Expanded(
            child: booksAsync.maybeWhen(
              data: (books) {
                final years = books.map((b) => b.publishYear).whereType<int>().toList();
                if (years.isEmpty) return Center(child: Text(context.l10n.statsAddedNoData, style: const TextStyle(fontSize: 10)));
                
                final grouped = <int, int>{};
                for (var y in years) {
                  grouped[y] = (grouped[y] ?? 0) + 1;
                }
                
                final sortedYears = grouped.keys.toList()..sort();
                final barGroups = sortedYears.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: grouped[e.value]!.toDouble(),
                        color: Theme.of(context).colorScheme.primary,
                        width: size == StatWidgetSize.s1x1 ? 1 : 2,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(1)),
                      )
                    ],
                  );
                }).toList();

                return BarChart(
                  BarChartData(
                    barGroups: barGroups,
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: showLabels,
                          reservedSize: 30,
                          getTitlesWidget: (val, meta) {
                            int idx = val.toInt();
                            if (idx < 0 || idx >= sortedYears.length || idx % 5 != 0) return const SizedBox.shrink();
                            return SideTitleWidget(
                              meta: meta,
                              angle: (size == StatWidgetSize.s1x2 || size == StatWidgetSize.s2x2) ? -0.5 : 0,
                              child: Text(
                                sortedYears[idx].toString(), 
                                style: const TextStyle(fontSize: 8, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
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

class ReadByYearTile extends ConsumerWidget {
  final StatWidgetSize size;
  const ReadByYearTile({super.key, required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(allBooksProvider);
    final showLabels = size != StatWidgetSize.s1x1;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetHeader(title: context.l10n.statsReadByYearTitle, icon: Icons.bar_chart),
          const SizedBox(height: 12),
          Expanded(
            child: booksAsync.maybeWhen(
              data: (books) {
                final readBooks = books.where((b) => b.status == ReadingStatus.read && b.finishedAt != null).toList();
                if (readBooks.isEmpty) return Center(child: Text(context.l10n.statsAddedNoData, style: const TextStyle(fontSize: 10)));
                
                final grouped = <int, int>{};
                for (var b in readBooks) {
                  final year = b.finishedAt!.year;
                  grouped[year] = (grouped[year] ?? 0) + 1;
                }
                
                final sortedYears = grouped.keys.toList()..sort();
                final maxCount = grouped.values.isEmpty ? 1 : grouped.values.reduce(max);

                final barGroups = sortedYears.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: grouped[e.value]!.toDouble(),
                        color: Theme.of(context).colorScheme.primary,
                        width: size == StatWidgetSize.s1x1 ? 12 : 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      )
                    ],
                  );
                }).toList();

                return BarChart(
                  BarChartData(
                    barGroups: barGroups,
                    maxY: maxCount.toDouble() + (maxCount * 0.2),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: showLabels,
                          reservedSize: 28,
                          getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 8, color: Colors.grey)),
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
                            if (idx < 0 || idx >= sortedYears.length) return const SizedBox.shrink();
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                sortedYears[idx].toString(), 
                                style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
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

class CollectionsDistributionTile extends ConsumerWidget {
  final StatWidgetSize size;
  const CollectionsDistributionTile({super.key, required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(allCollectionsWithCountsProvider);
    final limit = (size == StatWidgetSize.s2x2 || size == StatWidgetSize.s1x2) ? 8 : 4;

    return collectionsAsync.maybeWhen(
      data: (cols) {
        final sorted = List<(Tag, int)>.from(cols)..sort((a, b) => b.$2.compareTo(a.$2));
        final top = sorted.take(limit).toList();
        
        return Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetHeader(title: context.l10n.statsCollectionsTitle, icon: Icons.collections_bookmark),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: top.length,
                  itemBuilder: (context, i) {
                    final t = top[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(t.$1.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              Text('${t.$2}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: top.first.$2 > 0 ? t.$2 / top.first.$2 : 0,
                              minHeight: 4,
                              color: t.$1.color != null ? Color(int.parse('0xFF${t.$1.color}')) : Theme.of(context).colorScheme.primary,
                              backgroundColor: Colors.grey[900],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
