import 'package:drift/drift.dart';

enum TagType {
  tag,
  imprint,
  collection,
}

class TagTypeConverter extends TypeConverter<TagType, String> {
  const TagTypeConverter();

  @override
  TagType fromSql(String fromDb) {
    return TagType.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => TagType.tag,
    );
  }

  @override
  String toSql(TagType value) => value.name;
}
