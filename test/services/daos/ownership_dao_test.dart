import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/database.dart';

void main() {
  late AppDatabase db;
  late int bookId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    bookId = await db.into(db.books).insert(BooksCompanion.insert(
        title: 'T', author: 'A', status: ReadingStatus.read, ownershipStatus: const Value(OwnershipStatus.returned)));
    await db.ownershipDao.insertEvent(OwnershipLogCompanion.insert(
        bookId: bookId, eventType: OwnershipStatus.borrowed, personName: const Value('Ana'), date: DateTime(2024, 1, 1)));
    await db.ownershipDao.insertEvent(OwnershipLogCompanion.insert(
        bookId: bookId, eventType: OwnershipStatus.returned, date: DateTime(2024, 3, 1)));
  });

  tearDown(() => db.close());

  Future<List<OwnershipLogData>> entries() => db.ownershipDao.watchLogForBook(bookId).first;
  Future<OwnershipStatus?> bookStatus() async => (await db.bookDao.getBook(bookId))!.ownershipStatus;

  test('editing an entry updates it and the book follows the latest entry', () async {
    final latest = (await entries()).first;
    await db.ownershipDao.editEvent(latest.copyWith(eventType: OwnershipStatus.sold, personName: const Value('Luis')));

    final edited = (await entries()).first;
    expect((edited.eventType, edited.personName), (OwnershipStatus.sold, 'Luis'));
    expect(await bookStatus(), OwnershipStatus.sold);
  });

  test('editing an older entry leaves the book status alone', () async {
    final older = (await entries()).last;
    await db.ownershipDao.editEvent(older.copyWith(personName: const Value('Ana María')));

    expect((await entries()).last.personName, 'Ana María');
    expect(await bookStatus(), OwnershipStatus.returned);
  });

  test('moving an entry to a later date makes it the current status', () async {
    final older = (await entries()).last;
    await db.ownershipDao.editEvent(older.copyWith(date: DateTime(2024, 6, 1)));
    expect(await bookStatus(), OwnershipStatus.borrowed);
  });

  test('deleting the latest entry falls back to the previous one, then to none', () async {
    await db.ownershipDao.removeEvent((await entries()).first);
    expect((await entries()).length, 1);
    expect(await bookStatus(), OwnershipStatus.borrowed);

    await db.ownershipDao.removeEvent((await entries()).single);
    expect(await entries(), isEmpty);
    expect(await bookStatus(), isNull);
  });
}
