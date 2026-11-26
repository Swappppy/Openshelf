import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'database.dart';
import 'cover_service.dart';
import 'import_export_base.dart';
import '../models/search_filters.dart';
import '../utils/pagination_helper.dart';

/// Thrown when a backup archive is malformed or exceeds safety limits.
class BackupFormatException implements Exception {
  final String message;
  BackupFormatException(this.message);
  @override
  String toString() => 'Exception: $message';
}

/// Service for exporting and importing the entire library database via CSV and ZIP.
///
/// Backup format (v2). All cross-references are stored by *name* so a backup
/// can be restored into any database:
/// - manifest.json, books.csv, shelves.csv, tags.csv, history.csv, logs.csv,
///   goals.csv, ownership.csv, widgets.csv, search_history.csv
/// - cover images at the archive root, imprint images under `imprints/`.
/// Backups written by older versions (v1, without the newer files/columns)
/// are still accepted.
class DataMigrationService {
  final AppDatabase _db;
  Map<String, int> _tagCache = {};

  DataMigrationService(this._db);

  static const backupFormatVersion = 2;

  /// Per-entry and whole-archive limits on decompressed size (zip-bomb guard).
  static const _maxEntryBytes = 256 * 1024 * 1024;
  static const _maxTotalBytes = 4 * 1024 * 1024 * 1024;
  static const _imageExtensions = {'.jpg', '.jpeg', '.png', '.webp'};

  static const _tagFields = {
    SearchField.category: TagType.tag,
    SearchField.imprint: TagType.imprint,
    SearchField.collection: TagType.collection,
  };

  // ---------------------------------------------------------------------------
  // Export
  // ---------------------------------------------------------------------------

  Future<File> createBackupFile({bool includeCovers = true, void Function(String)? onProgress}) async {
    final tempDir = await getTemporaryDirectory();
    final zipFile = File(p.join(tempDir.path, 'openshelf_full_backup.zip'));
    if (await zipFile.exists()) await zipFile.delete();

    final encoder = ZipFileEncoder();
    encoder.create(zipFile.path);

    final backupSubDir = Directory(p.join(tempDir.path, 'backup_csv_${DateTime.now().microsecondsSinceEpoch}'))
      ..createSync(recursive: true);

    Future<void> add(String name, String content) async {
      final f = File(p.join(backupSubDir.path, name))..writeAsStringSync(content, encoding: utf8);
      await encoder.addFile(f, name);
    }

    try {
      onProgress?.call('data');
      await add('manifest.json', jsonEncode({
        'app': 'openshelf',
        'format': backupFormatVersion,
        'schemaVersion': _db.schemaVersion,
        'createdAt': DateTime.now().toIso8601String(),
      }));
      await add('books.csv', await exportBooksToCsv());
      await add('shelves.csv', await exportShelvesToCsv());
      await add('tags.csv', await exportTagsToCsv());
      await add('history.csv', await exportHistoryToCsv());
      await add('logs.csv', await exportLogsToCsv());
      await add('goals.csv', await exportGoalsToCsv());
      await add('ownership.csv', await exportOwnershipToCsv());
      await add('widgets.csv', await exportWidgetsToCsv());
      await add('search_history.csv', await exportSearchHistoryToCsv());

      if (includeCovers) {
        onProgress?.call('media');
        await _bundleMediaWithEncoder(encoder);
      }

      onProgress?.call('compress');
      await encoder.close();
    } finally {
      if (await backupSubDir.exists()) {
        try { await backupSubDir.delete(recursive: true); } catch (_) {}
      }
    }

    return zipFile;
  }

  Future<Map<int, Tag>> _tagsById() async =>
      {for (final t in await _db.select(_db.tags).get()) t.id: t};

  Future<String> exportBooksToCsv() async {
    final books = await _db.select(_db.books).get();
    final tagsById = await _tagsById();
    final linksByBook = groupBy(await _db.select(_db.bookTags).get(), (BookTag bt) => bt.bookId);
    final audioByBook = {for (final a in await _db.select(_db.audiobookInfo).get()) a.bookId: a};

    final rows = <List<dynamic>>[[
      'id', 'title', 'subtitle', 'author', 'isbn', 'language', 'translator',
      'publisher', 'publishYear', 'totalPages', 'currentPage', 'status',
      'rating', 'bookFormat', 'collectionName', 'collectionNumber',
      'notes', 'startedAt', 'finishedAt', 'createdAt', 'coverUrl', 'coverPath',
      'categories', 'categoryColors', 'imprintName', 'imprintColor', 'imprintImage',
      'collectionId', 'imprintId', 'paginationConfig',
      // v2
      'originalTitle', 'originalLanguage', 'description', 'ownershipStatus', 'copies', 'collections',
      // v2 (schema 33+)
      'openLibraryEditionKey',
      // v2 (schema 34+)
      'mediaType', 'narrator', 'platform', 'durationSeconds', 'audioPublisher', 'audioIdentifier',
    ]];

    for (final b in books) {
      final links = linksByBook[b.id] ?? const <BookTag>[];
      final categories = links.map((l) => tagsById[l.tagId]).whereType<Tag>().where((t) => t.type == TagType.tag).toList();
      final collections = [
        for (final l in links)
          if (tagsById[l.tagId]?.type == TagType.collection)
            {'name': tagsById[l.tagId]!.name, 'number': l.collectionNumber},
      ];
      final imprint = b.imprintId != null ? tagsById[b.imprintId] : null;
      final firstCollection = collections.firstOrNull;

      rows.add([
        b.id, b.title, b.subtitle, b.author, b.isbn, b.language, b.translator,
        b.publisher, b.publishYear, b.totalPages, b.currentPage, b.status.name,
        b.rating, b.bookFormat?.name,
        firstCollection?['name'] ?? b.collectionName ?? (b.collectionId != null ? tagsById[b.collectionId]?.name : null),
        firstCollection?['number'] ?? b.collectionNumber,
        b.notes, b.startedAt?.toIso8601String(), b.finishedAt?.toIso8601String(),
        b.createdAt.toIso8601String(), b.coverUrl,
        b.coverPath != null ? p.basename(b.coverPath!) : null,
        categories.map((t) => t.name).join('|'),
        categories.map((t) => t.color ?? '').join('|'),
        imprint?.name, imprint?.color, imprint?.imagePath != null ? p.basename(imprint!.imagePath!) : null,
        b.collectionId, b.imprintId,
        b.paginationConfig != null ? jsonEncode(b.paginationConfig!.toJson()) : null,
        b.originalTitle, b.originalLanguage, b.description, b.ownershipStatus?.name, b.copies,
        collections.isEmpty ? null : jsonEncode(collections),
        b.openLibraryEditionKey,
        b.mediaType.name,
        audioByBook[b.id]?.narrator, audioByBook[b.id]?.platform, audioByBook[b.id]?.durationSeconds,
        audioByBook[b.id]?.publisher, audioByBook[b.id]?.identifier,
      ]);
    }
    return Csv().encode(rows);
  }

