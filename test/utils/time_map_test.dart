import 'package:flutter_test/flutter_test.dart';
import 'package:openshelf/services/database.dart';
import 'package:openshelf/utils/time_map.dart';

void main() {
  PaginationSegment seg(int start, int end, {int? startSeconds, int? endSeconds}) => PaginationSegment(
        startPhysical: start,
        endPhysical: end,
        type: PageNumberingType.arabic,
        startSeconds: startSeconds,
        endSeconds: endSeconds,
      );

  test('without anchors it is a global proportion', () {
    final map = TimeMap(totalPages: 300, duration: 36000);
    expect(map.toSeconds(150), 18000);
    expect(map.toPages(9000), 75);
  });

  test('anchors keep each stretch local', () {
    // Body ends at page 240 (= 10:00:00); pages 241-300 are notes with no audio.
    final map = TimeMap(
      totalPages: 300,
      duration: 36000,
      segments: [seg(1, 240, endSeconds: 35999), seg(241, 300)],
    );
    expect(map.toSeconds(120), closeTo(18000, 1)); // middle of the body
    expect(map.toPages(18000), closeTo(120, 1));
    // The notes squeeze into the last second instead of shifting the body.
    expect(map.segmentSeconds(seg(241, 300)).$1, 35999);
  });

  test('contradictory anchors are ignored', () {
    final map = TimeMap(
      totalPages: 100,
      duration: 1000,
      segments: [seg(1, 50, endSeconds: 600), seg(51, 70, endSeconds: 400)],
    );
    expect(map.anchors, [(0, 0), (50, 600), (100, 1000)]);
  });

  test('marker anchors are used and positioned', () {
    final marker = PaginationMarker(physicalPage: 11, label: 'Cap. 1', seconds: 900);
    final map = TimeMap(totalPages: 200, duration: 20000, markers: [marker]);
    expect(map.markerSeconds(marker), 900);
    expect(map.toSeconds(10), 900);
    expect(map.toPages(900), 10);
  });

  group('sectionRuns', () {
    // Three sections: pages 1-100, 101-200, 201-300.
    const sections = [(0, 100), (100, 200), (200, 300)];

    test('sections read out of order are logged where they are', () {
      final runs = sectionRuns(
        sections: sections,
        oldProgress: const {0: 100},
        newProgress: const {0: 100, 2: 40}, // jumped to the third section
      );
      expect(runs, [(start: 200, delta: 40, section: 2)]);
    });

    test('a hand-off starts the run at startAt inside its section', () {
      final runs = sectionRuns(
        sections: sections,
        oldProgress: const {0: 30},
        newProgress: const {0: 80}, // listened 30-60 meanwhile; read 60-80
        startAt: 60,
      );
      expect(runs, [(start: 60, delta: 20, section: 0)]);
    });

    test('decreases are reported as negative deltas', () {
      final runs = sectionRuns(sections: sections, oldProgress: const {1: 50}, newProgress: const {1: 20});
      expect(runs, [(start: 150, delta: -30, section: 1)]);
    });
  });
}
