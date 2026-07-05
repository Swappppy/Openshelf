import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/tag_type.dart';
import 'database.dart';
import 'cover_service.dart';
import 'import_export_base.dart';

/// Service for exporting and importing the entire library database via CSV and ZIP.
class DataMigrationService {
  final AppDatabase _db;
  final Map<String, int> _tagCache = {};

  DataMigrationService(this._db);

  // --- Export ---

  Future<String> exportBooksToCsv() async {
    final books = await _db.bookDao.select(_db.bookDao.books).get();
    final rows = <List<dynamic>>[[
      'id', 'title', 'subtitle', 'author', 'isbn', 'language', 'translator',
      'publisher', 'publishYear', 'totalPages', 'currentPage', 'status',
      'rating', 'bookFormat', 'collectionName', 'collectionNumber',
      'notes', 'startedAt', 'finishedAt', 'createdAt', 'coverUrl', 'coverPath',
      'categories', 'categoryColors', 'imprintName', 'imprintColor', 'imprintImage',
      'collectionId', 'imprintId'
    ]];

    for (final b in books) {
      final tags = await _db.tagDao.watchTagsForBook(b.id).first;
      final imprint = await _db.tagDao.watchImprintForBook(b.id).first;

      // Resolve collection name from tag when collectionName field is null
      // (books created after v14 only store collectionId, not the text name)
      String? resolvedCollectionName = b.collectionName;
      if (resolvedCollectionName == null && b.collectionId != null) {
        final collTag = await (_db.tagDao.select(_db.tagDao.tags)
          ..where((t) => t.id.equals(b.collectionId!))).getSingleOrNull();
        resolvedCollectionName = collTag?.name;
      }

      rows.add([
        b.id, b.title, b.subtitle, b.author, b.isbn, b.language, b.translator,
        b.publisher, b.publishYear, b.totalPages, b.currentPage, b.status.name,
        b.rating, b.bookFormat?.name, resolvedCollectionName, b.collectionNumber,
        b.notes, b.startedAt?.toIso8601String(), b.finishedAt?.toIso8601String(),
        b.createdAt.toIso8601String(), b.coverUrl, b.coverPath,
        tags.map((t) => t.name).join('|'),
        tags.map((t) => t.color ?? '').join('|'),
        imprint?.name, imprint?.color, imprint?.imagePath,
        b.collectionId, b.imprintId
      ]);
    }
    return Csv().encode(rows);
  }

  Future<String> exportShelvesToCsv() async {
    final shelves = await _db.shelfDao.select(_db.shelfDao.shelves).get();
    final rows = <List<dynamic>>[[
      'name', 'filterQuery', 'filterAuthor', 'filterPublisher', 'filterIsbn',
      'filterSubtitle', 'filterLanguage', 'filterTranslator', 'filterCollectionIds',
      'filterStatus', 'filterTagNames', 'filterImprintNames'
    ]];

    for (final s in shelves) {
      final tagNames = await _getNamesFromIds(s.filterTagIds);
      final imprintNames = await _getNamesFromIds(s.filterImprintIds);
      rows.add([
        s.name, s.filterQuery, s.filterAuthor, s.filterPublisher, s.filterIsbn,
        s.filterSubtitle, s.filterLanguage, s.filterTranslator, s.filterCollectionIds,
        s.filterStatus, tagNames.join('|'), imprintNames.join('|')
      ]);
    }
    return Csv().encode(rows);
  }

  Future<String> exportTagsToCsv() async {
    final tags = await _db.tagDao.select(_db.tagDao.tags).get();
    final rows = <List<dynamic>>[['name', 'type', 'color', 'imagePath']];

    for (final t in tags) {
      rows.add([t.name, t.type.name, t.color, t.imagePath != null ? p.basename(t.imagePath!) : null]);
    }
    return Csv().encode(rows);
  }

  Future<List<String>> _getNamesFromIds(String? jsonIds) async {
    if (jsonIds == null) return [];
    try {
      final ids = (jsonDecode(jsonIds) as List).cast<int>();
      final tags = await _db.tagDao.getTagsByIds(ids);
      return tags.map((t) => t.name).toList();
    } catch (_) { return []; }
  }