  Future<String> exportShelvesToCsv() async {
    final shelves = await _db.select(_db.shelves).get();
    final tagsById = await _tagsById();
    final linksByShelf = groupBy(await _db.select(_db.shelfTags).get(), (ShelfTag st) => st.shelfId);

    List<String> namesFromJson(String? json) {
      if (json == null) return [];
      try {
        return (jsonDecode(json) as List).map((id) => tagsById[id]?.name).whereType<String>().toList();
      } catch (_) {
        return [];
      }
    }

    final rows = <List<dynamic>>[[
      'name', 'filterQuery', 'filterAuthor', 'filterPublisher', 'filterIsbn',
      'filterSubtitle', 'filterLanguage', 'filterTranslator', 'filterCollection',
      'filterStatus', 'filterTagNames', 'filterImprintNames',
      // v2
      'filterCollectionNames', 'filterNoCover', 'filterSearchMode', 'filterFormat',
      'filterOwnership', 'filterNotes', 'filterBooleanQuery',
    ]];

    for (final s in shelves) {
      // shelf_tags is authoritative; the JSON columns are a legacy mirror.
      final linked = (linksByShelf[s.id] ?? const <ShelfTag>[]).map((l) => tagsById[l.tagId]).whereType<Tag>().toList();
      List<String> names(TagType type, String? legacyJson) {
        final fromLinks = linked.where((t) => t.type == type).map((t) => t.name).toList();
        return fromLinks.isNotEmpty ? fromLinks : namesFromJson(legacyJson);
      }

      final collectionNames = names(TagType.collection, s.filterCollectionIds);
      rows.add([
        s.name, s.filterQuery, s.filterAuthor, s.filterPublisher, s.filterIsbn,
        s.filterSubtitle, s.filterLanguage, s.filterTranslator, collectionNames.join('|'),
        s.filterStatus, names(TagType.tag, s.filterTagIds).join('|'), names(TagType.imprint, s.filterImprintIds).join('|'),
        collectionNames.isEmpty ? null : jsonEncode(collectionNames),
        s.filterNoCover, s.filterSearchMode, s.filterFormat,
        s.filterOwnership, s.filterNotes, _booleanQueryIdsToNames(s.filterBooleanQuery, tagsById),
      ]);
    }
    return Csv().encode(rows);
  }

