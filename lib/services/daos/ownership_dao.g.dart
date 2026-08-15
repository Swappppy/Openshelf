// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ownership_dao.dart';

// ignore_for_file: type=lint
mixin _$OwnershipDaoMixin on DatabaseAccessor<AppDatabase> {
  $TagsTable get tags => attachedDatabase.tags;
  $BooksTable get books => attachedDatabase.books;
  $OwnershipLogTable get ownershipLog => attachedDatabase.ownershipLog;
  OwnershipDaoManager get managers => OwnershipDaoManager(this);
}

class OwnershipDaoManager {
  final _$OwnershipDaoMixin _db;
  OwnershipDaoManager(this._db);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$OwnershipLogTableTableManager get ownershipLog =>
      $$OwnershipLogTableTableManager(_db.attachedDatabase, _db.ownershipLog);
}