  Future<void> shareBackup({bool includeCovers = true, void Function(String)? onProgress}) async {
    final tempDir = await getTemporaryDirectory();
    final archive = Archive();

    onProgress?.call('data');
    final booksCsv = await exportBooksToCsv();
    archive.addFile(ArchiveFile('books.csv', booksCsv.length, utf8.encode(booksCsv)));

    final shelvesCsv = await exportShelvesToCsv();
    archive.addFile(ArchiveFile('shelves.csv', shelvesCsv.length, utf8.encode(shelvesCsv)));

    final tagsCsv = await exportTagsToCsv();
    archive.addFile(ArchiveFile('tags.csv', tagsCsv.length, utf8.encode(tagsCsv)));

    if (includeCovers) {
      onProgress?.call('media');
      await _bundleMedia(archive);
    }

    onProgress?.call('compress');
    final zipData = await Future.microtask(() => ZipEncoder().encode(archive));
    final zipFile = File(p.join(tempDir.path, 'openshelf_full_backup.zip'));
    await zipFile.writeAsBytes(zipData);

    onProgress?.call('finalize');
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(zipFile.path)], subject: 'Openshelf Full Backup');
  }

  Future<void> _bundleMedia(Archive archive) async {
    final books = await _db.bookDao.select(_db.bookDao.books).get();
    for (final b in books) {
      if (b.coverPath != null) await _addFileToArchive(archive, b.coverPath!);
    }
    final tags = await _db.tagDao.select(_db.tagDao.tags).get();
    for (final t in tags) {
      if (t.imagePath != null) await _addFileToArchive(archive, t.imagePath!, subDir: 'imprints');
    }
  }

  Future<void> _addFileToArchive(Archive archive, String path, {String? subDir}) async {
    final file = File(path);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      final name = subDir != null ? p.join(subDir, p.basename(path)) : p.basename(path);
      if (!archive.files.any((f) => f.name == name)) {
        archive.addFile(ArchiveFile(name, bytes.length, bytes));
      }
    }
  }

  // --- Import ---

  Future<int> importFromBackup(File sourceFile, {File? zipFile, bool compress = true}) async {
    if (p.extension(sourceFile.path).toLowerCase() == '.csv' && zipFile != null) {
      return _importLegacy(sourceFile, zipFile);
    }
    if (p.extension(sourceFile.path).toLowerCase() == '.zip') {
      return _importFromZip(sourceFile, compress: compress);
    }
    if (p.extension(sourceFile.path).toLowerCase() == '.csv') {
      return _importBooksCsv(sourceFile);
    }
    throw Exception('Format not supported');
  }

  Future<int> _importFromZip(File zipFile, {bool compress = true}) async {
    final archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());
    final docDir = await getApplicationDocumentsDirectory();
    final tempDir = await getTemporaryDirectory();

    ArchiveFile? booksF, shelvesF, tagsF;

    for (final file in archive) {
      if (!file.isFile) continue;
      if (file.name == 'books.csv') {
        booksF = file;
      } else if (file.name == 'shelves.csv') {
        shelvesF = file;
      } else if (file.name == 'tags.csv') {
        tagsF = file;
      } else {
        final data = file.content as List<int>;
        final target = p.join(docDir.path, file.name);
        final isImg = ['.jpg', '.png', '.jpeg'].any((ext) => file.name.toLowerCase().endsWith(ext));
        
        if (compress && isImg) {
          final temp = File(p.join(tempDir.path, 'import_${file.name}'))..createSync(recursive: true)..writeAsBytesSync(data);
          await CoverService.compressImage(temp.path, target);
          temp.deleteSync();
        } else {
          File(target)..createSync(recursive: true)..writeAsBytesSync(data);
        }
      }
    }

    if (booksF == null) throw Exception('books.csv missing');
    if (tagsF != null) await _importTagsCsvContent(utf8.decode(tagsF.content as List<int>), localBaseDir: docDir.path);
    
    final count = await _importBooksCsvContent(utf8.decode(booksF.content as List<int>), localBaseDir: docDir.path);
    if (shelvesF != null) await _importShelvesCsvContent(utf8.decode(shelvesF.content as List<int>));
    
    return count;
  }

  Future<int> _importLegacy(File csvFile, File zipFile) async {
    final archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());
    final docDir = await getApplicationDocumentsDirectory();
    for (final f in archive) {
      if (f.isFile) File(p.join(docDir.path, f.name))..createSync(recursive: true)..writeAsBytesSync(f.content as List<int>);
    }
    return _importBooksCsv(csvFile);
  }

  Future<int> _importBooksCsv(File file) async {
    final docDir = await getApplicationDocumentsDirectory();
    return _importBooksCsvContent(await file.readAsString(encoding: utf8), localBaseDir: docDir.path);
  }

  Future<void> _importTagsCsvContent(String content, {required String localBaseDir}) async {
    final rows = Csv().decode(content);
    if (rows.length < 2) return;
    final head = rows.first.map((e) => e.toString().toLowerCase()).toList();
    
    for (final row in rows.skip(1)) {
      final name = _get(head, row, 'name');
      final type = TagType.values.firstWhere((e) => e.name == _get(head, row, 'type'), orElse: () => TagType.tag);
      final img = _get(head, row, 'imagePath');
      final localImg = (img != null) ? p.join(localBaseDir, 'imprints', p.basename(img)) : null;
      
      if (name != null) await _getOrCreateTag(name, type, color: _get(head, row, 'color'), imagePath: localImg);
    }
  }

  Future<int> _importBooksCsvContent(String content, {required String localBaseDir}) async {
    final rows = Csv().decode(content);
    if (rows.length < 2) return 0;
    final head = rows.first.map((e) => e.toString().toLowerCase()).toList();
    int imported = 0;

    await _db.transaction(() async {
      for (final row in rows.skip(1)) {
        final comp = _mapRow(head, row, localBaseDir: localBaseDir);
        final exist = await (_db.bookDao.select(_db.bookDao.books)..where((t) => t.title.equals(comp.title.value) & t.author.equals(comp.author.value))).getSingleOrNull();
          
        int bookId = exist?.id ?? await _db.bookDao.into(_db.bookDao.books).insert(comp);
        if (exist == null) imported++;

        // Tags
        final cats = _get(head, row, 'categories')?.split('|') ?? [];
        final clrs = _get(head, row, 'categoryColors')?.split('|') ?? [];
        final ids = <int>[];
        for (int j = 0; j < cats.length; j++) {
          final name = cats[j].trim();
          if (name.isNotEmpty) {
            final color = (j < clrs.length) ? clrs[j].nullIfEmpty() : null;
            ids.add(await _getOrCreateTag(name, TagType.tag, color: color));
          }
        }
        if (ids.isNotEmpty) await _db.tagDao.setBookTags(bookId, ids);

        // Imprint
        final impName = _get(head, row, 'imprintName')?.trim();
        if (impName != null && impName.isNotEmpty) {
          final img = _get(head, row, 'imprintImage')?.trim();
          final tid = await _getOrCreateTag(
            impName, 
            TagType.imprint, 
            color: _get(head, row, 'imprintColor'), 
            imagePath: img != null ? p.join(localBaseDir, 'imprints', p.basename(img)) : null
          );
          await _db.bookDao.setBookImprint(bookId, tid);
        } else {
          // If no imprint name in CSV, ensure we don't keep a stale one if updating
          if (exist != null) await _db.bookDao.setBookImprint(bookId, null);
        }

        // Collection: always resolve by name so IDs are correct even when the
        // backup was created on a different DB instance (raw collectionId would
        // point to the wrong tag after re-import).
        // Falls back to collectionName field, which the export always populates.
        final collName = _get(head, row, 'collectionName')?.trim();
        if (collName != null && collName.isNotEmpty) {
          final tid = await _getOrCreateTag(collName, TagType.collection);
          await (_db.bookDao.update(_db.bookDao.books)..where((b) => b.id.equals(bookId)))
              .write(BooksCompanion(collectionId: Value(tid)));
        } else {
          if (exist != null) {
            await (_db.bookDao.update(_db.bookDao.books)..where((b) => b.id.equals(bookId)))
                .write(const BooksCompanion(collectionId: Value(null)));
          }
        }
      }
    });
    return imported;
  }

  Future<void> _importShelvesCsvContent(String content) async {
    final rows = Csv().decode(content);
    if (rows.length < 2) return;
    final head = rows.first.map((e) => e.toString().toLowerCase()).toList();

    for (final row in rows.skip(1)) {
      final name = _get(head, row, 'name');
      if (name == null) continue;

      final tagNames = _get(head, row, 'filterTagNames')?.split('|') ?? [];
      final impNames = _get(head, row, 'filterImprintNames')?.split('|') ?? [];

      final tIds = <int>[];
      for (final n in tagNames) {
        if (n.isNotEmpty) tIds.add(await _getOrCreateTag(n, TagType.tag));
      }

      final iIds = <int>[];
      for (final n in impNames) {
        if (n.isNotEmpty) iIds.add(await _getOrCreateTag(n, TagType.imprint));
      }

      // Support both new format (filterCollectionIds = JSON array of IDs) and
      // legacy backup format (filterCollection = pipe-separated collection names).
      // Name-based resolution keeps IDs correct across different DB instances.
      String? collIdsJson = _get(head, row, 'filterCollectionIds');
      if (collIdsJson == null) {
        final collNames = (_get(head, row, 'filterCollection') ?? '')
            .split('|')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (collNames.isNotEmpty) {
          final cIds = <int>[];
          for (final n in collNames) {
            cIds.add(await _getOrCreateTag(n, TagType.collection));
          }
          collIdsJson = jsonEncode(cIds);
        }
      }

      final comp = ShelvesCompanion.insert(
        name: name,
        filterQuery: Value(_get(head, row, 'filterQuery')),
        filterAuthor: Value(_get(head, row, 'filterAuthor')),
        filterPublisher: Value(_get(head, row, 'filterPublisher')),
        filterIsbn: Value(_get(head, row, 'filterIsbn')),
        filterSubtitle: Value(_get(head, row, 'filterSubtitle')),
        filterLanguage: Value(_get(head, row, 'filterLanguage')),
        filterTranslator: Value(_get(head, row, 'filterTranslator')),
        filterCollectionIds: Value(collIdsJson),
        filterStatus: Value(_get(head, row, 'filterStatus')),
        filterTagIds: Value(tIds.isEmpty ? null : jsonEncode(tIds)),
        filterImprintIds: Value(iIds.isEmpty ? null : jsonEncode(iIds)),
      );

      final exist = await (_db.shelfDao.select(_db.shelfDao.shelves)..where((t) => t.name.equals(name))).getSingleOrNull();
      if (exist == null) {
        final id = await _db.shelfDao.into(_db.shelfDao.shelves).insert(comp);
        if (tIds.isNotEmpty || iIds.isNotEmpty) {
          await _db.shelfDao.setShelfTags(id, [...tIds, ...iIds]);
        }
      } else {
        await _db.shelfDao.updateShelf(exist.copyWith(
          filterQuery: comp.filterQuery.value,
          filterAuthor: comp.filterAuthor.value,
          filterPublisher: comp.filterPublisher.value,
          filterIsbn: comp.filterIsbn.value,
          filterSubtitle: comp.filterSubtitle.value,
          filterLanguage: comp.filterLanguage.value,
          filterTranslator: comp.filterTranslator.value,
          filterCollectionIds: comp.filterCollectionIds.value,
          filterStatus: comp.filterStatus.value,
          filterTagIds: comp.filterTagIds.value,
          filterImprintIds: comp.filterImprintIds.value,
        ));
        await _db.shelfDao.setShelfTags(exist.id, [...tIds, ...iIds]);
      }
    }
  }

  Future<int> _getOrCreateTag(String name, TagType type, {String? color, String? imagePath}) async {
    final key = '${type.name}_$name'.toLowerCase();
    if (_tagCache.containsKey(key)) return _tagCache[key]!;
    final id = await ImportExportUtils.getOrCreateTag(_db, name, type, color: color, imagePath: imagePath);
    _tagCache[key] = id;
    return id;
  }

  String? _get(List<String> head, List<dynamic> row, String col) {
    final i = head.indexOf(col.toLowerCase());
    if (i == -1 || i >= row.length) return null;
    return row[i]?.toString().nullIfEmpty();
  }

  BooksCompanion _mapRow(List<String> head, List<dynamic> row, {required String localBaseDir}) {
    String? s(String c) => _get(head, row, c);
    final cp = s('coverPath');
    final localCp = cp != null && File(p.join(localBaseDir, p.basename(cp))).existsSync() ? p.join(localBaseDir, p.basename(cp)) : null;

    return BooksCompanion.insert(
      title: s('title') ?? 'Unknown',
      subtitle: Value(s('subtitle')),
      author: s('author') ?? 'Unknown',
      isbn: Value(s('isbn')),
      language: Value(s('language')),
      translator: Value(s('translator')),
      publisher: Value(s('publisher')),
      publishYear: Value(ImportExportUtils.parseInt(s('publishYear'))),
      totalPages: Value(ImportExportUtils.parseInt(s('totalPages'))),
      currentPage: Value(ImportExportUtils.parseInt(s('currentPage'))),
      status: ReadingStatus.values.firstWhere((e) => e.name == s('status'), orElse: () => ReadingStatus.wantToRead),
      rating: Value(ImportExportUtils.parseRating(s('rating'))),
      bookFormat: Value(BookFormat.values.firstWhereOrNull((e) => e.name == s('bookFormat'))),
      collectionName: Value(s('collectionName')),
      collectionNumber: Value(ImportExportUtils.parseInt(s('collectionNumber'))),
      notes: Value(s('notes')),
      startedAt: Value(ImportExportUtils.parseDate(s('startedAt'))),
      finishedAt: Value(ImportExportUtils.parseDate(s('finishedAt'))),
      createdAt: s('createdAt') != null ? Value(DateTime.parse(s('createdAt')!)) : const Value.absent(),
      coverUrl: Value(s('coverUrl')),
      coverPath: Value(localCp),
      collectionId: const Value.absent(), // Resolved by name in _importBooksCsvContent
      imprintId: const Value.absent(), // Resolved by name in _importBooksCsvContent
    );
  }
}
