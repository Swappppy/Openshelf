import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import '../database.dart';
import '../../models/search_filters.dart';

part 'book_dao.g.dart';

@DriftAccessor(tables: [Books, Tags, BookTags])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  BookDao(super.db);

  Stream<List<Book>> watchAllBooks() => select(books).watch();

  Stream<List<Book>> watchBooksByStatus(ReadingStatus status) {
    return (select(books)
      ..where((b) => b.status.equals(status.name)))
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
          collectionNumber: Value(tag.collectionNumber),
        ));
      }

      return newId;
    });
  }

  Future<void> deleteBook(int id, {bool pruneEnabled = true, List<int>? excludedIds}) async {
    await transaction(() async {
      // 1. Get tags before they are deleted by cascade or manual delete
      final linked = await (select(bookTags)
        ..where((bt) => bt.bookId.equals(id))).get();
      final tagIds = linked.map((bt) => bt.tagId).toList();

      // 2. Clear related records that might not have cascades (safety)
      await (delete(db.readHistory)..where((h) => h.bookId.equals(id))).go();
      await (delete(db.ownershipLog)..where((o) => o.bookId.equals(id))).go();
      await (delete(db.readingLog)..where((l) => l.bookId.equals(id))).go();
      
      // 3. Delete the book and its M:M relationships (bookTags)
      // Note: BookTags has onDelete: KeyAction.cascade on bookId, but we delete it explicitly for clarity/safety
      await (delete(bookTags)..where((bt) => bt.bookId.equals(id))).go();
      await (delete(books)..where((b) => b.id.equals(id))).go();

      // 4. Clean up orphan categories (tags of type 'tag')
      await db.tagDao.pruneOrphanTags(
        enabled: pruneEnabled,
        excludedIds: excludedIds,
        candidateIds: tagIds,
      );
    });
  }

  Future<Book?> getBook(int id) =>
      (select(books)..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<Book?> getBookByIsbn(String isbn) =>
      (select(books)..where((b) => b.isbn.equals(isbn))).getSingleOrNull();

  Stream<List<(Book, int?)>> watchBooksByCollectionWithNumbers(int collectionId) {
    final query = select(books).join([
      innerJoin(bookTags, bookTags.bookId.equalsExp(books.id)),
    ])
      ..where(bookTags.tagId.equals(collectionId))
      ..orderBy([OrderingTerm.asc(bookTags.collectionNumber)]);

    return query.watch().map((rows) => rows.map((r) {
          return (r.readTable(books), r.readTable(bookTags).collectionNumber);
        }).toList());
  }

  Future<bool> existsByTitleAndAuthor(String title, String author) async {
    final query = select(books)
      ..where((b) =>
          b.title.lower().equals(title.toLowerCase()) &
          b.author.lower().equals(author.toLowerCase()));
    final match = await query.getSingleOrNull();
    return match != null;
  }

  Future<void> setBookImprint(int bookId, int? imprintId) async {
    await (update(books)..where((b) => b.id.equals(bookId))).write(BooksCompanion(
      imprintId: Value(imprintId),
    ));
  }

  Stream<List<Book>> watchBooksFiltered({
    String? query,
    List<int>? tagIds,
    String? author,
    String? subtitle,
    String? publisher,
    String? isbn,
    String? language,
    String? translator,
    String? notes,
    List<int>? collectionIds,
    List<int>? imprintIds,
    bool? noCover,
    bool? hasNotes,
    DateTime? startedAt,
    BooleanOperator? startedAtOp,
    DateTime? finishedAt,
    BooleanOperator? finishedAtOp,
    ReadingStatus? status,
    String? format,
    String? ownership,
    BooleanQuery? booleanQuery,
  }) {
    if (booleanQuery != null && booleanQuery.conditions.isNotEmpty) {
      return _watchBooksBoolean(booleanQuery);
    }

    final q = select(books)
      ..where((b) {
        Expression<bool> expr = const Constant(true);
        if (query != null && query.isNotEmpty) {
          expr = expr & (b.title.contains(query) | b.author.contains(query) | b.isbn.contains(query));
        }
        if (author != null && author.isNotEmpty) {
          expr = expr & b.author.contains(author);
        }
        if (subtitle != null && subtitle.isNotEmpty) {
          expr = expr & b.subtitle.contains(subtitle);
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
        if (translator != null && translator.isNotEmpty) {
          expr = expr & b.translator.contains(translator);
        }
        if (notes != null && notes.isNotEmpty) {
          expr = expr & b.notes.contains(notes);
        }
        
        // Native Tag Filtering (AND logic)
        if (tagIds != null && tagIds.isNotEmpty) {
          for (final tid in tagIds) {
            final subquery = selectOnly(bookTags)
              ..addColumns([bookTags.bookId])
              ..where(bookTags.tagId.equals(tid));
            expr = expr & b.id.isInQuery(subquery);
          }
        }

        if (collectionIds != null && collectionIds.isNotEmpty) {
          final bookIdsWithCollection = selectOnly(bookTags)
            ..addColumns([bookTags.bookId])
            ..where(bookTags.tagId.isIn(collectionIds));

          // Check both the many-to-many table AND the direct collectionId column
          expr = expr & (b.id.isInQuery(bookIdsWithCollection) | b.collectionId.isIn(collectionIds));
        }
        if (imprintIds != null && imprintIds.isNotEmpty) {
          final bookIdsWithImprint = selectOnly(bookTags)
            ..addColumns([bookTags.bookId])
            ..where(bookTags.tagId.isIn(imprintIds));

          // Check both the many-to-many table AND the direct imprintId column
          expr = expr & (b.id.isInQuery(bookIdsWithImprint) | b.imprintId.isIn(imprintIds));
        }
        if (noCover == true) {
          expr = expr &
            (b.coverPath.isNull() | b.coverPath.equals('')) &
            (b.coverUrl.isNull() | b.coverUrl.equals(''));
        } else if (noCover == false) {
          expr = expr &
            (b.coverPath.isNotNull() & b.coverPath.equals('').not() |
             b.coverUrl.isNotNull() & b.coverUrl.equals('').not());
        }
        if (hasNotes == true) {
          expr = expr & (b.notes.isNotNull() & b.notes.equals('').not());
        } else if (hasNotes == false) {
          expr = expr & (b.notes.isNull() | b.notes.equals(''));
        }
        if (startedAt != null) {
          expr = expr & _applyDateOp(b.startedAt, startedAtOp ?? BooleanOperator.equals, startedAt);
        }
        if (finishedAt != null) {
          expr = expr & _applyDateOp(b.finishedAt, finishedAtOp ?? BooleanOperator.equals, finishedAt);
        }
        if (status != null) {
          expr = expr & b.status.equals(status.name);
        }
        if (format != null && format.isNotEmpty) {
          final f = BookFormat.values.where((e) => e.name == format).firstOrNull;
          if (f != null) expr = expr & b.bookFormat.equals(f.name);
        }
        if (ownership != null && ownership.isNotEmpty) {
          final o = OwnershipStatus.values.where((e) => e.name == ownership).firstOrNull;
          if (o != null) expr = expr & b.ownershipStatus.equals(o.name);
        }
        return expr;
      });

    // Forced Reactivity Signal: Combine with bookTags stream to guarantee updates on M:M changes
    return CombineLatestStream.combine2(
      q.watch(),
      (select(bookTags)..limit(1)).watch(),
      (books, _) => books,
    );
  }

  Stream<List<Book>> _watchBooksBoolean(BooleanQuery booleanQuery) {
    final q = select(books)..where((b) => _buildBooleanExpression(b, booleanQuery));

    // Forced Reactivity Signal for Boolean Queries too
    return CombineLatestStream.combine2(
      q.watch(),
      (select(bookTags)..limit(1)).watch(),
      (books, _) => books,
    );
  }

  Expression<bool> _buildBooleanExpression(Books b, BooleanQuery query) {
    Expression<bool> result = const Constant(true);

    for (int i = 0; i < query.conditions.length; i++) {
      final cond = query.conditions[i];
      final expr = _conditionToExpression(b, cond);

      if (i == 0) {
        result = expr;
      } else {
        if (cond.connector == BooleanConnector.or) {
          result = result | expr;
        } else {
          result = result & expr;
        }
      }
    }

    return result;
  }

  Expression<bool> _conditionToExpression(Books b, BooleanCondition cond) {
    final val = cond.value ?? '';
    switch (cond.field) {
      case SearchField.title:
        return _applyStringOp(b.title, cond.operator, val.toString());
      case SearchField.author:
        return _applyStringOp(b.author, cond.operator, val.toString());
      case SearchField.subtitle:
        return _applyStringOp(b.subtitle, cond.operator, val.toString());
      case SearchField.publisher:
        return _applyStringOp(b.publisher, cond.operator, val.toString());
      case SearchField.isbn:
        return _applyStringOp(b.isbn, cond.operator, val.toString());
      case SearchField.language:
        return _applyStringOp(b.language, cond.operator, val.toString());
      case SearchField.translator:
        return _applyStringOp(b.translator, cond.operator, val.toString());
      case SearchField.originalTitle:
        return _applyStringOp(b.originalTitle, cond.operator, val.toString());
      case SearchField.originalLanguage:
        return _applyStringOp(b.originalLanguage, cond.operator, val.toString());
      case SearchField.year:
        return _applyNumOp(b.publishYear, cond.operator, val);
      case SearchField.pages:
        return _applyNumOp(b.totalPages, cond.operator, val);
      case SearchField.status:
        final s = ReadingStatus.values.where((e) => e.name == val.toString()).firstOrNull;
        return s != null ? b.status.equals(s.name) : const Constant(false);
      case SearchField.noCover:
        if (val == true) {
          return (b.coverPath.isNull() | b.coverPath.equals('')) & 
                 (b.coverUrl.isNull() | b.coverUrl.equals(''));
        } else {
          return (b.coverPath.isNotNull() & b.coverPath.equals('').not()) | 
                 (b.coverUrl.isNotNull() & b.coverUrl.equals('').not());
        }
      case SearchField.category:
        return _applyTagOp(b.id, cond.operator, val, TagType.tag);
      case SearchField.imprint:
        if (cond.operator == BooleanOperator.includes && val.toString().isNotEmpty) {
          final intId = int.tryParse(val.toString());
          if (intId != null) return b.imprintId.equals(intId);
        }
        return _applyTagOp(b.id, cond.operator, val, TagType.imprint);
      case SearchField.collection:
        return _applyTagOp(b.id, cond.operator, val, TagType.collection);
      case SearchField.format:
        final f = BookFormat.values.where((e) => e.name == val.toString()).firstOrNull;
        return f != null ? b.bookFormat.equals(f.name) : const Constant(false);
      case SearchField.ownership:
        final o = OwnershipStatus.values.where((e) => e.name == val.toString()).firstOrNull;
        return o != null ? b.ownershipStatus.equals(o.name) : const Constant(false);
      case SearchField.startedAt:
        return _applyDateOp(b.startedAt, cond.operator, val);
      case SearchField.finishedAt:
        return _applyDateOp(b.finishedAt, cond.operator, val);
      case SearchField.notes:
        return _applyStringOp(b.notes, cond.operator, val.toString());
      case SearchField.hasNotes:
        if (val == true) {
          return b.notes.isNotNull() & b.notes.equals('').not();
        } else {
          return b.notes.isNull() | b.notes.equals('');
        }
    }
  }

  Expression<bool> _applyDateOp(DateTimeColumn col, BooleanOperator op, dynamic val) {
    if (val == null) return const Constant(true);
    final DateTime? date = val is DateTime ? val : DateTime.tryParse(val.toString());
    if (date == null) return const Constant(true);

    switch (op) {
      case BooleanOperator.equals:
        return col.equals(date);
      case BooleanOperator.greaterThan:
        return col.isBiggerThan(Constant(date));
      case BooleanOperator.lessThan:
        return col.isSmallerThan(Constant(date));
      default:
        return col.equals(date);
    }
  }

  Expression<bool> _applyStringOp(TextColumn col, BooleanOperator op, String val) {
    switch (op) {
      case BooleanOperator.contains:
        return col.contains(val);
      case BooleanOperator.exactly:
        return col.equals(val);
      case BooleanOperator.startsWith:
        return col.like('$val%');
      default:
        return col.contains(val);
    }
  }

  Expression<bool> _applyNumOp(IntColumn col, BooleanOperator op, dynamic val) {
    final numVal = int.tryParse(val.toString()) ?? 0;
    switch (op) {
      case BooleanOperator.equals:
        return col.equals(numVal);
      case BooleanOperator.notEquals:
        return col.equals(numVal).not();
      case BooleanOperator.greaterThan:
        return col.isBiggerThan(Constant(numVal));
      case BooleanOperator.lessThan:
        return col.isSmallerThan(Constant(numVal));
      case BooleanOperator.between:
        // Expects "min,max" string
        final parts = val.toString().split(',');
        if (parts.length == 2) {
          final min = int.tryParse(parts[0]) ?? 0;
          final max = int.tryParse(parts[1]) ?? 9999;
          return col.isBetween(Constant(min), Constant(max));
        }
        return const Constant(true);
      default:
        return col.equals(numVal);
    }
  }

  Expression<bool> _applyTagOp(IntColumn bookIdCol, BooleanOperator op, dynamic val, TagType type) {
    final tagId = int.tryParse(val.toString()) ?? 0;
    
    final subquery = selectOnly(bookTags)
      ..addColumns([bookTags.bookId])
      ..where(bookTags.tagId.equals(tagId));

    switch (op) {
      case BooleanOperator.includes:
        return bookIdCol.isInQuery(subquery);
      case BooleanOperator.notIncludes:
        return bookIdCol.isInQuery(subquery).not();
      default:
        return bookIdCol.isInQuery(subquery);
    }
  }

  /// Duplicates multiple books in a single transaction.
  Future<List<int>> bulkDuplicateBooks(List<int> originalIds) async {
    return await transaction(() async {
      final newIds = <int>[];
      for (final id in originalIds) {
        newIds.add(await duplicateBook(id));
      }
      return newIds;
    });
  }

  /// Deletes multiple books in a single transaction with orphan tag pruning.
  Future<void> bulkDeleteBooks(List<int> ids, {bool pruneEnabled = true, List<int>? excludedIds}) async {
    if (ids.isEmpty) return;
    await transaction(() async {
      final allTagIds = <int>{};
      for (final id in ids) {
        final linked = await (select(bookTags)..where((bt) => bt.bookId.equals(id))).get();
        allTagIds.addAll(linked.map((bt) => bt.tagId));
      }

      await (delete(db.readHistory)..where((h) => h.bookId.isIn(ids))).go();
      await (delete(db.ownershipLog)..where((o) => o.bookId.isIn(ids))).go();
      await (delete(db.readingLog)..where((l) => l.bookId.isIn(ids))).go();

      await (delete(bookTags)..where((bt) => bt.bookId.isIn(ids))).go();
      await (delete(books)..where((b) => b.id.isIn(ids))).go();

      await db.tagDao.pruneOrphanTags(
        enabled: pruneEnabled,
        excludedIds: excludedIds,
        candidateIds: allTagIds.toList(),
      );
    });
  }

  /// Applies bulk edits to a list of book IDs for specified unlocked fields.
  Future<void> bulkUpdateBooks(List<int> bookIds, BulkEditData data) async {
    if (bookIds.isEmpty || !data.hasAnyFieldToUpdate) return;

    await transaction(() async {
      final candidateTagIds = <int>{};

      for (final id in bookIds) {
        final existingBook = await getBook(id);
        if (existingBook == null) continue;

        BooksCompanion companion = const BooksCompanion();

        if (data.updateStatus && data.status != null) {
          companion = companion.copyWith(status: Value(data.status!));
        }
        if (data.updateOwnership) {
          companion = companion.copyWith(ownershipStatus: Value(data.ownershipStatus));
        }
        if (data.updateFormat) {
          companion = companion.copyWith(bookFormat: Value(data.format));
        }
        if (data.updateRating) {
          companion = companion.copyWith(rating: Value(data.rating));
        }
        if (data.updateAuthor && data.author != null) {
          companion = companion.copyWith(author: Value(data.author!));
        }
        if (data.updatePublisher) {
          companion = companion.copyWith(publisher: Value(data.publisher));
        }
        if (data.updateLanguage) {
          companion = companion.copyWith(language: Value(data.language));
        }
        if (data.updatePublishYear) {
          companion = companion.copyWith(publishYear: Value(data.publishYear));
        }
        if (data.updateTranslator) {
          companion = companion.copyWith(translator: Value(data.translator));
        }
        if (data.updateCopies && data.copies != null) {
          companion = companion.copyWith(copies: Value(data.copies!));
        }
        if (data.updateImprint) {
          companion = companion.copyWith(imprintId: Value(data.imprintId));
        }

        if (data.updateNotes) {
          if (data.appendNotes && data.notes != null && data.notes!.isNotEmpty) {
            final existingNotes = existingBook.notes ?? '';
            final combined = existingNotes.isEmpty
                ? data.notes!
                : '$existingNotes\n${data.notes!}';
            companion = companion.copyWith(notes: Value(combined));
          } else {
            companion = companion.copyWith(notes: Value(data.notes));
          }
        }

        if (companion != const BooksCompanion()) {
          await (update(books)..where((b) => b.id.equals(id))).write(companion);
        }

        // Tags & Collections M:M updates
        if (data.updateTags || data.updateCollections) {
          final oldTags = await db.tagDao.watchTagsForBook(id).first;
          candidateTagIds.addAll(oldTags.map((t) => t.id));

          final List<int> newTagIds = data.updateTags && data.tagIds != null
              ? data.tagIds!
              : (await db.tagDao.watchTagsForBook(id).first).map((t) => t.id).toList();

          final List<(int, int?)> newCollections = data.updateCollections && data.collections != null
              ? data.collections!
              : (await db.tagDao.watchCollectionsForBook(id).first)
                  .map((c) => (c.$1.id, c.$2))
                  .toList();

          candidateTagIds.addAll(newTagIds);
          for (final c in newCollections) {
            candidateTagIds.add(c.$1);
          }

          await db.tagDao.setBookTags(id, newTagIds, collections: newCollections);
        }
      }

      if (candidateTagIds.isNotEmpty) {
        await db.tagDao.pruneOrphanTags(
          candidateIds: candidateTagIds.toList(),
        );
      }
    });
  }

  Future<List<String>> getDistinctAuthors(String query) async {
    final q = selectOnly(books, distinct: true)
      ..addColumns([books.author])
      ..where(books.author.lower().contains(query.toLowerCase()) & books.author.isNotNull() & books.author.equals('').not())
      ..limit(20);
    final rows = await q.get();
    return rows.map((r) => r.read(books.author)!).where((s) => s.isNotEmpty).toList();
  }

  Future<List<String>> getDistinctPublishers(String query) async {
    final q = selectOnly(books, distinct: true)
      ..addColumns([books.publisher])
      ..where(books.publisher.lower().contains(query.toLowerCase()) & books.publisher.isNotNull() & books.publisher.equals('').not())
      ..limit(20);
    final rows = await q.get();
    return rows.map((r) => r.read(books.publisher)!).where((s) => s.isNotEmpty).toList();
  }

  Future<List<String>> getDistinctLanguages(String query) async {
    final q = selectOnly(books, distinct: true)
      ..addColumns([books.language])
      ..where(books.language.lower().contains(query.toLowerCase()) & books.language.isNotNull() & books.language.equals('').not())
      ..limit(20);
    final rows = await q.get();
    return rows.map((r) => r.read(books.language)!).where((s) => s.isNotEmpty).toList();
  }

  Future<List<String>> getDistinctTranslators(String query) async {
    final q = selectOnly(books, distinct: true)
      ..addColumns([books.translator])
      ..where(books.translator.lower().contains(query.toLowerCase()) & books.translator.isNotNull() & books.translator.equals('').not())
      ..limit(20);
    final rows = await q.get();
    return rows.map((r) => r.read(books.translator)!).where((s) => s.isNotEmpty).toList();
  }
}

class BulkEditData {
  final bool updateStatus;
  final ReadingStatus? status;

  final bool updateOwnership;
  final OwnershipStatus? ownershipStatus;

  final bool updateFormat;
  final BookFormat? format;

  final bool updateRating;
  final double? rating;

  final bool updateAuthor;
  final String? author;

  final bool updatePublisher;
  final String? publisher;

  final bool updateLanguage;
  final String? language;

  final bool updatePublishYear;
  final int? publishYear;

  final bool updateTranslator;
  final String? translator;

  final bool updateTags;
  final List<int>? tagIds;

  final bool updateImprint;
  final int? imprintId;

  final bool updateCollections;
  final List<(int, int?)>? collections;

  final bool updateNotes;
  final String? notes;
  final bool appendNotes;

  final bool updateCopies;
  final int? copies;

  const BulkEditData({
    this.updateStatus = false,
    this.status,
    this.updateOwnership = false,
    this.ownershipStatus,
    this.updateFormat = false,
    this.format,
    this.updateRating = false,
    this.rating,
    this.updateAuthor = false,
    this.author,
    this.updatePublisher = false,
    this.publisher,
    this.updateLanguage = false,
    this.language,
    this.updatePublishYear = false,
    this.publishYear,
    this.updateTranslator = false,
    this.translator,
    this.updateTags = false,
    this.tagIds,
    this.updateImprint = false,
    this.imprintId,
    this.updateCollections = false,
    this.collections,
    this.updateNotes = false,
    this.notes,
    this.appendNotes = false,
    this.updateCopies = false,
    this.copies,
  });

  bool get hasAnyFieldToUpdate =>
      updateStatus ||
      updateOwnership ||
      updateFormat ||
      updateRating ||
      updateAuthor ||
      updatePublisher ||
      updateLanguage ||
      updatePublishYear ||
      updateTranslator ||
      updateTags ||
      updateImprint ||
      updateCollections ||
      updateNotes ||
      updateCopies;
}

