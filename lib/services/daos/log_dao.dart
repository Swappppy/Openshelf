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
}
