// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_dao.dart';

// ignore_for_file: type=lint
mixin _$GoalDaoMixin on DatabaseAccessor<AppDatabase> {
  $ShelvesTable get shelves => attachedDatabase.shelves;
  $TagsTable get tags => attachedDatabase.tags;
  $ReadingGoalsTable get readingGoals => attachedDatabase.readingGoals;
  GoalDaoManager get managers => GoalDaoManager(this);
}

class GoalDaoManager {
  final _$GoalDaoMixin _db;
  GoalDaoManager(this._db);
  $$ShelvesTableTableManager get shelves =>
      $$ShelvesTableTableManager(_db.attachedDatabase, _db.shelves);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$ReadingGoalsTableTableManager get readingGoals =>
      $$ReadingGoalsTableTableManager(_db.attachedDatabase, _db.readingGoals);
}
