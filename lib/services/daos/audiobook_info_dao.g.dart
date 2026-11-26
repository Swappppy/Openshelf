// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audiobook_info_dao.dart';

// ignore_for_file: type=lint
mixin _$AudiobookInfoDaoMixin on DatabaseAccessor<AppDatabase> {
  $TagsTable get tags => attachedDatabase.tags;
  $BooksTable get books => attachedDatabase.books;
  $AudiobookInfoTable get audiobookInfo => attachedDatabase.audiobookInfo;
  AudiobookInfoDaoManager get managers => AudiobookInfoDaoManager(this);
}

class AudiobookInfoDaoManager {
  final _$AudiobookInfoDaoMixin _db;
  AudiobookInfoDaoManager(this._db);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$AudiobookInfoTableTableManager get audiobookInfo =>
      $$AudiobookInfoTableTableManager(_db.attachedDatabase, _db.audiobookInfo);
}
