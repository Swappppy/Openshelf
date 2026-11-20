import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/native.dart';
import 'package:openshelf/controllers/reading_session_controller.dart';
import 'package:openshelf/controllers/database_provider.dart';
import 'package:openshelf/controllers/reading_log_controller.dart';
import 'package:openshelf/services/database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

// Delegate to a mock to avoid Riverpod internal initialization issues in Mock class
abstract class ReadingLogService {
  Future<void> logPages(int bookId, int delta, [List<String>? sectionLabels]);
}

class MockReadingLogService extends Mock implements ReadingLogService {}

class DelegatingReadingLogController extends ReadingLogController {
  final ReadingLogService mock;
  DelegatingReadingLogController(this.mock);

  @override
  void build() {}

  @override
  Future<void> logPages(int bookId, int delta, [List<String>? sectionLabels]) {
    return mock.logPages(bookId, delta, sectionLabels);
  }
}

void main() {
  late AppDatabase db;
  late MockReadingLogService mockService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    mockService = MockReadingLogService();
    registerFallbackValue([]);
  });

  tearDown(() async {
    await db.close();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        readingLogControllerProvider.overrideWith(() => DelegatingReadingLogController(mockService)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ReadingSessionController Tests', () {
    test('resetting a re-read to 0 keeps earlier completed reads and status', () async {
      final container = createContainer();
      final controller = container.read(readingSessionControllerProvider);
      when(() => mockService.logPages(any(), any(), any())).thenAnswer((_) async {});

      final id = await db.into(db.books).insert(BooksCompanion.insert(
        title: 'T', author: 'A', status: ReadingStatus.reading, totalPages: const Value(100), currentPage: const Value(50)));
      await db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: id, readNumber: 1, startedAt: Value(DateTime(2025)), finishedAt: Value(DateTime(2025, 2)), progress: const Value(100)));
      await db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: id, readNumber: 2, startedAt: Value(DateTime(2026)), progress: const Value(50)));

      final book = (await db.bookDao.getBook(id))!;
      await controller.updatePageProgress(book: book, newPage: 0, newSegProgress: {}, sectionLabelGetter: (i) => '$i');

      final history = await db.readHistoryDao.getHistoryForBook(id);
      expect(history.map((h) => h.readNumber), [1], reason: 'only the re-read is undone');
      final updated = (await db.bookDao.getBook(id))!;
      expect(updated.status, ReadingStatus.read);
      expect(updated.finishedAt, DateTime(2025, 2));
    });

    test('updatePageProgress - transition to reading status', () async {
      final container = createContainer();
      final controller = container.read(readingSessionControllerProvider);

      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Test Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.wantToRead),
        totalPages: Value(100),
      ));
      final book = await db.bookDao.getBook(bookId);

      when(() => mockService.logPages(any(), any(), any())).thenAnswer((_) async {});

      await controller.updatePageProgress(
        book: book!,
        newPage: 10,
        newSegProgress: {},
        sectionLabelGetter: (i) => 'Section $i',
      );

      final updatedBook = await db.bookDao.getBook(bookId);
      expect(updatedBook!.status, ReadingStatus.reading);
      expect(updatedBook.currentPage, 10);
      expect(updatedBook.startedAt, isNotNull);

      verify(() => mockService.logPages(bookId, 10, any())).called(1);
    });

    test('updatePageProgress - completion logic', () async {
      final container = createContainer();
      final controller = container.read(readingSessionControllerProvider);

      final bookId = await db.bookDao.insertBook(BooksCompanion(
        title: const Value('To Complete'),
        author: const Value('Author'),
        status: const Value(ReadingStatus.reading),
        totalPages: const Value(100),
        currentPage: const Value(90),
        startedAt: Value(DateTime(2023, 1, 1)),
      ));
      final book = await db.bookDao.getBook(bookId);
      
      await db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: bookId,
        readNumber: 1,
        startedAt: Value(DateTime(2023, 1, 1)),
        progress: const Value(90),
      ));

      when(() => mockService.logPages(any(), any(), any())).thenAnswer((_) async {});

      await controller.updatePageProgress(
        book: book!,
        newPage: 100,
        newSegProgress: {},
        sectionLabelGetter: (i) => 'Section $i',
      );

      final updatedBook = await db.bookDao.getBook(bookId);
      expect(updatedBook!.status, ReadingStatus.read);
      expect(updatedBook.currentPage, 100);
      expect(updatedBook.finishedAt, isNotNull);

      verify(() => mockService.logPages(bookId, 10, any())).called(1);
    });

    test('updatePageProgress - progress reset to 0', () async {
      final container = createContainer();
      final controller = container.read(readingSessionControllerProvider);

      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.reading),
        totalPages: Value(100),
        currentPage: Value(10),
      ));
      final book = await db.bookDao.getBook(bookId);

      await db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: bookId,
        readNumber: 1,
        startedAt: Value(DateTime.now()),
        progress: const Value(10),
      ));

      when(() => mockService.logPages(any(), any(), any())).thenAnswer((_) async {});

      await controller.updatePageProgress(
        book: book!,
        newPage: 0,
        newSegProgress: {},
        sectionLabelGetter: (i) => 'Section $i',
      );

      final updatedBook = await db.bookDao.getBook(bookId);
      expect(updatedBook!.status, ReadingStatus.wantToRead);
      expect(updatedBook.currentPage, 0);
      expect(updatedBook.startedAt, isNull);

      final history = await db.readHistoryDao.watchHistoryForBook(bookId).first;
      expect(history, isEmpty);
    });

    test('startNewReading - session numbering', () async {
      final container = createContainer();
      final controller = container.read(readingSessionControllerProvider);

      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Re-read Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.read),
        totalPages: Value(200),
      ));
      
      await db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: bookId,
        readNumber: 1,
        startedAt: Value(DateTime(2023, 1, 1)),
        finishedAt: Value(DateTime(2023, 1, 10)),
        progress: const Value(200),
      ));

      final book = await db.bookDao.getBook(bookId);
      when(() => mockService.logPages(any(), any(), any())).thenAnswer((_) async {});

      await controller.startNewReading(
        book: book!,
        sectionLabelGetter: (i) => 'Section $i',
      );

      final history = await db.readHistoryDao.watchHistoryForBook(bookId).first;
      expect(history.length, 2);
      expect(history.last.readNumber, 2);
      expect(history.last.progress, 1); 
      
      final updatedBook = await db.bookDao.getBook(bookId);
      expect(updatedBook!.status, ReadingStatus.reading);
    });
  });
}
