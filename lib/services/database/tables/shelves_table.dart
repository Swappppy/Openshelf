import 'package:drift/drift.dart';
import '../../../models/shelf.dart';

/// Dynamic Shelves table definition (Saved smart-filters)
@UseRowClass(Shelf)
class Shelves extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get filterQuery => text().nullable()();
  TextColumn get filterSubtitle => text().nullable()();
  TextColumn get filterAuthor => text().nullable()();
  TextColumn get filterPublisher => text().nullable()();
  TextColumn get filterIsbn => text().nullable()();
  TextColumn get filterLanguage => text().nullable()();
  TextColumn get filterTranslator => text().nullable()();
  @Deprecated('Use filterCollectionIds instead')
  TextColumn get filterCollection => text().nullable()();
  TextColumn get filterCollectionIds => text().nullable()();
  TextColumn get filterStatus => text().nullable()();
  /// DEPRECATED: Replaced by ShelfTags table.
  @Deprecated('Use ShelfTags table instead')
  TextColumn get filterTagIds => text().nullable()();
  /// DEPRECATED: Replaced by ShelfTags table.
  @Deprecated('Use ShelfTags table instead')
  TextColumn get filterImprintIds => text().nullable()();
  BoolColumn get filterNoCover => boolean().withDefault(const Constant(false))();
}
