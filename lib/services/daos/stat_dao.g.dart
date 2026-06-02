// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stat_dao.dart';

// ignore_for_file: type=lint
mixin _$StatDaoMixin on DatabaseAccessor<AppDatabase> {
  $ShelvesTable get shelves => attachedDatabase.shelves;
  $TagsTable get tags => attachedDatabase.tags;
  $ReadingGoalsTable get readingGoals => attachedDatabase.readingGoals;
  $StatWidgetConfigsTable get statWidgetConfigs =>
      attachedDatabase.statWidgetConfigs;
  StatDaoManager get managers => StatDaoManager(this);
}

class StatDaoManager {
  final _$StatDaoMixin _db;
  StatDaoManager(this._db);
  $$ShelvesTableTableManager get shelves =>
      $$ShelvesTableTableManager(_db.attachedDatabase, _db.shelves);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$ReadingGoalsTableTableManager get readingGoals =>
      $$ReadingGoalsTableTableManager(_db.attachedDatabase, _db.readingGoals);
  $$StatWidgetConfigsTableTableManager get statWidgetConfigs =>
      $$StatWidgetConfigsTableTableManager(
        _db.attachedDatabase,
        _db.statWidgetConfigs,
      );
}
