import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/book_search_service.dart';
import 'package:openshelf/models/book_search_result.dart';

void main() {
  group('BookSearchService Logic Tests', () {
    test('calculateScore - exact ISBN match', () {
      final res = BookSearchResult(
        title: 'Some Book',
        authors: ['Author'],
        isbn: '1234567890',
        source: 'Provider',
      );

      final score = BookSearchService.calculateScore(res, '1234567890', true);
      expect(score, 5000);
    });

    test('calculateScore - exact title match', () {
      final res = BookSearchResult(
        title: 'Flutter in Action',
        authors: ['Eric Windmill'],
        source: 'Provider',
      );

      final score = BookSearchService.calculateScore(res, 'Flutter in Action', false);
      expect(score, 2000);
    });

    test('arePeers - same ISBN', () {
      final a = BookSearchResult(title: 'A', authors: ['Auth'], isbn: '123', source: 'S1');
      final b = BookSearchResult(title: 'B', authors: ['Auth'], isbn: '123', source: 'S2');

      expect(BookSearchService.arePeers(a, b), true);
    });

    test('arePeers - same title and similar authors', () {
      final a = BookSearchResult(title: 'Flutter Guide', authors: ['John Doe'], source: 'S1');
      final b = BookSearchResult(title: 'Flutter Guide', authors: ['John A. Doe'], source: 'S2');

      expect(BookSearchService.arePeers(a, b), true);
    });

    test('mergeResults - prioritizes data richness', () {
      final res1 = BookSearchResult(
        title: 'Short Title',
        authors: ['Author A'],
        description: 'Short desc',
        source: 'S1',
      );
      final res2 = BookSearchResult(
        title: 'Longer Title for Book',
        authors: ['Author A', 'Author B'],
        description: 'A much longer description that contains more info.',
        source: 'S2',
      );

      final merged = BookSearchService.mergeResults([res1, res2], query: 'test', isIsbn: false);

      expect(merged!.title, 'Longer Title for Book');
      expect(merged.authors, containsAll(['Author A', 'Author B']));
      expect(merged.description, 'A much longer description that contains more info.');
    });
  });
}
