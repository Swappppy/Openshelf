import 'package:drift/drift.dart';
import 'books_table.dart';

/// Reading Log table for tracking daily activity
class ReadingLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get pagesRead => integer()();
  TextColumn get sections => text().nullable()();
}
