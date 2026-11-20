import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/import_export_base.dart';

void main() {
  group('ImportExportUtils.parseDate', () {
    DateTime? parse(String s) => ImportExportUtils.parseDate(s);

    test('ISO and year-first formats', () {
      expect(parse('2024-03-05'), DateTime(2024, 3, 5));
      expect(parse('2024/03/05'), DateTime(2024, 3, 5));
    });

    test('day-first by default', () {
      expect(parse('05/03/2024'), DateTime(2024, 3, 5));
      expect(parse('25.12.2024'), DateTime(2024, 12, 25));
    });

    test('month-first when unambiguous (US exports)', () {
      expect(parse('12/25/2024'), DateTime(2024, 12, 25));
    });

    test('invalid dates are rejected instead of rolling over', () {
      expect(parse('31/02/2024'), isNull);
      expect(parse('13/13/2024'), isNull);
      expect(parse('2024/13/01'), isNull);
      expect(parse('not a date'), isNull);
    });
  });
}
