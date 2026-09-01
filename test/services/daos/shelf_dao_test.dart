import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/services/daos/shelf_dao.dart';

void main() {
  late AppDatabase db;
  late ShelfDao shelfDao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    shelfDao = db.shelfDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('ShelfDao Tests', () {
    test('insertShelf and watchAllShelves', () async {
      final id = await shelfDao.insertShelf(const ShelvesCompanion(
        name: Value('My Smart Shelf'),
        filterQuery: Value('Flutter'),
      ));

      final shelves = await shelfDao.watchAllShelves().first;
      expect(shelves.length, 1);
      expect(shelves.first.id, id);
      expect(shelves.first.name, 'My Smart Shelf');
      expect(shelves.first.filterQuery, 'Flutter');
    });

    test('updateShelf updates existing record', () async {
      final id = await shelfDao.insertShelf(const ShelvesCompanion(
        name: Value('Old Name'),
      ));

      final shelves = await shelfDao.watchAllShelves().first;
      final shelf = shelves.firstWhere((s) => s.id == id);
      
      final updated = await shelfDao.updateShelf(shelf.copyWith(name: 'New Name'));
      expect(updated, isTrue);

      final updatedShelves = await shelfDao.watchAllShelves().first;
      expect(updatedShelves.firstWhere((s) => s.id == id).name, 'New Name');
    });

    test('deleteShelf removes record and associations (cascade)', () async {
      final shelfId = await shelfDao.insertShelf(const ShelvesCompanion(
        name: Value('To Delete'),
      ));
      
      final tagId = await db.tagDao.getOrCreateCategory('T1');
      await shelfDao.setShelfTags(shelfId, [tagId]);

      await shelfDao.deleteShelf(shelfId);

      final shelves = await shelfDao.watchAllShelves().first;
      expect(shelves.any((s) => s.id == shelfId), isFalse);
      
      final shelfTags = await db.shelfDao.getTagIdsForShelf(shelfId);
      expect(shelfTags, isEmpty);
    });

    test('setShelfTags overwrites previous tags', () async {
      final shelfId = await shelfDao.insertShelf(const ShelvesCompanion(
        name: Value('Shelf'),
      ));

      final t1 = await db.tagDao.getOrCreateCategory('T1');
      final t2 = await db.tagDao.getOrCreateCategory('T2');

      await shelfDao.setShelfTags(shelfId, [t1]);
      var currentTags = await shelfDao.getTagIdsForShelf(shelfId);
      expect(currentTags, [t1]);

      await shelfDao.setShelfTags(shelfId, [t2]);
      currentTags = await shelfDao.getTagIdsForShelf(shelfId);
      expect(currentTags, [t2]);
      expect(currentTags.contains(t1), isFalse);
    });

    test('isTagUsedByAnyShelf identifies correctly', () async {
      final tagId = await db.tagDao.getOrCreateCategory('Check Tag');

      expect(await shelfDao.isTagUsedByAnyShelf(tagId), false);

      final shelfId = await shelfDao.insertShelf(const ShelvesCompanion(
        name: Value('Test Shelf'),
      ));
      await shelfDao.setShelfTags(shelfId, [tagId]);

      expect(await shelfDao.isTagUsedByAnyShelf(tagId), true);
    });
  });
}
