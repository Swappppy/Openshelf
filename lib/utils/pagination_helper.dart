import 'package:collection/collection.dart';
import '../services/database.dart';

class PaginationHelper {
  static String getVisualPage(int physicalPage, PaginationConfig? config, {bool forceRoman = false}) {
    if (config == null || config.segments.isEmpty) {
      if (forceRoman) return _toRoman(physicalPage);
      return physicalPage.toString();
    }

    final segment = config.segments.firstWhere(
      (s) => physicalPage >= s.startPhysical && physicalPage <= s.endPhysical,
      orElse: () => config.segments.last,
    );

    return getVisualPageInSegment(physicalPage, segment);
  }

  static String getVisualPageInSegment(int physicalPage, PaginationSegment segment) {
    // If physicalPage is exactly startPhysical - 1, it means 0 pages read in this segment
    if (physicalPage < segment.startPhysical) {
      return segment.type == PageNumberingType.roman ? '-' : '0';
    }

    // Clamp physicalPage to segment bounds for calculation
    final clampedPhys = physicalPage.clamp(segment.startPhysical, segment.endPhysical);
    final pageInSegment = clampedPhys - segment.startPhysical + 1;
    final visualValue = pageInSegment + segment.offset;

    if (segment.type == PageNumberingType.roman) {
      return _toRoman(visualValue);
    }

    return visualValue.toString();
  }

  static String _toRoman(int value) {
    if (value <= 0) return value.toString();
    
    final romanMap = {
      1000: 'M',
      900: 'CM',
      500: 'D',
      400: 'CD',
      100: 'C',
      90: 'XC',
      50: 'L',
      40: 'XL',
      10: 'X',
      9: 'IX',
      5: 'V',
      4: 'IV',
      1: 'I',
    };

    var result = '';
    var remaining = value;

    romanMap.forEach((key, roman) {
      while (remaining >= key) {
        result += roman;
        remaining -= key;
      }
    });

    return result.toLowerCase();
  }

  static int getActiveSessionNumber(ReadingStatus status, int completedReads) {
    if (status == ReadingStatus.read) {
      return completedReads > 0 ? completedReads : 1;
    }
    // For Reading, Paused, Abandoned or WantToRead, we look at the next/ongoing session
    return completedReads + 1;
  }

  static int getTotalReadPages(Book book, List<ReadHistoryData> history) {
    if (book.totalPages == null || book.totalPages == 0) return 0;
    
    final completedReads = history.where((h) => h.finishedAt != null).length;
    final activeSessionNum = getActiveSessionNumber(book.status, completedReads);
    final activeSession = history.firstWhereOrNull((h) => h.readNumber == activeSessionNum);

    if (book.paginationConfig == null || book.paginationConfig!.segments.isEmpty) {
      return (activeSession?.progress ?? 0).clamp(0, book.totalPages!);
    }
    
    int totalRead = 0;
    final Map<int, int> segProgress = activeSession?.segmentProgress ?? {};

    for (int i = 0; i < book.paginationConfig!.segments.length; i++) {
      totalRead += segProgress[i] ?? 0;
    }
    return totalRead.clamp(0, book.totalPages!);
  }

  static int getPhysicalFromVisual(String visual, PaginationConfig config) {
    if (config.segments.isEmpty) {
      return int.tryParse(visual) ?? 1;
    }

    final visualLower = visual.toLowerCase().trim();
    final visualInt = int.tryParse(visualLower);

    for (final s in config.segments) {
      int value;
      if (s.type == PageNumberingType.roman) {
        value = _fromRoman(visualLower);
      } else {
        if (visualInt == null) continue;
        value = visualInt;
      }

      // physical = visual - 1 - offset + start
      final phys = value - s.offset - 1 + s.startPhysical;
      if (phys >= s.startPhysical && phys <= s.endPhysical) {
        return phys;
      }
    }

    // Default to absolute value if not found in segments
    return visualInt ?? 1;
  }

  static int _fromRoman(String roman) {
    final romanMap = {
      'M': 1000,
      'CM': 900,
      'D': 500,
      'CD': 400,
      'C': 100,
      'XC': 90,
      'L': 50,
      'XL': 40,
      'X': 10,
      'IX': 9,
      'V': 5,
      'IV': 4,
      'I': 1,
    };

    var result = 0;
    var input = roman;
    
    for (final entry in romanMap.entries) {
      while (input.startsWith(entry.key)) {
        result += entry.value;
        input = input.substring(entry.key.length);
      }
    }
    return result;
  }
}
