import 'package:drift/drift.dart';
import '../database.dart';

part 'read_history_dao.g.dart';

@DriftAccessor(tables: [ReadHistory])
class ReadHistoryDao extends DatabaseAccessor<AppDatabase> with _$ReadHistoryDaoMixin {
  ReadHistoryDao(super.db);

  Stream<List<ReadHistoryData>> watchHistoryForBook(int bookId) =>
      (select(readHistory)..where((h) => h.bookId.equals(bookId))..orderBy([(h) => OrderingTerm(expression: h.readNumber, mode: OrderingMode.asc)])).watch();

  Future<int> insertRead(ReadHistoryCompanion entry) => into(readHistory).insert(entry);

  Future<bool> updateRead(ReadHistoryData entry) => update(readHistory).replace(entry);

  Future<void> deleteReadByNumber(int bookId, int readNumber) =>
      (delete(readHistory)..where((h) => h.bookId.equals(bookId) & h.readNumber.equals(readNumber))).go();

  Future<ReadHistoryData?> getRead(int bookId, int readNumber) =>
      (select(readHistory)..where((h) => h.bookId.equals(bookId) & h.readNumber.equals(readNumber))).getSingleOrNull();

  Future<void> deleteHistoryForBook(int bookId) =>
      (delete(readHistory)..where((h) => h.bookId.equals(bookId))).go();

  Future<void> deleteReadsAfter(int bookId, int readNumber) =>
      (delete(readHistory)..where((h) => h.bookId.equals(bookId) & h.readNumber.isBiggerThanValue(readNumber))).go();
}
