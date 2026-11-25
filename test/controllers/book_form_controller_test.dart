import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/native.dart';
import 'package:openshelf/controllers/book_form_controller.dart';
import 'package:openshelf/controllers/database_provider.dart';
import 'package:openshelf/controllers/reading_goals_controller.dart';
import 'package:openshelf/controllers/reading_log_controller.dart';
import 'package:openshelf/controllers/shelf_automation_controller.dart';
import 'package:openshelf/services/database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:openshelf/controllers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockReadingLogController extends Notifier<void> with Mock implements ReadingLogController {}
class MockShelfAutomationController extends Notifier<void> with Mock implements ShelfAutomationController {}

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
  late MockReadingLogController mockReadingLog;
  late MockShelfAutomationController mockShelfAuto;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase(NativeDatabase.memory());
    mockReadingLog = MockReadingLogController();
    mockShelfAuto = MockShelfAutomationController();
    
    registerFallbackValue(1); // For bookId
  });

  tearDown(() async {
    await db.close();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPrefsProvider.overrideWithValue(prefs),
        readingLogControllerProvider.overrideWith(() => mockReadingLog),
        shelfAutomationProvider.overrideWith(() => mockShelfAuto),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('BookFormController Tests', () {
    test('saveBook creates a new book and initial history', () async {
      final container = createContainer();
      final controller = container.read(bookFormControllerProvider);

      when(() => mockReadingLog.logPages(any(), any(), sections: any(named: 'sections'), date: any(named: 'date'), readNumber: any(named: 'readNumber'), backfill: any(named: 'backfill'))).thenAnswer((_) async {});
      when(() => mockShelfAuto.checkNoCoverShelf()).thenAnswer((_) async {});

      final bookId = await controller.saveBook(
        title: 'New Book',
        subtitle: 'Subtitle',
        author: 'Author',
        isbn: '12345',
        language: 'en',
        publisher: 'Pub',
        totalPages: 100,
        currentPage: 10,
        status: ReadingStatus.reading,
        ownershipStatus: OwnershipStatus.bought,
        format: BookFormat.paperback,
        rating: 4.0,
        notes: 'Notes',
        description: 'Desc',
        coverPath: null,
        collectionId: null,
        collectionName: null,
        collectionNumber: null,
        publishYear: 2023,
        copies: 1,
        paginationConfig: null,
        startedAt: DateTime(2023, 1, 1),
        finishedAt: null,
        imprintId: null,
        tagIds: [],
        collections: [],
        personName: null,
        unknownAuthorLabel: 'Unknown',
      );

      final book = await db.bookDao.getBook(bookId);
      expect(book!.title, 'New Book');
      expect(book.status, ReadingStatus.reading);
      expect(book.currentPage, 10);

      // Verify history creation
      final history = await db.readHistoryDao.watchHistoryForBook(bookId).first;
      expect(history.length, 1);
      expect(history.first.progress, 10);

      // Verify logPages call
      verify(() => mockReadingLog.logPages(bookId, 10, sections: null, date: null, readNumber: 1, backfill: false)).called(1);
      verify(() => mockShelfAuto.checkNoCoverShelf()).called(1);
    });

    test('saveBook updates existing book and syncs progress', () async {
      final container = createContainer();
      final controller = container.read(bookFormControllerProvider);

      final existingId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Existing'),
        author: Value('Author'),
        status: Value(ReadingStatus.reading),
        currentPage: Value(10),
        totalPages: Value(100),
      ));
      
      await db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: existingId,
        readNumber: 1,
        startedAt: Value(DateTime(2023, 1, 1)),
        progress: const Value(10),
      ));

      final existing = await db.bookDao.getBook(existingId);

      when(() => mockReadingLog.logPages(any(), any(), sections: any(named: 'sections'), date: any(named: 'date'), readNumber: any(named: 'readNumber'), backfill: any(named: 'backfill'))).thenAnswer((_) async {});
      when(() => mockShelfAuto.checkNoCoverShelf()).thenAnswer((_) async {});

      await controller.saveBook(
        existingBook: existing,
        title: 'Existing Updated',
        subtitle: null,
        author: 'Author',
        isbn: null,
        language: null,
        publisher: null,
        totalPages: 100,
        currentPage: 25,
        status: ReadingStatus.reading,
        ownershipStatus: null,
        format: null,
        rating: null,
        notes: null,
        description: null,
        coverPath: null,
        collectionId: null,
        collectionName: null,
        collectionNumber: null,
        publishYear: null,
        copies: 1,
        paginationConfig: null,
        startedAt: DateTime(2023, 1, 1),
        finishedAt: null,
        imprintId: null,
        tagIds: [],
        collections: [],
        personName: null,
        unknownAuthorLabel: 'Unknown',
      );

      final updated = await db.bookDao.getBook(existingId);
      expect(updated!.title, 'Existing Updated');
      expect(updated.currentPage, 25);

      final history = await db.readHistoryDao.watchHistoryForBook(existingId).first;
      expect(history.first.progress, 25);

      // Delta is 25 - 10 = 15
      verify(() => mockReadingLog.logPages(existingId, 15, sections: null, date: null, readNumber: 1, backfill: false)).called(1);
    });

    test('saveBook registers OwnershipLog event on change', () async {
      final container = createContainer();
      final controller = container.read(bookFormControllerProvider);

      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Ownership Test'),
        author: Value('Author'),
        status: Value(ReadingStatus.wantToRead),
        ownershipStatus: Value(OwnershipStatus.other),
      ));
      final book = await db.bookDao.getBook(bookId);

      when(() => mockReadingLog.logPages(any(), any(), sections: any(named: 'sections'), date: any(named: 'date'), readNumber: any(named: 'readNumber'), backfill: any(named: 'backfill'))).thenAnswer((_) async {});
      when(() => mockShelfAuto.checkNoCoverShelf()).thenAnswer((_) async {});

      await controller.saveBook(
        existingBook: book,
        title: 'Ownership Test',
        subtitle: null,
        author: 'Author',
        isbn: null,
        language: null,
        publisher: null,
        totalPages: 100,
        currentPage: 0,
        status: ReadingStatus.wantToRead,
        ownershipStatus: OwnershipStatus.bought,
        format: null,
        rating: null,
        notes: null,
        description: null,
        coverPath: null,
        collectionId: null,
        collectionName: null,
        collectionNumber: null,
        publishYear: null,
        copies: 1,
        paginationConfig: null,
        startedAt: null,
        finishedAt: null,
        imprintId: null,
        tagIds: [],
        collections: [],
        personName: 'Buyer',
        unknownAuthorLabel: 'Unknown',
      );

      final logs = await db.ownershipDao.watchLogForBook(bookId).first;
      expect(logs.length, 1);
      expect(logs.first.eventType, OwnershipStatus.bought);
      expect(logs.first.personName, 'Buyer');
    });

    test('saveBook for new book marked Read with past dates logs on finish date and not today, keeping current goal unchanged', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPrefsProvider.overrideWithValue(prefs),
          shelfAutomationProvider.overrideWith(() => mockShelfAuto),
        ],
      );
      addTearDown(container.dispose);

      when(() => mockShelfAuto.checkNoCoverShelf()).thenAnswer((_) async {});

      final controller = container.read(bookFormControllerProvider);

      // Create a pages goal for the current year
      final now = DateTime.now();
      final currentYearStart = DateTime(now.year, 1, 1);
      final currentYearEnd = DateTime(now.year, 12, 31, 23, 59, 59);
      final goalId = await db.goalDao.insertGoal(ReadingGoalsCompanion.insert(
        title: 'Pages Goal',
        type: 'pages',
        targetValue: 1000,
        startDate: currentYearStart,
        endDate: currentYearEnd,
      ));

      final pastDate = DateTime(now.year - 2, 5, 10);
      final pastFinishDate = DateTime(now.year - 2, 5, 20);

      final bookId = await controller.saveBook(
        title: 'Past Read Book',
        subtitle: null,
        author: 'Author',
        isbn: null,
        language: null,
        publisher: null,
        totalPages: 250,
        currentPage: 250,
        status: ReadingStatus.read,
        ownershipStatus: null,
        format: null,
        rating: null,
        notes: null,
        description: null,
        coverPath: null,
        collectionId: null,
        collectionName: null,
        collectionNumber: null,
        publishYear: 2020,
        copies: 1,
        paginationConfig: null,
        startedAt: pastDate,
        finishedAt: pastFinishDate,
        imprintId: null,
        tagIds: [],
        collections: [],
        personName: null,
        unknownAuthorLabel: 'Unknown',
      );

      // Check log entry
      final logs = await db.logDao.watchLogs().first;
      expect(logs.length, 1);
      final log = logs.first;
      expect(log.bookId, bookId);
      expect(log.pagesRead, 250);
      expect(log.date, DateTime(pastFinishDate.year, pastFinishDate.month, pastFinishDate.day));

      // Ensure no log entries for today
      final today = DateTime(now.year, now.month, now.day);
      final todayLogs = logs.where((l) => l.date == today);
      expect(todayLogs.isEmpty, true);

      // Verify pages goal progress for current period has not changed (remains 0)
      final goalProgress = await nextValue(container, goalProgressProvider(goalId));
      expect(goalProgress, 0);
    });
  });

  group('resolveEditionKey', () {
    const key = '/books/OL7353617M';

    test('keeps the link when the ISBN is unchanged (formatting ignored)', () {
      expect(BookFormController.resolveEditionKey(key: key, originalIsbn: '978-0-14-044913-6', newIsbn: '9780140449136'), key);
    });

    test('drops the link when the ISBN is replaced or removed', () {
      expect(BookFormController.resolveEditionKey(key: key, originalIsbn: '9780140449136', newIsbn: '9788491050292'), isNull);
      expect(BookFormController.resolveEditionKey(key: key, originalIsbn: '9780140449136', newIsbn: ''), isNull);
    });

    test('keeps the link when an ISBN is added to a record that had none', () {
      expect(BookFormController.resolveEditionKey(key: key, originalIsbn: null, newIsbn: '9780140449136'), key);
    });

    test('no key stays no key', () {
      expect(BookFormController.resolveEditionKey(key: null, originalIsbn: '978', newIsbn: '978'), isNull);
    });
  });
}
