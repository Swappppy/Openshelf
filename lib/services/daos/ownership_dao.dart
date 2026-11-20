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

  /// Edits an entry and keeps the book's ownership status in line with its
  /// most recent remaining entry.
  Future<void> editEvent(OwnershipLogData entry) => transaction(() async {
        await updateEvent(entry);
        await _syncBookStatus(entry.bookId);
      });

  /// Removes an entry; the book falls back to the status of its most recent
  /// remaining entry, or none.
  Future<void> removeEvent(OwnershipLogData entry) => transaction(() async {
        await deleteEvent(entry.id);
        await _syncBookStatus(entry.bookId);
      });

  Future<void> _syncBookStatus(int bookId) async {
    final latest = await (select(ownershipLog)
          ..where((l) => l.bookId.equals(bookId))
          ..orderBy([
            (l) => OrderingTerm(expression: l.date, mode: OrderingMode.desc),
            (l) => OrderingTerm(expression: l.id, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
    await (update(db.books)..where((b) => b.id.equals(bookId)))
        .write(BooksCompanion(ownershipStatus: Value(latest?.eventType)));
  }

  Future<void> deleteLogForBook(int bookId) =>
      (delete(ownershipLog)..where((l) => l.bookId.equals(bookId))).go();
}
