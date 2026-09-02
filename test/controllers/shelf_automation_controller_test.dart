import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:openshelf/controllers/shelf_automation_controller.dart';
import 'package:openshelf/controllers/database_provider.dart';
import 'package:openshelf/controllers/shared_prefs_provider.dart';
import 'package:openshelf/controllers/app_settings_controller.dart';
import 'package:openshelf/controllers/books_controller.dart';
import 'package:openshelf/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

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

  group('ShelfAutomationController Tests', () {
    test('Creates auto-shelf when books without covers exist and setting is enabled', () async {
      final container = createContainer();
      
      // Ensure we are listening to the automation controller
      container.listen(shelfAutomationProvider, (p, n) {});

      // Add a book without cover
      await db.bookDao.insertBook(const BooksCompanion(
        title: Value('No Cover Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.wantToRead),
      ));

      // Wait for allBooksProvider to emit the update
      await container.read(allBooksProvider.future);
      
      // Wait for the microtask and async DB operations inside checkNoCoverShelf
      // We use multiple delayed to ensure microtasks and events are processed
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      final shelf = await db.shelfDao.getShelfByName(ShelfAutomationController.internalName);
      expect(shelf, isNotNull);
      expect(shelf!.filterNoCover, true);
    });

    test('Deletes auto-shelf when all books have covers', () async {
      final container = createContainer();
      container.listen(shelfAutomationProvider, (p, n) {});

      // 1. Create shelf first
      await db.shelfDao.insertShelf(const ShelvesCompanion(
        name: Value(ShelfAutomationController.internalName),
        filterNoCover: Value(true),
      ));

      // 2. Add book WITH cover
      await db.bookDao.insertBook(const BooksCompanion(
        title: Value('With Cover Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.wantToRead),
        coverPath: Value('some/path.jpg'),
      ));

      await container.read(allBooksProvider.future);
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      final shelf = await db.shelfDao.getShelfByName(ShelfAutomationController.internalName);
      expect(shelf, isNull);
    });

    test('Deletes auto-shelf when setting is disabled', () async {
      final container = createContainer();
      container.listen(shelfAutomationProvider, (p, n) {});

      // 1. Create shelf and add book without cover
      await db.shelfDao.insertShelf(const ShelvesCompanion(
        name: Value(ShelfAutomationController.internalName),
        filterNoCover: Value(true),
      ));
      await db.bookDao.insertBook(const BooksCompanion(
        title: Value('No Cover'),
        author: Value('Author'),
        status: Value(ReadingStatus.wantToRead),
      ));

      await container.read(allBooksProvider.future);
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      expect(await db.shelfDao.getShelfByName(ShelfAutomationController.internalName), isNotNull);

      // 2. Disable setting
      container.read(appSettingsProvider.notifier).setAutoNoCoverShelf(false);

      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      final shelf = await db.shelfDao.getShelfByName(ShelfAutomationController.internalName);
      expect(shelf, isNull);
    });

    test('Handles pending checks and concurrency', () async {
      final container = createContainer();
      final controller = container.read(shelfAutomationProvider.notifier);

      // Trigger multiple times rapidly
      controller.checkNoCoverShelf();
      controller.checkNoCoverShelf();
      controller.checkNoCoverShelf();

      await Future.delayed(const Duration(milliseconds: 200));
      
      // Should not crash and should complete
      final shelf = await db.shelfDao.getShelfByName(ShelfAutomationController.internalName);
      // Since there are no books, it should be null if it was created/checked
      expect(shelf, isNull);
    });
  });
}
