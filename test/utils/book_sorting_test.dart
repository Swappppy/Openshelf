import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/models/display_preferences.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/utils/book_sorting.dart';

void main() {
  late AppDatabase db;
  late List<Book> books;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    Future<void> add(String title, DateTime? finishedAt, {int? year}) => db.into(db.books).insert(BooksCompanion.insert(
        title: title, author: 'A', status: ReadingStatus.read, finishedAt: Value(finishedAt), publishYear: Value(year)));
    await add('Old', DateTime(2022, 3, 1), year: 1990);
    await add('Unread', null);
    await add('Recent', DateTime(2025, 6, 1), year: 2010);
    await add('Middle', DateTime(2024, 1, 15));
    books = await db.select(db.books).get();
  });

  tearDown(() => db.close());

  List<String> sorted(DisplayPreferences prefs) => ([...books]..applyLibrarySorting(prefs)).map((b) => b.title).toList();

  test('finish date sorts most recent first by default, unread last', () {
    const prefs = DisplayPreferences(sortOrder: ['finishedAt', 'title']);
    expect(sorted(prefs), ['Recent', 'Middle', 'Old', 'Unread']);
  });

  test('ascending finish date keeps books without one at the end', () {
    final prefs = const DisplayPreferences(sortOrder: ['finishedAt']).copyWith(
      sortDirections: {...const DisplayPreferences().sortDirections, 'finishedAt': true},
    );
    expect(sorted(prefs), ['Old', 'Middle', 'Recent', 'Unread']);
  });

  test('empty-values toggle puts books without a value first', () {
    const prefs = DisplayPreferences(sortOrder: ['finishedAt'], emptyAtEnd: false);
    expect(sorted(prefs).first, 'Unread');
  });

  test('empty-values toggle also applies to other optional fields', () {
    final prefs = const DisplayPreferences(sortOrder: ['publishYear', 'title']);
    expect(sorted(prefs), ['Old', 'Recent', 'Middle', 'Unread']);
  });

  test('saved sort settings gain the new criterion without losing their order', () {
    final prefs = DisplayPreferences.fromJson({
      'sortOrder': ['rating', 'title', 'removedCriterion'],
      'sortDirections': {'rating': true},
    });
    expect(prefs.sortOrder.take(2), ['rating', 'title']);
    expect(prefs.sortOrder, contains('finishedAt'));
    expect(prefs.sortOrder, isNot(contains('removedCriterion')));
    expect(prefs.sortOrder.toSet().length, prefs.sortOrder.length);
    expect(prefs.sortDirections['rating'], isTrue, reason: 'saved direction kept');
    expect(prefs.sortDirections['finishedAt'], isFalse, reason: 'new criterion gets its default');
  });
}
