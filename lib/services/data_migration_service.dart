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

/// Service for exporting and importing the entire library database via CSV and ZIP.
class DataMigrationService {
  final AppDatabase _db;

  DataMigrationService(this._db);

  // --- Export ---

  /// Exports all books to a CSV string.
  Future<String> exportBooksToCsv() async {
    final books = await _db.select(_db.books).get();
    
    final rows = <List<dynamic>>[];
    // Header
    rows.add([
      'id', 'title', 'subtitle', 'author', 'isbn', 'language', 'translator',
      'publisher', 'publishYear', 'totalPages', 'currentPage', 'status',
      'rating', 'bookFormat', 'collectionName', 'collectionNumber',
      'notes', 'startedAt', 'finishedAt', 'createdAt', 'coverUrl', 'coverPath',
      'categories', 'categoryColors', 'imprintName', 'imprintColor', 'imprintImage'
    ]);

    for (final b in books) {
      // Fetch categories for this book
      final tags = await _db.watchTagsForBook(b.id).first;
      final cats = tags.map((t) => t.name).join('|');
      final colors = tags.map((t) => t.color ?? '').join('|');
      
      // Fetch imprint
      final imprint = await _db.watchImprintForBook(b.id).first;

      rows.add([
        b.id, b.title, b.subtitle, b.author, b.isbn, b.language, b.translator,
        b.publisher, b.publishYear, b.totalPages, b.currentPage, b.status.name,
        b.rating, b.bookFormat?.name, b.collectionName, b.collectionNumber,
        b.notes, b.startedAt?.toIso8601String(), b.finishedAt?.toIso8601String(),
        b.createdAt.toIso8601String(), b.coverUrl, b.coverPath,
        cats, colors, imprint?.name, imprint?.color, imprint?.imagePath
      ]);
    }

    return Csv().encode(rows);
  }

  /// Exports all custom shelves to a CSV string.
  Future<String> exportShelvesToCsv() async {
    final shelves = await _db.select(_db.shelves).get();
    final rows = <List<dynamic>>[];
    
    rows.add([
      'name', 'filterQuery', 'filterAuthor', 'filterPublisher', 'filterIsbn',
      'filterSubtitle', 'filterLanguage', 'filterTranslator', 'filterCollectionIds',
      'filterStatus', 'filterTagNames', 'filterImprintNames'
    ]);

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

  /// Exports all tags (categories, imprints, collections) to a CSV string.
  Future<String> exportTagsToCsv() async {
    final tags = await _db.select(_db.tags).get();
    final rows = <List<dynamic>>[];
    
    rows.add(['name', 'type', 'color', 'imagePath']);

    for (final t in tags) {
      rows.add([
        t.name, t.type.name, t.color, 
        t.imagePath != null ? p.basename(t.imagePath!) : null
      ]);
    }

    return Csv().encode(rows);
  }

  Future<List<String>> _getNamesFromIds(String? jsonIds) async {
    if (jsonIds == null || jsonIds.isEmpty) return [];
    try {
      final ids = (jsonDecode(jsonIds) as List).cast<int>();
      if (ids.isEmpty) return [];
      final tags = await _db.getTagsByIds(ids);
      return tags.map((t) => t.name).toList();
    } catch (_) {
      return [];
    }
  }

  /// Bundles all local media (covers and imprint images) into an Archive.
  Future<void> _bundleMedia(Archive archive) async {
    // 1. Book Covers
    final books = await _db.select(_db.books).get();
    for (final b in books) {
      if (b.coverPath != null) {
        await _addFileToArchive(archive, b.coverPath!);
      }
    }

    // 2. Tag Images (Imprints)
    final tags = await _db.select(_db.tags).get();
    for (final t in tags) {
      if (t.imagePath != null) {
        // Imprints are usually in a subfolder or just docDir. 
        // We preserve the 'imprints/' prefix if it was there or just put them in imprints/
        await _addFileToArchive(archive, t.imagePath!, subDir: 'imprints');
      }
    }
  }

  Future<void> _addFileToArchive(Archive archive, String path, {String? subDir}) async {
    final file = File(path);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      final fileName = p.basename(path);
      final archivePath = subDir != null ? p.join(subDir, fileName) : fileName;
      
      // Avoid duplicates in archive
      if (archive.files.any((f) => f.name == archivePath)) return;
      
      archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
    }
  }

