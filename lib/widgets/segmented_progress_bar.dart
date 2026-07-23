import 'package:flutter/material.dart';
import '../services/database.dart';
import '../utils/marker_layout_helper.dart';

import '../utils/pagination_helper.dart';

class SegmentedProgressBar extends StatelessWidget {
  final Book book;
  final List<ReadHistoryData> history;
  final double height;

  const SegmentedProgressBar({
    super.key,
    required this.book,
    required this.history,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final hasMarkers = book.paginationConfig?.markers.isNotEmpty ?? false;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SegmentedProgressPainter(
          book: book,
          history: history,
          colorScheme: Theme.of(context).colorScheme,
          textTheme: Theme.of(context).textTheme,
          hasMarkers: hasMarkers,
        ),
      ),
    );
  }
}

class _SegmentedProgressPainter extends CustomPainter {
  final Book book;
  final List<ReadHistoryData> history;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool hasMarkers;

  _SegmentedProgressPainter({
    required this.book,
    required this.history,
    required this.colorScheme,
    required this.textTheme,
    required this.hasMarkers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barY = size.height / 2; // Bar centered
    final totalW = size.width;
    final totalPages = book.totalPages ?? 0;
    if (totalPages == 0) return;
    
    // 1. Draw Background and segments
    final List<PaginationSegment> segments = (book.paginationConfig?.segments.isEmpty ?? true)
        ? [PaginationSegment(startPhysical: 1, endPhysical: totalPages, type: PageNumberingType.arabic)]
        : book.paginationConfig!.segments;

    final paintBg = Paint()
      ..color = colorScheme.surfaceContainerHighest
      ..style = PaintingStyle.fill;

    // Draw background first with rounded corners
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, barY - 3, totalW, 6),
        const Radius.circular(3),
      ),
      paintBg,
    );

    // Get active session data
    final completedReads = history.where((h) => h.finishedAt != null).length;
    final activeSessionNum = PaginationHelper.getActiveSessionNumber(book.status, completedReads);
    final activeSession = history.where((h) => h.readNumber == activeSessionNum).firstOrNull;
    
    final Map<int, int> segProgress = activeSession?.segmentProgress ?? {};

    // 2. Draw Progress Segments
    // We'll use a ClipRRect or manual clipping to ensure the overall progress also has rounded ends
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, barY - 3, totalW, 6),
        const Radius.circular(3),
      ),
    );

    for (var i = 0; i < segments.length; i++) {
      final s = segments[i];
      final startX = (s.startPhysical - 1) / totalPages * totalW;
      final endX = s.endPhysical / totalPages * totalW;
      final segmentW = (endX - startX).clamp(0.0, totalW);

      final segmentColor = (s.color != null && s.color!.isNotEmpty) 
          ? Color(int.parse('0xFF${s.color}')) 
          : colorScheme.primary;

      final segmentPaint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.fill;

      double progressInSegment = 0;
      final sessionProgress = segProgress[i] ?? 0;
      final segmentTotal = s.endPhysical - s.startPhysical + 1;

      if (sessionProgress > 0) {
        progressInSegment = (sessionProgress / segmentTotal) * segmentW;
      }

      if (progressInSegment > 0) {
        canvas.drawRect(
          Rect.fromLTWH(startX, barY - 3, progressInSegment.clamp(0.0, segmentW), 6),
          segmentPaint,
        );
      }

      // Draw segment divider (gap)
      if (i < segments.length - 1 && endX < totalW) {
        canvas.drawRect(
          Rect.fromLTWH(endX - 0.5, barY - 4, 1, 8), // Thinner gap
          Paint()..color = colorScheme.surface,
        );
      }
    }
    canvas.restore();

    // 3. Draw Markers with Anti-Collision and Leader Lines
    final layouts = MarkerLayoutHelper.calculateLayout(
      markers: book.paginationConfig?.markers ?? [],
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

      // Y-coordinates relative to barY
      final double endY = layout.level == 0 ? barY - 41 : barY - 27;
      final double labelTop = layout.level == 0 ? barY - 51 : barY - 37;
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
