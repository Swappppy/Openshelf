import 'package:drift/drift.dart';
import '../database.dart';
import '../../models/shelf.dart';

part 'shelf_dao.g.dart';

@DriftAccessor(tables: [Shelves, ShelfTags, Tags])
class ShelfDao extends DatabaseAccessor<AppDatabase> with _$ShelfDaoMixin {
  ShelfDao(super.db);

  Stream<List<Shelf>> watchAllShelves() => select(shelves).watch();

  Future<int> insertShelf(ShelvesCompanion shelf) =>
      into(shelves).insert(shelf);

  Future<bool> updateShelf(Shelf shelf) => update(shelves).replace(shelf);

  Future<void> deleteShelf(int id) =>
      (delete(shelves)..where((s) => s.id.equals(id))).go();

  Future<void> setShelfTags(int shelfId, List<int> tagIds) async {
    await transaction(() async {
      await (delete(shelfTags)..where((t) => t.shelfId.equals(shelfId))).go();
      for (final tid in tagIds) {
        await into(shelfTags).insert(ShelfTagsCompanion.insert(
          shelfId: shelfId,
          tagId: tid,
        ));
      }
    });
  }

  Stream<List<Tag>> watchTagsForShelf(int shelfId) {
    final query = select(tags).join([
      innerJoin(shelfTags, shelfTags.tagId.equalsExp(tags.id)),
    ])
      ..where(shelfTags.shelfId.equals(shelfId));

    return query.watch().map((rows) => rows.map((r) => r.readTable(tags)).toList());
  }

  Future<List<int>> getTagIdsForShelf(int shelfId) async {
    final rows = await (select(shelfTags)..where((t) => t.shelfId.equals(shelfId))).get();
    return rows.map((r) => r.tagId).toList();
  }
}
