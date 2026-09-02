import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/services/goodreads_import_service.dart';

void main() {
  late AppDatabase db;
  late GoodreadsImportService importService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    importService = GoodreadsImportService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('GoodreadsImportService Tests', () {
    test('Import valid Goodreads CSV', () async {
      final header = 'Title,Author,ISBN,ISBN13,My Rating,Publisher,Binding,Number of Pages,Year Published,Date Read,Date Added,Bookshelves,Exclusive Shelf,My Review,Private Notes,Read Count,Owned Copies\n';
      final row = 'Foundation,Asimov,="0553293354",="9780553293357",5,Bantam,Paperback,244,1951,2023/10/01,2023/09/01,sci-fi,read,Great book,Notes,1,1\n';
      
      final result = await importService.importFromString(header + row);
      
      expect(result.imported, 1);
      expect(result.skipped, 0);
      expect(result.errors.isEmpty, true);

      final books = await db.bookDao.watchAllBooks().first;
      expect(books.length, 1);
      expect(books.first.title, 'Foundation');
      expect(books.first.author, 'Asimov');
      expect(books.first.status, ReadingStatus.read);
      expect(books.first.isbn, '9780553293357');
    });

    test('Handles missing optional columns', () async {
      // Missing 'My Review' and 'Private Notes'
      final header = 'Title,Author,ISBN13,Exclusive Shelf\n';
      final row = 'Dune,Frank Herbert,9780441172719,to-read\n';

      final result = await importService.importFromString(header + row);

      expect(result.imported, 1);
      expect(result.errors.isEmpty, true);

      final books = await db.bookDao.watchAllBooks().first;
      expect(books.first.title, 'Dune');
      expect(books.first.status, ReadingStatus.wantToRead);
    });

    test('Skips duplicate book', () async {
      final header = 'Title,Author,ISBN13,Exclusive Shelf\n';
      final row = 'Duplicate Book,Author X,1234567890123,read\n';

      await importService.importFromString(header + row);
      final result = await importService.importFromString(header + row);

      expect(result.imported, 0);
      expect(result.skipped, 1);
    });
  });
}
