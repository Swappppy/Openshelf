import 'package:flutter/material.dart';

/// Represents a detected ISBN string and its position in the image.
class DetectedIsbn {
  final String isbn;
  final Rect boundingBox; // Coordinates relative to the CROPPED image

  DetectedIsbn({
    required this.isbn,
    required this.boundingBox,
  });
}

/// Result of the image processing isolate.
class OcrProcessingResult {
  final bool success;
  final int imageWidth;
  final int imageHeight;
  final int cropX;
  final int cropY;

  OcrProcessingResult({
    required this.success,
    this.imageWidth = 0,
    this.imageHeight = 0,
    this.cropX = 0,
    this.cropY = 0,
  });
}
