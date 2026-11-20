import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/database.dart';

import '../generated_migrations/schema.dart';

/// Schemas in drift_schemas/ were dumped from the released tags:
/// v16 = v1.0.x, v23 = v1.1.x, v26 = v1.2.x, v30 = v1.3.x–v1.4.x, v31 = v1.5.x.
/// When bumping schemaVersion, run:
///   dart run drift_dev schema dump lib/services/database.dart drift_schemas/
///   dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  for (final from in GeneratedHelper.versions.where((v) => v < 31)) {
    test('upgrade from released schema v$from produces the current schema', () async {
      final connection = await verifier.startAt(from);
      final db = AppDatabase(connection);
      await verifier.migrateAndValidate(db, 31);
      await db.close();
    });
  }

  test('v16 (v1.0.0) data survives the upgrade', () async {
    final schema = await verifier.schemaAt(16);
    final raw = schema.rawDatabase;
    raw.execute("INSERT INTO tags (id, name, type) VALUES (1, 'Sci-Fi', 'tag'), (2, 'Dune Saga', 'collection')");
    raw.execute("INSERT INTO books (id, title, author, status, collection_name, collection_id, collection_number, created_at) "
        "VALUES (1, 'Dune', 'Herbert', 'read', 'Dune Saga', 2, 1, 0)");
    raw.execute('INSERT INTO book_tags (book_id, tag_id) VALUES (1, 1)');

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 31);

    final book = await (db.select(db.books)..where((b) => b.id.equals(1))).getSingle();
    expect(book.title, 'Dune');
    expect(book.copies, 1);
    expect(book.collectionId, 2, reason: 'collection link must be preserved');
    final links = await db.select(db.bookTags).get();
    expect(links.map((l) => l.tagId), containsAll([1, 2]));
    expect(links.firstWhere((l) => l.tagId == 2).collectionNumber, 1);
    await db.close();
  });

  test('legacy reading_sessions/reads columns (v18–v22) are migrated and dropped', () async {
    final schema = await verifier.schemaAt(16);
    final raw = schema.rawDatabase;
    // Simulate what v17/v18 added with raw SQL.
    raw.execute('ALTER TABLE books ADD COLUMN reads INTEGER DEFAULT 0');
    raw.execute("ALTER TABLE books ADD COLUMN reading_sessions TEXT DEFAULT '{}'");
    raw.execute("INSERT INTO books (id, title, author, status, created_at, reading_sessions) "
        "VALUES (1, 'B', 'A', 'reading', 0, '{\"1\": 120, \"2\": 30}')");

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 31);

    final history = await (db.select(db.readHistory)..orderBy([(h) => OrderingTerm(expression: h.readNumber)])).get();
    expect(history.map((h) => (h.readNumber, h.progress)), [(1, 120), (2, 30)]);
    final cols = await db.customSelect('PRAGMA table_info(books)').get();
    expect(cols.map((c) => c.read<String>('name')), isNot(contains('reading_sessions')));
    await db.close();
  });
}
