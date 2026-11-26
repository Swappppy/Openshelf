import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/services/daos/book_dao.dart';
import 'package:openshelf/models/search_filters.dart';

void main() {
  late AppDatabase db;
  late BookDao bookDao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    bookDao = db.bookDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('BookDao Tests', () {
    test('insertBook and watchAllBooks', () async {
      final bookId = await bookDao.insertBook(const BooksCompanion(
        title: Value('Test Book'),
        author: Value('Test Author'),
        status: Value(ReadingStatus.wantToRead),
      ));

      expect(bookId, 1);

      final books = await bookDao.watchAllBooks().first;
      expect(books.length, 1);
      expect(books.first.id, bookId);
      expect(books.first.title, 'Test Book');
      expect(books.first.author, 'Test Author');
    });

    test('watchBookById', () async {
      final id = await bookDao.insertBook(const BooksCompanion(
        title: Value('Unique Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.wantToRead),
      ));

      final book = await bookDao.watchBookById(id).first;
      expect(book, isNotNull);
      expect(book!.id, id);
      expect(book.title, 'Unique Book');
    });

    test('updateBook', () async {
      final id = await bookDao.insertBook(const BooksCompanion(
        title: Value('Old Title'),
        author: Value('Author'),
        status: Value(ReadingStatus.wantToRead),
      ));

      final book = await bookDao.getBook(id);
      await bookDao.updateBook(book!.copyWith(title: 'New Title'));

      final updatedBook = await bookDao.getBook(id);
      expect(updatedBook!.title, 'New Title');
    });

    test('deleteBook and orphan tag cleanup', () async {
      final tagId = await db.into(db.tags).insert(TagsCompanion.insert(
        name: 'Test Tag',
        type: const Value(TagType.tag),
      ));

      final bookId = await bookDao.insertBook(const BooksCompanion(
        title: Value('Tagged Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.wantToRead),
      ));
      await db.into(db.bookTags).insert(BookTagsCompanion.insert(
        bookId: bookId,
        tagId: tagId,
      ));

      expect(await bookDao.getBook(bookId), isNotNull);
      expect(await (db.select(db.tags)..where((t) => t.id.equals(tagId))).getSingleOrNull(), isNotNull);

      await bookDao.deleteBook(bookId, pruneEnabled: true);

      expect(await bookDao.getBook(bookId), isNull);
      final tag = await (db.select(db.tags)..where((t) => t.id.equals(tagId))).getSingleOrNull();
      expect(tag, isNull);
    });

    test('duplicateBook copies tags correctly', () async {
      final originalId = await bookDao.insertBook(const BooksCompanion(
        title: Value('Original'),
        author: Value('Author'),
        status: Value(ReadingStatus.wantToRead),
      ));
      
      final tagId = await db.into(db.tags).insert(TagsCompanion.insert(
        name: 'Shared Tag',
        type: const Value(TagType.tag),
      ));
      await db.into(db.bookTags).insert(BookTagsCompanion.insert(
        bookId: originalId,
        tagId: tagId,
      ));

      final newId = await bookDao.duplicateBook(originalId);

      final duplicated = await bookDao.getBook(newId);
      expect(duplicated!.title, 'Original');
      expect(duplicated.id, isNot(originalId));

      final originalTags = await db.tagDao.watchTagsForBook(originalId).first;
      final duplicatedTags = await db.tagDao.watchTagsForBook(newId).first;
      expect(duplicatedTags.length, originalTags.length);
      expect(duplicatedTags.first.name, 'Shared Tag');
      expect(duplicatedTags.first.id, tagId);
    });

    test('watchBooksFiltered - basic query', () async {
      final b1 = await bookDao.insertBook(const BooksCompanion(
        title: Value('Flutter in Action'),
        author: Value('Eric W.'),
        status: Value(ReadingStatus.wantToRead),
      ));
      final b2 = await bookDao.insertBook(const BooksCompanion(
        title: Value('Dart Apprentice'),
        author: Value('Ray W.'),
        status: Value(ReadingStatus.wantToRead),
      ));

      final results = await bookDao.watchBooksFiltered(query: 'Flutter').first;
      expect(results.length, 1);
      expect(results.first.id, b1);
      expect(results.any((b) => b.id == b2), isFalse);
    });

    test('watchBooksFiltered - tag filter', () async {
      final tagId = await db.into(db.tags).insert(TagsCompanion.insert(
        name: 'Tech',
        type: const Value(TagType.tag),
      ));

      final b1 = await bookDao.insertBook(const BooksCompanion(
        title: Value('Tech Book'),
        author: Value('Author A'),
        status: Value(ReadingStatus.wantToRead),
      ));
      
      final b2 = await bookDao.insertBook(const BooksCompanion(
        title: Value('Other Book'),
        author: Value('Author B'),
        status: Value(ReadingStatus.wantToRead),
      ));

      await db.into(db.bookTags).insert(BookTagsCompanion.insert(bookId: b1, tagId: tagId));

      final techBooks = await bookDao.watchBooksFiltered(tagIds: [tagId]).first;
      expect(techBooks.length, 1);
      expect(techBooks.first.id, b1);
      expect(techBooks.any((b) => b.id == b2), isFalse);
    });

    test('watchBooksFiltered - date filters', () async {
      final now = DateTime.now();
      final oldDate = now.subtract(const Duration(days: 10));
      
      final b1 = await bookDao.insertBook(BooksCompanion(
        title: const Value('Old Book'),
        author: const Value('A'),
        status: const Value(ReadingStatus.read),
        finishedAt: Value(oldDate),
      ));
      
      final b2 = await bookDao.insertBook(BooksCompanion(
        title: const Value('New Book'),
        author: const Value('B'),
        status: const Value(ReadingStatus.read),
        finishedAt: Value(now),
      ));

      final oldResults = await bookDao.watchBooksFiltered(
        finishedAt: now.subtract(const Duration(days: 5)),
        finishedAtOp: BooleanOperator.lessThan,
      ).first;
      
      expect(oldResults.length, 1);
      expect(oldResults.first.id, b1);
      expect(oldResults.any((b) => b.id == b2), isFalse);
    });

    test('existsByTitleAndAuthor is case insensitive', () async {
      await bookDao.insertBook(const BooksCompanion(
        title: Value('Exist Title'),
        author: Value('Exist Author'),
        status: Value(ReadingStatus.wantToRead),
      ));

      expect(await bookDao.existsByTitleAndAuthor('exist title', 'exist author'), isTrue);
      expect(await bookDao.existsByTitleAndAuthor('Other', 'Author'), isFalse);
    });

    group('Boolean search query filter tests (#53)', () {
      test('hasNotes ≠ true returns books without notes and excludes books with notes', () async {
        final b1 = await bookDao.insertBook(const BooksCompanion(
          title: Value('With Notes'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
          notes: Value('Some notes here'),
        ));
        final b2 = await bookDao.insertBook(const BooksCompanion(
          title: Value('Without Notes'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
        ));

        final query = BooleanQuery(conditions: const [
          BooleanCondition(
            field: SearchField.hasNotes,
            operator: BooleanOperator.notEquals,
            value: true,
          ),
        ]);

        final results = await bookDao.watchBooksFiltered(booleanQuery: query).first;
        expect(results.map((b) => b.id), contains(b2));
        expect(results.map((b) => b.id), isNot(contains(b1)));
      });

      test('Year ≠ 2020 includes books with different year and empty year', () async {
        final b2020 = await bookDao.insertBook(const BooksCompanion(
          title: Value('Book 2020'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
          publishYear: Value(2020),
        ));
        final b2018 = await bookDao.insertBook(const BooksCompanion(
          title: Value('Book 2018'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
          publishYear: Value(2018),
        ));
        final bNoYear = await bookDao.insertBook(const BooksCompanion(
          title: Value('Book No Year'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
        ));

        final query = BooleanQuery(conditions: const [
          BooleanCondition(
            field: SearchField.year,
            operator: BooleanOperator.notEquals,
            value: 2020,
          ),
        ]);

        final results = await bookDao.watchBooksFiltered(booleanQuery: query).first;
        final ids = results.map((b) => b.id).toList();
        expect(ids, contains(b2018));
        expect(ids, contains(bNoYear));
        expect(ids, isNot(contains(b2020)));
      });

      test('Pages ≠ 300 includes books with different page count and empty page count', () async {
        final b300 = await bookDao.insertBook(const BooksCompanion(
          title: Value('300 Pages'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
          totalPages: Value(300),
        ));
        final b150 = await bookDao.insertBook(const BooksCompanion(
          title: Value('150 Pages'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
          totalPages: Value(150),
        ));
        final bNoPages = await bookDao.insertBook(const BooksCompanion(
          title: Value('No Pages'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
        ));

        final query = BooleanQuery(conditions: const [
          BooleanCondition(
            field: SearchField.pages,
            operator: BooleanOperator.notEquals,
            value: 300,
          ),
        ]);

        final results = await bookDao.watchBooksFiltered(booleanQuery: query).first;
        final ids = results.map((b) => b.id).toList();
        expect(ids, contains(b150));
        expect(ids, contains(bNoPages));
        expect(ids, isNot(contains(b300)));
      });

      test('Ownership ≠ bought includes books with other ownership or empty ownership', () async {
        final bBought = await bookDao.insertBook(const BooksCompanion(
          title: Value('Bought Book'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
          ownershipStatus: Value(OwnershipStatus.bought),
        ));
        final bGifted = await bookDao.insertBook(const BooksCompanion(
          title: Value('Gifted Book'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
          ownershipStatus: Value(OwnershipStatus.gifted),
        ));
        final bNoOwnership = await bookDao.insertBook(const BooksCompanion(
          title: Value('No Ownership'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
        ));

        final query = BooleanQuery(conditions: const [
          BooleanCondition(
            field: SearchField.ownership,
            operator: BooleanOperator.notEquals,
            value: 'bought',
          ),
        ]);

        final results = await bookDao.watchBooksFiltered(booleanQuery: query).first;
        final ids = results.map((b) => b.id).toList();
        expect(ids, contains(bGifted));
        expect(ids, contains(bNoOwnership));
        expect(ids, isNot(contains(bBought)));
      });

      test('Format ≠ digital includes paperback and empty format', () async {
        final bDigital = await bookDao.insertBook(const BooksCompanion(
          title: Value('Digital'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
          bookFormat: Value(BookFormat.digital),
        ));
        final bPaperback = await bookDao.insertBook(const BooksCompanion(
          title: Value('Paperback'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
          bookFormat: Value(BookFormat.paperback),
        ));
        final bNoFormat = await bookDao.insertBook(const BooksCompanion(
          title: Value('No Format'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
        ));

        final query = BooleanQuery(conditions: const [
          BooleanCondition(
            field: SearchField.format,
            operator: BooleanOperator.notEquals,
            value: 'digital',
          ),
        ]);

        final results = await bookDao.watchBooksFiltered(booleanQuery: query).first;
        final ids = results.map((b) => b.id).toList();
        expect(ids, contains(bPaperback));
        expect(ids, contains(bNoFormat));
        expect(ids, isNot(contains(bDigital)));
      });

      test('Status ≠ read excludes read books', () async {
        final bRead = await bookDao.insertBook(const BooksCompanion(
          title: Value('Read'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
        ));
        final bReading = await bookDao.insertBook(const BooksCompanion(
          title: Value('Reading'),
          author: Value('Author'),
          status: Value(ReadingStatus.reading),
        ));

        final query = BooleanQuery(conditions: const [
          BooleanCondition(
            field: SearchField.status,
            operator: BooleanOperator.notEquals,
            value: 'read',
          ),
        ]);

        final results = await bookDao.watchBooksFiltered(booleanQuery: query).first;
        final ids = results.map((b) => b.id).toList();
        expect(ids, contains(bReading));
        expect(ids, isNot(contains(bRead)));
      });

      test('No cover ≠ true returns books with cover', () async {
        final bWithCover = await bookDao.insertBook(const BooksCompanion(
          title: Value('With Cover'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
          coverPath: Value('/path/to/cover.jpg'),
        ));
        final bNoCover = await bookDao.insertBook(const BooksCompanion(
          title: Value('No Cover'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
        ));

        final query = BooleanQuery(conditions: const [
          BooleanCondition(
            field: SearchField.noCover,
            operator: BooleanOperator.notEquals,
            value: true,
          ),
        ]);

        final results = await bookDao.watchBooksFiltered(booleanQuery: query).first;
        final ids = results.map((b) => b.id).toList();
        expect(ids, contains(bWithCover));
        expect(ids, isNot(contains(bNoCover)));
      });

      test('Empty or invalid year value is ignored', () async {
        final b1 = await bookDao.insertBook(const BooksCompanion(
          title: Value('Book 1'),
          author: Value('Author'),
          status: Value(ReadingStatus.read),
          publishYear: Value(2020),
        ));

        final query = BooleanQuery(conditions: const [
          BooleanCondition(
            field: SearchField.year,
            operator: BooleanOperator.equals,
            value: '',
          ),
        ]);

        final results = await bookDao.watchBooksFiltered(booleanQuery: query).first;
        expect(results.map((b) => b.id), contains(b1));
      });

      test('Finished date = compares whole day ignoring time', () async {
        final finishedTime = DateTime(2023, 5, 15, 14, 30, 0);
        final otherTime = DateTime(2023, 5, 16, 9, 0, 0);

        final b1 = await bookDao.insertBook(BooksCompanion(
          title: const Value('Finished Afternoon'),
          author: const Value('Author'),
          status: const Value(ReadingStatus.read),
          finishedAt: Value(finishedTime),
        ));
        final b2 = await bookDao.insertBook(BooksCompanion(
          title: const Value('Finished Next Day'),
          author: const Value('Author'),
          status: const Value(ReadingStatus.read),
          finishedAt: Value(otherTime),
        ));

        final query = BooleanQuery(conditions: [
          BooleanCondition(
            field: SearchField.finishedAt,
            operator: BooleanOperator.equals,
            value: DateTime(2023, 5, 15, 0, 0, 0).toIso8601String(),
          ),
        ]);

        final results = await bookDao.watchBooksFiltered(booleanQuery: query).first;
        final ids = results.map((b) => b.id).toList();
        expect(ids, contains(b1));
        expect(ids, isNot(contains(b2)));
      });
    });
  });

  group('Date filter day boundaries', () {
    late int sameDay;
    late int nextDay;
    late int prevDay;

    setUp(() async {
      Future<int> add(String t, DateTime d) => bookDao.insertBook(BooksCompanion(
          title: Value(t), author: const Value('A'), status: const Value(ReadingStatus.read), finishedAt: Value(d)));
      prevDay = await add('Prev', DateTime(2023, 5, 14, 23, 59));
      sameDay = await add('Same', DateTime(2023, 5, 15, 14, 30));
      nextDay = await add('Next', DateTime(2023, 5, 16, 0, 0));
    });

    Future<List<int>> run(BooleanOperator op) async {
      final query = BooleanQuery(conditions: [
        BooleanCondition(field: SearchField.finishedAt, operator: op, value: DateTime(2023, 5, 15).toIso8601String()),
      ]);
      return (await bookDao.watchBooksFiltered(booleanQuery: query).first).map((b) => b.id).toList();
    }

    test('> excludes the chosen day itself', () async {
      expect(await run(BooleanOperator.greaterThan), [nextDay]);
    });

    test('< excludes the chosen day itself', () async {
      expect(await run(BooleanOperator.lessThan), [prevDay]);
    });

    test('= matches the whole chosen day only', () async {
      expect(await run(BooleanOperator.equals), [sameDay]);
    });

    test('a UTC value is interpreted as the local calendar day', () async {
      final query = BooleanQuery(conditions: [
        BooleanCondition(field: SearchField.finishedAt, operator: BooleanOperator.equals,
            value: DateTime(2023, 5, 15, 12).toUtc().toIso8601String()),
      ]);
      final ids = (await bookDao.watchBooksFiltered(booleanQuery: query).first).map((b) => b.id).toList();
      expect(ids, [sameDay]);
    });
  });

  group('Bulk edit of finish date', () {
    Future<int> readBook({required ReadingStatus status}) => bookDao.insertBook(BooksCompanion(
        title: const Value('B'), author: const Value('A'), status: Value(status), finishedAt: Value(DateTime(2024, 3, 1))));

    test('an empty finish date never reopens a completed read', () async {
      final id = await readBook(status: ReadingStatus.read);
      await db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
          bookId: id, readNumber: 1, startedAt: Value(DateTime(2024, 2, 1)), finishedAt: Value(DateTime(2024, 3, 1))));

      await bookDao.bulkUpdateBooks([id], BulkEditData(updateStartedAt: true, startedAt: DateTime(2024, 1, 1), updateFinishedAt: true),
          pruneEnabled: false);

      final read = (await db.readHistoryDao.getHistoryForBook(id)).single;
      expect(read.finishedAt, DateTime(2024, 3, 1));
    });

    test('a new finish date moves the completed read and its whole-book entry', () async {
      final id = await readBook(status: ReadingStatus.read);
      await db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
          bookId: id, readNumber: 1, startedAt: Value(DateTime(2024, 2, 1)), finishedAt: Value(DateTime(2024, 3, 1))));
      await db.logDao.insertLog(ReadingLogCompanion.insert(
          bookId: id, date: DateTime(2024, 3, 1), pagesRead: 200, readNumber: const Value(1), isBackfill: const Value(true)));

      await bookDao.bulkUpdateBooks([id], BulkEditData(updateFinishedAt: true, finishedAt: DateTime(2024, 4, 10)),
          pruneEnabled: false);

      expect((await db.readHistoryDao.getHistoryForBook(id)).single.finishedAt, DateTime(2024, 4, 10));
      expect((await db.select(db.readingLog).get()).single.date, DateTime(2024, 4, 10));
    });

    test('a book being re-read keeps its earlier completed read untouched', () async {
      final id = await readBook(status: ReadingStatus.reading);
      await db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
          bookId: id, readNumber: 1, startedAt: Value(DateTime(2024, 2, 1)), finishedAt: Value(DateTime(2024, 3, 1))));
      await db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(bookId: id, readNumber: 2, startedAt: Value(DateTime(2025, 1, 1))));

      await bookDao.bulkUpdateBooks([id], BulkEditData(updateFinishedAt: true, finishedAt: DateTime(2025, 6, 1)),
          pruneEnabled: false);

      final history = await db.readHistoryDao.getHistoryForBook(id);
      expect(history.first.finishedAt, DateTime(2024, 3, 1));
      expect(history.last.finishedAt, null);
    });
  });

  group('Media type filter', () {
    Future<void> add(String title, MediaType m) => bookDao.insertBook(BooksCompanion(
          title: Value(title),
          author: const Value('A'),
          status: const Value(ReadingStatus.wantToRead),
          mediaType: Value(m),
        ));

    setUp(() async {
      await add('Paper', MediaType.reading);
      await add('Audio', MediaType.audio);
      await add('Mixed', MediaType.both);
    });

    Future<Set<String>> titles(String m) async =>
        (await bookDao.watchBooksFiltered(mediaType: m).first).map((b) => b.title).toSet();

    test('a medium matches the books that have it, mixed ones included', () async {
      expect(await titles('audio'), {'Audio', 'Mixed'});
      expect(await titles('reading'), {'Paper', 'Mixed'});
      expect(await titles('both'), {'Mixed'});
    });

    test('boolean ≠ audio keeps only books without audio', () async {
      final books = await bookDao
          .watchBooksFiltered(
            booleanQuery: const BooleanQuery(conditions: [
              BooleanCondition(field: SearchField.mediaType, operator: BooleanOperator.notEquals, value: 'audio'),
            ]),
          )
          .first;
      expect(books.map((b) => b.title).toSet(), {'Paper'});
    });
  });
}
