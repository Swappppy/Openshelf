import 'package:flutter/material.dart';
import 'ocr_models.dart';

class HocrParser {
  /// Parses hOCR string and extracts ISBNs with their bounding boxes.
  static List<DetectedIsbn> parse(String hocr) {
    final List<DetectedIsbn> results = [];
    
    // Tesseract hOCR uses <span class='ocr_line' ... title='bbox x1 y1 x2 y2; ...'>
    // Some versions might use ocrx_word. We'll check both.
    final regExp = RegExp(r"<span[^>]*class='(ocr_line|ocrx_word)'[^>]*title='bbox ([^']+)'>([\s\S]*?)</span>");
    final matches = regExp.allMatches(hocr);
    
    for (final match in matches) {
      final bboxStr = match.group(2)!;
      final rawContent = match.group(3)!;
      
      // Clean HTML tags inside content if any
      final content = rawContent.replaceAll(RegExp(r'<[^>]*>'), '');
      
      final isbn = _extractIsbn(content);
      if (isbn != null) {
        final coords = bboxStr.split(';')[0].split(' ');
        if (coords.length >= 4) {
          final x1 = double.tryParse(coords[0]) ?? 0;
          final y1 = double.tryParse(coords[1]) ?? 0;
          final x2 = double.tryParse(coords[2]) ?? 0;
          final y2 = double.tryParse(coords[3]) ?? 0;
          
          results.add(DetectedIsbn(
            isbn: isbn,
            boundingBox: Rect.fromLTRB(x1, y1, x2, y2),
          ));
        }
      }
    }
    
    // Deduplicate same ISBNs if they appear in multiple words/lines (keep first)
    final Map<String, DetectedIsbn> unique = {};
    for (final item in results) {
      if (!unique.containsKey(item.isbn)) {
        unique[item.isbn] = item;
      }
    }
    
    return unique.values.toList();
  }
  
  static String? _extractIsbn(String text) {
    final clean = text.replaceAll(RegExp(r'[^0123456789X]'), '');
    
    // Validate ISBN-13
    final isbn13Match = RegExp(r'(97[89]\d{10})').firstMatch(clean);
    if (isbn13Match != null) {
      final candidate = isbn13Match.group(1)!;
      if (_validateIsbn13(candidate)) return candidate;
    }
    
    // Validate ISBN-10
    final isbn10Match = RegExp(r'(\d{9}[\dX])').firstMatch(clean);
    if (isbn10Match != null) {
      final candidate = isbn10Match.group(1)!;
      if (_validateIsbn10(candidate)) return candidate;
    }
    
    return null;
  }

  static bool _validateIsbn13(String isbn) {
    if (isbn.length != 13) return false;
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final d = int.tryParse(isbn[i]) ?? -1;
      if (d < 0) return false;
      sum += i.isEven ? d : d * 3;
    }
    final check = (10 - (sum % 10)) % 10;
    return check == int.tryParse(isbn[12]);
  }

  static bool _validateIsbn10(String isbn) {
    if (isbn.length != 10) return false;
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      final d = int.tryParse(isbn[i]) ?? -1;
      if (d < 0) return false;
      sum += d * (10 - i);
    }
    final lastChar = isbn[9].toUpperCase();
    final last = lastChar == 'X' ? 10 : (int.tryParse(lastChar) ?? -1);
    if (last < 0) return false;
    sum += last;
    return sum % 11 == 0;
  }
}
