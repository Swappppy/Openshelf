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

part 'database.g.dart';

@DriftDatabase(
  tables: [Books, Tags, BookTags, Shelves, ShelfTags, ReadingGoals, ReadingLog, StatWidgetConfigs, ReadHistory, OwnershipLog],
  daos: [BookDao, TagDao, ShelfDao, GoalDao, LogDao, StatDao, ReadHistoryDao, OwnershipDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 30;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // ... previous migrations ...
      if (from < 27) {
        await m.addColumn(shelves, shelves.filterBooleanQuery as GeneratedColumn);
      }
      if (from < 28) {
        await m.addColumn(shelves, shelves.filterSearchMode as GeneratedColumn);
      }
      if (from < 29) {
        await m.addColumn(shelves, shelves.filterFormat as GeneratedColumn);
        await m.addColumn(shelves, shelves.filterOwnership as GeneratedColumn);
      }
      if (from < 30) {
        await m.addColumn(shelves, shelves.filterNotes as GeneratedColumn);
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
              ..where((t) => t.name.equals(book.collectionName!) & t.type.equals(TagType.collection.name))).getSingleOrNull();
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
              ..where(tags.type.equals(TagType.imprint.name))).getSingleOrNull();
            
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
      // 1. Delete tables that reference other tables but are not referenced themselves (Leaf nodes)
      await delete(statWidgetConfigs).go();
      await delete(readingLog).go();

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
