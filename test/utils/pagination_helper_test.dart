import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/utils/pagination_helper.dart';

void main() {
  group('PaginationHelper.distributePhysicalPage', () {
    final segments = [
      PaginationSegment(startPhysical: 1, endPhysical: 10, type: PageNumberingType.arabic), // 10 pages
      PaginationSegment(startPhysical: 11, endPhysical: 30, type: PageNumberingType.arabic), // 20 pages
      PaginationSegment(startPhysical: 31, endPhysical: 100, type: PageNumberingType.arabic), // 70 pages
    ];

    test('Zero progress', () {
      final result = PaginationHelper.distributePhysicalPage(0, segments);
      expect(result, isEmpty);
    });

    test('Progress in first segment', () {
      final result = PaginationHelper.distributePhysicalPage(5, segments);
      expect(result[0], 5);
      expect(result[1], 0);
      expect(result[2], 0);
    });

    test('Progress at end of first segment', () {
      final result = PaginationHelper.distributePhysicalPage(10, segments);
      expect(result[0], 10);
      expect(result[1], 0);
      expect(result[2], 0);
    });

    test('Progress in second segment', () {
      final result = PaginationHelper.distributePhysicalPage(15, segments);
      expect(result[0], 10); // Completed
      expect(result[1], 5);  // 15 - 11 + 1 = 5
      expect(result[2], 0);
    });

    test('Progress at end of second segment', () {
      final result = PaginationHelper.distributePhysicalPage(30, segments);
      expect(result[0], 10);
      expect(result[1], 20);
      expect(result[2], 0);
    });

    test('Progress in third segment', () {
      final result = PaginationHelper.distributePhysicalPage(50, segments);
      expect(result[0], 10);
      expect(result[1], 20);
      expect(result[2], 20); // 50 - 31 + 1 = 20
    });

    test('Total completion', () {
      final result = PaginationHelper.distributePhysicalPage(100, segments);
      expect(result[0], 10);
      expect(result[1], 20);
      expect(result[2], 70);
    });

    test('Overflow past total pages', () {
      final result = PaginationHelper.distributePhysicalPage(150, segments);
      expect(result[0], 10);
      expect(result[1], 20);
      expect(result[2], 70);
    });
  });
}
