import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/books_controller.dart';
import '../../services/database.dart';
import '../../l10n/l10n_extension.dart';

class StatsView extends ConsumerWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(allBooksProvider);
    final tagsWithCountsAsync = ref.watch(allTagsWithCountsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.navStats,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
            color: Colors.white,
          ),
        ),
        toolbarHeight: 64,
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0,
      ),
      body: booksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (books) {
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(context.l10n.statsPlaceholder),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(context, books),
                const SizedBox(height: 24),
                _buildSectionTitle(context, context.l10n.searchTabStatus),
                const SizedBox(height: 16),
                _StatusPieChart(books: books),
                const SizedBox(height: 32),
                _buildSectionTitle(context, context.l10n.managementCategories),
                const SizedBox(height: 16),
                tagsWithCountsAsync.maybeWhen(
                  data: (tags) => _CategoriesBarChart(tags: tags),
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(height: 32),
                _buildSectionTitle(context, 'Libros añadidos (6 meses)'),
                const SizedBox(height: 16),
                _TimelineChart(books: books),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, List<Book> books) {
    final totalBooks = books.length;
    final totalPages = books.fold<int>(0, (sum, b) => sum + (b.totalPages ?? 0));
    final readBooks = books.where((b) => b.status == ReadingStatus.read).length;

    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Libros', value: totalBooks.toString(), icon: Icons.book)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Páginas', value: totalPages.toString(), icon: Icons.auto_stories)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Leídos', value: readBooks.toString(), icon: Icons.check_circle)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.outline)),
        ],
      ),
    );
  }
}

class _StatusPieChart extends StatelessWidget {
  final List<Book> books;
  const _StatusPieChart({required this.books});

  @override
  Widget build(BuildContext context) {
    final counts = <ReadingStatus, int>{};
    for (final b in books) {
      counts[b.status] = (counts[b.status] ?? 0) + 1;
    }

    final data = ReadingStatus.values.map((status) {
      final count = counts[status] ?? 0;
      if (count == 0) return null;
      return PieChartSectionData(
        value: count.toDouble(),
        title: '',
        radius: 20,
        color: _statusColor(status),
      );
    }).whereType<PieChartSectionData>().toList();

    return Row(
      children: [
        SizedBox(
          height: 160,
          width: 160,
          child: PieChart(
            PieChartData(
              sections: data,
              sectionsSpace: 4,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ReadingStatus.values.map((s) {
              final count = counts[s] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: _statusColor(s), borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_statusLabel(context, s), style: const TextStyle(fontSize: 12))),
                    Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _statusColor(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.wantToRead: return Colors.orange;
      case ReadingStatus.reading: return Colors.blue;
      case ReadingStatus.read: return Colors.green;
      case ReadingStatus.abandoned: return Colors.red;
      case ReadingStatus.paused: return const Color(0xFFB39DDB);
    }
  }

  String _statusLabel(BuildContext context, ReadingStatus status) {
    switch (status) {
      case ReadingStatus.reading: return context.l10n.statusReading;
      case ReadingStatus.wantToRead: return context.l10n.statusWantToRead;
      case ReadingStatus.read: return context.l10n.statusRead;
      case ReadingStatus.paused: return context.l10n.statusPaused;
      case ReadingStatus.abandoned: return context.l10n.statusAbandoned;
    }
  }
}

class _CategoriesBarChart extends StatelessWidget {
  final List<(Tag, int)> tags;
  const _CategoriesBarChart({required this.tags});

  @override
  Widget build(BuildContext context) {
    final sorted = List<(Tag, int)>.from(tags)
      ..sort((a, b) => b.$2.compareTo(a.$2));
    
    final top = sorted.take(6).toList();
    if (top.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: top.map((e) => e.$2.toDouble()).reduce(math.max) + 1,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= top.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      top[index].$1.name.substring(0, math.min(top[index].$1.name.length, 5)),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: top.asMap().entries.map((e) {
            final color = e.value.$1.color != null ? Color(int.parse('0xFF${e.value.$1.color}')) : Theme.of(context).colorScheme.primary;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.$2.toDouble(),
                  color: color,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TimelineChart extends StatelessWidget {
  final List<Book> books;
  const _TimelineChart({required this.books});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - i, 1)).reversed.toList();
    
    final counts = <DateTime, int>{};
    for (final m in months) {
      counts[m] = books.where((b) => b.createdAt.year == m.year && b.createdAt.month == m.month).length;
    }

    final spots = months.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), counts[e.value]!.toDouble());
    }).toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= months.length) return const SizedBox.shrink();
                  final m = months[index];
                  return Text('${m.month}/${m.year.toString().substring(2)}', style: const TextStyle(fontSize: 9));
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
