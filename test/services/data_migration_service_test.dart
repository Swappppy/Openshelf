import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/services/data_migration_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DataMigrationService migrationService;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    migrationService = DataMigrationService(db);
    tempDir = await Directory.systemTemp.createTemp('openshelf_test');
    
    // Mock path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (methodCall) async {
        if (methodCall.method == 'getTemporaryDirectory' || methodCall.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      },
    );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  group('DataMigrationService Tests', () {
    test('Full Backup and Restore (ZIP)', () async {
      // 1. Populate DB
      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Backup Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.reading),
        isbn: Value('987654321'),
      ));
      
      final tagId = await db.tagDao.insertTag(const TagsCompanion(
        name: Value('History'),
        type: Value(TagType.tag),
      ));
      await db.tagDao.setBookTags(bookId, [tagId]);
      
      await db.shelfDao.insertShelf(const ShelvesCompanion(
        name: Value('My Shelf'),
        filterStatus: Value('reading'),
      ));

      // 2. Export to ZIP
      final zipFile = await migrationService.createBackupFile(includeCovers: false);
      expect(await zipFile.exists(), true);
      expect(zipFile.lengthSync(), greaterThan(0));

      // 3. Import into a NEW DB
      final db2 = AppDatabase(NativeDatabase.memory());
      final migrationService2 = DataMigrationService(db2);
      
      final count = await migrationService2.importFromBackup(zipFile);
      expect(count, 1);
      
      // 4. Verify DB2
      final books = await db2.bookDao.watchAllBooks().first;
      expect(books.length, 1);
      expect(books.first.title, 'Backup Book');
      expect(books.first.isbn, '987654321');
      
      final shelves = await db2.shelfDao.watchAllShelves().first;
      expect(shelves.any((s) => s.name == 'My Shelf'), true);
      
      final tags = await db2.tagDao.watchTagsForBook(books.first.id).first;
      expect(tags.any((t) => t.name == 'History'), true);
      
      await db2.close();
    });

    test('Import Books CSV only', () async {
      // 1. Create a dummy CSV content
      final header = 'id,title,subtitle,author,isbn,language,status,createdAt\n';
      final row = '1,CSV Book,Sub,Author,11111,en,read,2023-01-01T00:00:00.000\n';
      final csvFile = File(p.join(tempDir.path, 'books.csv'))..writeAsStringSync(header + row);

      // 2. Import
      final count = await migrationService.importFromBackup(csvFile);
      expect(count, 1);

      final books = await db.bookDao.watchAllBooks().first;
      expect(books.first.title, 'CSV Book');
      expect(books.first.status, ReadingStatus.read);
    });
  });
}
