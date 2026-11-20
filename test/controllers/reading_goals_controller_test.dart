import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:openshelf/controllers/database_provider.dart';
import 'package:openshelf/controllers/reading_goals_controller.dart';
import 'package:openshelf/controllers/reading_log_controller.dart';
import 'package:openshelf/services/database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:openshelf/utils/date_range.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<T> nextValue<T>(ProviderContainer container, StreamProvider<T> provider) {
    final completer = Completer<T>();
    container.listen(provider, (prev, next) {
      next.whenData((data) {
        if (!completer.isCompleted) completer.complete(data);
      });
    }, fireImmediately: true);
    return completer.future.timeout(const Duration(seconds: 5));
  }

  group('ReadingGoalsController Tests', () {
    test('addGoal inserts goal into db', () async {
      final container = createContainer();
      final controller = container.read(readingGoalsControllerProvider.notifier);

      final now = DateTime.now();
      await controller.addGoal(ReadingGoalsCompanion.insert(
        title: 'New Goal',
        type: 'books',
        targetValue: 12,
        startDate: now,
        endDate: now.add(const Duration(days: 365)),
      ));

      final goals = await db.goalDao.watchAllGoals().first;
      expect(goals.length, 1);
      expect(goals.first.title, 'New Goal');
      expect(goals.first.targetValue, 12);
    });

    test('goalProgressProvider calculates books read progress', () async {
      final container = createContainer();
      
      final goalId = await db.goalDao.insertGoal(ReadingGoalsCompanion.insert(
        title: 'Goal 2023',
        type: 'books',
        targetValue: 10,
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2023, 12, 31),
      ));

      // Book read in 2023
      await db.bookDao.insertBook(BooksCompanion.insert(
        title: 'Book 1',
        author: 'Author',
        status: ReadingStatus.read,
        finishedAt: Value(DateTime(2023, 6, 1)),
      ));

      final progress = await nextValue(container, goalProgressProvider(goalId));
      expect(progress, 1);
    });

    test('goalProgressProvider calculates pages read progress', () async {
      final container = createContainer();
      
      final goalId = await db.goalDao.insertGoal(ReadingGoalsCompanion.insert(
        title: 'Pages Goal',
        type: 'pages',
        targetValue: 1000,
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2023, 12, 31),
      ));

      final bookId = await db.bookDao.insertBook(BooksCompanion.insert(
        title: 'Book',
        author: 'Author',
        status: ReadingStatus.reading,
      ));

      // Logs in 2023
      await db.logDao.insertLog(ReadingLogCompanion.insert(
        bookId: bookId,
        date: DateTime(2023, 1, 15),
        pagesRead: 50,
      ));
      await db.logDao.insertLog(ReadingLogCompanion.insert(
        bookId: bookId,
        date: DateTime(2023, 2, 1),
        pagesRead: 150,
      ));

      final progress = await nextValue(container, goalProgressProvider(goalId));
      expect(progress, 200);
    });

    test('goalProgressProvider handles shelf goals', () async {
      final container = createContainer();
      
      final shelfId = await db.shelfDao.insertShelf(ShelvesCompanion.insert(
        name: 'Sci-Fi Shelf',
        filterQuery: const Value('Sci-Fi'),
        filterStatus: const Value('read'), // match status
      ));

      final goalId = await db.goalDao.insertGoal(ReadingGoalsCompanion.insert(
        title: 'Shelf Goal',
        type: 'shelf',
        targetValue: 5,
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2023, 12, 31),
        shelfId: Value(shelfId),
      ));

      // Book matching shelf and status read
      await db.bookDao.insertBook(BooksCompanion.insert(
        title: 'Sci-Fi Adventure',
        author: 'Author',
        status: ReadingStatus.read,
      ));

      final progress = await nextValue(container, goalProgressProvider(goalId));
      expect(progress, 1);
    });
  });

  group('Goal periods use whole days', () {
    late ProviderContainer container;
    late int bookId;

    setUp(() async {
      container = createContainer();
      bookId = await db.into(db.books).insert(BooksCompanion.insert(title: 'T', author: 'A', status: ReadingStatus.read));
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
  });
}
