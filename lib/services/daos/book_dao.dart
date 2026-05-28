import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import '../database.dart';
import '../../models/tag_type.dart';

part 'book_dao.g.dart';

@DriftAccessor(tables: [Books, Tags, BookTags])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  BookDao(super.db);

  Stream<List<Book>> watchAllBooks() => select(books).watch();

  Stream<List<Book>> watchBooksByStatus(ReadingStatus status) {
    return (select(books)
      ..where((b) => b.status.equalsValue(status)))
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
        ));
      }

      return newId;
    });
  }

  Future<void> deleteBook(int id) async {
    await transaction(() async {
      final linked = await (select(bookTags)
        ..where((bt) => bt.bookId.equals(id))).get();
      final tagIds = linked.map((bt) => bt.tagId).toList();

      await (delete(bookTags)..where((bt) => bt.bookId.equals(id))).go();
      await (delete(books)..where((b) => b.id.equals(id))).go();

      // Clean up orphan categories (tags)
      for (final tagId in tagIds) {
        final remaining = await (select(bookTags)
          ..where((bt) => bt.tagId.equals(tagId))).get();
        if (remaining.isEmpty) {
          final t = await (select(tags)..where((t) => t.id.equals(tagId)))
              .getSingleOrNull();
          if (t != null && t.type == TagType.tag) {
            await (delete(tags)..where((t) => t.id.equals(tagId))).go();
          }
        }
      }
    });
  }

  Future<Book?> getBook(int id) =>
      (select(books)..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<Book?> getBookByIsbn(String isbn) =>
      (select(books)..where((b) => b.isbn.equals(isbn))).getSingleOrNull();

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
    String? publisher,
    String? isbn,
    String? language,
    List<int>? collectionIds,
    List<int>? imprintIds,
    bool? noCover,
    ReadingStatus? status,
  }) {
    if (tagIds != null && tagIds.isNotEmpty) {
      return _watchBooksWithTags(
        query: query,
        tagIds: tagIds,
        author: author,
        publisher: publisher,
        isbn: isbn,
        language: language,
        collectionIds: collectionIds,
        imprintIds: imprintIds,
        noCover: noCover,
        status: status,
      );
    }

    final q = select(books)
      ..where((b) {
        Expression<bool> expr = const Constant(true);
        if (query != null && query.isNotEmpty) {
          expr = expr & b.title.contains(query);
        }
        if (author != null && author.isNotEmpty) {
          expr = expr & b.author.contains(author);
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
        if (collectionIds != null && collectionIds.isNotEmpty) {
          expr = expr & b.collectionId.isIn(collectionIds);
        }
        if (imprintIds != null && imprintIds.isNotEmpty) {
          expr = expr & b.imprintId.isIn(imprintIds);
        }
        if (noCover == true) {
          expr = expr & (b.coverPath.isNull() | b.coverPath.equals(''));
        }
        if (status != null) {
          expr = expr & b.status.equalsValue(status);
        }
        return expr;
      });
    return q.watch();
  }

  Stream<List<Book>> _watchBooksWithTags({
    String? query,
    List<int>? tagIds,
    String? author,
    String? publisher,
    String? isbn,
    String? language,
    List<int>? collectionIds,
    List<int>? imprintIds,
    bool? noCover,
    ReadingStatus? status,
  }) {
    if (tagIds == null || tagIds.isEmpty) {
      return watchBooksFiltered(
        query: query,
        author: author,
        publisher: publisher,
        isbn: isbn,
        language: language,
        collectionIds: collectionIds,
        imprintIds: imprintIds,
        noCover: noCover,
        status: status,
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
      ]
    ).watch().switchMap((rows) {
      final validBookIds = rows.map((r) => r.read<int>('book_id')).toList();
      if (validBookIds.isEmpty) return Stream.value(<Book>[]);

      final q = select(books)
        ..where((b) {
          Expression<bool> expr = b.id.isIn(validBookIds);
          if (query != null && query.isNotEmpty) {
            expr = expr & b.title.contains(query);
          }
          if (author != null && author.isNotEmpty) {
            expr = expr & b.author.contains(author);
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
          if (collectionIds != null && collectionIds.isNotEmpty) {
            expr = expr & b.collectionId.isIn(collectionIds);
          }
          if (imprintIds != null && imprintIds.isNotEmpty) {
            expr = expr & b.imprintId.isIn(imprintIds);
          }
          if (noCover == true) {
            expr = expr & (b.coverPath.isNull() | b.coverPath.equals(''));
          }
          if (status != null) {
            expr = expr & b.status.equalsValue(status);
          }
          return expr;
        });
      return q.watch();
    });
  }
}
