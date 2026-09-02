import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('GoalDao Tests', () {
    test('insertGoal and watchAllGoals', () async {
      final now = DateTime.now();
      await db.goalDao.insertGoal(ReadingGoalsCompanion.insert(
        title: 'Read 50 books',
        type: 'books',
        target: 50,
        startDate: now,
        endDate: now.add(const Duration(days: 365)),
      ));

      final goals = await db.goalDao.watchAllGoals().first;
      expect(goals.length, 1);
      expect(goals.first.title, 'Read 50 books');
      expect(goals.first.target, 50);
    });

    test('updateGoal', () async {
      final now = DateTime.now();
      final id = await db.goalDao.insertGoal(ReadingGoalsCompanion.insert(
        title: 'Initial Goal',
        type: 'books',
        target: 10,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
      ));

      final goal = await (db.select(db.readingGoals)..where((t) => t.id.equals(id))).getSingle();
      await db.goalDao.updateGoal(goal.copyWith(title: 'Updated Goal', target: 20));

      final updated = await (db.select(db.readingGoals)..where((t) => t.id.equals(id))).getSingle();
      expect(updated.title, 'Updated Goal');
      expect(updated.target, 20);
    });

    test('deleteGoal', () async {
      final now = DateTime.now();
      final id = await db.goalDao.insertGoal(ReadingGoalsCompanion.insert(
        title: 'To be deleted',
        type: 'books',
        target: 5,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
      ));

      expect((await db.goalDao.watchAllGoals().first).length, 1);
      await db.goalDao.deleteGoal(id);
      expect((await db.goalDao.watchAllGoals().first).length, 0);
    });
  });
}
