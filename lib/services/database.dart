import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/shelf.dart';

part 'database.g.dart';

/// Books table definition
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get author => text()();
  TextColumn get isbn => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get translator => text().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  IntColumn get totalPages => integer().nullable()();
  IntColumn get currentPage => integer().nullable()();
  TextColumn get status => textEnum<ReadingStatus>()();
  RealColumn get rating => real().nullable()();
  TextColumn get bookFormat => text().nullable().map(
    const BookFormatConverter(),
  )();
  TextColumn get collectionName => text().nullable()();
  IntColumn get collectionNumber => integer().nullable()();
  TextColumn get coverPath => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get publishYear => integer().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Tags table definition (used for Categories, Imprints, and Collections)
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  /// Type can be 'tag' (category), 'imprint', or 'collection'
  TextColumn get type => text().withDefault(const Constant('tag'))();
  TextColumn get color => text().nullable()();
  TextColumn get imagePath => text().nullable()();
}

/// Many-to-Many relationship between Books and Tags
class BookTags extends Table {
  IntColumn get bookId => integer().references(Books, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {bookId, tagId};
}

/// Dynamic Shelves table definition (Saved smart-filters)
@UseRowClass(Shelf)
class Shelves extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get filterQuery => text().nullable()();
  TextColumn get filterAuthor => text().nullable()();
  TextColumn get filterPublisher => text().nullable()();
  TextColumn get filterIsbn => text().nullable()();
  TextColumn get filterCollection => text().nullable()();
  TextColumn get filterStatus => text().nullable()();
  /// JSON-encoded list of tag IDs for the shelf filter
  TextColumn get filterTagIds => text().nullable()();
  IntColumn get filterImprintId => integer().nullable()();
}

enum ReadingStatus {
  wantToRead,
  reading,
  read,
  abandoned,
  paused,
}

enum BookFormat {
  paperback,
  hardcover,
  leatherbound,
  rustic,
  digital,
  other,
}

/// Converts between BookFormat enum and String for DB storage
class BookFormatConverter extends TypeConverter<BookFormat?, String?> {
  const BookFormatConverter();

  @override
  BookFormat? fromSql(String? fromDb) {
    if (fromDb == null) return null;
    return BookFormat.values.firstWhere(
          (e) => e.name == fromDb,
      orElse: () => BookFormat.other,
    );
  }

  @override
  String? toSql(BookFormat? value) => value?.name;
}

