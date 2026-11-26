import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/utils/media_progress.dart';
import 'package:openshelf/services/database.dart';

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

  group('coveredRuns', () {
    ReadingLogData log(int id, ReadingMedium medium, int? start, int amount, {int read = 1}) => ReadingLogData(
          id: id,
          bookId: 1,
          date: DateTime(2026, 1, id),
          pagesRead: amount,
          readNumber: read,
          isBackfill: false,
          medium: medium,
          startPosition: start,
        );

    test('each medium keeps its own runs; gaps are the other medium', () {
      final logs = [
        log(1, ReadingMedium.audio, 0, 3600), // listened 0:00-1:00
        log(2, ReadingMedium.text, 44, 76), // read pages 45-120
        log(3, ReadingMedium.audio, 11400, 1800), // resumed at 3:10
      ];
      expect(coveredRuns(logs: logs, readNumber: 1, medium: ReadingMedium.text, pointer: 120), [(44, 120)]);
      expect(coveredRuns(logs: logs, readNumber: 1, medium: ReadingMedium.audio, pointer: 13200),
          [(0, 3600), (11400, 13200)]);
    });

    test('touching or overlapping runs merge; other reads are ignored', () {
      final logs = [
        log(1, ReadingMedium.text, 0, 50),
        log(2, ReadingMedium.text, 50, 30),
        log(3, ReadingMedium.text, 70, 20), // overlaps 70-80
        log(4, ReadingMedium.text, 0, 300, read: 2),
      ];
      expect(coveredRuns(logs: logs, readNumber: 1, medium: ReadingMedium.text, pointer: 90), [(0, 90)]);
    });

    test('entries without a start fall back to one run up to the pointer', () {
      final logs = [log(1, ReadingMedium.text, null, 40)];
      expect(coveredRuns(logs: logs, readNumber: 1, medium: ReadingMedium.text, pointer: 40), [(0, 40)]);
      expect(coveredRuns(logs: const [], readNumber: 1, medium: ReadingMedium.text, pointer: 0), isEmpty);
    });
  });
}
