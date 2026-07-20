import 'package:drift/drift.dart';
import 'books_table.dart';

/// Table to store the history of each reading session for a book
class ReadHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get readNumber => integer()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get sections => text().nullable()();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  TextColumn get segmentProgress => text().nullable()();
}
