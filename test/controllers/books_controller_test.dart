import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:openshelf/controllers/books_controller.dart';
import 'package:openshelf/controllers/database_provider.dart';
import 'package:openshelf/controllers/search_filters_controller.dart';
import 'package:openshelf/controllers/shared_prefs_provider.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/models/shelf.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await db.close();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('BooksController Tests', () {
    test('allBooksProvider emits books from database', () async {
      final container = createContainer();
      
      final completer = Completer<List<Book>>();
      container.listen(allBooksProvider, (prev, next) {
        next.whenData((data) {
          if (!completer.isCompleted) completer.complete(data);
        });
      }, fireImmediately: true);

      final initial = await completer.future.timeout(const Duration(seconds: 5));
      expect(initial, isEmpty);
      
      final nextData = Completer<List<Book>>();
      container.listen(allBooksProvider, (prev, next) {
        next.whenData((data) {
          if (data.isNotEmpty && !nextData.isCompleted) nextData.complete(data);
        });
      });

      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Controller Test Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.wantToRead),
      ));
      expect(bookId, isNotNull);

      final result = await nextData.future.timeout(const Duration(seconds: 5));
      expect(result.length, 1);
      expect(result.first.title, 'Controller Test Book');
    });

    test('filteredBooksProvider responds to filter changes', () async {
      final container = createContainer();

      await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Flutter Book'), 
        author: Value('A'),
        status: Value(ReadingStatus.wantToRead),
      ));
      await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Dart Book'), 
        author: Value('B'),
        status: Value(ReadingStatus.wantToRead),
      ));

      final completer = Completer<List<Book>>();
      container.listen(filteredBooksProvider, (prev, next) {
        next.whenData((data) {
          if (data.length == 2 && !completer.isCompleted) completer.complete(data);
        });
      }, fireImmediately: true);

      await completer.future.timeout(const Duration(seconds: 5));

      final filteredCompleter = Completer<List<Book>>();
      container.listen(filteredBooksProvider, (prev, next) {
        next.whenData((data) {
          if (data.length == 1 && !filteredCompleter.isCompleted) filteredCompleter.complete(data);
        });
      });

      container.read(searchFiltersProvider.notifier).setQuery('Flutter');

      final filtered = await filteredCompleter.future.timeout(const Duration(seconds: 5));
      expect(filtered.length, 1);
      expect(filtered.first.title, 'Flutter Book');
    });

    test('allShelvesWithStatsProvider calculates counts correctly', () async {
      final container = createContainer();

      final shelfId = await db.shelfDao.insertShelf(const ShelvesCompanion(
        name: Value('Finished Books'),
        filterStatus: Value('read'),
      ));

      await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Read Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.read),
        coverPath: Value('path.jpg'),
      ));
      await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Unread Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.wantToRead),
        coverPath: Value('path.jpg'),
      ));

      final completer = Completer<List<(Shelf, int, int)>>();
      container.listen(allShelvesWithStatsProvider, (prev, next) {
        next.whenData((data) {
          final shelfStat = data.firstWhere((s) => s.$1.id == shelfId, orElse: () => (data.first.$1, -1, -1));
          if (shelfStat.$2 == 1 && !completer.isCompleted) {
            completer.complete(data);
          }
        });
      }, fireImmediately: true);

      final stats = await completer.future.timeout(const Duration(seconds: 5));
      final shelfStat = stats.firstWhere((s) => s.$1.id == shelfId);
      
      expect(shelfStat.$2, 1); 
      expect(shelfStat.$3, 1); 
    });
  });
}