  /// Annotates tag conditions with the tag name, since tag IDs differ between databases.
  String? _booleanQueryIdsToNames(String? json, Map<int, Tag> tagsById) {
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      for (final c in (map['conditions'] as List? ?? const []).cast<Map<String, dynamic>>()) {
        final field = SearchField.values.firstWhereOrNull((f) => f.name == c['field']);
        if (field == null || !_tagFields.containsKey(field)) continue;
        final id = int.tryParse('${c['value']}');
        final name = id != null ? tagsById[id]?.name : null;
        if (name != null) c['valueName'] = name;
      }
      return jsonEncode(map);
    } catch (_) {
      return json;
    }
  }

  Future<String> exportTagsToCsv() async {
    final tags = await _db.select(_db.tags).get();
    final rows = <List<dynamic>>[['name', 'type', 'color', 'imagePath']];
    for (final t in tags) {
      rows.add([t.name, t.type.name, t.color, t.imagePath != null ? p.basename(t.imagePath!) : null]);
    }
    return Csv().encode(rows);
  }

  Future<String> exportHistoryToCsv() async {
    final history = await _db.select(_db.readHistory).get();
    final rows = <List<dynamic>>[[
      'bookId', 'readNumber', 'startedAt', 'finishedAt', 'sections', 'progress', 'segmentProgress',
      'audioProgress', 'audioSegmentProgress',
    ]];
    for (final h in history) {
      rows.add([
        h.bookId,
        h.readNumber,
        h.startedAt?.toIso8601String(),
        h.finishedAt?.toIso8601String(),
        h.sections != null ? jsonEncode(h.sections) : null,
        h.progress,
        h.segmentProgress != null ? jsonEncode(h.segmentProgress!.map((k, v) => MapEntry(k.toString(), v))) : null,
        h.audioProgress,
        h.audioSegmentProgress != null ? jsonEncode(h.audioSegmentProgress!.map((k, v) => MapEntry(k.toString(), v))) : null,
      ]);
    }
    return Csv().encode(rows);
  }

  Future<String> exportLogsToCsv() async {
    final logs = await _db.select(_db.readingLog).get();
    final rows = <List<dynamic>>[['bookId', 'date', 'pagesRead', 'sections', 'readNumber', 'isBackfill', 'medium', 'startPosition']];
    for (final l in logs) {
      rows.add([l.bookId, l.date.toIso8601String(), l.pagesRead, l.sections != null ? jsonEncode(l.sections) : null, l.readNumber, l.isBackfill, l.medium.name, l.startPosition]);
    }
    return Csv().encode(rows);
  }

  Future<String> exportGoalsToCsv() async {
    final goals = await _db.select(_db.readingGoals).get();
    final shelfNames = {for (final s in await _db.select(_db.shelves).get()) s.id: s.name};
    final tagsById = await _tagsById();
    final rows = <List<dynamic>>[[
      'title', 'type', 'targetValue', 'startDate', 'endDate', 'shelfName', 'collectionName'
    ]];
    for (final g in goals) {
      rows.add([
        g.title, g.type, g.targetValue,
        g.startDate.toIso8601String(), g.endDate.toIso8601String(),
        g.shelfId != null ? shelfNames[g.shelfId] : null,
        g.collectionId != null ? tagsById[g.collectionId]?.name : null,
      ]);
    }
    return Csv().encode(rows);
  }

  Future<String> exportOwnershipToCsv() async {
    final events = await _db.select(_db.ownershipLog).get();
    final rows = <List<dynamic>>[['bookId', 'eventType', 'personName', 'date', 'notes']];
    for (final e in events) {
      rows.add([e.bookId, e.eventType.name, e.personName, e.date.toIso8601String(), e.notes]);
    }
    return Csv().encode(rows);
  }

  Future<String> exportWidgetsToCsv() async {
    final widgets = await _db.select(_db.statWidgetConfigs).get();
    final goals = {for (final g in await _db.select(_db.readingGoals).get()) g.id: g};
    final rows = <List<dynamic>>[['type', 'size', 'sortOrder', 'config', 'goalTitle', 'goalStartDate']];
    for (final w in widgets) {
      final goal = w.goalId != null ? goals[w.goalId] : null;
      rows.add([w.type, w.size, w.sortOrder, w.config, goal?.title, goal?.startDate.toIso8601String()]);
    }
    return Csv().encode(rows);
  }

  Future<String> exportSearchHistoryToCsv() async {
    final entries = await _db.select(_db.searchHistory).get();
    final rows = <List<dynamic>>[['query', 'type', 'status', 'title', 'author', 'publisher', 'timestamp']];
    for (final e in entries) {
      rows.add([e.query, e.type, e.status, e.title, e.author, e.publisher, e.timestamp.toIso8601String()]);
    }
    return Csv().encode(rows);
  }

  Future<void> shareBackup({bool includeCovers = true, void Function(String)? onProgress}) async {
    final zipFile = await createBackupFile(includeCovers: includeCovers, onProgress: onProgress);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(zipFile.path, mimeType: 'application/zip')],
        subject: 'Openshelf Full Backup',
      ),
    );
  }

  Future<void> _bundleMediaWithEncoder(ZipFileEncoder encoder) async {
    final addedNames = <String>{};
    for (final b in await _db.select(_db.books).get()) {
      if (b.coverPath == null) continue;
      final file = File(b.coverPath!);
      final name = p.basename(b.coverPath!);
      if (await file.exists() && addedNames.add(name)) await encoder.addFile(file, name);
    }
    for (final t in await _db.select(_db.tags).get()) {
      if (t.imagePath == null) continue;
      final file = File(t.imagePath!);
      final name = 'imprints/${p.basename(t.imagePath!)}';
      if (await file.exists() && addedNames.add(name)) await encoder.addFile(file, name);
    }
  }

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  Future<int> importFromBackup(File sourceFile, {File? zipFile, bool compress = true}) async {
    _tagCache = {};
    final ext = p.extension(sourceFile.path).toLowerCase();
    if (ext == '.csv' && zipFile != null) return _importLegacy(sourceFile, zipFile);
    if (ext == '.zip') return _importFromZip(sourceFile, compress: compress);
    if (ext == '.csv') return _importBooksCsv(sourceFile);
    throw Exception('Format not supported');
  }

  /// Opens a zip without loading it fully into memory and enforces size limits.
  (Archive, InputFileStream) _openZipSafely(File zipFile) {
    final input = InputFileStream(zipFile.path);
    try {
      final decoder = ZipDecoder();
      final archive = decoder.decodeStream(input);
      var total = 0;
      for (final header in decoder.directory.fileHeaders) {
        final file = header.file;
        if (file == null) continue;
        if (file.uncompressedSize > _maxEntryBytes) {
          throw BackupFormatException('Backup entry "${header.filename}" is too large');
        }
        if (header.filename.toLowerCase().endsWith('.csv')) {
          // Backups written before v1.5 recorded the UTF-16 length of the CSV
          // text instead of its UTF-8 byte length. UTF-8 needs at most 3 bytes
          // per UTF-16 code unit, so allow that much (still bounded).
          file.uncompressedSize = min(file.uncompressedSize * 3 + 1024, _maxEntryBytes);
        }
        total += file.uncompressedSize;
        if (total > _maxTotalBytes) throw BackupFormatException('Backup is too large');
      }
      return (archive, input);
    } catch (_) {
      input.closeSync();
      rethrow;
    }
  }

  /// Maps an archive entry to a safe relative path inside the app's storage,
  /// or `null` if the entry must be ignored (path traversal, unexpected
  /// location or non-image file).
  static String? safeMediaPath(String entryName) {
    final normalized = p.posix.normalize(entryName.replaceAll('\\', '/'));
    if (normalized.startsWith('/') || normalized.startsWith('..') || normalized.contains(':')) return null;
    final parts = p.posix.split(normalized);
    if (parts.contains('..') || parts.contains('.')) return null;
    if (!_imageExtensions.contains(p.extension(normalized).toLowerCase())) return null;
    if (parts.length == 1) return parts.single;
    if (parts.length == 2 && parts.first == 'imprints') return normalized;
    return null;
  }

  Future<void> _extractMedia(ArchiveFile file, {required String coverDir, required String docDir, required bool compress}) async {
    final rel = safeMediaPath(file.name);
    if (rel == null) {
      debugPrint('DataMigrationService: skipping unexpected archive entry "${file.name}"');
      return;
    }
    final baseDir = rel.startsWith('imprints/') ? docDir : coverDir;
    final target = File(p.join(baseDir, rel));
    if (!p.isWithin(baseDir, target.path)) return; // defence in depth
    await target.parent.create(recursive: true);

    final data = file.content as List<int>;
    if (compress) {
      final tempDir = await getTemporaryDirectory();
      final temp = File(p.join(tempDir.path, 'import_${DateTime.now().microsecondsSinceEpoch}_${p.basename(rel)}'));
      await temp.writeAsBytes(data);
      try {
        await CoverService.compressImage(temp.path, target.path);
      } finally {
        if (await temp.exists()) await temp.delete();
      }
    } else {
      await target.writeAsBytes(data);
    }
    file.clear();
  }

  String _text(ArchiveFile f) {
    final s = utf8.decode(f.content as List<int>, allowMalformed: true);
    f.clear();
    return s;
  }

  Future<int> _importFromZip(File zipFile, {bool compress = true}) async {
    final (archive, input) = _openZipSafely(zipFile);
    try {
      final docDir = (await getApplicationDocumentsDirectory()).path;
      final coverDir = (await CoverService.getCoverDirectory()).path;

      final csv = <String, ArchiveFile>{};
      for (final file in archive) {
        if (!file.isFile) continue;
        if (file.name.toLowerCase().endsWith('.csv') && !file.name.contains('/')) {
          csv[file.name] = file;
        } else if (file.name != 'manifest.json') {
          await _extractMedia(file, coverDir: coverDir, docDir: docDir, compress: compress);
        }
      }

      final booksF = csv['books.csv'];
      if (booksF == null) throw Exception('books.csv missing');

      String? read(String name) => csv[name] != null ? _text(csv[name]!) : null;
      final tagsCsv = read('tags.csv');
      final booksCsv = _text(booksF);
      final shelvesCsv = read('shelves.csv');
      final historyCsv = read('history.csv');
      final logsCsv = read('logs.csv');
      final goalsCsv = read('goals.csv');
      final ownershipCsv = read('ownership.csv');
      final widgetsCsv = read('widgets.csv');
      final searchCsv = read('search_history.csv');

      return await _db.transaction(() async {
        if (tagsCsv != null) await _importTagsCsvContent(tagsCsv, docDir: docDir);
        final bookIdMap = <int, int>{};
        final count = await _importBooksCsvContent(booksCsv, coverDir: coverDir, docDir: docDir, bookIdMap: bookIdMap);
        if (shelvesCsv != null) await _importShelvesCsvContent(shelvesCsv);
        if (historyCsv != null) await _importHistoryCsvContent(historyCsv, bookIdMap);
        if (logsCsv != null) await _importLogsCsvContent(logsCsv, bookIdMap);
        if (goalsCsv != null) await _importGoalsCsvContent(goalsCsv);
        if (ownershipCsv != null) await _importOwnershipCsvContent(ownershipCsv, bookIdMap);
        if (widgetsCsv != null) await _importWidgetsCsvContent(widgetsCsv);
        if (searchCsv != null) await _importSearchHistoryCsvContent(searchCsv);
        return count;
      });
    } finally {
      input.closeSync();
    }
  }

  /// Old two-file format: books CSV + a zip containing only images.
  Future<int> _importLegacy(File csvFile, File zipFile) async {
    final (archive, input) = _openZipSafely(zipFile);
    try {
      final docDir = (await getApplicationDocumentsDirectory()).path;
      final coverDir = (await CoverService.getCoverDirectory()).path;
      for (final f in archive) {
        if (f.isFile) await _extractMedia(f, coverDir: coverDir, docDir: docDir, compress: false);
      }
    } finally {
      input.closeSync();
    }
    return _importBooksCsv(csvFile);
  }

  Future<int> _importBooksCsv(File file) async {
    final docDir = (await getApplicationDocumentsDirectory()).path;
    final coverDir = (await CoverService.getCoverDirectory()).path;
    final content = await file.readAsString(encoding: utf8);
    return _db.transaction(() => _importBooksCsvContent(content, coverDir: coverDir, docDir: docDir));
  }

  /// Parses CSV rows into header-keyed accessors, skipping (and logging) rows
  /// whose processing throws, so one bad row never aborts a whole restore.
  Future<void> _forEachRow(String content, String label, Future<void> Function(String? Function(String) get) body) async {
    final rows = Csv().decode(content);
    if (rows.length < 2) return;
    final head = rows.first.map((e) => e.toString().trim().toLowerCase()).toList();
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      String? get(String col) {
        final idx = head.indexOf(col.toLowerCase());
        if (idx == -1 || idx >= row.length) return null;
        return row[idx]?.toString().nullIfEmpty();
      }
      try {
        await body(get);
      } catch (e) {
        debugPrint('DataMigrationService: skipped $label row ${i + 1}: $e');
      }
    }
  }

  Future<void> _importTagsCsvContent(String content, {required String docDir}) async {
    await _forEachRow(content, 'tags', (get) async {
      final name = get('name');
      if (name == null) return;
      final type = TagType.values.firstWhere((e) => e.name == get('type'), orElse: () => TagType.tag);
      final img = get('imagePath');
      await _getOrCreateTag(name, type, color: get('color'), imagePath: _existingImprintImage(img, docDir));
    });
  }

  String? _existingImprintImage(String? name, String docDir) {
    if (name == null) return null;
    final path = p.join(docDir, 'imprints', p.basename(name));
    return File(path).existsSync() ? path : null;
  }

  /// Finds a pre-existing book that this row should update. Each existing
  /// book is matched at most once per import ([claimed]), so restoring a
  /// library that intentionally contains duplicates (copies) keeps them all,
  /// while re-importing the same backup does not create new ones.
  Future<Book?> _findMatch(BooksCompanion comp, Set<int> claimed) async {
    final isbn = comp.isbn.value;
    final query = _db.select(_db.books);
    if (isbn != null && isbn.isNotEmpty) {
      query.where((b) => b.isbn.equals(isbn));
    } else {
      query.where((b) =>
          b.title.lower().equals(comp.title.value.toLowerCase()) &
          b.author.lower().equals(comp.author.value.toLowerCase()) &
          (b.isbn.isNull() | b.isbn.equals('')));
    }
    query.orderBy([(b) => OrderingTerm(expression: b.id)]);
    return (await query.get()).firstWhereOrNull((b) => !claimed.contains(b.id));
  }

  Future<int> _importBooksCsvContent(String content, {required String coverDir, required String docDir, Map<int, int>? bookIdMap}) async {
    var imported = 0;
    final claimed = <int>{};

    await _forEachRow(content, 'books', (get) async {
      final comp = _mapRow(get, coverDir: coverDir);
      final exist = await _findMatch(comp, claimed);

      final int bookId;
      if (exist != null) {
        bookId = exist.id;
        // Never wipe a local cover just because the backup has none.
        final update = comp.coverPath.value == null ? comp.copyWith(coverPath: const Value.absent()) : comp;
        await (_db.update(_db.books)..where((t) => t.id.equals(bookId))).write(update);
      } else {
        bookId = await _db.into(_db.books).insert(comp);
        imported++;
      }
      claimed.add(bookId);

      final oldId = ImportExportUtils.parseInt(get('id'));
      if (oldId != null) bookIdMap?[oldId] = bookId;

      // Audio data (schema 34+ backups).
      final narrator = get('narrator'), platform = get('platform');
      final duration = ImportExportUtils.parseInt(get('durationSeconds'));
      final audioPublisher = get('audioPublisher'), audioIdentifier = get('audioIdentifier');
      if ([narrator, platform, duration, audioPublisher, audioIdentifier].any((v) => v != null)) {
        await _db.audiobookInfoDao.upsert(AudiobookInfoCompanion(
          bookId: Value(bookId),
          narrator: Value(narrator),
          platform: Value(platform),
          durationSeconds: Value(duration),
          publisher: Value(audioPublisher),
          identifier: Value(audioIdentifier),
        ));
      }

      // Standalone CSV import: synthesize a read history entry. In a ZIP
      // restore (bookIdMap != null) history.csv provides the real records.
      final status = comp.status.value;
      if (bookIdMap == null && (status == ReadingStatus.reading || status == ReadingStatus.read)) {
        await _synthesizeHistory(bookId, comp);
      }

      // Categories
      final tagIds = <int>[];
      final cats = get('categories')?.split('|') ?? const [];
      final colors = get('categoryColors')?.split('|') ?? const [];
      for (var j = 0; j < cats.length; j++) {
        final name = cats[j].trim();
        if (name.isEmpty) continue;
        tagIds.add(await _getOrCreateTag(name, TagType.tag, color: j < colors.length ? colors[j].nullIfEmpty() : null));
      }

      // Collections: v2 JSON list, falling back to the single v1 columns.
      final collections = <(int, int?)>[];
      final collectionsJson = get('collections');
      if (collectionsJson != null) {
        for (final c in (jsonDecode(collectionsJson) as List).cast<Map>()) {
          final name = c['name']?.toString().trim();
          if (name == null || name.isEmpty) continue;
          collections.add((await _getOrCreateTag(name, TagType.collection), (c['number'] as num?)?.toInt()));
        }
      } else {
        final collName = get('collectionName')?.trim();
        if (collName != null && collName.isNotEmpty) {
          collections.add((await _getOrCreateTag(collName, TagType.collection), ImportExportUtils.parseInt(get('collectionNumber'))));
        }
      }
      await _db.tagDao.setBookTags(bookId, tagIds, collections: collections);
      await (_db.update(_db.books)..where((b) => b.id.equals(bookId)))
          .write(BooksCompanion(collectionId: Value(collections.firstOrNull?.$1)));

      // Imprint (one-to-one)
      final impName = get('imprintName')?.trim();
      if (impName != null && impName.isNotEmpty) {
        final tid = await _getOrCreateTag(impName, TagType.imprint,
            color: get('imprintColor'), imagePath: _existingImprintImage(get('imprintImage'), docDir));
        await _db.bookDao.setBookImprint(bookId, tid);
      } else if (exist != null) {
        await _db.bookDao.setBookImprint(bookId, null);
      }
    });
    return imported;
  }

  Future<void> _synthesizeHistory(int bookId, BooksCompanion comp) async {
    final status = comp.status.value;
    final total = comp.totalPages.value ?? 0;
    final current = comp.currentPage.value ?? 0;
    final progress = status == ReadingStatus.read ? (total > 0 ? total : current) : current;
    final segments = comp.paginationConfig.present ? comp.paginationConfig.value?.segments : null;
    final distributed = (segments?.isNotEmpty ?? false)
        ? PaginationHelper.distributePhysicalPage(progress, segments!)
        : {0: progress};

    final historyExist = await _db.readHistoryDao.getRead(bookId, 1);
    if (historyExist == null) {
      await _db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: bookId,
        readNumber: 1,
        startedAt: comp.startedAt,
        finishedAt: comp.finishedAt,
        progress: Value(progress),
        segmentProgress: Value(distributed.isEmpty ? null : distributed),
      ));
    } else if (progress > historyExist.progress) {
      await _db.readHistoryDao.updateRead(historyExist.copyWith(
        progress: progress,
        finishedAt: comp.finishedAt,
        segmentProgress: Value(distributed.isEmpty ? null : distributed),
      ));
    }

    if (progress > 0) {
      final logDate = comp.finishedAt.value ?? comp.startedAt.value ?? (comp.createdAt.present ? comp.createdAt.value : DateTime.now());
      final day = DateTime(logDate.year, logDate.month, logDate.day);
      if (!await _logExists(bookId, day, isBackfill: true, readNumber: 1)) {
        await _db.logDao.insertLog(ReadingLogCompanion.insert(
          bookId: bookId,
          date: day,
          pagesRead: progress,
          readNumber: const Value(1),
          isBackfill: const Value(true),
        ));
      }
    }
  }

  Future<bool> _logExists(int bookId, DateTime date,
          {bool isBackfill = false, int? readNumber, ReadingMedium medium = ReadingMedium.text}) async =>
      await (_db.select(_db.readingLog)
            ..where((l) =>
                l.bookId.equals(bookId) &
                l.date.equals(date) &
                l.isBackfill.equals(isBackfill) &
                l.medium.equalsValue(medium) &
                (readNumber != null ? l.readNumber.equals(readNumber) : l.readNumber.isNull()))
            ..limit(1))
          .getSingleOrNull() !=
      null;

  BooksCompanion _mapRow(String? Function(String) s, {required String coverDir}) {
    final cp = s('coverPath');
    final localCover = cp != null ? p.join(coverDir, p.basename(cp)) : null;

    PaginationConfig? pagination;
    final rawPagination = s('paginationConfig');
    if (rawPagination != null) {
      try {
        pagination = PaginationConfig.fromJson(jsonDecode(rawPagination));
      } catch (_) {}
    }
    final createdAt = ImportExportUtils.parseDate(s('createdAt'));

    return BooksCompanion.insert(
      title: s('title') ?? 'Unknown',
      subtitle: Value(s('subtitle')),
      originalTitle: Value(s('originalTitle')),
      author: s('author') ?? 'Unknown',
      isbn: Value(s('isbn')),
      language: Value(s('language')),
      originalLanguage: Value(s('originalLanguage')),
      translator: Value(s('translator')),
      publisher: Value(s('publisher')),
      publishYear: Value(ImportExportUtils.parseInt(s('publishYear'))),
      totalPages: Value(ImportExportUtils.parseInt(s('totalPages'))),
      currentPage: Value(ImportExportUtils.parseInt(s('currentPage'))),
      status: ReadingStatus.values.firstWhere((e) => e.name == s('status'), orElse: () => ReadingStatus.wantToRead),
      ownershipStatus: Value(OwnershipStatus.values.firstWhereOrNull((e) => e.name == s('ownershipStatus'))),
      rating: Value(ImportExportUtils.parseRating(s('rating'))),
      bookFormat: Value(BookFormat.values.firstWhereOrNull((e) => e.name == s('bookFormat'))),
      collectionName: Value(s('collectionName')),
      collectionNumber: Value(ImportExportUtils.parseInt(s('collectionNumber'))),
      notes: Value(s('notes')),
      description: Value(s('description')),
      copies: Value(max(1, ImportExportUtils.parseInt(s('copies')) ?? 1)),
      startedAt: Value(ImportExportUtils.parseDate(s('startedAt'))),
      finishedAt: Value(ImportExportUtils.parseDate(s('finishedAt'))),
      createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
      coverUrl: Value(s('coverUrl')),
      coverPath: Value(localCover != null && File(localCover).existsSync() ? localCover : null),
      collectionId: const Value.absent(),
      imprintId: const Value.absent(),
      paginationConfig: pagination != null ? Value(pagination) : const Value.absent(),
      // Older backups lack the column: leave an existing link untouched.
      openLibraryEditionKey: s('openLibraryEditionKey') != null ? Value(s('openLibraryEditionKey')) : const Value.absent(),
      mediaType: Value(MediaType.values.firstWhereOrNull((e) => e.name == s('mediaType')) ?? MediaType.reading),
    );
  }

  Future<void> _importShelvesCsvContent(String content) async {
    await _forEachRow(content, 'shelves', (get) async {
      final name = get('name');
      if (name == null) return;

      Future<List<int>> resolve(List<String> names, TagType type) async => [
            for (final n in names.map((e) => e.trim()).where((e) => e.isNotEmpty)) await _getOrCreateTag(n, type),
          ];
      List<String> pipe(String? v) => v?.split('|') ?? const [];

      final tIds = await resolve(pipe(get('filterTagNames')), TagType.tag);
      final iIds = await resolve(pipe(get('filterImprintNames')), TagType.imprint);
      final collectionNamesJson = get('filterCollectionNames');
      final cIds = await resolve(
        collectionNamesJson != null
            ? (jsonDecode(collectionNamesJson) as List).map((e) => e.toString()).toList()
            : pipe(get('filterCollection')),
        TagType.collection,
      );

      final comp = ShelvesCompanion(
        name: Value(name),
        filterQuery: Value(get('filterQuery')),
        filterAuthor: Value(get('filterAuthor')),
        filterPublisher: Value(get('filterPublisher')),
        filterIsbn: Value(get('filterIsbn')),
        filterSubtitle: Value(get('filterSubtitle')),
        filterLanguage: Value(get('filterLanguage')),
        filterTranslator: Value(get('filterTranslator')),
        filterCollectionIds: Value(cIds.isEmpty ? null : jsonEncode(cIds)),
        filterStatus: Value(get('filterStatus')),
        filterTagIds: Value(tIds.isEmpty ? null : jsonEncode(tIds)),
        filterImprintIds: Value(iIds.isEmpty ? null : jsonEncode(iIds)),
        filterNoCover: Value(get('filterNoCover')?.toLowerCase() == 'true'),
        filterSearchMode: Value(ImportExportUtils.parseInt(get('filterSearchMode')) ?? 0),
        filterFormat: Value(get('filterFormat')),
        filterOwnership: Value(get('filterOwnership')),
        filterNotes: Value(get('filterNotes')),
        filterBooleanQuery: Value(await _booleanQueryNamesToIds(get('filterBooleanQuery'))),
      );

      final exist = await _db.shelfDao.getShelfByName(name);
      final shelfId = exist?.id ?? await _db.into(_db.shelves).insert(comp);
      if (exist != null) {
        await (_db.update(_db.shelves)..where((s) => s.id.equals(shelfId))).write(comp);
      }
      await _db.shelfDao.setShelfTags(shelfId, {...tIds, ...iIds, ...cIds}.toList());
    });
  }

  Future<String?> _booleanQueryNamesToIds(String? json) async {
    if (json == null) return null;
    final map = jsonDecode(json) as Map<String, dynamic>;
    for (final c in (map['conditions'] as List? ?? const []).cast<Map<String, dynamic>>()) {
      final field = SearchField.values.firstWhereOrNull((f) => f.name == c['field']);
      final name = c.remove('valueName') as String?;
      if (field == null || name == null) continue;
      final type = _tagFields[field];
      if (type != null) c['value'] = await _getOrCreateTag(name, type);
    }
    return jsonEncode(map);
  }

  Future<int> _getOrCreateTag(String name, TagType type, {String? color, String? imagePath}) async {
    final key = '${type.name}_$name'.toLowerCase();
    final cached = _tagCache[key];
    if (cached != null) return cached;
    final id = await ImportExportUtils.getOrCreateTag(_db, name, type, color: color, imagePath: imagePath);
    _tagCache[key] = id;
    return id;
  }

  Future<void> _importHistoryCsvContent(String content, Map<int, int> bookIdMap) async {
    await _forEachRow(content, 'history', (get) async {
      final newBookId = bookIdMap[ImportExportUtils.parseInt(get('bookId'))];
      if (newBookId == null) return;
      final readNum = ImportExportUtils.parseInt(get('readNumber')) ?? 1;
      if (await _db.readHistoryDao.getRead(newBookId, readNum) != null) return;

      final sectionsRaw = get('sections');
      final segRaw = get('segmentProgress');
      final progress = ImportExportUtils.parseInt(get('progress')) ?? 0;
      await _db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
        bookId: newBookId,
        readNumber: readNum,
        startedAt: Value(ImportExportUtils.parseDate(get('startedAt'))),
        finishedAt: Value(ImportExportUtils.parseDate(get('finishedAt'))),
        sections: Value(sectionsRaw != null ? (jsonDecode(sectionsRaw) as List).cast<String>() : null),
        progress: Value(progress),
        segmentProgress: Value(segRaw != null
            ? (jsonDecode(segRaw) as Map).map((k, v) => MapEntry(int.parse(k.toString()), (v as num).toInt()))
            : (progress > 0 ? {0: progress} : null)),
        audioProgress: Value(ImportExportUtils.parseInt(get('audioProgress')) ?? 0),
        audioSegmentProgress: Value(get('audioSegmentProgress') != null
            ? (jsonDecode(get('audioSegmentProgress')!) as Map).map((k, v) => MapEntry(int.parse(k.toString()), (v as num).toInt()))
            : null),
      ));
    });
  }

  Future<void> _importLogsCsvContent(String content, Map<int, int> bookIdMap) async {
    await _forEachRow(content, 'logs', (get) async {
      final newBookId = bookIdMap[ImportExportUtils.parseInt(get('bookId'))];
      final date = ImportExportUtils.parseDate(get('date'));
      if (newBookId == null || date == null) return;
      final readNumber = ImportExportUtils.parseInt(get('readNumber'));
      final isBackfillRaw = get('isBackfill');
      final isBackfill = isBackfillRaw != null && (isBackfillRaw.toLowerCase() == 'true' || isBackfillRaw == '1');

      final medium = ReadingMedium.values.firstWhereOrNull((e) => e.name == get('medium')) ?? ReadingMedium.text;
      if (await _logExists(newBookId, date, isBackfill: isBackfill, readNumber: readNumber, medium: medium)) return;
      final sectionsRaw = get('sections');
      await _db.logDao.insertLog(ReadingLogCompanion.insert(
        bookId: newBookId,
        date: date,
        pagesRead: ImportExportUtils.parseInt(get('pagesRead')) ?? 0,
        sections: Value(sectionsRaw != null ? (jsonDecode(sectionsRaw) as List).cast<String>() : null),
        readNumber: Value(readNumber),
        isBackfill: Value(isBackfill),
        medium: Value(medium),
        startPosition: Value(ImportExportUtils.parseInt(get('startPosition'))),
      ));
    });
  }

  Future<ReadingGoal?> _findGoal(String title, DateTime startDate) =>
      (_db.select(_db.readingGoals)
            ..where((t) => t.title.equals(title) & t.startDate.equals(startDate))
            ..limit(1))
          .getSingleOrNull();

  Future<void> _importGoalsCsvContent(String content) async {
    await _forEachRow(content, 'goals', (get) async {
      final title = get('title');
      final startDate = ImportExportUtils.parseDate(get('startDate'));
      if (title == null || startDate == null) return;
      if (await _findGoal(title, startDate) != null) return;

      final shelfName = get('shelfName');
      final collectionName = get('collectionName');
      await _db.goalDao.insertGoal(ReadingGoalsCompanion.insert(
        title: title,
        type: get('type') ?? 'books',
        targetValue: ImportExportUtils.parseInt(get('targetValue')) ?? 1,
        startDate: startDate,
        endDate: ImportExportUtils.parseDate(get('endDate')) ?? DateTime(startDate.year, 12, 31),
        shelfId: Value(shelfName != null ? (await _db.shelfDao.getShelfByName(shelfName))?.id : null),
        collectionId: Value(collectionName != null ? await _getOrCreateTag(collectionName, TagType.collection) : null),
      ));
    });
  }

  Future<void> _importOwnershipCsvContent(String content, Map<int, int> bookIdMap) async {
    await _forEachRow(content, 'ownership', (get) async {
      final bookId = bookIdMap[ImportExportUtils.parseInt(get('bookId'))];
      final type = OwnershipStatus.values.firstWhereOrNull((e) => e.name == get('eventType'));
      final date = ImportExportUtils.parseDate(get('date'));
      if (bookId == null || type == null || date == null) return;
      final exists = await (_db.select(_db.ownershipLog)
            ..where((o) => o.bookId.equals(bookId) & o.eventType.equals(type.name) & o.date.equals(date))
            ..limit(1))
          .getSingleOrNull();
      if (exists != null) return;
      await _db.ownershipDao.insertEvent(OwnershipLogCompanion.insert(
        bookId: bookId,
        eventType: type,
        personName: Value(get('personName')),
        date: date,
        notes: Value(get('notes')),
      ));
    });
  }

  Future<void> _importWidgetsCsvContent(String content) async {
    // The dashboard layout is restored only into an empty dashboard; merging
    // two layouts would just produce duplicate widgets.
    final existing = await (_db.select(_db.statWidgetConfigs)..limit(1)).get();
    if (existing.isNotEmpty) return;
    await _forEachRow(content, 'widgets', (get) async {
      final type = get('type');
      final size = get('size');
      if (type == null || size == null) return;
      final goalTitle = get('goalTitle');
      final goalStart = ImportExportUtils.parseDate(get('goalStartDate'));
      final goal = goalTitle != null && goalStart != null ? await _findGoal(goalTitle, goalStart) : null;
      await _db.statDao.insertWidgetConfig(StatWidgetConfigsCompanion.insert(
        type: type,
        size: size,
        sortOrder: ImportExportUtils.parseInt(get('sortOrder')) ?? 0,
        goalId: Value(goal?.id),
        config: Value(get('config')),
      ));
    });
  }

  Future<void> _importSearchHistoryCsvContent(String content) async {
    await _forEachRow(content, 'search history', (get) async {
      final query = get('query');
      final timestamp = ImportExportUtils.parseDate(get('timestamp'));
      if (query == null || timestamp == null) return;
      final exists = await (_db.select(_db.searchHistory)
            ..where((h) => h.query.equals(query) & h.timestamp.equals(timestamp))
            ..limit(1))
          .getSingleOrNull();
      if (exists != null) return;
      await _db.searchHistoryDao.insertEntry(SearchHistoryCompanion.insert(
        query: query,
        type: get('type') ?? 'text_search',
        status: get('status') ?? 'success',
        title: Value(get('title')),
        author: Value(get('author')),
        publisher: Value(get('publisher')),
        timestamp: timestamp,
      ));
    });
  }
}
