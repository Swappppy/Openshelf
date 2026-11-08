import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/services/daos/search_history_dao.dart';

void main() {
  late AppDatabase db;
  late SearchHistoryDao searchHistoryDao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    searchHistoryDao = db.searchHistoryDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('SearchHistoryDao Tests', () {
    test('insertEntry and watchAllHistory ordering by timestamp descending', () async {
      await searchHistoryDao.insertEntry(SearchHistoryCompanion.insert(
        query: '9780132350884',
        type: 'batch_scan',
        status: 'failed',
        timestamp: DateTime(2023, 1, 1, 10, 0),
      ));

      await searchHistoryDao.insertEntry(SearchHistoryCompanion.insert(
        query: 'Clean Code',
        type: 'text_search',
        status: 'success',
        title: const Value('Clean Code'),
        author: const Value('Robert C. Martin'),
        timestamp: DateTime(2023, 1, 1, 11, 0),
      ));

      final history = await searchHistoryDao.watchAllHistory().first;
      expect(history.length, 2);
      // Most recent first (11:00 before 10:00)
      expect(history[0].query, 'Clean Code');
      expect(history[0].status, 'success');
      expect(history[1].query, '9780132350884');
      expect(history[1].status, 'failed');
    });

    test('updateEntry status transition from failed to success', () async {
      final id = await searchHistoryDao.insertEntry(SearchHistoryCompanion.insert(
        query: '9780132350884',
        type: 'isbn_scan',
        status: 'failed',
        timestamp: DateTime.now(),
      ));

      final entry = (await searchHistoryDao.getAllHistory()).firstWhere((h) => h.id == id);
      expect(entry.status, 'failed');

      await searchHistoryDao.updateEntry(entry.copyWith(
        status: 'success',
        title: const Value('Clean Code'),
      ));

      final updated = (await searchHistoryDao.getAllHistory()).firstWhere((h) => h.id == id);
      expect(updated.status, 'success');
      expect(updated.title, 'Clean Code');
    });

    test('deleteEntry and clearHistory work correctly', () async {
      await searchHistoryDao.insertEntry(SearchHistoryCompanion.insert(
        query: 'Query 1',
        type: 'text_search',
        status: 'success',
        timestamp: DateTime.now(),
      ));

      await searchHistoryDao.insertEntry(SearchHistoryCompanion.insert(
        query: 'Query 2',
        type: 'text_search',
        status: 'failed',
        timestamp: DateTime.now(),
      ));

      var history = await searchHistoryDao.getAllHistory();
      expect(history.length, 2);

      await searchHistoryDao.deleteEntry(history.first.id);
      history = await searchHistoryDao.getAllHistory();
      expect(history.length, 1);

      await searchHistoryDao.clearHistory();
      history = await searchHistoryDao.getAllHistory();
      expect(history, isEmpty);
    });
  });
}
