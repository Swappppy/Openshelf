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
      // Recoge los tagIds vinculados antes de borrar
      final linked = await (select(bookTags)
        ..where((bt) => bt.bookId.equals(id))).get();
      final tagIds = linked.map((bt) => bt.tagId).toList();

      // Borra las relaciones
      await (delete(bookTags)..where((bt) => bt.bookId.equals(id))).go();

      // Borra el libro
      await (delete(books)..where((b) => b.id.equals(id))).go();

      // Para cada tag, si ya no tiene libros asociados, bórralo
      for (final tagId in tagIds) {
        final remaining = await (select(bookTags)
          ..where((bt) => bt.tagId.equals(tagId))).get();
        if (remaining.isEmpty) {
          await (delete(tags)..where((t) => t.id.equals(tagId))).go();
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

  Future<int> deleteTag(int id) =>
      (delete(tags)..where((t) => t.id.equals(id))).go();

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
}