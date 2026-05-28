import 'package:drift/drift.dart';
import '../database.dart';

part 'goal_dao.g.dart';

@DriftAccessor(tables: [ReadingGoals])
class GoalDao extends DatabaseAccessor<AppDatabase> with _$GoalDaoMixin {
  GoalDao(super.db);

  Stream<List<ReadingGoal>> watchAllGoals() => select(readingGoals).watch();
  Future<int> insertGoal(ReadingGoalsCompanion goal) => into(readingGoals).insert(goal);
  Future<bool> updateGoal(ReadingGoal goal) => update(readingGoals).replace(goal);
  Future<void> deleteGoal(int id) => (delete(readingGoals)..where((t) => t.id.equals(id))).go();
}
