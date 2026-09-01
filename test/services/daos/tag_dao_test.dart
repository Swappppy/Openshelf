import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/services/daos/tag_dao.dart';

void main() {
  late AppDatabase db;
  late TagDao tagDao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tagDao = db.tagDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('TagDao Tests', () {
    test('getOrCreateCollection', () async {
      final id1 = await tagDao.getOrCreateCollection('Fantasy');
      final id2 = await tagDao.getOrCreateCollection('Fantasy');
      
      expect(id1, id2); 
      
      final tags = await tagDao.getTagsByType(TagType.collection);
      expect(tags.length, 1);
      expect(tags.first.id, id1);
      expect(tags.first.name, 'Fantasy');
    });

    test('getOrCreateTag', () async {
      final id1 = await tagDao.getOrCreateTag('Ficción', TagType.tag);
      final id2 = await tagDao.getOrCreateTag('Ficción', TagType.tag);
      
      expect(id1, id2);
      
      final tags = await tagDao.getTagsByType(TagType.tag);
      expect(tags.length, 1);
      expect(tags.first.id, id1);
    });

    test('deleteTag - clears references in Books table for collections', () async {
      final collId = await tagDao.getOrCreateCollection('Sci-Fi');
      
      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Dune'),
        author: Value('Frank Herbert'),
        status: Value(ReadingStatus.wantToRead),
        collectionId: Value(1), 
      ));

      var book = await db.bookDao.getBook(bookId);
      expect(book!.collectionId, collId);

      await tagDao.deleteTag(collId);

      book = await db.bookDao.getBook(bookId);
      expect(book!.collectionId, isNull);
      
      final tag = await db.tagDao.getTagsByIds([collId]);
      expect(tag, isEmpty);
    });

    test('setBookTags and watchTagsForBook', () async {
      final t1 = await tagDao.getOrCreateCategory('Tag 1');
      final t2 = await tagDao.getOrCreateCategory('Tag 2');
      
      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.wantToRead),
      ));

      await tagDao.setBookTags(bookId, [t1, t2]);

      final bookTags = await tagDao.watchTagsForBook(bookId).first;
      expect(bookTags.length, 2);
      expect(bookTags.map((e) => e.id), containsAll([t1, t2]));

      // Overwrite check
      await tagDao.setBookTags(bookId, [t1]);
      final updatedTags = await tagDao.watchTagsForBook(bookId).first;
      expect(updatedTags.length, 1);
      expect(updatedTags.first.id, t1);
      expect(updatedTags.any((e) => e.id == t2), isFalse);
    });

    test('pruneOrphanTags', () async {
      final t1 = await tagDao.getOrCreateCategory('Used Tag');
      final t2 = await tagDao.getOrCreateCategory('Orphan Tag');
      
      final bookId = await db.bookDao.insertBook(const BooksCompanion(
        title: Value('Book'),
        author: Value('Author'),
        status: Value(ReadingStatus.wantToRead),
      ));
      await tagDao.setBookTags(bookId, [t1]);

      await tagDao.pruneOrphanTags();

      final remaining = await tagDao.getTagsByType(TagType.tag);
      expect(remaining.length, 1);
      expect(remaining.first.id, t1);
      expect(remaining.any((e) => e.id == t2), isFalse);
    });

    test('searchTags returns relevant results', () async {
      await tagDao.getOrCreateCategory('History');
      await tagDao.getOrCreateCategory('Science');
      
      final results = await tagDao.searchTags('Hist', TagType.tag);
      expect(results.length, 1);
      expect(results.first.name, 'History');
    });

    test('getTagsByIds returns specific tags', () async {
      final id1 = await tagDao.getOrCreateCategory('T1');
      final id2 = await tagDao.getOrCreateCategory('T2');
      
      final tags = await tagDao.getTagsByIds([id1, id2]);
      expect(tags.length, 2);
      expect(tags.map((e) => e.id), containsAll([id1, id2]));
    });
  });
}
