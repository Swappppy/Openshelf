import 'package:drift/drift.dart';
import '../database.dart';


part 'tag_dao.g.dart';

@DriftAccessor(tables: [Tags, BookTags, Books])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  Future<int> getOrCreateCollection(String name) async {
    final existing = await (select(tags)
      ..where((t) => t.name.equals(name) & t.type.equals(TagType.collection.name)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return insertTag(TagsCompanion(
      name: Value(name),
      type: const Value(TagType.collection),
    ));
  }

  Future<int> getOrCreateTag(String name, TagType type) async {
    final existing = await (select(tags)
      ..where((t) => t.name.equals(name) & t.type.equals(type.name)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return insertTag(TagsCompanion(
      name: Value(name),
      type: Value(type),
    ));
  }

  Future<int> getOrCreateCategory(String name) => getOrCreateTag(name, TagType.tag);

  Future<int> insertTag(TagsCompanion tag) => into(tags).insert(tag);

  Future<List<Tag>> getTagsByType(TagType type) =>
      (select(tags)..where((t) => t.type.equals(type.name))).get();

  Future<List<Tag>> getTagsByIds(List<int> ids) =>
      (select(tags)..where((t) => t.id.isIn(ids))).get();

  Future<List<Tag>> searchTags(String query, TagType type) =>
      (select(tags)
        ..where((t) => t.name.contains(query) & t.type.equals(type.name)))
          .get();

  Future<bool> updateTag(Tag tag) => update(tags).replace(tag);

  Future<void> deleteTag(int id) async {
    await transaction(() async {
      final tag = await (select(tags)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      // If deleting a collection, we must clear the references in Books table
      if (tag != null && tag.type == TagType.collection) {
        await (update(books)
          ..where((b) => b.collectionId.equals(tag.id)))
            .write(const BooksCompanion(
          collectionId: Value(null),
        ));
      }
      // Remove M:M links
      await (delete(bookTags)..where((bt) => bt.tagId.equals(id))).go();
      // Delete the tag itself
      await (delete(tags)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> setBookTags(int bookId, List<int> tagIds, {List<(int, int?)>? collections}) async {
    await transaction(() async {
      await (delete(bookTags)
        ..where((bt) => bt.bookId.equals(bookId))).go();
      
      for (final tagId in tagIds) {
        await into(bookTags).insert(
          BookTagsCompanion(
            bookId: Value(bookId),
            tagId: Value(tagId),
          ),
        );
      }

      if (collections != null) {
        for (final col in collections) {
          await into(bookTags).insert(
            BookTagsCompanion(
              bookId: Value(bookId),
              tagId: Value(col.$1),
              collectionNumber: Value(col.$2),
            ),
          );
        }
      }
    });
  }

  Future<void> pruneOrphanTags() async {
    final allTags = await select(tags).get();
    for (final tag in allTags) {
      // Imprints and collections are managed manually, don't auto-prune
      if (tag.type == TagType.imprint || tag.type == TagType.collection) continue;
      final refs = await (select(bookTags)
        ..where((bt) => bt.tagId.equals(tag.id))).get();
      if (refs.isEmpty) {
        await (delete(tags)..where((t) => t.id.equals(tag.id))).go();
      }
    }
  }

  Stream<List<Tag>> watchTagsForBook(int bookId) {
    final query = select(tags).join([
      innerJoin(bookTags, bookTags.tagId.equalsExp(tags.id)),
    ])
      ..where(bookTags.bookId.equals(bookId))
      ..where(tags.type.equals(TagType.tag.name));

    return query.watch().map(
          (rows) => rows.map((r) => r.readTable(tags)).toList(),
    );
  }

  Stream<List<(Tag, int?)>> watchCollectionsForBook(int bookId) {
    final query = select(tags).join([
      innerJoin(bookTags, bookTags.tagId.equalsExp(tags.id)),
    ])
      ..where(bookTags.bookId.equals(bookId))
      ..where(tags.type.equals(TagType.collection.name));

    return query.watch().map((rows) => rows.map((r) {
          final tag = r.readTable(tags);
          final number = r.readTable(bookTags).collectionNumber;
          return (tag, number);
        }).toList());
  }

  Stream<List<String>> watchTopTagNamesForBooks(List<int> bookIds, {int limit = 3}) {
    if (bookIds.isEmpty) return Stream.value([]);
    
    final countExp = bookTags.tagId.count();
    final query = select(tags).join([
      innerJoin(bookTags, bookTags.tagId.equalsExp(tags.id)),
    ])
      ..where(bookTags.bookId.isIn(bookIds))
      ..where(tags.type.equals(TagType.tag.name))
      ..addColumns([countExp])
      ..groupBy([tags.id, tags.name])
      ..orderBy([OrderingTerm(expression: countExp, mode: OrderingMode.desc)])
      ..limit(limit);

    return query.watch().map((rows) {
      final results = rows.map((r) => r.readTable(tags).name).toList();
      return results;
    });
  }

  Stream<Tag?> watchImprintForBook(int bookId) {
    return (select(books).join([
      innerJoin(tags, tags.id.equalsExp(books.imprintId)),
    ])
      ..where(books.id.equals(bookId)))
        .watchSingleOrNull()
        .map((row) => row?.readTable(tags));
  }

  Stream<List<Tag>> watchTagsByType(TagType type) =>
      (select(tags)..where((t) => t.type.equals(type.name))).watch();

  Stream<List<(Tag, int)>> watchTagsByTypeWithCounts(TagType type) {
    if (type == TagType.imprint) {
      final countExp = books.id.count();
      final query = select(tags).join([
        leftOuterJoin(books, books.imprintId.equalsExp(tags.id)),
      ])
        ..where(tags.type.equals(type.name))
        ..addColumns([countExp])
        ..groupBy([tags.id]);

      return query.watch().map((rows) {
        return rows.map((row) {
          final tag = row.readTable(tags);
          final tagCount = row.read(countExp) ?? 0;
          return (tag, tagCount);
        }).toList();
      });
    }

    final countExp = bookTags.bookId.count();
    final query = select(tags).join([
      leftOuterJoin(bookTags, bookTags.tagId.equalsExp(tags.id)),
    ])
      ..where(tags.type.equals(type.name))
      ..addColumns([countExp])
      ..groupBy([tags.id]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final tag = row.readTable(tags);
        final tagCount = row.read(countExp) ?? 0;
        return (tag, tagCount);
      }).toList();
    });
  }

  Stream<List<(Tag, int)>> watchCollectionsWithCounts() {
    final countExp = bookTags.bookId.count();
    final query = select(tags).join([
      leftOuterJoin(bookTags, bookTags.tagId.equalsExp(tags.id)),
    ])
      ..where(tags.type.equals(TagType.collection.name))
      ..addColumns([countExp])
      ..groupBy([tags.id]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final tag = row.readTable(tags);
        final tagCount = row.read(countExp) ?? 0;
        return (tag, tagCount);
      }).toList();
    });
  }

  Future<int> getBookCountByImprint(int imprintId) async {
    final query = select(books)..where((b) => b.imprintId.equals(imprintId));
    final rows = await query.get();
    return rows.length;
  }

  Stream<int> watchBookCountByImprint(int imprintId) {
    final query = select(books)..where((b) => b.imprintId.equals(imprintId));
    return query.watch().map((rows) => rows.length);
  }

  Future<int> getBookCountByTag(int tagId) async {
    final rows = await (select(bookTags)
      ..where((bt) => bt.tagId.equals(tagId)))
        .get();
    return rows.length;
  }

  Stream<int> watchBookCountByTag(int tagId) {
    return (select(bookTags)
      ..where((bt) => bt.tagId.equals(tagId)))
        .watch()
        .map((rows) => rows.length);
  }

  Future<void> pruneCollectionIfOrphan(int collectionId) async {
    final users = await (select(books)
          ..where((b) => b.collectionId.equals(collectionId)))
        .get();
    if (users.isEmpty) {
      await (delete(tags)..where((t) => t.id.equals(collectionId))).go();
    }
  }
}
