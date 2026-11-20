import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/controllers/database_provider.dart';
import 'package:openshelf/controllers/reading_goals_controller.dart';
import 'package:openshelf/controllers/reading_log_controller.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/utils/date_range.dart';

Future<T> nextValue<T>(ProviderContainer container, StreamProvider<T> provider) {
  final completer = Completer<T>();
  container.listen(provider, (prev, next) {
    next.whenData((data) {
      if (!completer.isCompleted) completer.complete(data);
    });
  }, fireImmediately: true);
  return completer.future.timeout(const Duration(seconds: 5));
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int bookId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    bookId = await db.into(db.books).insert(BooksCompanion.insert(title: 'T', author: 'A', status: ReadingStatus.read));
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  // Goals are created with midnight dates from the date picker.
  Future<int> goal(String type) => db.goalDao.insertGoal(ReadingGoalsCompanion.insert(
      title: 'G', type: type, targetValue: 10, startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 12, 31)));

  test('DayRange.contains includes both boundary days', () {
    final start = DateTime(2024, 1, 1);
    final end = DateTime(2024, 12, 31);
    expect(DayRange.contains(DateTime(2024, 1, 1), start, end), isTrue);
    expect(DayRange.contains(DateTime(2024, 12, 31, 23, 59), start, end), isTrue);
    expect(DayRange.contains(DateTime(2023, 12, 31, 23, 59), start, end), isFalse);
    expect(DayRange.contains(DateTime(2025, 1, 1), start, end), isFalse);
  });

  test('pages goal counts entries on the first and last day', () async {
    final id = await goal('pages');
    for (final d in [DateTime(2023, 12, 31), DateTime(2024, 1, 1), DateTime(2024, 12, 31), DateTime(2025, 1, 1)]) {
      await db.logDao.insertLog(ReadingLogCompanion.insert(bookId: bookId, date: d, pagesRead: 10));
    }
    expect(await nextValue(container, goalProgressProvider(id)), 20);
  });

  test('books goal counts a book finished during the last day', () async {
    final id = await goal('books');
    await (db.update(db.books)..where((b) => b.id.equals(bookId)))
        .write(BooksCompanion(finishedAt: Value(DateTime(2024, 12, 31, 18))));
    expect(await nextValue(container, goalProgressProvider(id)), 1);
  });

  test('logPages keeps whole-book and tracked entries of the same day apart', () async {
    final log = container.read(readingLogControllerProvider.notifier);
    final day = DateTime(2024, 5, 1);
    await log.logPages(bookId, 30, date: day, readNumber: 1);
    await log.logPages(bookId, 200, date: day, readNumber: 1, backfill: true);
    await log.logPages(bookId, 5, date: day, readNumber: 1);

    final logs = await db.select(db.readingLog).get();
    expect(logs.length, 2);
    expect(logs.firstWhere((l) => !l.isBackfill).pagesRead, 35);
    expect(logs.firstWhere((l) => l.isBackfill).pagesRead, 200);
  });
}
