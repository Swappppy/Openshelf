import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/services/data_migration_service.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DataMigrationService migrationService;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    migrationService = DataMigrationService(db);
    tempDir = await Directory.systemTemp.createTemp('openshelf_edge_test');
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (methodCall) async {
        return tempDir.path;
      },
    );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('DataMigrationService Edge Cases', () {
    test('Importing file with unsupported extension throws', () async {
      final invalidFile = File(p.join(tempDir.path, 'test.txt'))..writeAsStringSync('dummy');
      
      expect(() => migrationService.importFromBackup(invalidFile), throwsException);
    });

    test('ZIP import fails if books.csv is missing', () async {
      final archive = Archive();
      archive.addFile(ArchiveFile('other.csv', 5, [1, 2, 3, 4, 5]));
      final zipData = ZipEncoder().encode(archive);
      final zipFile = File(p.join(tempDir.path, 'bad_backup.zip'))..writeAsBytesSync(zipData);

      expect(() => migrationService.importFromBackup(zipFile), throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('books.csv missing'))));
    });

    test('CSV import handles missing non-mandatory columns', () async {
      // Minimal CSV with only title and author
      final csvContent = 'title,author\nMinimal Book,John Doe';
      final csvFile = File(p.join(tempDir.path, 'minimal.csv'))..writeAsStringSync(csvContent);

      final count = await migrationService.importFromBackup(csvFile);
      expect(count, 1);

      final books = await db.bookDao.watchAllBooks().first;
      expect(books.first.title, 'Minimal Book');
      expect(books.first.author, 'John Doe');
      expect(books.first.status, ReadingStatus.wantToRead); // Default
    });

    test('CSV import handles malformed data (invalid dates) gracefully', () async {
      final csvContent = 'title,author,startedAt\nBook,Author,not-a-date';
      final csvFile = File(p.join(tempDir.path, 'malformed.csv'))..writeAsStringSync(csvContent);

      // DataMigrationService uses ImportExportUtils.parseDate which should return null on failure
      final count = await migrationService.importFromBackup(csvFile);
      expect(count, 1);

      final books = await db.bookDao.watchAllBooks().first;
      expect(books.first.startedAt, isNull);
    });
  });
}
