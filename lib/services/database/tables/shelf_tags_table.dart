import 'package:drift/drift.dart';
import 'shelves_table.dart';
import 'tags_table.dart';

/// Relationship table between Shelves and Tags for filtering.
/// Replaces the JSON-encoded string columns in the Shelves table.
class ShelfTags extends Table {
  IntColumn get shelfId => integer().references(Shelves, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId => integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {shelfId, tagId};
}
