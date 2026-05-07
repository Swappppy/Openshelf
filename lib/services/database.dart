import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  TextColumn get isbn => text().nullable()();
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
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text().withDefault(const Constant('tag'))();
  TextColumn get color => text().nullable()();
  TextColumn get imagePath => text().nullable()();
}

class BookTags extends Table {
  IntColumn get bookId => integer().references(Books, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {bookId, tagId};
}

enum ReadingStatus {
  wantToRead,
  reading,
  read,
  abandoned,
}

enum BookFormat {
  paperback,    // Tapa blanda
  hardcover,    // Tapa dura
  leatherbound, // Piel
  rustic,       // Rústica
  digital,      // Digital
  other,        // Otro
}

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

@DriftDatabase(tables: [Books, Tags, BookTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

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
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'openshelf_db');
  }

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

  Future<void> deleteBook(int id) async {
    await transaction(() async {
      final book = await (select(books)..where((b) => b.id.equals(id)))
          .getSingleOrNull();

      final linked = await (select(bookTags)
        ..where((bt) => bt.bookId.equals(id))).get();
      final tagIds = linked.map((bt) => bt.tagId).toList();

      await (delete(bookTags)..where((bt) => bt.bookId.equals(id))).go();
      await (delete(books)..where((b) => b.id.equals(id))).go();

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

  // --- Colección  ---
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

  // --- Tags ---
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
      // Si es una colección, limpiar los libros que la usan
      final tag = await (select(tags)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (tag != null && tag.type == 'collection') {
        await (update(books)
          ..where((b) => b.collectionName.equals(tag.name)))
            .write(const BooksCompanion(
          collectionName: Value(null),
          collectionNumber: Value(null),
        ));
      }
      // Borrar relaciones libro↔tag
      await (delete(bookTags)..where((bt) => bt.tagId.equals(id))).go();
      // Borrar el tag
      await (delete(tags)..where((t) => t.id.equals(id))).go();
    });
  }

// --- Relación libro<->tags ---
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
      // Imprints y colecciones se gestionan manualmente, no se auto-borran
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

  Future<void> setBookImprint(int bookId, int? imprintId) async {
    await transaction(() async {
      // Borrar sello anterior
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
      // Insertar nuevo sello si hay uno
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
}