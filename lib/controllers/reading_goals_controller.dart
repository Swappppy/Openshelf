import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import 'database_provider.dart';

final allGoalsProvider = StreamProvider<List<ReadingGoal>>((ref) {
  return ref.watch(databaseProvider).watchAllGoals();
});

final goalProgressProvider = StreamProvider.family<int, int>((ref, goalId) {
  final db = ref.watch(databaseProvider);
  
  return db.watchAllGoals().asyncMap((goals) async {
    final goal = goals.where((g) => g.id == goalId).firstOrNull;
    if (goal == null) return 0;

    if (goal.type == 'books') {
      final books = await db.watchAllBooks().first;
      return books.where((b) => 
        b.status == ReadingStatus.read &&
        b.finishedAt != null &&
        b.finishedAt!.isAfter(goal.startDate) &&
        b.finishedAt!.isBefore(goal.endDate)
      ).length;
    } else if (goal.type == 'pages') {
      final logs = await db.watchLogs().first;
      return logs.where((l) => 
        l.date.isAfter(goal.startDate) &&
        l.date.isBefore(goal.endDate)
      ).fold<int>(0, (sum, l) => sum + l.pagesRead);
    } else if (goal.type == 'shelf' && goal.shelfId != null) {
      // For shelf goals, progress is how many books in that shelf are 'read'
      final shelf = await (db.select(db.shelves)..where((t) => t.id.equals(goal.shelfId!))).getSingleOrNull();
      if (shelf == null) return 0;
      
      final books = await db.watchBooksFiltered(
        query: shelf.filterQuery,
        author: shelf.filterAuthor,
        publisher: shelf.filterPublisher,
        isbn: shelf.filterIsbn,
        collectionNames: shelf.filterCollection?.split(' | '),
        tagIds: shelf.filterTagIds != null ? (jsonDecode(shelf.filterTagIds!) as List).cast<int>() : null,
        imprintIds: shelf.filterImprintIds != null ? (jsonDecode(shelf.filterImprintIds!) as List).cast<int>() : null,
      ).first;
      
      return books.where((b) => b.status == ReadingStatus.read).length;
    }
    return 0;
  });
});

class ReadingGoalsController extends Notifier<void> {
  @override
  void build() {}

  Future<void> addGoal(ReadingGoalsCompanion goal) async {
    await ref.read(databaseProvider).insertGoal(goal);
  }

  Future<void> deleteGoal(int id) async {
    await ref.read(databaseProvider).deleteGoal(id);
  }

  Future<void> updateGoal(ReadingGoal goal) async {
    await ref.read(databaseProvider).updateGoal(goal);
  }
}

final readingGoalsControllerProvider = NotifierProvider<ReadingGoalsController, void>(
  ReadingGoalsController.new,
);
