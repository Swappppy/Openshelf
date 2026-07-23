import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:collection/collection.dart';

import '../models/tag_type.dart';
import 'database.dart';
import 'import_export_base.dart';

/// Parses and imports a LibraryThing JSON export (the "book list" JSON feed,
/// keyed by `books_id`) into the app database.
///
/// LibraryThing's JSON is notoriously irregular: the same logical field can
/// come back as a `Map` (e.g. `{"0": "...", "2": "..."}`) in one entry and a
/// plain `List` in another (seen firsthand: `isbn` and `lcc` both do this
/// across the 100-book sample used to build this importer). Every accessor
/// below is written to tolerate that instead of assuming one shape.
///
/// Known, deliberate limitations (documented here instead of buried in code):
/// - This JSON feed carries catalog/bibliographic data only — no rating, no
///   read/finished dates, no personal review. Every imported book is created
///   with [ReadingStatus.wantToRead]; there is nothing in this feed to infer
///   a better status from. If you also have LibraryThing's separate reviews
///   or tags export, that would need its own pass merged in by ISBN/books_id.
/// - `series`/`collections_idA` volume numbers aren't a separate field in
///   this feed (LT usually embeds them in the title, e.g. "(v. 1)"), so
///   `collectionNumber` is left null rather than guessed from free text.
/// - `subject`/`ddc`/`lcc`/`awards` have no matching column in Openshelf and
///   are intentionally dropped. `collections` (LT's own multi-library
///   feature) and `genre` are both folded into Openshelf's category tags,
///   since that's the closest multi-valued concept Openshelf has.
class LibrarythingImportService {
  final AppDatabase _db;
  LibrarythingImportService(this._db);

  // LT's default library name is on virtually every book and adds no
  // distinguishing information, so it's skipped rather than becoming a tag
  // every single book carries.
  static const _skipCollectionNames = {'your library'};

  Future<ImportResult> importFromFile(File file) async {
    final contents = await file.readAsString(encoding: utf8);
    return importFromString(contents);
  }

  Future<ImportResult> importFromString(String contents) async {
    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(contents) as Map<String, dynamic>;
    } catch (e) {
      return ImportResult(imported: 0, skipped: 0, errors: ['Invalid JSON: $e']);
    }

    if (decoded.isEmpty) {
      return const ImportResult(imported: 0, skipped: 0, errors: ['Empty export']);
    }

    int imported = 0;
    int skipped = 0;
    final errors = <String>[];

    for (final entry in decoded.entries) {
      final booksId = entry.key;
      final raw = entry.value;
      if (raw is! Map<String, dynamic>) {
        errors.add('Entry $booksId: not an object');
        skipped++;
        continue;
      }

      final title = (raw['title'] ?? '').toString().trim();
      if (title.isEmpty) {
        errors.add('Entry $booksId: missing title');
        skipped++;
        continue;
      }

      try {
        final authorInfo = _extractAuthors(raw);
        final isbn = _extractIsbn(raw['isbn'], originalIsbn: raw['originalisbn']?.toString());

        final isDuplicate = isbn != null
            ? await _db.bookDao.getBookByIsbn(isbn) != null
            : await _db.bookDao.existsByTitleAndAuthor(title, authorInfo.primary);

        if (isDuplicate) {
          skipped++;
          continue;
        }

        final companion = _rowToCompanion(raw, title: title, author: authorInfo.primary, translator: authorInfo.translator, isbn: isbn);
        final bookId = await _db.bookDao.insertBook(companion);

        // Series -> single-value "collection" (mirrors the pattern used by
        // the Bookshelf importer: set the free-text name on the row AND
        // resolve/create the matching collection tag for filtering).
        final seriesName = _flattenToStrings(raw['series']).firstOrNull;
        if (seriesName != null) {
          final id = await ImportExportUtils.getOrCreateTag(_db, seriesName, TagType.collection);
          await (_db.bookDao.update(_db.bookDao.books)..where((b) => b.id.equals(bookId)))
              .write(BooksCompanion(collectionId: Value(id)));
        }

        // Collections (LT's own libraries) + genre -> category tags
        final tagNames = _extractTagNames(raw);
        if (tagNames.isNotEmpty) {
          final ids = <int>[];
          for (final name in tagNames) {
            ids.add(await ImportExportUtils.getOrCreateTag(_db, name, TagType.tag));
          }
          await _db.tagDao.setBookTags(bookId, ids);
        }

        imported++;
      } catch (e) {
        errors.add('Entry $booksId ("$title"): $e');
        skipped++;
      }
    }

