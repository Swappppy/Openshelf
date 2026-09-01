import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/services/bookshelf_import_service.dart';

void main() {
  late AppDatabase db;
  late BookshelfImportService importService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    importService = BookshelfImportService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('BookshelfImportService Tests', () {
    test('Import valid CSV string', () async {
      // Create a CSV with minimum required columns
      // Headers (1 row) + 1 Data row
      // We need at least 35 columns as per _minColumns = 35
      final header = List.generate(50, (i) => 'Col $i').join(',');
      
      final row = List.generate(50, (i) => '');
      row[18] = 'Test Book'; // _colTitle = 18
      row[22] = 'Test Author'; // _colAuthors = 22
      row[1] = '1234567890'; // _colIsbn = 1
      row[29] = '300'; // _colPageCount = 29
      row[8] = '1'; // _colRead = 8 (Mark as read)

      final csv = '$header\n${row.join(',')}';

      final result = await importService.importFromString(csv);

      expect(result.imported, 1);
      expect(result.skipped, 0);
      expect(result.errors.isEmpty, true);

      final books = await db.bookDao.watchAllBooks().first;
      expect(books.length, 1);
      expect(books.first.title, 'Test Book');
      expect(books.first.author, 'Test Author');
      expect(books.first.status, ReadingStatus.read);
    });

    test('Skip duplicate ISBN', () async {
      final header = List.generate(50, (i) => 'Col $i').join(',');
      final row = List.generate(50, (i) => '');
      row[18] = 'Duplicate Book';
      row[1] = '9999999999';
      
      final csv = '$header\n${row.join(',')}\n${row.join(',')}';

      final result = await importService.importFromString(csv);

      expect(result.imported, 1);
      expect(result.skipped, 1);
    });

    test('Handle insufficient columns', () async {
      final header = 'Col1,Col2';
      final row = 'Val1,Val2';
      final csv = '$header\n$row';

      final result = await importService.importFromString(csv);

      expect(result.imported, 0);
      expect(result.skipped, 1);
      expect(result.errors.first, contains('Insufficient columns'));
    });
  });
}
