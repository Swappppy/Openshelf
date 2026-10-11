import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/book_search_service.dart';
import 'package:openshelf/models/book_search_result.dart';

void main() {
  group('BookSearchService Phase A: Eligibility (isEligible)', () {
    test('isEligible returns false if ISBN does not match requested ISBN', () {
      final res = BookSearchResult(
        title: 'Random Book',
        authors: ['Author'],
        isbn: '9780000000000',
        source: 'Provider',
      );
      final query = BookSearchQuery(isbn: '9781111111111');

      expect(BookSearchService.isEligible(res, query), false);
    });

    test('isEligible returns true for exact matching ISBN', () {
      final res = BookSearchResult(
        title: 'Random Book',
        authors: ['Author'],
        isbn: '9781234567890',
        source: 'Provider',
      );
      final query = BookSearchQuery(isbn: '9781234567890');

      expect(BookSearchService.isEligible(res, query), true);
    });

    test('isEligible returns false if title does not match query title', () {
      final res = BookSearchResult(
        title: 'Cooking 101',
        authors: ['Chef John'],
        source: 'Provider',
      );
      final query = BookSearchQuery(title: 'Quantum Physics Guide');

      expect(BookSearchService.isEligible(res, query), false);
    });

    test('isEligible returns true when title matches partially or exactly', () {
      final res = BookSearchResult(
        title: 'Cien años de soledad',
        authors: ['Gabriel García Márquez'],
        source: 'Provider',
      );
      final query = BookSearchQuery(title: 'Cien Años');

      expect(BookSearchService.isEligible(res, query), true);
    });

    test('isEligible returns false if author does not match requested author', () {
      final res = BookSearchResult(
        title: 'Don Quijote',
        authors: ['Stephen King'],
        source: 'Provider',
      );
      final query = BookSearchQuery(title: 'Don Quijote', author: 'Cervantes');

      expect(BookSearchService.isEligible(res, query), false);
    });

    test('isEligible returns true when both title and author match', () {
      final res = BookSearchResult(
        title: 'Don Quijote de la Mancha',
        authors: ['Miguel de Cervantes'],
        source: 'Provider',
      );
      final query = BookSearchQuery(title: 'Don Quijote', author: 'Cervantes');

      expect(BookSearchService.isEligible(res, query), true);
    });
  });

  group('BookSearchService Phase B: Ranking (calculateRankScore)', () {
    test('calculateRankScore applies preferred language boost', () {
      final query = BookSearchQuery(title: 'Dune');
      final spanishEd = BookSearchResult(
        title: 'Dune',
        authors: ['Frank Herbert'],
        language: 'es',
        source: 'S1',
      );
      final englishEd = BookSearchResult(
        title: 'Dune',
        authors: ['Frank Herbert'],
        language: 'en',
        source: 'S2',
      );

      final scoreEs = BookSearchService.calculateRankScore(spanishEd, query, preferredLanguage: 'es');
      final scoreEn = BookSearchService.calculateRankScore(englishEd, query, preferredLanguage: 'es');

      expect(scoreEs, greaterThan(scoreEn));
    });

    test('calculateRankScore penalizes self-published books', () {
      final query = BookSearchQuery(title: 'Sample');
      final selfPub = BookSearchResult(
        title: 'Sample',
        authors: ['Author'],
        publisher: 'Independently published',
        source: 'S1',
      );
      final tradPub = BookSearchResult(
        title: 'Sample',
        authors: ['Author'],
        publisher: 'Penguin Random House',
        source: 'S2',
      );

      final scoreSelf = BookSearchService.calculateRankScore(selfPub, query);
      final scoreTrad = BookSearchService.calculateRankScore(tradPub, query);

      expect(scoreTrad, greaterThan(scoreSelf));
    });

    test('calculateRankScore boosts canonical work with higher edition count', () {
      final query = BookSearchQuery(title: 'Yo, robot', author: 'Asimov');
      final canonicalWork = BookSearchResult(
        title: 'Yo, robot',
        authors: ['Isaac Asimov'],
        publishYear: 1950,
        editionCount: 85,
        source: 'Open Library',
      );
      final selfPublishedDup = BookSearchResult(
        title: 'Yo, robot',
        authors: ['Isaac Asimov'],
        publishYear: 2015,
        editionCount: 1,
        publisher: 'Independently published',
        source: 'Open Library',
      );

      final canonicalScore = BookSearchService.calculateRankScore(canonicalWork, query);
      final selfPubScore = BookSearchService.calculateRankScore(selfPublishedDup, query);

      expect(canonicalScore, greaterThan(selfPubScore));
    });
  });

  group('Deduplication & Peer Grouping', () {
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

    test('mergeResults - prioritizes data richness and max edition count', () {
      final res1 = BookSearchResult(
        title: 'Short Title',
        authors: ['Author A'],
        description: 'Short desc',
        source: 'S1',
        editionCount: 10,
      );
      final res2 = BookSearchResult(
        title: 'Longer Title for Book',
        authors: ['Author A', 'Author B'],
        description: 'A much longer description that contains more info.',
        source: 'S2',
        editionCount: 50,
      );

      final merged = BookSearchService.mergeResults([res1, res2], query: 'test', isIsbn: false);

      expect(merged!.title, 'Longer Title for Book');
      expect(merged.authors, containsAll(['Author A', 'Author B']));
      expect(merged.description, 'A much longer description that contains more info.');
      expect(merged.editionCount, 50);
    });
  });
}
