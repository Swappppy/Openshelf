import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/utils/media_progress.dart';

void main() {
  group('parseDuration', () {
    test('accepts h:mm:ss, h:mm and bare hours', () {
      expect(parseDuration('3:10:05'), 3 * 3600 + 10 * 60 + 5);
      expect(parseDuration('12:30'), 12 * 3600 + 30 * 60);
      expect(parseDuration('10'), 10 * 3600);
      expect(parseDuration(' 0:05 '), 5 * 60);
    });

    test('rejects malformed or out-of-range input', () {
      expect(parseDuration(''), isNull);
      expect(parseDuration('1:60'), isNull);
      expect(parseDuration('1:00:60'), isNull);
      expect(parseDuration('1::00'), isNull);
      expect(parseDuration('a:00'), isNull);
      expect(parseDuration('1:2:3:4'), isNull);
    });
  });

  group('formatDuration', () {
    test('formats as hh:mm and hh:mm:ss', () {
      expect(formatDuration(0), '00:00');
      expect(formatDuration(10 * 3600), '10:00');
      expect(formatDuration(3 * 3600 + 5 * 60 + 9), '03:05');
      expect(formatDuration(3 * 3600 + 5 * 60 + 9, withSeconds: true), '03:05:09');
    });

    test('round-trips through parseDuration', () {
      const s = 10 * 3600 + 7 * 60 + 42;
      expect(parseDuration(formatDuration(s, withSeconds: true)), s);
    });
  });
}
