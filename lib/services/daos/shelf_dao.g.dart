// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_dao.dart';

// ignore_for_file: type=lint
mixin _$ShelfDaoMixin on DatabaseAccessor<AppDatabase> {
  $ShelvesTable get shelves => attachedDatabase.shelves;
  $TagsTable get tags => attachedDatabase.tags;
  $ShelfTagsTable get shelfTags => attachedDatabase.shelfTags;
  ShelfDaoManager get managers => ShelfDaoManager(this);
}

class ShelfDaoManager {
  final _$ShelfDaoMixin _db;
  ShelfDaoManager(this._db);
  $$ShelvesTableTableManager get shelves =>
      $$ShelvesTableTableManager(_db.attachedDatabase, _db.shelves);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$ShelfTagsTableTableManager get shelfTags =>
      $$ShelfTagsTableTableManager(_db.attachedDatabase, _db.shelfTags);
}
