import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '../services/database.dart';
import 'database_provider.dart';

final allGoalsProvider = StreamProvider<List<ReadingGoal>>((ref) {
  return ref.watch(databaseProvider).goalDao.watchAllGoals();
});

final goalProgressProvider = StreamProvider.family<int, int>((ref, goalId) {
  final db = ref.watch(databaseProvider);

  return (db.goalDao.select(db.goalDao.readingGoals)
        ..where((t) => t.id.equals(goalId)))
      .watchSingle()
      .switchMap((goal) {
    if (goal.type == 'books') {
      return db.bookDao.watchAllBooks().map((books) => books
          .where((b) =>
              b.status == ReadingStatus.read &&
              b.finishedAt != null &&
              b.finishedAt!.isAfter(goal.startDate) &&
              b.finishedAt!.isBefore(goal.endDate))
          .length);
    } else if (goal.type == 'pages') {
      return db.logDao.watchLogs().map((logs) => logs
          .where((l) =>
              l.date.isAfter(goal.startDate) && l.date.isBefore(goal.endDate))
          .fold<int>(0, (sum, l) => sum + l.pagesRead));
    } else if (goal.type == 'shelf' && goal.shelfId != null) {
      // For shelf goals, progress is how many books in that shelf are 'read'
      return (db.shelfDao.select(db.shelfDao.shelves)
            ..where((t) => t.id.equals(goal.shelfId!)))
          .watchSingle()
          .switchMap((shelf) {
        return db.bookDao
            .watchBooksFiltered(
              query: shelf.filterQuery,
              author: shelf.filterAuthor,
              publisher: shelf.filterPublisher,
              isbn: shelf.filterIsbn,
              collectionIds: shelf.filterCollectionIds != null
                  ? (jsonDecode(shelf.filterCollectionIds!) as List).cast<int>()
                  : null,
              tagIds: shelf.filterTagIds != null
                  ? (jsonDecode(shelf.filterTagIds!) as List).cast<int>()
                  : null,
              imprintIds: shelf.filterImprintIds != null
                  ? (jsonDecode(shelf.filterImprintIds!) as List).cast<int>()
                  : null,
              status: ReadingStatus.read,
            )
            .map((books) => books.length);
      });
    }
    return Stream.value(0);
  });
});

class ReadingGoalsController extends Notifier<void> {
  @override
  void build() {}

  Future<void> addGoal(ReadingGoalsCompanion goal) async {
    await ref.read(databaseProvider).goalDao.insertGoal(goal);
  }

  Future<void> deleteGoal(int id) async {
    await ref.read(databaseProvider).goalDao.deleteGoal(id);
  }

  Future<void> updateGoal(ReadingGoal goal) async {
    await ref.read(databaseProvider).goalDao.updateGoal(goal);
  }
}

final readingGoalsControllerProvider = NotifierProvider<ReadingGoalsController, void>(
  ReadingGoalsController.new,
);
