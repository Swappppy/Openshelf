import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/services/daos/read_history_dao.dart';

void main() {
  late AppDatabase db;
  late ReadHistoryDao readHistoryDao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    readHistoryDao = db.readHistoryDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('ReadHistoryDao Tests', () {
    test('insertRead and watchHistoryForBook ordering', () async {
      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.reading),
      ));

      // Insert out of order
      await readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: bookId,
        readNumber: 2,
        startedAt: Value(DateTime(2023, 2, 1)),
        progress: const Value(20),
      ));

      await readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: bookId,
        readNumber: 1,
        startedAt: Value(DateTime(2023, 1, 1)),
        progress: const Value(10),
      ));

      final history = await readHistoryDao.watchHistoryForBook(bookId).first;
      expect(history.length, 2);
      expect(history[0].readNumber, 1);
      expect(history[1].readNumber, 2);
    });

    test('updateRead and retrieval', () async {
      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.reading),
      ));

      await readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: bookId,
        readNumber: 1,
        startedAt: Value(DateTime(2023, 1, 1)),
        progress: const Value(10),
      ));

      final entry = await readHistoryDao.getRead(bookId, 1);
      expect(entry, isNotNull);
      
      final updated = await readHistoryDao.updateRead(entry!.copyWith(progress: 50));
      expect(updated, isTrue);

      final fetched = await readHistoryDao.getRead(bookId, 1);
      expect(fetched!.progress, 50);
    });

    test('deleteReadByNumber removes specific entry', () async {
      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.reading),
      ));

      await readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: bookId,
        readNumber: 1,
        startedAt: Value(DateTime(2023, 1, 1)),
        progress: const Value(10),
      ));
      
      await readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: bookId,
        readNumber: 2,
        startedAt: Value(DateTime(2023, 2, 1)),
        progress: const Value(20),
      ));

      await readHistoryDao.deleteReadByNumber(bookId, 1);

      final history = await readHistoryDao.watchHistoryForBook(bookId).first;
      expect(history.length, 1);
      expect(history.first.readNumber, 2);
    });

    test('deleteHistoryForBook clears all', () async {
      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.reading),
      ));

      await readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: bookId,
        readNumber: 1,
        startedAt: Value(DateTime(2023, 1, 1)),
        progress: const Value(10),
      ));

      await readHistoryDao.deleteHistoryForBook(bookId);
      final history = await readHistoryDao.watchHistoryForBook(bookId).first;
      expect(history, isEmpty);
    });
  });
}
