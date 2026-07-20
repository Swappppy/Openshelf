// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'read_history_dao.dart';

// ignore_for_file: type=lint
mixin _$ReadHistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $TagsTable get tags => attachedDatabase.tags;
  $BooksTable get books => attachedDatabase.books;
  $ReadHistoryTable get readHistory => attachedDatabase.readHistory;
  ReadHistoryDaoManager get managers => ReadHistoryDaoManager(this);
}

class ReadHistoryDaoManager {
  final _$ReadHistoryDaoMixin _db;
  ReadHistoryDaoManager(this._db);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$ReadHistoryTableTableManager get readHistory =>
      $$ReadHistoryTableTableManager(_db.attachedDatabase, _db.readHistory);
}
