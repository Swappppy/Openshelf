import 'package:drift/drift.dart';
import 'shelves_table.dart';
import 'tags_table.dart';

/// Reading Goals table
class ReadingGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  /// Type can be 'books' or 'pages'
  TextColumn get type => text()();
  IntColumn get targetValue => integer()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  /// Optional filters
  IntColumn get shelfId => integer().nullable().references(Shelves, #id)();
  IntColumn get collectionId => integer().nullable().references(Tags, #id)();
}
