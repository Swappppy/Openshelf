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

  Future<void> deleteBook(int id) async {
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
      for (final tagId in tagIds) {
        // Check if any OTHER book uses this tag
        final remainingBooks = await (select(bookTags)
          ..where((bt) => bt.tagId.equals(tagId))).get();
        
        if (remainingBooks.isEmpty) {
          // IMPORTANT: Also check if any Shelf uses this tag for filtering
          final usedByShelf = await db.shelfDao.isTagUsedByAnyShelf(tagId);
          
          if (!usedByShelf) {
            final t = await (select(tags)..where((t) => t.id.equals(tagId)))
                .getSingleOrNull();
            if (t != null && t.type == TagType.tag) {
              await (delete(tags)..where((t) => t.id.equals(tagId))).go();
            }
          }
        }
      }
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

    if (tagIds != null && tagIds.isNotEmpty) {
      return _watchBooksWithTags(
        query: query,
        tagIds: tagIds,
        author: author,
        subtitle: subtitle,
        publisher: publisher,
        isbn: isbn,
        language: language,
        translator: translator,
        notes: notes,
        collectionIds: collectionIds,
        imprintIds: imprintIds,
        noCover: noCover,
        hasNotes: hasNotes,
        startedAt: startedAt,
        startedAtOp: startedAtOp,
        finishedAt: finishedAt,
        finishedAtOp: finishedAtOp,
        status: status,
        format: format,
        ownership: ownership,
      );
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

    // Ensure we are ALWAYS reactive to both tables when any filter is active
    return CombineLatestStream.combine2(
      q.watch(),
      (select(bookTags)..limit(1)).watch(),
      (books, _) => books,
    );
  }

  Stream<List<Book>> _watchBooksWithTags({
    String? query,
    required List<int> tagIds,
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
  }) {
    if (tagIds.isEmpty) {
      return watchBooksFiltered(
        query: query,
        author: author,
        subtitle: subtitle,
        publisher: publisher,
        isbn: isbn,
        language: language,
        translator: translator,
        notes: notes,
        collectionIds: collectionIds,
        imprintIds: imprintIds,
        noCover: noCover,
        hasNotes: hasNotes,
        startedAt: startedAt,
        startedAtOp: startedAtOp,
        finishedAt: finishedAt,
        finishedAtOp: finishedAtOp,
        status: status,
        format: format,
        ownership: ownership,
      );
    }

    final amountOfTags = tagIds.length;
    final placeholders = tagIds.map((_) => '?').join(',');
    final sql = '''
      SELECT book_id FROM book_tags
      WHERE tag_id IN ($placeholders)
      GROUP BY book_id
      HAVING COUNT(DISTINCT tag_id) >= ?
    ''';

    return customSelect(
      sql, 
      variables: [
        ...tagIds.map((id) => Variable<int>(id)),
        Variable<int>(amountOfTags),
      ],
      readsFrom: {bookTags, books}, // Ensure reactivity to book edits
    ).watch().switchMap((rows) {
      final validBookIds = rows.map((r) => r.read<int>('book_id')).toList();

      final q = select(books)
        ..where((b) {
          Expression<bool> expr = validBookIds.isEmpty ? const Constant(false) : b.id.isIn(validBookIds);
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
          if (collectionIds != null && collectionIds.isNotEmpty) {
            final bookIdsWithCollection = selectOnly(bookTags)
              ..addColumns([bookTags.bookId])
              ..where(bookTags.tagId.isIn(collectionIds));
            
            // Check both bridge table and column
            expr = expr & (b.id.isInQuery(bookIdsWithCollection) | b.collectionId.isIn(collectionIds));
          }
          if (imprintIds != null && imprintIds.isNotEmpty) {
            final bookIdsWithImprint = selectOnly(bookTags)
              ..addColumns([bookTags.bookId])
              ..where(bookTags.tagId.isIn(imprintIds));
            
            // Check both bridge table and column
            expr = expr & (b.id.isInQuery(bookIdsWithImprint) | b.imprintId.isIn(imprintIds));
          }
          if (noCover == true) {
            expr = expr & (b.coverPath.isNull() | b.coverPath.equals(''));
          } else if (noCover == false) {
            expr = expr & (b.coverPath.isNotNull() & b.coverPath.equals('').not());
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
      return q.watch();
    });
  }

  Stream<List<Book>> _watchBooksBoolean(BooleanQuery booleanQuery) {
    final q = select(books)..where((b) => _buildBooleanExpression(b, booleanQuery));
    
    // We must ensure we watch bookTags if any tag-related field is used
    final usesTags = booleanQuery.conditions.any((c) => 
      c.field == SearchField.category || 
      c.field == SearchField.collection || 
      c.field == SearchField.imprint
    );

    if (usesTags) {
      return CombineLatestStream.combine2(
        q.watch(),
        (select(bookTags)..limit(1)).watch(),
        (books, _) => books,
      );
    }
    return q.watch();
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
}
