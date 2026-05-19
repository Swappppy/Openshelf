import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
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
    final existing = await (db.select(db.readingLog)
          ..where((l) => l.bookId.equals(bookId) & l.date.equals(today)))
        .getSingleOrNull();

    if (existing != null) {
      await db.update(db.readingLog).replace(
        existing.copyWith(pagesRead: existing.pagesRead + delta),
      );
    } else {
      await db.into(db.readingLog).insert(
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
  return db.watchLogs().map((logs) {
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
  
  // Combine ReadingLog entries with the static progress of books 
  // to account for legacy books that weren't tracked via logs.
  return db.watchAllBooks().asyncMap((books) async {
    final logs = await db.watchLogs().first;
    
    // 1. Sum all logged activity
    final loggedPages = logs.fold(0, (sum, l) => sum + l.pagesRead);
    
    // 2. Identify books that don't have ANY log entries yet
    final loggedBookIds = logs.map((l) => l.bookId).toSet();
    
    // 3. Sum current progress of those un-logged books
    int unloggedPages = 0;
    for (final b in books) {
      if (!loggedBookIds.contains(b.id)) {
        if (b.status == ReadingStatus.read) {
          unloggedPages += (b.totalPages ?? 0);
        } else {
          unloggedPages += (b.currentPage ?? 0);
        }
      }
    }
    
    return loggedPages + unloggedPages;
  });
});
