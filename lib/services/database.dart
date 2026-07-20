import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../models/shelf.dart';
import '../models/tag_type.dart';

import 'daos/book_dao.dart';
import 'daos/tag_dao.dart';
import 'daos/shelf_dao.dart';
import 'daos/goal_dao.dart';
import 'daos/log_dao.dart';
import 'daos/stat_dao.dart';
import 'daos/read_history_dao.dart';

import 'database/converters.dart';
import 'database/tables/books_table.dart';
import 'database/tables/tags_table.dart';
import 'database/tables/shelves_table.dart';
import 'database/tables/shelf_tags_table.dart';
import 'database/tables/goals_table.dart';
import 'database/tables/logs_table.dart';
import 'database/tables/stats_table.dart';
import 'database/tables/read_history_table.dart';

export 'database/converters.dart';
export 'database/tables/books_table.dart';
export 'database/tables/tags_table.dart';
export 'database/tables/shelves_table.dart';
export 'database/tables/shelf_tags_table.dart';
export 'database/tables/goals_table.dart';
export 'database/tables/logs_table.dart';
export 'database/tables/stats_table.dart';
export 'database/tables/read_history_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Books, Tags, BookTags, Shelves, ShelfTags, ReadingGoals, ReadingLog, StatWidgetConfigs, ReadHistory],
  daos: [BookDao, TagDao, ShelfDao, GoalDao, LogDao, StatDao, ReadHistoryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 23;

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
      if (from < 15) {
        await m.createTable(shelfTags);
      }
      if (from < 16) {
        await transaction(() async {
          // 1. Get existing data
          final existing = await customSelect('SELECT book_id, tag_id FROM book_tags').get();
          // 2. Drop and recreate
          await m.deleteTable('book_tags');
          await m.createTable(bookTags);
          // 3. Restore data
          for (final row in existing) {
            await into(bookTags).insert(BookTagsCompanion.insert(
              bookId: row.read<int>('book_id'),
              tagId: row.read<int>('tag_id'),
            ));
          }
        });
      }
      if (from < 17) {
        try {
          await customStatement('ALTER TABLE books ADD COLUMN reads INTEGER DEFAULT 0');
        } catch (_) {}
        try {
          await m.addColumn(books, books.copies);
        } catch (_) {}
      }
      if (from < 18) {
        try {
          await customStatement("ALTER TABLE books ADD COLUMN reading_sessions TEXT DEFAULT '{}'");
        } catch (_) {}
      }
      if (from < 19) {
        try {
          await m.addColumn(books, books.paginationConfig as GeneratedColumn);
        } catch (_) {}
      }
      if (from < 20) {
        await m.createTable(readHistory);
      }
      if (from < 21) {
        // Guarded: if `from < 20` just ran in this same upgrade, createTable(readHistory)
        // already created the table with the CURRENT class schema (sections/progress/
        // segmentProgress included), so these columns may already exist.
        try {
          await m.addColumn(readingLog, readingLog.sections as GeneratedColumn);
        } catch (_) {}
        try {
          await m.addColumn(readHistory, readHistory.sections as GeneratedColumn);
        } catch (_) {}
      }
      if (from < 22) {
        // Skip alterTable here to avoid premature removal of columns like reading_sessions
        // which are needed for the version 23 migration.
      }
      if (from < 23) {
        await transaction(() async {
          // 1. Add new columns to ReadHistory
          // Guarded for the same reason as above: a fresh createTable at `from < 20`
          // already includes these columns.
          try {
            await m.addColumn(readHistory, readHistory.progress);
          } catch (_) {}
          try {
            await m.addColumn(readHistory, readHistory.segmentProgress);
          } catch (_) {}

          // 2. Migrate data from Books.readingSessions and PaginationConfig.segments.sessions
          List<QueryRow> allBooks;
          try {
            allBooks = await customSelect('SELECT id, reading_sessions, pagination_config FROM books').get();
          } catch (e) {
            // If reading_sessions is already missing, we can't migrate its data
            allBooks = [];
          }

          for (final row in allBooks) {
            final bookId = row.read<int>('id');
            final readingSessionsRaw = row.readNullable<String>('reading_sessions');
            final paginationConfigRaw = row.readNullable<String>('pagination_config');

            Map<int, int> readingSessions = {};
            if (readingSessionsRaw != null) {
              try {
                final Map<String, dynamic> decoded = jsonDecode(readingSessionsRaw);
                readingSessions = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
              } catch (_) {}
            }

            // Extract segment progress per session
            final segmentProgressPerSession = <int, Map<int, int>>{}; // readNumber -> {segmentIndex -> pagesRead}
            if (paginationConfigRaw != null) {
              try {
                // We use custom logic to extract 'sessions' from raw JSON if needed,
                // but during migration PaginationConfig.fromJson will fail if 'sessions' is missing in model.
                // Wait, if I changed the model, fromJson won't see 'sessions'.
                // I should parse the raw JSON manually here.
                final Map<String, dynamic> rawConfig = jsonDecode(paginationConfigRaw);
                final List<dynamic> rawSegments = rawConfig['segments'] ?? [];
                for (int i = 0; i < rawSegments.length; i++) {
                  final s = rawSegments[i];
                  final Map<String, dynamic> segmentSessionsRaw = s['sessions'] ?? {};
                  segmentSessionsRaw.forEach((sessionKey, progress) {
                    final sessionNum = int.tryParse(sessionKey);
                    if (sessionNum != null) {
                      segmentProgressPerSession.putIfAbsent(sessionNum, () => {})[i] = progress as int;
                    }
                  });
                }
              } catch (_) {}
            }

            // Update ReadHistory entries
            final history = await (select(readHistory)..where((h) => h.bookId.equals(bookId))).get();
            for (final h in history) {
              final sessionProgress = readingSessions[h.readNumber] ?? 0;
              final segProgress = segmentProgressPerSession[h.readNumber];
              
              await (update(readHistory)..where((rh) => rh.id.equals(h.id))).write(
                ReadHistoryCompanion(
                  progress: Value(sessionProgress),
                  segmentProgress: Value(segProgress != null ? jsonEncode(segProgress.map((k, v) => MapEntry(k.toString(), v))) : null),
                ),
              );
            }
          }

          // 3. Drop and recreate books table to remove the column (SQLite doesn't support DROP COLUMN easily via drift alterTable for all cases)
          // Drift's alterTable handles column removal by recreating the table if necessary.
          await m.alterTable(TableMigration(books));
        });
      }
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

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(shelfTags).go();
      await delete(bookTags).go();
      await delete(books).go();
      await delete(shelves).go();
      await delete(tags).go(); // Clears Categories, Imprints, and Collections
      await delete(readingGoals).go();
      await delete(readingLog).go();
      await delete(statWidgetConfigs).go();
    });
  }
}
