import 'dart:convert';
import 'package:drift/drift.dart';

enum ReadingStatus {
  wantToRead,
  reading,
  read,
  abandoned,
  paused,
}

enum BookFormat {
  paperback,
  hardcover,
  leatherbound,
  rustic,
  digital,
  other,
}

/// Converts between BookFormat enum and String for DB storage
class BookFormatConverter extends TypeConverter<BookFormat?, String?> {
  const BookFormatConverter();

  @override
  BookFormat? fromSql(String? fromDb) {
    if (fromDb == null) return null;
    return BookFormat.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => BookFormat.other,
    );
  }

  @override
  String? toSql(BookFormat? value) => value?.name;
}

/// Converts between Map<int, int> and String (JSON) for DB storage
class ReadingSessionsConverter extends TypeConverter<Map<int, int>, String> {
  const ReadingSessionsConverter();

  @override
  Map<int, int> fromSql(String fromDb) {
    try {
      final Map<String, dynamic> decoded = Map<String, dynamic>.from(jsonDecode(fromDb));
      return decoded.map((key, value) => MapEntry(int.parse(key), value as int));
    } catch (_) {
      return {};
    }
  }

  @override
  String toSql(Map<int, int> value) => jsonEncode(value.map((key, val) => MapEntry(key.toString(), val)));
}