  /// Exports everything into a single ZIP file and opens the share sheet.
  Future<void> shareBackup({bool includeCovers = true}) async {
    final tempDir = await getTemporaryDirectory();
    final archive = Archive();
    final encoder = ZipEncoder();

    // 1. Add CSVs to Archive
    final booksCsv = await exportBooksToCsv();
    archive.addFile(ArchiveFile('books.csv', booksCsv.length, utf8.encode(booksCsv)));

    final shelvesCsv = await exportShelvesToCsv();
    archive.addFile(ArchiveFile('shelves.csv', shelvesCsv.length, utf8.encode(shelvesCsv)));

    final tagsCsv = await exportTagsToCsv();
    archive.addFile(ArchiveFile('tags.csv', tagsCsv.length, utf8.encode(tagsCsv)));

    // 2. Add Media if requested
    if (includeCovers) {
      await _bundleMedia(archive);
    }

    final zipData = encoder.encode(archive);
    final zipFile = File(p.join(tempDir.path, 'openshelf_full_backup.zip'));
    await zipFile.writeAsBytes(zipData);

    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(zipFile.path)], subject: 'Openshelf Full Backup');
  }

  // --- Import ---

  /// Imports from an Openshelf backup (ZIP or CSV).
  Future<int> importFromBackup(File sourceFile, {File? zipFile, bool compress = true}) async {
    // Compatibility: if sourceFile is CSV and zipFile is provided, handle as legacy
    if (p.extension(sourceFile.path).toLowerCase() == '.csv' && zipFile != null) {
      return _importLegacy(sourceFile, zipFile);
    }

    // If it's a ZIP, extract and process
    if (p.extension(sourceFile.path).toLowerCase() == '.zip') {
      return _importFromZip(sourceFile, compress: compress);
    }

    // If it's just a CSV, import books only
    if (p.extension(sourceFile.path).toLowerCase() == '.csv') {
      return _importBooksCsv(sourceFile);
    }

    throw Exception('Unsupported file format');
  }

  Future<int> _importFromZip(File zipFile, {bool compress = true}) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final docDir = await getApplicationDocumentsDirectory();
    final tempDir = await getTemporaryDirectory();

    ArchiveFile? booksFile;
    ArchiveFile? shelvesFile;
    ArchiveFile? tagsFile;

    // 1. Extract files and identify CSVs
    for (final file in archive) {
      if (!file.isFile) continue;
      
      if (file.name == 'books.csv') {
        booksFile = file;
      } else if (file.name == 'shelves.csv') {
        shelvesFile = file;
      } else if (file.name == 'tags.csv') {
        tagsFile = file;
      } else {
        // Extract media with optional compression
        final data = file.content as List<int>;
        final fileName = file.name;
        final targetPath = p.join(docDir.path, fileName);
        
        final isImage = fileName.toLowerCase().endsWith('.jpg') || 
                        fileName.toLowerCase().endsWith('.png') || 
                        fileName.toLowerCase().endsWith('.jpeg');
        
        if (compress && isImage) {
          final tempFile = File(p.join(tempDir.path, 'import_$fileName'))..createSync(recursive: true)..writeAsBytesSync(data);
          await CoverService.compressImage(tempFile.path, targetPath);
          tempFile.deleteSync();
        } else {
          File(targetPath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        }
      }
    }

    if (booksFile == null) throw Exception('Invalid backup: books.csv missing');

    // 2. Process Tags first (they are dependencies for books and shelves)
    if (tagsFile != null) {
      final content = utf8.decode(tagsFile.content as List<int>);
      await _importTagsCsvContent(content, localBaseDir: docDir.path);
    }

    // 3. Process Books
    final booksContent = utf8.decode(booksFile.content as List<int>);
    final importedCount = await _importBooksCsvContent(booksContent, localBaseDir: docDir.path);

    // 4. Process Shelves
    if (shelvesFile != null) {
      final content = utf8.decode(shelvesFile.content as List<int>);
      await _importShelvesCsvContent(content);
    }

    return importedCount;
  }

  Future<int> _importLegacy(File csvFile, File zipFile) async {
    // Extract media from ZIP
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final docDir = await getApplicationDocumentsDirectory();
    for (final file in archive) {
      if (file.isFile) {
        final data = file.content as List<int>;
        final fullPath = p.join(docDir.path, file.name);
        File(fullPath)..createSync(recursive: true)..writeAsBytesSync(data);
      }
    }
    return _importBooksCsv(csvFile);
  }

  Future<int> _importBooksCsv(File file) async {
    final docDir = await getApplicationDocumentsDirectory();
    final content = await file.readAsString(encoding: utf8);
    return _importBooksCsvContent(content, localBaseDir: docDir.path);
  }

  Future<void> _importTagsCsvContent(String content, {required String localBaseDir}) async {
    final rows = Csv().decode(content);
    if (rows.length < 2) return;
    final header = rows.first.map((e) => e.toString().toLowerCase()).toList();
    
    for (final row in rows.skip(1)) {
      final name = _getRaw(header, row, 'name');
      final typeStr = _getRaw(header, row, 'type') ?? 'tag';
      final type = TagType.values.firstWhere((e) => e.name == typeStr, orElse: () => TagType.tag);
      final color = _getRaw(header, row, 'color');
      final img = _getRaw(header, row, 'imagePath');
      
      if (name == null) continue;
      
      String? localImgPath;
      if (img != null && img.isNotEmpty) {
        localImgPath = p.join(localBaseDir, 'imprints', p.basename(img));
      }
      
      await _getOrCreateTag(name, type, color: color, imagePath: localImgPath);
    }
  }

  Future<int> _importBooksCsvContent(String content, {required String localBaseDir}) async {
    final rows = Csv().decode(content);
    if (rows.length < 2) return 0;
    final header = rows.first.map((e) => e.toString().toLowerCase()).toList();
    int imported = 0;

    await _db.transaction(() async {
      for (final row in rows.skip(1)) {
        final b = _mapRowToCompanion(header, row, localBaseDir: localBaseDir);
        
        final existing = await (_db.select(_db.books)
          ..where((tbl) => tbl.title.equals(b.title.value) & tbl.author.equals(b.author.value)))
          .getSingleOrNull();
          
        int bookId;
        if (existing == null) {
          bookId = await _db.into(_db.books).insert(b);
          imported++;
        } else {
          bookId = existing.id;
        }

        // Handle tags
        final cats = _getRaw(header, row, 'categories')?.split('|') ?? [];
        final clrs = _getRaw(header, row, 'categoryColors')?.split('|') ?? [];
        final List<int> tagIds = [];
        for (int j = 0; j < cats.length; j++) {
          final name = cats[j].trim();
          if (name.isEmpty) continue;
          
          final colorRaw = j < clrs.length ? clrs[j].trim() : null;
          final color = (colorRaw == null || colorRaw.isEmpty || colorRaw.toLowerCase() == 'null') ? null : colorRaw;

          final tid = await _getOrCreateTag(name, TagType.tag, color: color);
          tagIds.add(tid);
        }
        if (tagIds.isNotEmpty) await _db.setBookTags(bookId, tagIds);

        // Handle imprint
        final impName = _getRaw(header, row, 'imprintName')?.trim();
        if (impName != null && impName.isNotEmpty) {
          final impColor = _getRaw(header, row, 'imprintColor')?.trim();
          final impImg = _getRaw(header, row, 'imprintImage')?.trim();
          String? localImpPath;
          if (impImg != null && impImg.isNotEmpty) {
            localImpPath = p.join(localBaseDir, 'imprints', p.basename(impImg));
          }
          final tid = await _getOrCreateTag(impName, TagType.imprint, color: impColor, imagePath: localImpPath);
          await _db.setBookImprint(bookId, tid);
        }
      }
    });
    return imported;
  }

  Future<void> _importShelvesCsvContent(String content) async {
    final rows = Csv().decode(content);
    if (rows.length < 2) return;
    final header = rows.first.map((e) => e.toString().toLowerCase()).toList();

    for (final row in rows.skip(1)) {
      final name = _getRaw(header, row, 'name');
      if (name == null) continue;

      // Map names back to IDs
      final tagNames = _getRaw(header, row, 'filterTagNames')?.split('|') ?? [];
      final imprintNames = _getRaw(header, row, 'filterImprintNames')?.split('|') ?? [];

      final List<int> tagIds = [];
      for (final tn in tagNames) {
        if (tn.isEmpty) continue;
        final t = await _getOrCreateTag(tn, TagType.tag);
        tagIds.add(t);
      }

      final List<int> imprintIds = [];
      for (final iname in imprintNames) {
        if (iname.isEmpty) continue;
        final i = await _getOrCreateTag(iname, TagType.imprint);
        imprintIds.add(i);
      }

      final companion = ShelvesCompanion.insert(
        name: name,
        filterQuery: Value(_getRaw(header, row, 'filterQuery')),
        filterAuthor: Value(_getRaw(header, row, 'filterAuthor')),
        filterPublisher: Value(_getRaw(header, row, 'filterPublisher')),
        filterIsbn: Value(_getRaw(header, row, 'filterIsbn')),
        filterSubtitle: Value(_getRaw(header, row, 'filterSubtitle')),
        filterLanguage: Value(_getRaw(header, row, 'filterLanguage')),
        filterTranslator: Value(_getRaw(header, row, 'filterTranslator')),
        filterCollectionIds: Value(_getRaw(header, row, 'filterCollectionIds')),
        filterStatus: Value(_getRaw(header, row, 'filterStatus')),
        filterTagIds: Value(tagIds.isEmpty ? null : jsonEncode(tagIds)),
        filterImprintIds: Value(imprintIds.isEmpty ? null : jsonEncode(imprintIds)),
      );

      // Check if shelf exists
      final existing = await (_db.select(_db.shelves)..where((t) => t.name.equals(name))).getSingleOrNull();
      if (existing == null) {
        await _db.into(_db.shelves).insert(companion);
      } else {
        await _db.updateShelf(existing.copyWith(
          filterQuery: companion.filterQuery.value,
          filterAuthor: companion.filterAuthor.value,
          filterPublisher: companion.filterPublisher.value,
          filterIsbn: companion.filterIsbn.value,
          filterSubtitle: companion.filterSubtitle.value,
          filterLanguage: companion.filterLanguage.value,
          filterTranslator: companion.filterTranslator.value,
          filterCollectionIds: companion.filterCollectionIds.value,
          filterStatus: companion.filterStatus.value,
          filterTagIds: companion.filterTagIds.value,
          filterImprintIds: companion.filterImprintIds.value,
        ));
      }
    }
  }

  // --- Helpers ---

  Future<int> _getOrCreateTag(String name, TagType type, {String? color, String? imagePath}) async {
    final existing = await _db.searchTags(name, type);
    final exact = existing.firstWhereOrNull((t) => t.name.toLowerCase() == name.toLowerCase());
    
    if (exact != null) {
      if ((color != null && exact.color == null) || (imagePath != null && exact.imagePath == null)) {
        final updated = exact.copyWith(
          color: Value(exact.color ?? color),
          imagePath: Value(exact.imagePath ?? imagePath),
        );
        await _db.updateTag(updated);
      }
      return exact.id;
    }

    return await _db.insertTag(TagsCompanion.insert(
      name: name,
      type: Value(type),
      color: Value(color),
      imagePath: Value(imagePath),
    ));
  }

  String? _getRaw(List<String> header, List<dynamic> row, String col) {
    final idx = header.indexOf(col.toLowerCase());
    if (idx == -1 || idx >= row.length) return null;
    final v = row[idx]?.toString();
    if (v == null || v.trim().isEmpty || v.trim().toLowerCase() == 'null') return null;
    return v;
  }

  BooksCompanion _mapRowToCompanion(List<String> header, List<dynamic> row, {required String localBaseDir}) {
    String? s(String col) => _getRaw(header, row, col);
    int? i(String col) => int.tryParse(s(col) ?? '');
    DateTime? d(String col) => DateTime.tryParse(s(col) ?? '');

    final originalCoverPath = s('coverPath');
    String? relinkedCoverPath;
    if (originalCoverPath != null) {
      relinkedCoverPath = p.join(localBaseDir, p.basename(originalCoverPath));
    }

    return BooksCompanion.insert(
      title: s('title') ?? 'Unknown',
      subtitle: Value(s('subtitle')),
      author: s('author') ?? 'Unknown',
      isbn: Value(s('isbn')),
      language: Value(s('language')),
      translator: Value(s('translator')),
      publisher: Value(s('publisher')),
      publishYear: Value(i('publishYear')),
      totalPages: Value(i('totalPages')),
      currentPage: Value(i('currentPage')),
      status: _parseStatus(s('status')),
      rating: Value(double.tryParse(s('rating') ?? '')),
      bookFormat: Value(_parseFormat(s('bookFormat'))),
      collectionName: Value(s('collectionName')),
      collectionNumber: Value(i('collectionNumber')),
      notes: Value(s('notes')),
      startedAt: Value(d('startedAt')),
      finishedAt: Value(d('finishedAt')),
      createdAt: s('createdAt') != null ? Value(DateTime.parse(s('createdAt')!)) : const Value.absent(),
      coverUrl: Value(s('coverUrl')),
      coverPath: Value(relinkedCoverPath),
    );
  }

  ReadingStatus _parseStatus(String? name) {
    return ReadingStatus.values.firstWhere((e) => e.name == name, orElse: () => ReadingStatus.wantToRead);
  }

  BookFormat? _parseFormat(String? name) {
    if (name == null) return null;
    return BookFormat.values.firstWhereOrNull((e) => e.name == name);
  }
}
