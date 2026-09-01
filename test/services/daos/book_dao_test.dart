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

      await bookDao.deleteBook(bookId);

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
  });
}
