import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/native.dart';
import 'package:openshelf/controllers/book_form_controller.dart';
import 'package:openshelf/controllers/database_provider.dart';
import 'package:openshelf/controllers/reading_log_controller.dart';
import 'package:openshelf/controllers/shelf_automation_controller.dart';
import 'package:openshelf/services/database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

class MockReadingLogController extends Notifier<void> with Mock implements ReadingLogController {}
class MockShelfAutomationController extends Notifier<void> with Mock implements ShelfAutomationController {}

void main() {
  late AppDatabase db;
  late MockReadingLogController mockReadingLog;
  late MockShelfAutomationController mockShelfAuto;

  setUp(() {
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

      when(() => mockReadingLog.logPages(any(), any(), any())).thenAnswer((_) async {});
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
      verify(() => mockReadingLog.logPages(bookId, 10)).called(1);
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

      when(() => mockReadingLog.logPages(any(), any(), any())).thenAnswer((_) async {});
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
      verify(() => mockReadingLog.logPages(existingId, 15)).called(1);
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

      when(() => mockReadingLog.logPages(any(), any(), any())).thenAnswer((_) async {});
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
  });
}
