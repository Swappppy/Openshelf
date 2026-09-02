import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:openshelf/controllers/database_provider.dart';
import 'package:openshelf/controllers/reading_goals_controller.dart';
import 'package:openshelf/services/database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

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
}
