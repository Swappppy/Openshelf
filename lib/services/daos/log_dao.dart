import 'package:drift/drift.dart';
import '../database.dart';

part 'log_dao.g.dart';

@DriftAccessor(tables: [ReadingLog])
class LogDao extends DatabaseAccessor<AppDatabase> with _$LogDaoMixin {
  LogDao(super.db);

  Stream<List<ReadingLogData>> watchLogs() => select(readingLog).watch();
  Stream<List<ReadingLogData>> watchLogForBook(int bookId) =>
      (select(readingLog)..where((l) => l.bookId.equals(bookId))).watch();
  Future<int> insertLog(ReadingLogCompanion log) => into(readingLog).insert(log);
  Future<bool> updateLog(ReadingLogData log) => update(readingLog).replace(log);
  Future<void> deleteLog(int id) => (delete(readingLog)..where((l) => l.id.equals(id))).go();

  Future<void> moveBackfill(int bookId, int? readNumber, DateTime newDay) async {
    final dateOnly = DateTime(newDay.year, newDay.month, newDay.day);
    var query = update(readingLog)
      ..where((l) => l.bookId.equals(bookId) & l.isBackfill.equals(true));
    if (readNumber != null) {
      query = query..where((l) => l.readNumber.equals(readNumber));
    } else {
      query = query..where((l) => l.readNumber.isNull());
    }
    await query.write(ReadingLogCompanion(date: Value(dateOnly)));
  }

  Future<void> deleteForRead(int bookId, int readNumber) async {
    await (delete(readingLog)
          ..where((l) => l.bookId.equals(bookId) & l.readNumber.equals(readNumber)))
        .go();
  }

  Future<void> renumberRead(int bookId, int from, int to) async {
    await (update(readingLog)
          ..where((l) => l.bookId.equals(bookId) & l.readNumber.equals(from)))
        .write(ReadingLogCompanion(readNumber: Value(to)));
  }
}
