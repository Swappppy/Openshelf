import 'package:drift/drift.dart';
import 'books_table.dart';
import '../converters.dart';

/// Table to store the ownership history (bought, borrowed, sold, etc.)
class OwnershipLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get eventType => textEnum<OwnershipStatus>()();
  TextColumn get personName => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
}