@DriftDatabase(tables: [Books, Tags, BookTags, Shelves])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(books, books.bookFormat as GeneratedColumn);
        await m.addColumn(books, books.collectionName as GeneratedColumn);
        await m.addColumn(books, books.collectionNumber as GeneratedColumn);
        await m.addColumn(books, books.coverPath as GeneratedColumn);
      }
      if (from < 3) {
        await m.createTable(tags);
        await m.createTable(bookTags);
      }
      if (from < 4) {
        await m.createTable(shelves);
      }
      if (from < 5) {
        await m.addColumn(books, books.publishYear as GeneratedColumn);
      }
      if (from < 6) {
        // Guard against duplicate column if version 6 was partially applied
        try {
          await m.addColumn(books, books.subtitle as GeneratedColumn);
        } catch (_) {}
        try {
          await m.addColumn(books, books.language as GeneratedColumn);
        } catch (_) {}
      }
      if (from < 7) {
        // Guard against duplicate column if version 7 was partially applied
        try {
          await m.addColumn(books, books.translator as GeneratedColumn);
        } catch (_) {}
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'openshelf_db');
  }

  // --- Book Operations ---

  Stream<List<Book>> watchAllBooks() => select(books).watch();

  Stream<List<Book>> watchBooksByStatus(ReadingStatus status) {
    return (select(books)
      ..where((b) => b.status.equalsValue(status)))
        .watch();
  }

  Stream<Book?> watchBookById(int id) =>
      (select(books)..where((b) => b.id.equals(id))).watchSingleOrNull();

  Future<int> insertBook(BooksCompanion book) => into(books).insert(book);

  Future<bool> updateBook(Book book) => update(books).replace(book);

  /// Deletes a book and performs cleanup of orphan tags/collections
  Future<void> deleteBook(int id) async {
    await transaction(() async {
      final book = await (select(books)..where((b) => b.id.equals(id)))
          .getSingleOrNull();

      final linked = await (select(bookTags)
        ..where((bt) => bt.bookId.equals(id))).get();
      final tagIds = linked.map((bt) => bt.tagId).toList();

      await (delete(bookTags)..where((bt) => bt.bookId.equals(id))).go();
      await (delete(books)..where((b) => b.id.equals(id))).go();

      // Clean up orphan categories (tags)
      for (final tagId in tagIds) {
        final remaining = await (select(bookTags)
          ..where((bt) => bt.tagId.equals(tagId))).get();
        if (remaining.isEmpty) {
          final t = await (select(tags)..where((t) => t.id.equals(tagId)))
              .getSingleOrNull();
          if (t != null && t.type == 'tag') {
            await (delete(tags)..where((t) => t.id.equals(tagId))).go();
          }
        }
      }

      // Clean up orphan collection reference if no more books use it
      if (book != null && book.collectionName != null) {
        final others = await (select(books)
          ..where((b) => b.collectionName.equals(book.collectionName!)))
            .get();
        if (others.isEmpty) {
          await (delete(tags)
            ..where((t) =>
            t.name.equals(book.collectionName!) &
            t.type.equals('collection'))).go();
        }
      }
    });
  }

  Future<Book?> getBook(int id) =>
      (select(books)..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<Book?> getBookByIsbn(String isbn) =>
      (select(books)..where((b) => b.isbn.equals(isbn))).getSingleOrNull();

  Future<void> deleteAllBooks() async {
    await transaction(() async {
      await delete(bookTags).go();
      await delete(books).go();
      // Also prune orphan tags that are not imprints or collections
      final allTags = await select(tags).get();
      for (final tag in allTags) {
        if (tag.type == 'tag') {
          await (delete(tags)..where((t) => t.id.equals(tag.id))).go();
        }
      }
    });
  }

  // --- Collection Operations ---

  Future<int> getOrCreateCollection(String name) async {
    final existing = await (select(tags)
      ..where((t) => t.name.equals(name) & t.type.equals('collection')))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return insertTag(TagsCompanion(
      name: Value(name),
      type: const Value('collection'),
    ));
  }

  // --- Tag/Category Operations ---

  Future<int> insertTag(TagsCompanion tag) => into(tags).insert(tag);

  Future<List<Tag>> getTagsByType(String type) =>
      (select(tags)..where((t) => t.type.equals(type))).get();

  Future<List<Tag>> searchTags(String query, String type) =>
      (select(tags)
        ..where((t) => t.name.contains(query) & t.type.equals(type)))
          .get();

  Future<bool> updateTag(Tag tag) => update(tags).replace(tag);

  Future<void> deleteTag(int id) async {
    await transaction(() async {
      final tag = await (select(tags)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      // If deleting a collection, we must clear the references in Books table
      if (tag != null && tag.type == 'collection') {
        await (update(books)
          ..where((b) => b.collectionName.equals(tag.name)))
            .write(const BooksCompanion(
          collectionName: Value(null),
          collectionNumber: Value(null),
        ));
      }
      // Remove M:M links
      await (delete(bookTags)..where((bt) => bt.tagId.equals(id))).go();
      // Delete the tag itself
      await (delete(tags)..where((t) => t.id.equals(id))).go();
    });
  }

  // --- Book-Tag Relationship Operations ---

  Future<void> setBookTags(int bookId, List<int> tagIds) async {
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
    });
  }

  Future<void> pruneOrphanTags() async {
    final allTags = await select(tags).get();
    for (final tag in allTags) {
      // Imprints and collections are managed manually, don't auto-prune
      if (tag.type == 'imprint' || tag.type == 'collection') continue;
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
      ..where(tags.type.equals('tag'));

    return query.watch().map(
          (rows) => rows.map((r) => r.readTable(tags)).toList(),
    );
  }

  Stream<Tag?> watchImprintForBook(int bookId) {
    final query = select(tags).join([
      innerJoin(bookTags, bookTags.tagId.equalsExp(tags.id)),
    ])
      ..where(bookTags.bookId.equals(bookId))
      ..where(tags.type.equals('imprint'));

    return query.watch().map(
          (rows) => rows.isEmpty ? null : rows.first.readTable(tags),
    );
  }

  Stream<List<Tag>> watchTagsByType(String type) =>
      (select(tags)..where((t) => t.type.equals(type))).watch();

  Future<int> getBookCountByImprint(int imprintId) async {
    final rows = await (select(bookTags)
      ..where((bt) => bt.tagId.equals(imprintId)))
        .get();
    return rows.length;
  }

  Stream<int> watchBookCountByImprint(int imprintId) {
    return (select(bookTags)
      ..where((bt) => bt.tagId.equals(imprintId)))
        .watch()
        .map((rows) => rows.length);
  }

  Future<void> setBookImprint(int bookId, int? imprintId) async {
    await transaction(() async {
      // Delete old imprint links for this book
      final oldLinks = await (select(bookTags)
        ..where((bt) => bt.bookId.equals(bookId))).get();
      for (final link in oldLinks) {
        final t = await (select(tags)..where((t) => t.id.equals(link.tagId)))
            .getSingleOrNull();
        if (t != null && t.type == 'imprint') {
          await (delete(bookTags)
            ..where((bt) =>
            bt.bookId.equals(bookId) &
            bt.tagId.equals(link.tagId))).go();
        }
      }
      // Insert new imprint link if provided
      if (imprintId != null) {
        await into(bookTags).insert(
          BookTagsCompanion(
            bookId: Value(bookId),
            tagId: Value(imprintId),
          ),
        );
      }
    });
  }

  Future<void> pruneCollectionIfOrphan(String collectionName) async {
    final users = await (select(books)
      ..where((b) => b.collectionName.equals(collectionName))).get();
    if (users.isEmpty) {
      await (delete(tags)
        ..where((t) =>
        t.name.equals(collectionName) &
        t.type.equals('collection'))).go();
    }
  }

  // --- Filtering & Search ---

  Stream<List<Book>> watchBooksFiltered({
    String? query,
    List<int>? tagIds,
    String? author,
    String? publisher,
    String? isbn,
    String? collectionName,
    List<int>? imprintIds,
  }) {
    // If filtering by tags or imprints, use the complex join query
    if ((tagIds != null && tagIds.isNotEmpty) || (imprintIds != null && imprintIds.isNotEmpty)){
      return _watchBooksWithTags(
        query: query,
        tagIds: tagIds,
        author: author,
        publisher: publisher,
        isbn: isbn,
        collectionName: collectionName,
        imprintIds: imprintIds,
      );
    }

    // Standard column filtering
    final q = select(books)
      ..where((b) {
        Expression<bool> expr = const Constant(true);
        if (query != null && query.isNotEmpty) {
          expr = expr & b.title.contains(query);
        }
        if (author != null && author.isNotEmpty) {
          expr = expr & b.author.contains(author);
        }
        if (publisher != null && publisher.isNotEmpty) {
          expr = expr & b.publisher.contains(publisher);
        }
        if (isbn != null && isbn.isNotEmpty) {
          expr = expr & b.isbn.contains(isbn);
        }
        if (collectionName != null && collectionName.isNotEmpty) {
          expr = expr & b.collectionName.contains(collectionName);
        }
        return expr;
      });
    return q.watch();
  }

  /// Complex filtering using the M:M relationship with Tags
  Stream<List<Book>> _watchBooksWithTags({
    String? query,
    List<int>? tagIds,
    String? author,
    String? publisher,
    String? isbn,
    String? collectionName,
    List<int>? imprintIds,
  }) {
    final allRequiredTagIds = [
      ...?tagIds,
      ...?imprintIds,
    ].whereType<int>().toSet().toList();

    if (allRequiredTagIds.isEmpty) return watchAllBooks();

    return (select(bookTags)
      ..where((bt) => bt.tagId.isIn(allRequiredTagIds)))
        .watch()
        .asyncMap((links) async {
      final Map<int, Set<int>> bookToTags = {};
      for (final link in links) {
        bookToTags.putIfAbsent(link.bookId, () => {}).add(link.tagId);
      }
      
      // We only want books that match ALL required tags (Intersection logic)
      final validBookIds = bookToTags.entries
          .where((e) => e.value.length >= allRequiredTagIds.length)
          .map((e) => e.key)
          .toList();

      if (validBookIds.isEmpty) return <Book>[];

      final q = select(books)
        ..where((b) {
          Expression<bool> expr = b.id.isIn(validBookIds);
          if (query != null && query.isNotEmpty) {
            expr = expr & b.title.contains(query);
          }
          if (author != null && author.isNotEmpty) {
            expr = expr & b.author.contains(author);
          }
          if (publisher != null && publisher.isNotEmpty) {
            expr = expr & b.publisher.contains(publisher);
          }
          if (isbn != null && isbn.isNotEmpty) {
            expr = expr & b.isbn.contains(isbn);
          }
          if (collectionName != null && collectionName.isNotEmpty) {
            expr = expr & b.collectionName.contains(collectionName);
          }
          return expr;
        });
      return q.get();
    });
  }

  // --- Shelf Operations ---

  Stream<List<Shelf>> watchAllShelves() => select(shelves).watch();

  Future<int> insertShelf(ShelvesCompanion shelf) =>
      into(shelves).insert(shelf);

  Future<bool> updateShelf(Shelf shelf) => update(shelves).replace(shelf);

  Future<void> deleteShelf(int id) =>
      (delete(shelves)..where((s) => s.id.equals(id))).go();

}