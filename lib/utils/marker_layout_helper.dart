import 'package:flutter/material.dart';
import '../services/database.dart';

class MarkerLayout {
  final PaginationMarker marker;
  final double markerX;
  final TextPainter textPainter;
  double labelX;
  int level; // 0 for top, 1 for slightly below

  MarkerLayout({
    required this.marker,
    required this.markerX,
    required this.textPainter,
    required this.labelX,
    this.level = 0,
  });

  double get width => textPainter.width;
  double get centerX => labelX + width / 2;
}

class MarkerLayoutHelper {
  static List<MarkerLayout> calculateLayout({
    required List<PaginationMarker> markers,
    required int totalPages,
    required double totalWidth,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
    double labelSpacing = 4.0,
  }) {
    if (markers.isEmpty) return [];

    final sortedMarkers = List<PaginationMarker>.from(markers)
      ..sort((a, b) => a.physicalPage.compareTo(b.physicalPage));

    // Attempt 1: Single level, Font 9
    List<MarkerLayout> layouts = _attemptLayout(
      markers: sortedMarkers,
      totalPages: totalPages,
      totalWidth: totalWidth,
      textTheme: textTheme,
      colorScheme: colorScheme,
      fontSize: 9.0,
      labelSpacing: labelSpacing,
      useStaggering: false,
    );

    if (!_doesFit(layouts, totalWidth, labelSpacing)) {
       // Attempt 2: Staggered (2 levels), Font 9
       layouts = _attemptLayout(
         markers: sortedMarkers,
         totalPages: totalPages,
         totalWidth: totalWidth,
         textTheme: textTheme,
         colorScheme: colorScheme,
         fontSize: 9.0,
         labelSpacing: labelSpacing,
         useStaggering: true,
       );
    }

    if (_doesFit(layouts, totalWidth, labelSpacing)) return layouts;

    // Attempt 3+: Staggered, decreasing font size
    for (double fs = 8.5; fs >= 7.0; fs -= 0.5) {
      layouts = _attemptLayout(
        markers: sortedMarkers,
        totalPages: totalPages,
        totalWidth: totalWidth,
        textTheme: textTheme,
        colorScheme: colorScheme,
        fontSize: fs,
        labelSpacing: labelSpacing,
        useStaggering: true,
      );
      if (_doesFit(layouts, totalWidth, labelSpacing)) break;
    }

    return layouts;
  }

  static bool _doesFit(List<MarkerLayout> layouts, double totalWidth, double labelSpacing) {
    if (layouts.isEmpty) return true;
    
    // 1. Check screen boundaries
    for (final l in layouts) {
      if (l.labelX + l.width > totalWidth + 0.01) return false;
      if (l.labelX < -0.01) return false;
    }

    // 2. Check internal overlaps within the same level
    final Map<int, List<MarkerLayout>> byLevel = {};
    for (final l in layouts) {
      byLevel.putIfAbsent(l.level, () => []).add(l);
    }

    for (final levelLayouts in byLevel.values) {
      // levelLayouts are already sorted because the source markers were sorted
      for (int i = 0; i < levelLayouts.length - 1; i++) {
        final current = levelLayouts[i];
        final next = levelLayouts[i + 1];
        if (next.labelX < current.labelX + current.width + labelSpacing - 0.01) {
          return false;
        }
      }
    }

    return true;
  }

  static List<MarkerLayout> _attemptLayout({
    required List<PaginationMarker> markers,
    required int totalPages,
    required double totalWidth,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
    required double fontSize,
    required double labelSpacing,
    required bool useStaggering,
  }) {
    if (totalPages <= 0) return [];
    final List<MarkerLayout> layouts = [];

    // First pass: Initial positions and levels
    for (int i = 0; i < markers.length; i++) {
      final marker = markers[i];
      final markerX = (marker.physicalPage - 1) / totalPages * totalWidth;
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: marker.label,
          style: textTheme.labelSmall?.copyWith(
            color: (marker.color != null && marker.color!.isNotEmpty) 
                ? Color(int.parse('0xFF${marker.color}')) 
                : colorScheme.secondary,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      )..layout(maxWidth: 80);

      layouts.add(MarkerLayout(
        marker: marker,
        markerX: markerX,
        textPainter: textPainter,
        labelX: (markerX - (textPainter.width / 2)),
        level: useStaggering ? (i % 2) : 0,
      ));
    }

    // Second pass: Resolve collisions independently per level
    for (int level = 0; level < (useStaggering ? 2 : 1); level++) {
      double minAllowedX = 0;
      for (int i = 0; i < layouts.length; i++) {
        if (layouts[i].level != level) continue;
        
        if (layouts[i].labelX < minAllowedX) {
          layouts[i].labelX = minAllowedX;
        }
        minAllowedX = layouts[i].labelX + layouts[i].width + labelSpacing;
      }
    }

    // Third pass: Boundary check per level (Push left)
    for (int level = 0; level < (useStaggering ? 2 : 1); level++) {
      double maxAllowedRight = totalWidth;
      for (int i = layouts.length - 1; i >= 0; i--) {
        if (layouts[i].level != level) continue;

        if (layouts[i].labelX + layouts[i].width > maxAllowedRight) {
          layouts[i].labelX = maxAllowedRight - layouts[i].width;
        }
        maxAllowedRight = layouts[i].labelX - labelSpacing;
        
        if (layouts[i].labelX < 0) layouts[i].labelX = 0;
      }
    }

    return layouts;
  }
}
