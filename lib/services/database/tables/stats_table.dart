import 'package:drift/drift.dart';
import 'goals_table.dart';

/// Configuration for stats widgets layout
class StatWidgetConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// Type: 'pages', 'streak', 'goal', 'status', 'currentBook', 'addedOverTime', 'categories', 'publishYear', 'readList'
  TextColumn get type => text()();
  /// Size: 'half', 'full', 'fullTall'
  TextColumn get size => text()();
  IntColumn get sortOrder => integer()();
  IntColumn get goalId => integer().nullable().references(ReadingGoals, #id)();
  /// JSON-encoded configuration for the widget (e.g. time period)
  TextColumn get config => text().nullable()();
}
