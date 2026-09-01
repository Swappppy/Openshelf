import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/models/shelf.dart';

void main() {
  group('Shelf Model Tests', () {
    test('Shelf copyWith', () {
      const shelf = Shelf(
        id: 1,
        name: 'Initial Name',
        filterQuery: 'Initial Query',
      );

      final updated = shelf.copyWith(name: 'Updated Name');
      expect(updated.name, 'Updated Name');
      expect(updated.filterQuery, 'Initial Query');
      expect(updated.id, 1);
    });

    test('Shelf copyWith clearStatus', () {
      const shelf = Shelf(
        id: 1,
        name: 'Shelf',
        filterStatus: 'toRead',
      );

      final cleared = shelf.copyWith(clearStatus: true);
      expect(cleared.filterStatus, isNull);
      
      final preserved = shelf.copyWith(name: 'New');
      expect(preserved.filterStatus, 'toRead');
    });

    test('Shelf toJson and equality edge cases', () {
      const shelf = Shelf(
        id: 1,
        name: 'Smart Shelf',
        filterNoCover: true,
        filterSearchMode: 2,
      );

      final json = shelf.toJson();
      expect(json['name'], 'Smart Shelf');
      expect(json['filterNoCover'], true);
      expect(json['filterSearchMode'], 2);
      
      final copy = shelf.copyWith(id: 2, name: 'Other');
      expect(copy.id, 2);
      expect(copy.name, 'Other');
      expect(copy.filterNoCover, true); 
    });
  });
}
