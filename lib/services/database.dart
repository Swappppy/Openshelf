import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../models/shelf.dart';
import '../models/tag_type.dart';

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
  TextColumn get description => text().nullable()();
  IntColumn get publishYear => integer().nullable()();
  IntColumn get collectionId => integer().nullable().references(Tags, #id)();
  IntColumn get imprintId => integer().nullable().references(Tags, #id)();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Tags table definition (used for Categories, Imprints, and Collections)
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  /// Type can be 'tag' (category), 'imprint', or 'collection'
  TextColumn get type => text().map(const TagTypeConverter()).withDefault(const Constant('tag'))();
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
  TextColumn get filterSubtitle => text().nullable()();
  TextColumn get filterAuthor => text().nullable()();
  TextColumn get filterPublisher => text().nullable()();
  TextColumn get filterIsbn => text().nullable()();
  TextColumn get filterLanguage => text().nullable()();
  TextColumn get filterTranslator => text().nullable()();
  TextColumn get filterCollectionIds => text().nullable()();
  TextColumn get filterStatus => text().nullable()();
  /// JSON-encoded list of tag IDs for the shelf filter
  TextColumn get filterTagIds => text().nullable()();
  TextColumn get filterImprintIds => text().nullable()();
  BoolColumn get filterNoCover => boolean().withDefault(const Constant(false))();
}

/// Reading Goals table
class ReadingGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  /// Type can be 'books' or 'pages'
  TextColumn get type => text()();
  IntColumn get targetValue => integer()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  /// Optional filters
  IntColumn get shelfId => integer().nullable().references(Shelves, #id)();
  IntColumn get collectionId => integer().nullable().references(Tags, #id)();
}

/// Reading Log table for tracking daily activity
class ReadingLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  DateTimeColumn get date => dateTime()();
  IntColumn get pagesRead => integer()();
}

/// Configuration for stats widgets layout
class StatWidgetConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// Type: 'pages', 'streak', 'goal', 'status', 'currentBook', 'addedOverTime', 'categories', 'publishYear', 'readList'
  TextColumn get type => text()();
  /// Size: 'half', 'full', 'fullTall'
  TextColumn get size => text()();
  IntColumn get sortOrder => integer()();
  IntColumn get goalId => integer().nullable().references(ReadingGoals, #id)();
  /// JSON-encoded configuration for the widget (e.g. time period)
  TextColumn get config => text().nullable()();
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

@DriftDatabase(tables: [Books, Tags, BookTags, Shelves, ReadingGoals, ReadingLog, StatWidgetConfigs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 14;

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
      if (from < 8) {
        try {
          await m.addColumn(shelves, shelves.filterSubtitle as GeneratedColumn);
          await m.addColumn(shelves, shelves.filterLanguage as GeneratedColumn);
          await m.addColumn(shelves, shelves.filterTranslator as GeneratedColumn);
        } catch (_) {}
      }
      if (from < 9) {
        try {
          await m.addColumn(shelves, shelves.filterImprintIds as GeneratedColumn);
        } catch (_) {}
      }
      if (from < 10) {
        await m.createTable(readingGoals);
        await m.createTable(readingLog);
        await m.createTable(statWidgetConfigs);
      }
      if (from < 11) {
        try {
          await m.addColumn(books, books.description as GeneratedColumn);
        } catch (_) {}
      }
      if (from < 12) {
        try {
          await m.addColumn(shelves, shelves.filterNoCover as GeneratedColumn);
        } catch (_) {}
      }
      if (from < 13) {
        try {
          await m.addColumn(statWidgetConfigs, statWidgetConfigs.config as GeneratedColumn);
        } catch (_) {}
      }
      if (from < 14) {
        await m.addColumn(books, books.collectionId as GeneratedColumn);
        await m.addColumn(books, books.imprintId as GeneratedColumn);
        await m.addColumn(shelves, shelves.filterCollectionIds as GeneratedColumn);
        // Migration logic for collectionId will be handled via transactional update after schema change
        // Drift migrations support post-schema-change actions
      }
    },
    beforeOpen: (details) async {
      if (details.wasCreated || details.hadUpgrade && details.versionBefore! < 14) {
        // We perform the data migration from collectionName to collectionId
        await customStatement('PRAGMA foreign_keys = ON');
        
        // 1. Books: Map collectionName to collectionId
        final allBooks = await select(books).get();
        for (final book in allBooks) {
          // Collection migration
          if (book.collectionName != null && book.collectionId == null) {
            final col = await (select(tags)
              ..where((t) => t.name.equals(book.collectionName!) & t.type.equalsValue(TagType.collection))).getSingleOrNull();
            if (col != null) {
              await (update(books)..where((b) => b.id.equals(book.id))).write(BooksCompanion(
                collectionId: Value(col.id),
              ));
            }
          }

          // Imprint migration from BookTags
          if (book.imprintId == null) {
            final imprintLink = await (select(bookTags).join([
              innerJoin(tags, tags.id.equalsExp(bookTags.tagId)),
            ])
              ..where(bookTags.bookId.equals(book.id))
              ..where(tags.type.equalsValue(TagType.imprint))).getSingleOrNull();
            
            if (imprintLink != null) {
              final tagId = imprintLink.readTable(bookTags).tagId;
              await (update(books)..where((b) => b.id.equals(book.id))).write(BooksCompanion(
                imprintId: Value(tagId),
              ));
            }
          }
        }

        // 2. Shelves: Map filterCollection (names) to filterCollectionIds (JSON)
        final allShelves = await select(shelves).get();
        for (final shelf in allShelves) {
          if (shelf.filterCollection != null && shelf.filterCollectionIds == null) {
            final names = shelf.filterCollection!.split(' | ');
            final matchingTags = await (select(tags)
              ..where((t) => t.name.isIn(names) & t.type.equalsValue(TagType.collection))).get();
            
            if (matchingTags.isNotEmpty) {
              final ids = matchingTags.map((t) => t.id).toList();
              await (update(shelves)..where((s) => s.id.equals(shelf.id))).write(ShelvesCompanion(
                filterCollectionIds: Value(json.encode(ids)),
              ));
            }
          }
        }
      }
    }
  );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final prefs = await SharedPreferences.getInstance();
      final customPath = prefs.getString('app_db_path');
      
      final File dbFile;
      if (customPath != null && customPath.isNotEmpty) {
        dbFile = File(p.join(customPath, 'openshelf_db.sqlite'));
      } else {
        final dbFolder = await getApplicationDocumentsDirectory();
        dbFile = File(p.join(dbFolder.path, 'openshelf_db.sqlite'));
      }

      // Ensure the directory exists and is writable
      if (!await dbFile.parent.exists()) {
        await dbFile.parent.create(recursive: true);
      }

      return NativeDatabase.createInBackground(dbFile);
    });
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

  /// Duplicates a book record and all its associated tags/imprints
  Future<int> duplicateBook(int originalId) async {
    return await transaction(() async {
      final original = await (select(books)..where((b) => b.id.equals(originalId))).getSingle();
      
      // Create companion without ID to trigger auto-increment
      final companion = original.toCompanion(false).copyWith(
        id: const Value.absent(),
        createdAt: Value(DateTime.now()),
      );
      
      final newId = await into(books).insert(companion);

      // Copy tag relationships
      final tags = await (select(bookTags)..where((bt) => bt.bookId.equals(originalId))).get();
      for (final tag in tags) {
        await into(bookTags).insert(BookTagsCompanion.insert(
          bookId: newId,
          tagId: tag.tagId,
        ));
      }

      return newId;
    });
  }

  Future<void> deleteBook(int id) async {
    await transaction(() async {
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
          if (t != null && t.type == TagType.tag) {
            await (delete(tags)..where((t) => t.id.equals(tagId))).go();
          }
        }
      }
    });
  }

  Future<Book?> getBook(int id) =>
      (select(books)..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<Book?> getBookByIsbn(String isbn) =>
      (select(books)..where((b) => b.isbn.equals(isbn))).getSingleOrNull();

  Future<bool> existsByTitleAndAuthor(String title, String author) async {
    final query = select(books)
      ..where((b) =>
          b.title.lower().equals(title.toLowerCase()) &
          b.author.lower().equals(author.toLowerCase()));
    final match = await query.getSingleOrNull();
    return match != null;
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(bookTags).go();
      await delete(books).go();
      await delete(shelves).go();
      await delete(tags).go(); // Clears Categories, Imprints, and Collections
      await delete(readingGoals).go();
      await delete(readingLog).go();
      await delete(statWidgetConfigs).go();
    });
  }

  // --- Collection Operations ---

  Future<int> getOrCreateCollection(String name) async {
    final existing = await (select(tags)
      ..where((t) => t.name.equals(name) & t.type.equalsValue(TagType.collection)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return insertTag(TagsCompanion(
      name: Value(name),
      type: const Value(TagType.collection),
    ));
  }

  // --- Tag/Category Operations ---

  Future<int> insertTag(TagsCompanion tag) => into(tags).insert(tag);

  Future<List<Tag>> getTagsByType(TagType type) =>
      (select(tags)..where((t) => t.type.equalsValue(type))).get();

  Future<List<Tag>> getTagsByIds(List<int> ids) =>
      (select(tags)..where((t) => t.id.isIn(ids))).get();

  Future<List<Tag>> searchTags(String query, TagType type) =>
      (select(tags)
        ..where((t) => t.name.contains(query) & t.type.equalsValue(type)))
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
      ..where(tags.type.equalsValue(TagType.tag));

    return query.watch().map(
          (rows) => rows.map((r) => r.readTable(tags)).toList(),
    );
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
      (select(tags)..where((t) => t.type.equalsValue(type))).watch();

  Stream<List<(Tag, int)>> watchTagsByTypeWithCounts(TagType type) {
    if (type == TagType.imprint) {
      final countExp = books.id.count();
      final query = select(tags).join([
        leftOuterJoin(books, books.imprintId.equalsExp(tags.id)),
      ])
        ..where(tags.type.equalsValue(type))
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
      ..where(tags.type.equalsValue(type))
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
    final countExp = books.id.count();
    final query = select(tags).join([
      leftOuterJoin(books, books.collectionId.equalsExp(tags.id)),
    ])
      ..where(tags.type.equalsValue(TagType.collection))
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

  Future<void> setBookImprint(int bookId, int? imprintId) async {
    await (update(books)..where((b) => b.id.equals(bookId))).write(BooksCompanion(
      imprintId: Value(imprintId),
    ));
  }

  Future<void> pruneCollectionIfOrphan(int collectionId) async {
    final users = await (select(books)
          ..where((b) => b.collectionId.equals(collectionId)))
        .get();
    if (users.isEmpty) {
      await (delete(tags)..where((t) => t.id.equals(collectionId))).go();
    }
  }

  // --- Filtering & Search ---

  Stream<List<Book>> watchBooksFiltered({
    String? query,
    List<int>? tagIds,
    String? author,
    String? publisher,
    String? isbn,
    String? language,
    List<int>? collectionIds,
    List<int>? imprintIds,
    bool? noCover,
  }) {
    // If filtering by general tags, use the complex M:M join query.
    // Imprints and Collections now live in dedicated columns, so they are handled in the standard query below.
    if (tagIds != null && tagIds.isNotEmpty) {
      return _watchBooksWithTags(
        query: query,
        tagIds: tagIds,
        author: author,
        publisher: publisher,
        isbn: isbn,
        language: language,
        collectionIds: collectionIds,
        imprintIds: imprintIds,
        noCover: noCover,
      );
    }

    // Standard column filtering (handles titles, authors, collections, and now imprints)
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
        if (language != null && language.isNotEmpty) {
          expr = expr & b.language.contains(language);
        }
        if (collectionIds != null && collectionIds.isNotEmpty) {
          expr = expr & b.collectionId.isIn(collectionIds);
        }
        if (imprintIds != null && imprintIds.isNotEmpty) {
          expr = expr & b.imprintId.isIn(imprintIds);
        }
        if (noCover == true) {
          expr = expr & (b.coverPath.isNull() | b.coverPath.equals(''));
        }
        return expr;
      });
    return q.watch();
  }

  /// Complex filtering using the M:M relationship with Tags (only for TagType.tag)
  Stream<List<Book>> _watchBooksWithTags({
    String? query,
    List<int>? tagIds,
    String? author,
    String? publisher,
    String? isbn,
    String? language,
    List<int>? collectionIds,
    List<int>? imprintIds,
    bool? noCover,
  }) {
    if (tagIds == null || tagIds.isEmpty) {
      return watchBooksFiltered(
        query: query,
        author: author,
        publisher: publisher,
        isbn: isbn,
        language: language,
        collectionIds: collectionIds,
        imprintIds: imprintIds,
        noCover: noCover,
      );
    }

    // Optimization: Use custom SQL to find books matching ALL required tags (Intersection)
    final amountOfTags = tagIds.length;
    final placeholders = tagIds.map((_) => '?').join(',');
    final sql = '''
      SELECT book_id FROM book_tags
      WHERE tag_id IN ($placeholders)
      GROUP BY book_id
      HAVING COUNT(DISTINCT tag_id) >= ?
    ''';

    return customSelect(
      sql, 
      variables: [
        ...tagIds.map((id) => Variable<int>(id)),
        Variable<int>(amountOfTags),
      ]
    ).watch().asyncMap((rows) async {
      final validBookIds = rows.map((r) => r.read<int>('book_id')).toList();
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
          if (language != null && language.isNotEmpty) {
            expr = expr & b.language.contains(language);
          }
          if (collectionIds != null && collectionIds.isNotEmpty) {
            expr = expr & b.collectionId.isIn(collectionIds);
          }
          if (imprintIds != null && imprintIds.isNotEmpty) {
            expr = expr & b.imprintId.isIn(imprintIds);
          }
          if (noCover == true) {
            expr = expr & (b.coverPath.isNull() | b.coverPath.equals(''));
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

  // --- Reading Goal Operations ---
  Stream<List<ReadingGoal>> watchAllGoals() => select(readingGoals).watch();
  Future<int> insertGoal(ReadingGoalsCompanion goal) => into(readingGoals).insert(goal);
  Future<bool> updateGoal(ReadingGoal goal) => update(readingGoals).replace(goal);
  Future<void> deleteGoal(int id) => (delete(readingGoals)..where((t) => t.id.equals(id))).go();

  // --- Reading Log Operations ---
  Stream<List<ReadingLogData>> watchLogs() => select(readingLog).watch();
  Stream<List<ReadingLogData>> watchLogForBook(int bookId) =>
      (select(readingLog)..where((l) => l.bookId.equals(bookId))).watch();
  Future<int> insertLog(ReadingLogCompanion log) => into(readingLog).insert(log);
  Future<void> deleteLog(int id) => (delete(readingLog)..where((l) => l.id.equals(id))).go();

  // --- Stat Widget Operations ---
  Stream<List<StatWidgetConfig>> watchWidgetConfigs() =>
      (select(statWidgetConfigs)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).watch();
  Future<int> insertWidgetConfig(StatWidgetConfigsCompanion config) => into(statWidgetConfigs).insert(config);
  Future<bool> updateWidgetConfig(StatWidgetConfig config) => update(statWidgetConfigs).replace(config);
  Future<void> deleteWidgetConfig(int id) => (delete(statWidgetConfigs)..where((t) => t.id.equals(id))).go();
}
