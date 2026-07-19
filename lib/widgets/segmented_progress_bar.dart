import 'package:flutter/material.dart';
import '../services/database.dart';
import '../utils/marker_layout_helper.dart';

class SegmentedProgressBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int currentReads;
  final PaginationConfig? config;
  final double height;

  const SegmentedProgressBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.currentReads = 0,
    this.config,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + 55, // Increased from 45 to support 2 levels
      width: double.infinity,
      child: CustomPaint(
        painter: _SegmentedProgressPainter(
          currentPage: currentPage,
          totalPages: totalPages,
          currentReads: currentReads,
          config: config,
          colorScheme: Theme.of(context).colorScheme,
          textTheme: Theme.of(context).textTheme,
        ),
      ),
    );
  }
}

class _SegmentedProgressPainter extends CustomPainter {
  final int currentPage;
  final int totalPages;
  final int currentReads;
  final PaginationConfig? config;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  _SegmentedProgressPainter({
    required this.currentPage,
    required this.totalPages,
    required this.currentReads,
    this.config,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barY = size.height - 10; // Bar at the bottom area
    final totalW = size.width;
    
    // 1. Draw Background and segments
    final List<PaginationSegment> segments = (config?.segments.isEmpty ?? true)
        ? [PaginationSegment(startPhysical: 1, endPhysical: totalPages, type: PageNumberingType.arabic)]
        : config!.segments;

    final paintBg = Paint()
      ..color = colorScheme.surfaceContainerHighest
      ..style = PaintingStyle.fill;

    // Draw background first
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, barY - 3, totalW, 6),
        const Radius.circular(3),
      ),
      paintBg,
    );

    // Draw segments one by one
    for (var i = 0; i < segments.length; i++) {
      final s = segments[i];
      final startX = (s.startPhysical - 1) / totalPages * totalW;
      final endX = s.endPhysical / totalPages * totalW;
      final segmentW = (endX - startX).clamp(0.0, totalW);

      final segmentColor = (s.color != null && s.color!.isNotEmpty) 
          ? Color(int.parse('0xFF${s.color}')) 
          : colorScheme.primary;

      // Use a separate paint object for each segment to ensure color is applied
      final segmentPaint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.fill;

      // Calculate progress width within this specific segment
      double progressInSegment = 0;
      final sessionProgress = s.sessions[currentReads + 1] ?? 0;
      final segmentTotal = s.endPhysical - s.startPhysical + 1;

      if (sessionProgress > 0) {
        progressInSegment = (sessionProgress / segmentTotal) * segmentW;
      } else if (currentPage >= s.startPhysical) {
        // Fallback for global progress if session data is missing (legacy/simple)
        if (currentPage >= s.endPhysical) {
          progressInSegment = segmentW;
        } else {
          progressInSegment = ((currentPage - s.startPhysical + 1) / segmentTotal) * segmentW;
        }
      }

      if (progressInSegment > 0) {
        canvas.drawRect(
          Rect.fromLTWH(startX, barY - 3, progressInSegment.clamp(0.0, segmentW), 6),
          segmentPaint,
        );
      }

      // Draw segment divider (gap) if not last and within bounds
      if (i < segments.length - 1 && endX < totalW) {
        canvas.drawRect(
          Rect.fromLTWH(endX - 1, barY - 4, 2, 8),
          Paint()..color = colorScheme.surface,
        );
      }
    }

    // 2. Draw Markers with Anti-Collision and Leader Lines
    final layouts = MarkerLayoutHelper.calculateLayout(
      markers: config?.markers ?? [],
      totalPages: totalPages,
      totalWidth: totalW,
      textTheme: textTheme,
      colorScheme: colorScheme,
    );

    for (final layout in layouts) {
      final markerColor = (layout.marker.color != null && layout.marker.color!.isNotEmpty) 
          ? Color(int.parse('0xFF${layout.marker.color}')) 
          : colorScheme.secondary;

      // 1. Draw small dot on the bar
      canvas.drawCircle(Offset(layout.markerX, barY), 2, Paint()..color = markerColor);

      // Y-coordinates based on level
      final double endY = layout.level == 0 ? 12 : 26;
      final double labelTop = layout.level == 0 ? 2 : 16;
      final double cp1Y = layout.level == 0 ? barY - 15 : barY - 10;
      final double cp2Y = layout.level == 0 ? barY - 12 : barY - 8;

      // 2. Draw Leader Line (Smooth Curve)
      final linePath = Path()
        ..moveTo(layout.markerX, barY - 4)
        ..cubicTo(
          layout.markerX, cp1Y,
          layout.centerX, cp2Y,
          layout.centerX, endY,
        );

      canvas.drawPath(
        linePath,
        Paint()
          ..color = markerColor.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      // 3. Draw label background
      final labelRect = Rect.fromLTWH(
        layout.labelX - 2, 
        labelTop,
        layout.width + 4, 
        12,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
        Paint()..color = colorScheme.surface.withValues(alpha: 0.9),
      );

      // 4. Paint text
      layout.textPainter.paint(canvas, Offset(layout.labelX, labelTop));
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedProgressPainter oldDelegate) {
    // Force repaint to ensure all session changes in segments are caught correctly.
    // Given the low frequency of updates in this view, the performance impact is negligible.
    return true;
  }
}
