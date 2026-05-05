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

@DriftDatabase(tables: [Books])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(books, books.bookFormat as GeneratedColumn);
        await m.addColumn(books, books.collectionName as GeneratedColumn);
        await m.addColumn(books, books.collectionNumber as GeneratedColumn);
        await m.addColumn(books, books.coverPath as GeneratedColumn);
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

  Future<int> deleteBook(int id) =>
      (delete(books)..where((b) => b.id.equals(id))).go();

  Future<Book?> getBook(int id) =>
      (select(books)..where((b) => b.id.equals(id))).getSingleOrNull();
}