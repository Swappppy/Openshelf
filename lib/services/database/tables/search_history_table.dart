import 'package:drift/drift.dart';

/// Table to store search history and scan records (including failed/offline lookups)
class SearchHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text()(); // ISBN, search string, etc.
  TextColumn get type => text()(); // 'isbn_scan', 'batch_scan', 'text_search'
  TextColumn get status => text()(); // 'success', 'failed', 'pending'
  TextColumn get title => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get publisher => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
}
