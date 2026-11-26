import 'package:drift/drift.dart';
import 'books_table.dart';
import '../converters.dart';

/// Audio-specific data of a book (1:1, optional). In `both` mode the main
/// book fields describe the reading edition and [publisher]/[identifier]
/// describe the audio edition.
class AudiobookInfo extends Table {
  IntColumn get bookId => integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get narrator => text().nullable()();
  TextColumn get platform => text().nullable()();

  /// Total duration in seconds.
  IntColumn get durationSeconds => integer().nullable()();
  TextColumn get publisher => text().nullable()();

  /// ISBN or ASIN of the audio edition.
  TextColumn get identifier => text().nullable()();

  /// Sections and markers of a plain audiobook, in seconds with the page
  /// convention (`startPhysical = startSecond + 1`). Kept apart from the
  /// book's page pagination, which stays hidden (not deleted) in audio mode.
  /// Mixed books share the page sections instead (with time anchors).
  TextColumn get paginationConfig => text().nullable().map(const PaginationConfigConverter())();

  @override
  Set<Column> get primaryKey => {bookId};
}
