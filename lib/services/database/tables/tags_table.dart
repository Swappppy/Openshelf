import 'package:drift/drift.dart';
import '../../../models/tag_type.dart';

/// Tags table definition (used for Categories, Imprints, and Collections)
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  /// Type can be 'tag' (category), 'imprint', or 'collection'
  TextColumn get type => text().map(const TagTypeConverter()).withDefault(const Constant('tag'))();
  TextColumn get color => text().nullable()();
  TextColumn get imagePath => text().nullable()();
}
