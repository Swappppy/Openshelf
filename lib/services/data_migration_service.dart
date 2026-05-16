import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'database.dart';

/// Service for exporting and importing the entire library database via CSV and ZIP.
class DataMigrationService {
  final AppDatabase _db;

  DataMigrationService(this._db);

  // --- Export ---

  /// Exports all books and tags to a CSV string.
  Future<String> exportToCsv() async {
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

    return const ListToCsvConverter().convert(rows);
  }

  /// Bundles all local cover images and imprint logos into a ZIP file.
  Future<File?> exportCoversToZip() async {
    final books = await _db.select(_db.books).get();
    final encoder = ZipEncoder();
    final archive = Archive();

    int addedCount = 0;

    // Helper to add files to archive with subdirectories
    Future<void> addFileToArchive(String? path, {String? subDir}) async {
      if (path == null) return;
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final fileName = p.basename(path);
        final archivePath = subDir != null ? p.join(subDir, fileName) : fileName;
        archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
        addedCount++;
      }
    }

    for (final b in books) {
      await addFileToArchive(b.coverPath);
      
      // Also zip imprints linked to this book
      final imprint = await _db.watchImprintForBook(b.id).first;
      if (imprint?.imagePath != null) {
        await addFileToArchive(imprint!.imagePath, subDir: 'imprints');
      }
    }

    if (addedCount == 0) return null;

    final zipData = encoder.encode(archive);
    final tempDir = await getTemporaryDirectory();
    final zipFile = File(p.join(tempDir.path, 'openshelf_media_backup.zip'));
    await zipFile.writeAsBytes(zipData);
    return zipFile;
  }

  /// Exports both CSV and optionally ZIP, then opens the system share sheet.
  Future<void> shareBackup({bool includeCovers = true}) async {
    final csvContent = await exportToCsv();
    final tempDir = await getTemporaryDirectory();
    
    final csvFile = File(p.join(tempDir.path, 'openshelf_library_backup.csv'));
    await csvFile.writeAsString(csvContent, encoding: utf8);

    final filesToShare = [XFile(csvFile.path)];

    if (includeCovers) {
      final zipFile = await exportCoversToZip();
      if (zipFile != null) {
        filesToShare.add(XFile(zipFile.path));
      }
    }

    // ignore: deprecated_member_use
    await Share.shareXFiles(filesToShare, subject: 'Openshelf Library Backup');
  }

  // --- Import ---

  /// Imports a previously exported CSV and optionally restores covers from a ZIP.
  /// This operation is additive by default (doesn't delete existing books).
  Future<int> importFromBackup(File csvFile, {File? zipFile}) async {
    final docDir = await getApplicationDocumentsDirectory();

    // 1. Extract covers if provided
    if (zipFile != null) {
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        if (file.isFile) {
          final data = file.content as List<int>;
          // Zip entry might be 'cover.jpg' or 'imprints/logo.png'
          final fullPath = p.join(docDir.path, file.name);
          File(fullPath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        }
      }
    }

    // 2. Parse CSV
    final contents = await csvFile.readAsString(encoding: utf8);
    final rows = const CsvToListConverter().convert(contents);
    if (rows.length < 2) return 0; // Only header or empty

    final header = rows.first.map((e) => e.toString().toLowerCase()).toList();
    final data = rows.skip(1);

    int imported = 0;
    
    await _db.transaction(() async {
      for (final row in data) {
        final b = _mapRowToCompanion(header, row, localBaseDir: docDir.path);
        
        // Duplicate check (by Title + Author)
        final existing = await (_db.select(_db.books)
          ..where((tbl) => tbl.title.equals(b.title.value) & tbl.author.equals(b.author.value)))
          .getSingleOrNull();
          
        int bookId;
        if (existing == null) {
          bookId = await _db.into(_db.books).insert(b);
          imported++;
        } else {
          bookId = existing.id;
          // Optionally update existing book if needed, but let's keep it additive for now
        }

        // Handle tags (categories)
        final cats = _getRaw(header, row, 'categories')?.split('|') ?? [];
        final clrs = _getRaw(header, row, 'categoryColors')?.split('|') ?? [];
        final List<int> tagIds = [];
        for (int j = 0; j < cats.length; j++) {
          final name = cats[j].trim();
          if (name.isEmpty) continue;
          final colorRaw = j < clrs.length ? clrs[j].trim() : null;
          final color = (colorRaw == null || colorRaw.isEmpty || colorRaw.toLowerCase() == 'null') ? null : colorRaw;
          final tid = await _getOrCreateTag(name, 'tag', color: color);
          tagIds.add(tid);
        }
        if (tagIds.isNotEmpty) await _db.setBookTags(bookId, tagIds);

        // Handle imprint
        final impName = _getRaw(header, row, 'imprintName')?.trim();
        if (impName != null && impName.isNotEmpty) {
          final impColor = _getRaw(header, row, 'imprintColor')?.trim();
          final impImg = _getRaw(header, row, 'imprintImage')?.trim();
          // Relink image path to local directory
          String? localImpPath;
          if (impImg != null && impImg.isNotEmpty) {
            localImpPath = p.join(docDir.path, 'imprints', p.basename(impImg));
          }
          final tid = await _getOrCreateTag(impName, 'imprint', color: impColor, imagePath: localImpPath);
          await _db.setBookImprint(bookId, tid);
        }
      }
    });

    return imported;
  }

  Future<int> _getOrCreateTag(String name, String type, {String? color, String? imagePath}) async {
    final existing = await _db.searchTags(name, type);
    final exact = existing.firstWhereOrNull((t) => t.name.toLowerCase() == name.toLowerCase());
    
    if (exact != null) {
      // If tag exists but migration provides color/image that is missing, update it
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

    int? i(String col) {
      final v = s(col);
      return v != null ? int.tryParse(v) : null;
    }

    DateTime? d(String col) {
      final v = s(col);
      return v != null ? DateTime.tryParse(v) : null;
    }

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
      createdAt: s('createdAt') != null 
          ? Value(DateTime.parse(s('createdAt')!)) 
          : const Value.absent(),
      coverUrl: Value(s('coverUrl')),
      coverPath: Value(relinkedCoverPath),
    );
  }

  ReadingStatus _parseStatus(String? name) {
    return ReadingStatus.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ReadingStatus.wantToRead,
    );
  }

  BookFormat? _parseFormat(String? name) {
    if (name == null) return null;
    return BookFormat.values.firstWhereOrNull((e) => e.name == name);
  }
}
