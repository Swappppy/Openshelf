import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/services/daos/log_dao.dart';

void main() {
  late AppDatabase db;
  late LogDao logDao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    logDao = db.logDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('LogDao Tests', () {
    test('insertLog and watchLogs', () async {
      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.reading),
      ));

      final date = DateTime(2023, 9, 1);
      final id = await logDao.insertLog(ReadingLogCompanion.insert(
        bookId: bookId,
        date: date,
        pagesRead: 15,
      ));
      expect(id, isNotNull);

      final logs = await logDao.watchLogs().first;
      expect(logs.length, 1);
      expect(logs.first.pagesRead, 15);
      expect(logs.first.bookId, bookId);
    });

    test('updateLog and deleteLog', () async {
      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.reading),
      ));

      await logDao.insertLog(ReadingLogCompanion.insert(
        bookId: bookId,
        date: DateTime(2023, 9, 1),
        pagesRead: 10,
      ));

      var currentLogs = await logDao.watchLogs().first;
      final entry = currentLogs.first;
      
      await logDao.updateLog(entry.copyWith(pagesRead: 25));
      currentLogs = await logDao.watchLogs().first;
      expect(currentLogs.first.pagesRead, 25);

      await logDao.deleteLog(entry.id);
      currentLogs = await logDao.watchLogs().first;
      expect(currentLogs, isEmpty);
    });

    test('watchLogForBook returns entries for specific book only', () async {
      final b1 = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('B1'), author: Value('A'), status: Value(ReadingStatus.reading),
      ));
      final b2 = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('B2'), author: Value('A'), status: Value(ReadingStatus.reading),
      ));

      await logDao.insertLog(ReadingLogCompanion.insert(
        bookId: b1, date: DateTime(2023, 9, 1), pagesRead: 10,
      ));
      await logDao.insertLog(ReadingLogCompanion.insert(
        bookId: b2, date: DateTime(2023, 9, 1), pagesRead: 20,
      ));

      final b1Logs = await logDao.watchLogForBook(b1).first;
      expect(b1Logs.length, 1);
      expect(b1Logs.first.pagesRead, 10);
      expect(b1Logs.first.bookId, b1);
    });
  });
}
