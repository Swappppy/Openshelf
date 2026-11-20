import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/models/search_filters.dart';
import 'package:openshelf/services/data_migration_service.dart';
import 'package:openshelf/services/database.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory root;
  late Directory docDir;
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    root = await Directory.systemTemp.createTemp('openshelf_roundtrip');
    docDir = Directory(p.join(root.path, 'app_flutter'))..createSync();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => docDir.path,
    );
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });

  File zipOf(Map<String, List<int>> entries) {
    final a = Archive();
    entries.forEach((name, data) => a.addFile(ArchiveFile(name, data.length, data)));
    return File(p.join(root.path, 'in_${entries.length}_${DateTime.now().microsecondsSinceEpoch}.zip'))
      ..writeAsBytesSync(ZipEncoder().encode(a));
  }

  final booksCsv = utf8.encode('title,author\nX,Y\n');
  final png = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');

  group('archive safety', () {
    test('entries escaping the app folder are ignored (zip slip)', () async {
      final zip = zipOf({
        'books.csv': booksCsv,
        '../evil.png': png,
        '../shared_prefs/prefs.xml': utf8.encode('x'),
        '/abs/evil.png': png,
        'imprints/../../evil2.png': png,
        'nested/dir/cover.png': png,
        'openshelf_db.sqlite': utf8.encode('not a db'),
      });
      await DataMigrationService(db).importFromBackup(zip, compress: false);

      expect(File(p.join(root.path, 'evil.png')).existsSync(), isFalse);
      expect(Directory(p.join(root.path, 'shared_prefs')).existsSync(), isFalse);
      expect(File(p.join(root.path, 'evil2.png')).existsSync(), isFalse);
      expect(File(p.join(docDir.path, 'openshelf_db.sqlite')).existsSync(), isFalse);
      expect(File(p.join(docDir.path, 'nested', 'dir', 'cover.png')).existsSync(), isFalse);
    });

    test('valid cover and imprint images are extracted', () async {
      final zip = zipOf({'books.csv': booksCsv, 'cover_1.png': png, 'imprints/logo.png': png});
      await DataMigrationService(db).importFromBackup(zip, compress: false);
      expect(File(p.join(docDir.path, 'cover_1.png')).existsSync(), isTrue);
      expect(File(p.join(docDir.path, 'imprints', 'logo.png')).existsSync(), isTrue);
    });

    test('safeMediaPath rejects traversal and non-images', () {
      expect(DataMigrationService.safeMediaPath('a.jpg'), 'a.jpg');
      expect(DataMigrationService.safeMediaPath('imprints/a.png'), 'imprints/a.png');
      for (final bad in ['../a.jpg', '/a.jpg', 'imprints/../../a.jpg', 'x/a.jpg', 'a.sqlite', r'..\a.jpg', 'C:/a.jpg']) {
        expect(DataMigrationService.safeMediaPath(bad), isNull, reason: bad);
      }
    });

    test('entries declaring an oversized payload are rejected', () async {
      final a = Archive()..addFile(ArchiveFile('books.csv', booksCsv.length, booksCsv));
      final bytes = ZipEncoder().encode(a);
      // Patch the central directory uncompressed size (offset 24 in the CD header) to 1 GiB.
      final cd = _lastIndexOf(bytes, const [0x50, 0x4b, 0x01, 0x02]);
      final view = ByteData.sublistView(Uint8List.fromList(bytes));
      view.setUint32(cd + 24, 1 << 30, Endian.little);
      final f = File(p.join(root.path, 'bomb.zip'))..writeAsBytesSync(view.buffer.asUint8List());
      expect(() => DataMigrationService(db).importFromBackup(f), throwsA(isA<BackupFormatException>()));
    });
  });

  group('lossless round trip', () {
    late int bookId;

    Future<void> seed() async {
      final cat = await db.tagDao.insertTag(TagsCompanion.insert(name: 'Sci-Fi', type: const Value(TagType.tag), color: const Value('ff0000')));
      final colA = await db.tagDao.insertTag(TagsCompanion.insert(name: 'Saga A', type: const Value(TagType.collection)));
      final colB = await db.tagDao.insertTag(TagsCompanion.insert(name: 'Saga B', type: const Value(TagType.collection)));
      final imp = await db.tagDao.insertTag(TagsCompanion.insert(name: 'Imprint', type: const Value(TagType.imprint)));
      bookId = await db.into(db.books).insert(BooksCompanion.insert(
        title: 'Book', author: 'Author', isbn: const Value('978'), status: ReadingStatus.read,
        originalTitle: const Value('Orig'), originalLanguage: const Value('en'), description: const Value('Desc'),
        ownershipStatus: const Value(OwnershipStatus.borrowed), copies: const Value(3),
      ));
      await db.tagDao.setBookTags(bookId, [cat], collections: [(colA, 1), (colB, 7)]);
      await db.bookDao.setBookImprint(bookId, imp);
      await db.into(db.readingLog).insert(ReadingLogCompanion.insert(bookId: bookId, date: DateTime(2026, 1, 1), pagesRead: 10));
      await db.ownershipDao.insertEvent(OwnershipLogCompanion.insert(bookId: bookId, eventType: OwnershipStatus.borrowed, personName: const Value('Ana'), date: DateTime(2026, 2, 1)));

      final shelf = await db.into(db.shelves).insert(ShelvesCompanion.insert(
        name: 'My shelf', filterNoCover: const Value(true), filterSearchMode: const Value(2),
        filterFormat: const Value('paperback'), filterOwnership: const Value('borrowed'), filterNotes: const Value('n'),
        filterBooleanQuery: Value(jsonEncode(BooleanQuery(conditions: [
          BooleanCondition(field: SearchField.collection, operator: BooleanOperator.includes, value: colB),
        ]).toJson())),
      ));
      await db.shelfDao.setShelfTags(shelf, [cat, colA]);
      final goal = await db.goalDao.insertGoal(ReadingGoalsCompanion.insert(
        title: 'G', type: 'shelf', targetValue: 5, startDate: DateTime(2026), endDate: DateTime(2027), shelfId: Value(shelf)));
      await db.statDao.insertWidgetConfig(StatWidgetConfigsCompanion.insert(type: 'goal', size: 'half', sortOrder: 0, goalId: Value(goal)));
      await db.searchHistoryDao.insertEntry(SearchHistoryCompanion.insert(query: '978', type: 'isbn_scan', status: 'success', timestamp: DateTime(2026, 3, 1)));
    }

    test('every field and relation survives, with IDs remapped by name', () async {
      await seed();
      final zip = (await DataMigrationService(db).createBackupFile(includeCovers: false)).copySync(p.join(root.path, 'b.zip'));

      final db2 = AppDatabase(NativeDatabase.memory());
      // Pre-existing tags shift every ID in the target database.
      await db2.tagDao.insertTag(TagsCompanion.insert(name: 'Other', type: const Value(TagType.collection)));
      await db2.tagDao.insertTag(TagsCompanion.insert(name: 'Other2', type: const Value(TagType.tag)));
      await DataMigrationService(db2).importFromBackup(zip);

      final b = (await db2.select(db2.books).get()).single;
      expect((b.originalTitle, b.originalLanguage, b.description, b.ownershipStatus, b.copies),
          ('Orig', 'en', 'Desc', OwnershipStatus.borrowed, 3));
      final cols = await db2.tagDao.watchCollectionsForBook(b.id).first;
      expect(cols.map((c) => (c.$1.name, c.$2)).toSet(), {('Saga A', 1), ('Saga B', 7)});
      expect((await db2.tagDao.watchTagsForBook(b.id).first).single.name, 'Sci-Fi');
      expect((await db2.select(db2.ownershipLog).get()).single.personName, 'Ana');
      expect((await db2.select(db2.searchHistory).get()).single.query, '978');

      final shelf = (await db2.select(db2.shelves).get()).single;
      expect((shelf.filterNoCover, shelf.filterSearchMode, shelf.filterFormat, shelf.filterOwnership, shelf.filterNotes),
          (true, 2, 'paperback', 'borrowed', 'n'));
      final shelfTagNames = (await db2.shelfDao.watchTagsForShelf(shelf.id).first).map((t) => t.name).toSet();
      expect(shelfTagNames, {'Sci-Fi', 'Saga A'});
      final bq = BooleanQuery.fromJson(jsonDecode(shelf.filterBooleanQuery!));
      final sagaB = (await db2.select(db2.tags).get()).firstWhere((t) => t.name == 'Saga B');
      expect(bq.conditions.single.value, sagaB.id, reason: 'boolean condition must point at the new tag id');

      final goal = (await db2.select(db2.readingGoals).get()).single;
      expect(goal.shelfId, shelf.id);
      expect((await db2.select(db2.statWidgetConfigs).get()).single.goalId, goal.id);
      await db2.close();
    });

    test('re-importing the same backup is idempotent', () async {
      await seed();
      final zip = (await DataMigrationService(db).createBackupFile(includeCovers: false)).copySync(p.join(root.path, 'b.zip'));
      final db2 = AppDatabase(NativeDatabase.memory());
      for (var i = 0; i < 2; i++) {
        await DataMigrationService(db2).importFromBackup(zip);
      }
      expect((await db2.select(db2.books).get()).length, 1);
      expect((await db2.select(db2.readingLog).get()).length, 1);
      expect((await db2.select(db2.ownershipLog).get()).length, 1);
      expect((await db2.select(db2.statWidgetConfigs).get()).length, 1);
      expect((await db2.select(db2.searchHistory).get()).length, 1);
      await db2.close();
    });

    test('intentional duplicates (same ISBN / no ISBN) are preserved, not merged', () async {
      for (final isbn in ['111', '111', null, null]) {
        await db.into(db.books).insert(BooksCompanion.insert(title: 'Same', author: 'A', status: ReadingStatus.wantToRead, isbn: Value(isbn)));
      }
      final zip = (await DataMigrationService(db).createBackupFile(includeCovers: false)).copySync(p.join(root.path, 'b.zip'));
      final db2 = AppDatabase(NativeDatabase.memory());
      await DataMigrationService(db2).importFromBackup(zip);
      expect((await db2.select(db2.books).get()).length, 4);
      await DataMigrationService(db2).importFromBackup(zip);
      expect((await db2.select(db2.books).get()).length, 4);
      await db2.close();
    });
  });

  group('robustness', () {
    test('existing duplicate ISBNs no longer crash a CSV import', () async {
      for (var i = 0; i < 2; i++) {
        await db.into(db.books).insert(BooksCompanion.insert(title: 'T', author: 'A', status: ReadingStatus.read, isbn: const Value('999')));
      }
      final f = File(p.join(root.path, 'x.csv'))..writeAsStringSync('title,author,isbn\nX,Y,999\n');
      await DataMigrationService(db).importFromBackup(f);
      expect(await db.bookDao.getBookByIsbn('999'), isNotNull);
    });

    test('a malformed row is skipped instead of aborting the import', () async {
      final f = File(p.join(root.path, 'x.csv'))
        ..writeAsStringSync('title,author,createdAt,paginationConfig\nGood,A,,\nBad,B,not-a-date,{broken\n');
      final count = await DataMigrationService(db).importFromBackup(f);
      expect(count, 2);
    });
  });

  group('deletes referenced by other rows (foreign keys)', () {
    test('imprint in use, shelf used by goal, goal shown in widget', () async {
      final imp = await db.tagDao.insertTag(TagsCompanion.insert(name: 'Imp', type: const Value(TagType.imprint)));
      final col = await db.tagDao.insertTag(TagsCompanion.insert(name: 'Col', type: const Value(TagType.collection)));
      final book = await db.into(db.books).insert(BooksCompanion.insert(title: 'T', author: 'A', status: ReadingStatus.read));
      await db.bookDao.setBookImprint(book, imp);
      final shelf = await db.into(db.shelves).insert(ShelvesCompanion.insert(name: 's'));
      final goal = await db.goalDao.insertGoal(ReadingGoalsCompanion.insert(
          title: 'g', type: 'shelf', targetValue: 1, startDate: DateTime(2026), endDate: DateTime(2027),
          shelfId: Value(shelf), collectionId: Value(col)));
      await db.statDao.insertWidgetConfig(StatWidgetConfigsCompanion.insert(type: 'goal', size: 'half', sortOrder: 0, goalId: Value(goal)));

      await db.tagDao.deleteTag(imp);
      await db.tagDao.deleteTag(col);
      await db.shelfDao.deleteShelf(shelf);
      await db.goalDao.deleteGoal(goal);

      expect((await db.bookDao.getBook(book))!.imprintId, isNull);
      expect(await db.select(db.readingGoals).get(), isEmpty);
      expect((await db.select(db.statWidgetConfigs).get()).single.goalId, isNull);
    });
  });
}

int _lastIndexOf(List<int> haystack, List<int> needle) {
  for (var i = haystack.length - needle.length; i >= 0; i--) {
    var ok = true;
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        ok = false;
        break;
      }
    }
    if (ok) return i;
  }
  return -1;
}
