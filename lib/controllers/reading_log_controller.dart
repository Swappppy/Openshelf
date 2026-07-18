import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import '../services/database.dart';
import 'database_provider.dart';

class ReadingLogController extends Notifier<void> {
  @override
  void build() {}

  Future<void> logPages(int bookId, int delta) async {
    if (delta <= 0) return;

    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if an entry for this book and day already exists
    final existing = await (db.logDao.select(db.logDao.readingLog)
          ..where((l) => l.bookId.equals(bookId) & l.date.equals(today)))
        .getSingleOrNull();

    if (existing != null) {
      await db.logDao.updateLog(
        existing.copyWith(pagesRead: existing.pagesRead + delta),
      );
    } else {
      await db.logDao.insertLog(
        ReadingLogCompanion.insert(
          bookId: bookId,
          date: today,
          pagesRead: delta,
        ),
      );
    }
  }
}

final readingLogControllerProvider = NotifierProvider<ReadingLogController, void>(
  ReadingLogController.new,
);

final readingStreakProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.logDao.watchLogs().map((logs) {
    if (logs.isEmpty) return 0;

    final activeDates = logs
        .where((l) => l.pagesRead > 0)
        .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (activeDates.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (activeDates.first != today && activeDates.first != yesterday) {
      return 0;
    }

    int streak = 0;
    DateTime current = activeDates.first;

    for (final date in activeDates) {
      if (date == current) {
        streak++;
        current = current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  });
});

final totalPagesReadProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  
  return db.bookDao.watchAllBooks().map((books) {
    int total = 0;
    for (final b in books) {
      for (final pages in b.readingSessions.values) {
        total += pages;
      }
    }
    return total;
  });
});

final dailyReadingProvider = StreamProvider<Map<DateTime, int>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.logDao.watchLogs().map((logs) {
    final Map<DateTime, int> daily = {};
    for (final l in logs) {
      final day = DateTime(l.date.year, l.date.month, l.date.day);
      daily[day] = (daily[day] ?? 0) + l.pagesRead;
    }
    return daily;
  });
});
