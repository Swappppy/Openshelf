import 'package:drift/drift.dart';
import '../database.dart';

part 'ownership_dao.g.dart';

@DriftAccessor(tables: [OwnershipLog])
class OwnershipDao extends DatabaseAccessor<AppDatabase> with _$OwnershipDaoMixin {
  OwnershipDao(super.db);

  Stream<List<OwnershipLogData>> watchLogForBook(int bookId) =>
      (select(ownershipLog)
        ..where((l) => l.bookId.equals(bookId))
        ..orderBy([(l) => OrderingTerm(expression: l.date, mode: OrderingMode.desc)]))
      .watch();

  Future<int> insertEvent(OwnershipLogCompanion entry) => into(ownershipLog).insert(entry);

  Future<bool> updateEvent(OwnershipLogData entry) => update(ownershipLog).replace(entry);

  Future<void> deleteEvent(int id) =>
      (delete(ownershipLog)..where((l) => l.id.equals(id))).go();

  Future<void> deleteLogForBook(int bookId) =>
      (delete(ownershipLog)..where((l) => l.bookId.equals(bookId))).go();
}