    return ImportResult(imported: imported, skipped: skipped, errors: errors);
  }

  BooksCompanion _rowToCompanion(
      Map<String, dynamic> raw, {
        required String title,
        required String author,
        String? translator,
        String? isbn,
      }) {
    final languages = _flattenToStrings(raw['language']);
    final publicationInfo = _parsePublication(raw['publication']?.toString());
    final year = ImportExportUtils.parseInt(raw['date']?.toString()) ?? publicationInfo.year;
    final pages = ImportExportUtils.parseInt(raw['pages']?.toString().trim());
    final copies = ImportExportUtils.parseInt(raw['copies']?.toString()) ?? 1;
    final createdAt = ImportExportUtils.parseDate(raw['entrydate']?.toString()) ?? DateTime.now();
    final seriesName = _flattenToStrings(raw['series']).firstOrNull;

    return BooksCompanion.insert(
      title: title,
      author: author,
      isbn: Value(isbn),
      language: Value(languages.firstOrNull),
      translator: Value(translator),
      // Stored as free text only -- deliberately NOT linked to an Imprint
      // tag. Imprints in Openshelf are a manually curated feature (custom
      // name, logo, color); auto-creating one per raw publisher string
      // from an import would flood that list with uncurated one-offs.
      publisher: Value(publicationInfo.publisher),
      totalPages: Value(pages),
      // See class docstring: this feed has no read/rating/review signal.
      status: ReadingStatus.wantToRead,
      copies: Value(copies),
      bookFormat: Value(_parseFormat(raw['format'])),
      collectionName: Value(seriesName),
      publishYear: Value(year),
      createdAt: Value(createdAt),
    );
  }

  _AuthorInfo _extractAuthors(Map<String, dynamic> raw) {
    final authorsRaw = raw['authors'];
    String? primary;
    String? translator;

    if (authorsRaw is List) {
      for (final a in authorsRaw) {
        if (a is! Map) continue;
        final name = (a['fl'] ?? a['lf'])?.toString().trim();
        if (name == null || name.isEmpty) continue;
        final role = (a['role'] ?? '').toString().toLowerCase();
        if (role.contains('translat')) {
          translator ??= name;
        } else {
          primary ??= name;
        }
      }
    }

    primary ??= _lastFirstToFirstLast(raw['primaryauthor']?.toString());
    // Matches the fallback BookshelfImportService uses for the same
    // situation (no usable author data at all).
    return _AuthorInfo(primary ?? 'Unknown', translator);
  }

  String? _lastFirstToFirstLast(String? lf) {
    if (lf == null || lf.trim().isEmpty) return null;
    final parts = lf.split(',');
    if (parts.length < 2) return lf.trim();
    final last = parts.first.trim();
    final first = parts.sublist(1).join(',').trim();
    return '$first $last'.trim();
  }

  /// Collects LT's own "collections" (its multi-library feature) and
  /// "genre" into one deduplicated (case-insensitive) list of tag names,
  /// skipping [_skipCollectionNames].
  List<String> _extractTagNames(Map<String, dynamic> raw) {
    final seen = <String, String>{}; // lowercase -> original casing
    void add(String name) {
      final key = name.trim().toLowerCase();
      if (key.isEmpty || _skipCollectionNames.contains(key)) return;
      seen.putIfAbsent(key, () => name.trim());
    }

    for (final c in _flattenToStrings(raw['collections'])) {
      add(c);
    }
    for (final g in _flattenToStrings(raw['genre'])) {
      add(g);
    }
    return seen.values.toList();
  }

  String? _extractIsbn(dynamic raw, {String? originalIsbn}) {
    final candidates = [..._flattenToStrings(raw), ?originalIsbn];
    String clean(String s) => s.replaceAll(RegExp(r'[^0-9Xx]'), '');
    final cleaned = candidates.map(clean).where((s) => s.isNotEmpty).toList();
    return cleaned.firstWhereOrNull((s) => s.length == 13) ?? cleaned.firstWhereOrNull((s) => s.length == 10) ?? cleaned.firstOrNull;
  }

  _PublicationInfo _parsePublication(String? raw) {
    if (raw == null || raw.trim().isEmpty) return _PublicationInfo(null, null);
    // e.g. "Harper Perennial (1990), 624 pages" or
    // "Canongate Books Limited (2007), Edition: First Edition, 320 pages"
    final match = RegExp(r'^(.*?)\s*\((\d{4})\)').firstMatch(raw);
    if (match == null) return _PublicationInfo(raw.trim().nullIfEmpty(), null);
    return _PublicationInfo(match.group(1)?.trim().nullIfEmpty(), int.tryParse(match.group(2)!));
  }

  String? _formatText(dynamic raw) {
    if (raw is List) {
      for (final f in raw) {
        if (f is Map && f['text'] != null) {
          final t = f['text'].toString().trim();
          if (t.isNotEmpty) return t;
        }
      }
    }
    return null;
  }

  BookFormat? _parseFormat(dynamic raw) {
    final text = _formatText(raw);
    if (text == null) return null;
    return switch (text.toLowerCase()) {
      'paperback' || 'paper book' => BookFormat.paperback,
      'hardcover' || 'hardback' => BookFormat.hardcover,
      'leatherbound' || 'leather bound' => BookFormat.leatherbound,
      'ebook' || 'e-book' || 'digital' || 'kindle edition' => BookFormat.digital,
      _ => BookFormat.other,
    };
  }

  /// Recursively flattens LT's inconsistent `Map`/`List`/`List-of-List`
  /// shapes (seen in `collections`, `genre`, `series`, `language`, `subject`,
  /// `lcc`, `isbn`, etc.) into a flat list of non-empty strings, ignoring
  /// map keys (which are just numeric indices in this feed).
  List<String> _flattenToStrings(dynamic raw) {
    final out = <String>[];
    void walk(dynamic v) {
      if (v == null) return;
      if (v is String) {
        final s = v.trim();
        if (s.isNotEmpty) out.add(s);
      } else if (v is List) {
        for (final e in v) {
          walk(e);
        }
      } else if (v is Map) {
        for (final e in v.values) {
          walk(e);
        }
      } else {
        final s = v.toString().trim();
        if (s.isNotEmpty) out.add(s);
      }
    }

    walk(raw);
    return out;
  }
}

class _AuthorInfo {
  final String primary;
  final String? translator;
  _AuthorInfo(this.primary, this.translator);
}

class _PublicationInfo {
  final String? publisher;
  final int? year;
  _PublicationInfo(this.publisher, this.year);
}