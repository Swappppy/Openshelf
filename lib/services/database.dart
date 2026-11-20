import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../models/shelf.dart';
import '../models/tag_type.dart';
export '../models/tag_type.dart';

import 'daos/book_dao.dart';
import 'daos/tag_dao.dart';
import 'daos/shelf_dao.dart';
import 'daos/goal_dao.dart';
import 'daos/log_dao.dart';
import 'daos/stat_dao.dart';
import 'daos/read_history_dao.dart';
import 'daos/ownership_dao.dart';
import 'daos/search_history_dao.dart';

import 'database/converters.dart';
import 'database/tables/books_table.dart';
import 'database/tables/tags_table.dart';
import 'database/tables/shelves_table.dart';
import 'database/tables/shelf_tags_table.dart';
import 'database/tables/goals_table.dart';
import 'database/tables/logs_table.dart';
import 'database/tables/stats_table.dart';
import 'database/tables/read_history_table.dart';
import 'database/tables/ownership_log_table.dart';
import 'database/tables/search_history_table.dart';

export 'database/converters.dart';
export 'database/tables/books_table.dart';
export 'database/tables/tags_table.dart';
export 'database/tables/shelves_table.dart';
export 'database/tables/shelf_tags_table.dart';
export 'database/tables/goals_table.dart';
export 'database/tables/logs_table.dart';
export 'database/tables/stats_table.dart';
export 'database/tables/read_history_table.dart';
export 'database/tables/ownership_log_table.dart';
export 'database/tables/search_history_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Books, Tags, BookTags, Shelves, ShelfTags, ReadingGoals, ReadingLog, StatWidgetConfigs, ReadHistory, OwnershipLog, SearchHistory],
  daos: [BookDao, TagDao, ShelfDao, GoalDao, LogDao, StatDao, ReadHistoryDao, OwnershipDao, SearchHistoryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static const fileName = 'openshelf_db.sqlite';
  static const customPathPrefKey = 'app_db_path';

  /// Returns the configured custom database folder if it is set but the
  /// database file is not there (e.g. removed SD card, or settings restored
  /// on a new device). Used at startup to ask the user instead of silently
  /// creating a new, empty library.
  static String? missingCustomDatabaseDir(SharedPreferences prefs) {
    final custom = prefs.getString(customPathPrefKey);
    if (custom == null || custom.isEmpty) return null;
    return File(p.join(custom, fileName)).existsSync() ? null : custom;
  }

  @override
  int get schemaVersion => 31;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // IMPORTANT: never remove steps from this list. Users can upgrade from any
      // version that was ever released (v1.0.0 shipped schema 16). Every step is
      // written to be idempotent, because `createTable` always uses the CURRENT
      // table definition, so a table created by an early step may already
      // contain columns that a later step adds.
      // Covered by test/services/database_migration_test.dart.
      await customStatement('PRAGMA foreign_keys = OFF');

      if (from < 2) {
        await _addColumnIfMissing(m, books, books.bookFormat);
        await _addColumnIfMissing(m, books, books.collectionName);
        await _addColumnIfMissing(m, books, books.collectionNumber);
        await _addColumnIfMissing(m, books, books.coverPath);
      }
      if (from < 3) {
        await m.createTable(tags);
        await m.createTable(bookTags);
      }
      if (from < 4) {
        await m.createTable(shelves);
      }
      if (from < 5) {
        await _addColumnIfMissing(m, books, books.publishYear);
      }
      if (from < 6) {
        await _addColumnIfMissing(m, books, books.subtitle);
        await _addColumnIfMissing(m, books, books.language);
      }
      if (from < 7) {
        await _addColumnIfMissing(m, books, books.translator);
      }
      if (from < 8) {
        await _addColumnIfMissing(m, shelves, shelves.filterSubtitle);
        await _addColumnIfMissing(m, shelves, shelves.filterLanguage);
        await _addColumnIfMissing(m, shelves, shelves.filterTranslator);
      }
      if (from < 9) {
        await _addColumnIfMissing(m, shelves, shelves.filterImprintIds);
      }
      if (from < 10) {
        await m.createTable(readingGoals);
        await m.createTable(readingLog);
        await m.createTable(statWidgetConfigs);
      }
      if (from < 11) {
        await _addColumnIfMissing(m, books, books.description);
      }
      if (from < 12) {
        await _addColumnIfMissing(m, shelves, shelves.filterNoCover);
      }
      if (from < 13) {
        await _addColumnIfMissing(m, statWidgetConfigs, statWidgetConfigs.config);
      }
      if (from < 14) {
        await _addColumnIfMissing(m, books, books.collectionId);
        await _addColumnIfMissing(m, books, books.imprintId);
        await _addColumnIfMissing(m, shelves, shelves.filterCollectionIds);
        // Data part of this migration (collectionName -> collectionId) runs in beforeOpen.
      }
      if (from < 15) {
        await m.createTable(shelfTags);
      }
      if (from < 16) {
        // Recreate book_tags to get the composite primary key and ON DELETE CASCADE.
        await transaction(() async {
          final existing = await customSelect('SELECT book_id, tag_id FROM book_tags').get();
          await m.deleteTable('book_tags');
          await m.createTable(bookTags);
          for (final row in existing) {
            await into(bookTags).insert(
              BookTagsCompanion.insert(bookId: row.read<int>('book_id'), tagId: row.read<int>('tag_id')),
              mode: InsertMode.insertOrIgnore,
            );
          }
        });
      }
      if (from < 17) {
        // v17 also added a `reads` column that was later dropped (see v23).
        await _addColumnIfMissing(m, books, books.copies);
      }
      // v18 added `books.reading_sessions`, which v23 migrates and drops. It is not
      // re-created here: a database older than 18 has no session data to migrate.
      if (from < 19) {
        await _addColumnIfMissing(m, books, books.paginationConfig);
      }
      if (from < 20) {
        await m.createTable(readHistory);
      }
      if (from < 21) {
        await _addColumnIfMissing(m, readingLog, readingLog.sections);
        await _addColumnIfMissing(m, readHistory, readHistory.sections);
      }
      // v22: intentionally empty (schema change was folded into v23).
      if (from < 23) {
        await transaction(() async {
          await _addColumnIfMissing(m, readHistory, readHistory.progress);
          await _addColumnIfMissing(m, readHistory, readHistory.segmentProgress);
          await _migrateLegacyReadingSessions();
          // Drop the legacy columns. Done with DROP COLUMN instead of rebuilding
          // `books`, because dropping `books` would cascade into book_tags/read_history.
          for (final legacy in const ['reading_sessions', 'reads']) {
            if (await _columnExists('books', legacy)) {
              await customStatement('ALTER TABLE books DROP COLUMN $legacy');
            }
          }
        });
      }
      if (from < 24) {
        await _addColumnIfMissing(m, bookTags, bookTags.collectionNumber);
        await transaction(() async {
          final rows = await customSelect(
            'SELECT id, collection_id, collection_number FROM books WHERE collection_id IS NOT NULL',
          ).get();
          for (final row in rows) {
            await into(bookTags).insert(
              BookTagsCompanion.insert(
                bookId: row.read<int>('id'),
                tagId: row.read<int>('collection_id'),
                collectionNumber: Value(row.readNullable<int>('collection_number')),
              ),
              mode: InsertMode.insertOrIgnore,
            );
          }
        });
      }
      if (from < 25) {
        await _addColumnIfMissing(m, books, books.originalTitle);
        await _addColumnIfMissing(m, books, books.ownershipStatus);
        await m.createTable(ownershipLog);
      }
      if (from < 26) {
        await _addColumnIfMissing(m, books, books.originalLanguage);
      }
      if (from < 27) {
        await _addColumnIfMissing(m, shelves, shelves.filterBooleanQuery);
      }
      if (from < 28) {
        await _addColumnIfMissing(m, shelves, shelves.filterSearchMode);
      }
      if (from < 29) {
        await _addColumnIfMissing(m, shelves, shelves.filterFormat);
        await _addColumnIfMissing(m, shelves, shelves.filterOwnership);
      }
      if (from < 30) {
        await _addColumnIfMissing(m, shelves, shelves.filterNotes);
      }
      if (from < 31) {
        await m.createTable(searchHistory);
      }

      await customStatement('PRAGMA foreign_keys = ON');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated || details.hadUpgrade && details.versionBefore! < 14) {
        // We perform the data migration from collectionName to collectionId
        
        // 1. Books: Map collectionName to collectionId
        final allBooks = await select(books).get();
        for (final book in allBooks) {
          // Collection migration
          if (book.collectionName != null && book.collectionId == null) {
            final col = await (select(tags)
              ..where((t) => t.name.equals(book.collectionName!) & t.type.equals(TagType.collection.name))..limit(1)).getSingleOrNull();
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
              ..where(tags.type.equals(TagType.imprint.name))
              ..limit(1)).getSingleOrNull();
            
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
              ..where((t) => t.name.isIn(names) & t.type.equals(TagType.collection.name))).get();
            
            if (matchingTags.isNotEmpty) {
              final ids = matchingTags.map((t) => t.id).toList();
              await (update(shelves)..where((s) => s.id.equals(shelf.id))).write(ShelvesCompanion(
                filterCollectionIds: Value(json.encode(ids)),
              ));
            }
          }
        }
      }

      if (details.hadUpgrade && details.versionBefore! < 15) {
        // Data migration from JSON strings to ShelfTags table
        final allShelves = await select(shelves).get();
        for (final shelf in allShelves) {
          final tagIds = <int>[];
          
          if (shelf.filterTagIds != null) {
            try { tagIds.addAll((jsonDecode(shelf.filterTagIds!) as List).cast<int>()); } catch (_) {}
          }
          if (shelf.filterImprintIds != null) {
            try { tagIds.addAll((jsonDecode(shelf.filterImprintIds!) as List).cast<int>()); } catch (_) {}
          }
          if (shelf.filterCollectionIds != null) {
            try { tagIds.addAll((jsonDecode(shelf.filterCollectionIds!) as List).cast<int>()); } catch (_) {}
          }

          for (final tid in tagIds.toSet()) {
             await into(shelfTags).insert(ShelfTagsCompanion.insert(
               shelfId: shelf.id,
               tagId: tid,
             ), mode: InsertMode.insertOrIgnore);
          }
        }
      }

      // Default stats widgets are no longer initialized here to allow showing an empty state for new users
    }
  );

  Future<bool> _columnExists(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info("$table")').get();
    return rows.any((r) => r.read<String>('name') == column);
  }

  Future<void> _addColumnIfMissing(Migrator m, TableInfo table, GeneratedColumn column) async {
    if (!await _columnExists(table.actualTableName, column.name)) {
      await m.addColumn(table, column);
    }
  }

  /// v23: moves per-read progress that used to live in `books.reading_sessions`
  /// (JSON `{readNumber: pages}`) and in `pagination_config.segments[].sessions`
  /// into the `read_history` table.
  Future<void> _migrateLegacyReadingSessions() async {
    final hasSessions = await _columnExists('books', 'reading_sessions');
    final rows = await customSelect(
      hasSessions
          ? 'SELECT id, reading_sessions, pagination_config FROM books'
          : 'SELECT id, NULL AS reading_sessions, pagination_config FROM books',
    ).get();

    for (final row in rows) {
      final bookId = row.read<int>('id');

      final readingSessions = <int, int>{};
      final rawSessions = row.readNullable<String>('reading_sessions');
      if (rawSessions != null) {
        try {
          (jsonDecode(rawSessions) as Map<String, dynamic>).forEach((k, v) {
            final n = int.tryParse(k);
            if (n != null && v is num) readingSessions[n] = v.toInt();
          });
        } catch (_) {}
      }

      // readNumber -> {segmentIndex -> pagesRead}
      final segmentProgress = <int, Map<int, int>>{};
      final rawConfig = row.readNullable<String>('pagination_config');
      if (rawConfig != null) {
        try {
          final segments = (jsonDecode(rawConfig) as Map<String, dynamic>)['segments'] as List? ?? const [];
          for (var i = 0; i < segments.length; i++) {
            final sessions = (segments[i] as Map)['sessions'];
            if (sessions is! Map) continue;
            sessions.forEach((k, v) {
              final n = int.tryParse(k.toString());
              if (n != null && v is num) segmentProgress.putIfAbsent(n, () => {})[i] = v.toInt();
            });
          }
        } catch (_) {}
      }

      if (readingSessions.isEmpty && segmentProgress.isEmpty) continue;

      final history = await (select(readHistory)..where((h) => h.bookId.equals(bookId))).get();
      for (final h in history) {
        await (update(readHistory)..where((rh) => rh.id.equals(h.id))).write(ReadHistoryCompanion(
          progress: Value(readingSessions[h.readNumber] ?? h.progress),
          segmentProgress: Value(segmentProgress[h.readNumber] ?? h.segmentProgress),
        ));
      }
      final known = history.map((h) => h.readNumber).toSet();
      for (final n in {...readingSessions.keys, ...segmentProgress.keys}) {
        if (known.contains(n)) continue;
        await into(readHistory).insert(ReadHistoryCompanion.insert(
          bookId: bookId,
          readNumber: n,
          progress: Value(readingSessions[n] ?? 0),
          segmentProgress: Value(segmentProgress[n]),
        ));
      }
    }
  }

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final prefs = await SharedPreferences.getInstance();
      final customPath = prefs.getString(customPathPrefKey);

      final File dbFile;
      if (customPath != null && customPath.isNotEmpty) {
        dbFile = File(p.join(customPath, fileName));
        // Never create a fresh database in a custom folder: a missing file
        // there means the storage is unavailable (handled at startup).
        if (!await dbFile.exists()) {
          throw StateError('Library database not found at ${dbFile.path}');
        }
      } else {
        final dbFolder = await getApplicationDocumentsDirectory();
        dbFile = File(p.join(dbFolder.path, fileName));
      }

      if (!await dbFile.parent.exists()) {
        await dbFile.parent.create(recursive: true);
      }

      return NativeDatabase.createInBackground(
        dbFile,
        setup: (db) {
          db.execute('PRAGMA foreign_keys = ON');
        },
      );
    });
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      // 1. Delete tables that reference other tables but are not referenced themselves (Leaf nodes)
      await delete(statWidgetConfigs).go();
      await delete(readingLog).go();
      await delete(searchHistory).go();

      // 2. Delete tables with foreign keys to main entities
      await delete(readingGoals).go();
      await delete(readHistory).go();
      await delete(ownershipLog).go();

      // 3. Delete relationship tables (Many-to-Many)
      await delete(shelfTags).go();
      await delete(bookTags).go();

      // 4. Delete main entities (Parents)
      // Note: books has references to tags (collectionId, imprintId)
      await delete(books).go();
      await delete(shelves).go();
      await delete(tags).go(); // Clears Categories, Imprints, and Collections
    });
  }
}
