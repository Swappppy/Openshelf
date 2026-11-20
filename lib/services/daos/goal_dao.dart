import 'package:drift/drift.dart';
import '../database.dart';

part 'goal_dao.g.dart';

@DriftAccessor(tables: [ReadingGoals])
class GoalDao extends DatabaseAccessor<AppDatabase> with _$GoalDaoMixin {
  GoalDao(super.db);

  Stream<List<ReadingGoal>> watchAllGoals() => select(readingGoals).watch();
  Future<int> insertGoal(ReadingGoalsCompanion goal) => into(readingGoals).insert(goal);
  Future<bool> updateGoal(ReadingGoal goal) => update(readingGoals).replace(goal);
  Future<void> deleteGoal(int id) => transaction(() async {
        // Stats widgets may display this goal (no ON DELETE action on that FK).
        await (update(db.statWidgetConfigs)..where((w) => w.goalId.equals(id)))
            .write(const StatWidgetConfigsCompanion(goalId: Value(null)));
        await (delete(readingGoals)..where((t) => t.id.equals(id))).go();
      });
}
