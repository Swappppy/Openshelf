import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../controllers/books_controller.dart';
import '../../../controllers/stats_controller.dart';
import '../../../models/stats_widget.dart';
import '../../../services/database.dart';
import '../../book_detail/book_detail_view.dart';
import '../../shelves/shelf_books_view.dart';
import 'widget_header.dart';
import '../../../l10n/l10n_extension.dart';

class ReadListTile extends ConsumerWidget {
  final StatWidgetConfig config;
  final StatWidgetSize size;

  const ReadListTile({super.key, required this.config, required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(allBooksProvider);
    final period = _getPeriod(config.config);

    return booksAsync.maybeWhen(
      data: (allBooks) {
        final now = DateTime.now();
        final filtered = allBooks.where((b) {
          if (b.status != ReadingStatus.read || b.finishedAt == null) return false;
          final finished = b.finishedAt!;
          
          switch (period) {
            case 'this_month':
              return finished.year == now.year && finished.month == now.month;
            case 'last_3_months':
              final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
              return finished.isAfter(threeMonthsAgo);
            case 'this_year':
              return finished.year == now.year;
            case 'last_3_years':
              return finished.year >= now.year - 3;
            default:
              return finished.year == now.year && finished.month == now.month;
          }
        }).toList();

        // Sort by finishedAt descending (last read first)
        filtered.sort((a, b) => b.finishedAt!.compareTo(a.finishedAt!));

        final displayBooks = filtered.take(10).toList();
        final remainingCount = filtered.length - displayBooks.length;

        return Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: WidgetHeader(
                      title: _getPeriodLabel(context, period),
                      icon: Icons.checklist_rtl,
                    ),
                  ),
                  _buildPeriodMenu(context, ref),
                ],
              ),
              const SizedBox(height: 12),
              if (displayBooks.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      context.l10n.statsAddedNoData,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayBooks.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final book = displayBooks[index];
                            return _buildBookItem(context, book);
                          },
                        ),
                      ),
                      if (remainingCount > 0) ...[
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _openFullList(context, filtered, _getPeriodLabel(context, period)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '+$remainingCount ${context.l10n.tabMore}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
      orElse: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildBookItem(BuildContext context, Book book) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookDetailView(book: book)),
      ),
      child: Row(
        children: [
          if (book.coverPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.file(File(book.coverPath!), width: 24, height: 36, fit: BoxFit.cover),
            )
          else
            Container(
              width: 24, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.book, size: 14, color: Colors.white24),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  book.author,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
      padding: EdgeInsets.zero,
      onSelected: (val) {
        final currentConfig = config.config != null ? jsonDecode(config.config!) as Map<String, dynamic> : {};
        currentConfig['period'] = val;
        ref.read(statsControllerProvider.notifier).updateWidgetConfig(
          config.copyWith(config: Value(jsonEncode(currentConfig))),
        );
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'this_month', child: Text(context.l10n.statsPeriodThisMonth)),
        PopupMenuItem(value: 'last_3_months', child: Text(context.l10n.statsPeriodLast3Months)),
        PopupMenuItem(value: 'this_year', child: Text(context.l10n.statsPeriodThisYear)),
        PopupMenuItem(value: 'last_3_years', child: Text(context.l10n.statsPeriodLast3Years)),
      ],
    );
  }

  String _getPeriod(String? configStr) {
    if (configStr == null) return 'this_month';
    try {
      final map = jsonDecode(configStr) as Map<String, dynamic>;
      return map['period'] ?? 'this_month';
    } catch (_) {
      return 'this_month';
    }
  }

  String _getPeriodLabel(BuildContext context, String period) {
    switch (period) {
      case 'this_month': return context.l10n.statsPeriodThisMonth;
      case 'last_3_months': return context.l10n.statsPeriodLast3Months;
      case 'this_year': return context.l10n.statsPeriodThisYear;
      case 'last_3_years': return context.l10n.statsPeriodLast3Years;
      default: return context.l10n.statsPeriodThisMonth;
    }
  }

  void _openFullList(BuildContext context, List<Book> books, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatusBooksView(
          status: ReadingStatus.read,
          title: title,
          // Custom override to filter and sort exactly as the widget does
          customBooks: books,
        ),
      ),
    );
  }
}
