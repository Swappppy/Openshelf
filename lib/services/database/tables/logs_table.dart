import 'package:drift/drift.dart';
import 'books_table.dart';
import '../converters.dart';

/// Reading Log table for tracking daily activity
class ReadingLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get pagesRead => integer()();
  TextColumn get sections => text().nullable().map(const StringListConverter())();
  IntColumn get readNumber => integer().nullable()();
  BoolColumn get isBackfill => boolean().withDefault(const Constant(false))();

  /// Medium of this entry. For `audio`, [pagesRead] holds seconds listened.
  /// Page statistics and page goals only aggregate `text` entries.
  TextColumn get medium => textEnum<ReadingMedium>().withDefault(Constant(ReadingMedium.text.name))();

  /// Position (page or second, in this entry's medium) where the entry's
  /// progress started. Null for entries recorded before schema 34.
  IntColumn get startPosition => integer().nullable()();
}
