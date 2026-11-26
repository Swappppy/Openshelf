import 'package:flutter/material.dart';
import '../services/database.dart';
import '../utils/media_progress.dart';
import '../utils/time_map.dart';
import 'segmented_progress_bar.dart';

/// Progress bars of a book with its markers drawn once for all of them.
///
/// A mixed book shows the page bar and, right below, the audio bar, both the
/// same width so their sections line up; a reading book shows only the page
/// bar. Each marker is a numbered badge above the bars with a line down to
/// its page (and on to its translated time in the audio bar). Tapping a
/// badge shows its name; the numbers match the markers list in the sections
/// tile.
class MixedProgressBars extends StatelessWidget {
  final Book book;
  final List<ReadHistoryData> history;
  final MediaProgress? text;
  final MediaProgress? audio;
  final List<(int, int)>? textRuns;
  final List<(int, int)>? audioRuns;
  final String textCaption;
  final VoidCallback onTapText;
  final VoidCallback? onTapAudio;

  /// False for reading-only books: a single page bar, without media icons.
  final bool showAudio;

  /// False for plain audiobooks: a single audio bar with its own sections and
  /// markers ([audioConfig]).
  final bool showText;
  final PaginationConfig? audioConfig;

  static const _iconWidth = 18.0;
  static const _gap = 8.0;
  static const _captionWidth = 104.0;
  static const _rowHeight = 40.0;
  static const _badgeArea = 28.0;
  static const _badgeRadius = 9.0;

  const MixedProgressBars({
    super.key,
    required this.book,
    required this.history,
    required this.text,
    required this.textCaption,
    required this.onTapText,
    this.audio,
    this.textRuns,
    this.audioRuns,
    this.onTapAudio,
    this.showAudio = true,
    this.showText = true,
    this.audioConfig,
  });

  @override
  Widget build(BuildContext context) {
    // Plain audiobooks have their own markers, already in seconds.
    final markers = showText
        ? (book.paginationConfig?.markers ?? const <PaginationMarker>[])
        : audioMarkersFor(book, audio?.total ?? 0, audioConfig: audioConfig);
    final duration = audio?.total ?? 0;
    final textTotal = text?.total ?? 0;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final twoRows = showText && showAudio;
    final iconWidth = twoRows ? _iconWidth + _gap : 0.0;
    final captionStyle = textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
    final percentStyle = textTheme.bodySmall?.copyWith(color: colorScheme.outline);
    // Mixed books reserve the same caption width on both rows so the bars
    // line up; a single bar runs right up to its own caption.
    final audioCaption = audio == null ? '—' : '${formatDuration(audio!.current)} / ${formatDuration(duration)} $durationUnit';
    final captionWidth = twoRows
        ? _captionWidth
        : _textWidth(context, showText ? textCaption : audioCaption, captionStyle)
            .clamp(_textWidth(context, '100%', percentStyle), double.infinity);

    Widget row({
      IconData? icon,
      required Widget bar,
      required String caption,
      required double fraction,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: _rowHeight,
          child: Row(
            children: [
              if (icon != null) ...[
                SizedBox(width: _iconWidth, child: Icon(icon, size: 16, color: colorScheme.outline)),
                const SizedBox(width: _gap),
              ],
              Expanded(child: bar),
              const SizedBox(width: _gap),
              SizedBox(
                width: captionWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(caption, style: captionStyle),
                    ),
                    Text('${(fraction * 100).toStringAsFixed(0)}%', style: percentStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final hasMarkers = markers.isNotEmpty && (showText ? textTotal > 0 : duration > 0);
    final withAudio = showAudio && duration > 0;
    final timeMap = hasMarkers && withAudio && showText
        ? TimeMap(totalPages: textTotal, duration: duration, segments: book.paginationConfig!.segments, markers: markers)
        : null;

    final bars = Column(
      children: [
        if (hasMarkers) const SizedBox(height: _badgeArea),
        if (showText) row(
          icon: twoRows ? Icons.menu_book_outlined : null,
          caption: textCaption,
          fraction: text?.fraction ?? 0,
          onTap: onTapText,
          bar: text == null
              ? const SizedBox.shrink()
              : SegmentedProgressBar(book: book, history: history, runs: textRuns, markers: const []),
        ),
        if (showAudio)
          row(
            icon: twoRows ? Icons.headphones_outlined : null,
            caption: audioCaption,
            fraction: audio?.fraction ?? 0,
            onTap: onTapAudio ?? onTapText,
            bar: audio == null
                ? const SizedBox.shrink()
                : SegmentedProgressBar(
                    book: book,
                    history: history,
                    total: duration,
                    runs: audioRuns ?? [(0, audio!.current)],
                    segments: audioSegmentsFor(book, duration, audioConfig: audioConfig),
                    markers: const [],
                  ),
          ),
      ],
    );
    if (!hasMarkers) return bars;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barLeft = iconWidth;
        final barWidth = constraints.maxWidth - barLeft - _gap - captionWidth;
        final layout = _layoutBadges(
          markers: markers,
          // Fractions on the top bar: pages, or seconds for a plain audiobook.
          textFractions: [
            for (final m in markers) ((m.physicalPage - 1) / (showText ? textTotal : duration)).clamp(0.0, 1.0),
          ],
          audioFractions: timeMap == null
              ? null
              : [for (final m in markers) (timeMap.markerSeconds(m) / duration).clamp(0.0, 1.0)],
          barLeft: barLeft,
          barWidth: barWidth,
        );

        return Stack(
          children: [
            bars,
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _MarkerLinesPainter(
                    layout: layout,
                    colorScheme: colorScheme,
                    badgeBottom: _badgeArea / 2 + _badgeRadius,
                    topBarY: _badgeArea + _rowHeight / 2,
                    bottomBarY: _badgeArea + _rowHeight * 1.5,
                  ),
                ),
              ),
            ),
            for (final b in layout)
              Positioned(
                left: b.badgeX - _badgeRadius,
                top: _badgeArea / 2 - _badgeRadius,
                child: Tooltip(
                  message: b.marker.label,
                  triggerMode: TooltipTriggerMode.tap,
                  preferBelow: false,
                  child: CircleAvatar(
                    radius: _badgeRadius,
                    backgroundColor: b.color(colorScheme),
                    child: Text(
                      '${b.number}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ThemeData.estimateBrightnessForColor(b.color(colorScheme)) == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static double _textWidth(BuildContext context, String text, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return painter.width + 1;
  }

  /// Badge positions in marker order of position, pushed right so they
  /// never overlap; each keeps the exact x of its marker on every bar.
  static List<_Badge> _layoutBadges({
    required List<PaginationMarker> markers,
    required List<double> textFractions,
    required List<double>? audioFractions,
    required double barLeft,
    required double barWidth,
  }) {
    if (barWidth <= 0) return const [];
    final order = List.generate(markers.length, (i) => i)
      ..sort((a, b) => textFractions[a].compareTo(textFractions[b]));
    final result = <_Badge>[];
    var last = double.negativeInfinity;
    for (final i in order) {
      final xTop = barLeft + textFractions[i] * barWidth;
      var x = xTop.clamp(barLeft + _badgeRadius, barLeft + barWidth - _badgeRadius).toDouble();
      if (x < last + _badgeRadius * 2 + 2) x = last + _badgeRadius * 2 + 2;
      last = x;
      result.add(_Badge(
        marker: markers[i],
        number: i + 1,
        badgeX: x,
        xTop: xTop,
        xBottom: audioFractions == null ? null : barLeft + audioFractions[i] * barWidth,
      ));
    }
    return result;
  }
}

class _Badge {
  final PaginationMarker marker;
  final int number;
  final double badgeX;
  final double xTop;
  final double? xBottom;

  const _Badge({required this.marker, required this.number, required this.badgeX, required this.xTop, this.xBottom});

  Color color(ColorScheme scheme) =>
      (marker.color != null && marker.color!.isNotEmpty) ? Color(int.parse('0xFF${marker.color}')) : scheme.secondary;
}

/// Lines from each badge down to its page, and on to its time when the
/// audio bar is shown; dots mark the exact positions on the bars.
class _MarkerLinesPainter extends CustomPainter {
  final List<_Badge> layout;
  final ColorScheme colorScheme;
  final double badgeBottom;
  final double topBarY;
  final double bottomBarY;

  _MarkerLinesPainter({
    required this.layout,
    required this.colorScheme,
    required this.badgeBottom,
    required this.topBarY,
    required this.bottomBarY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in layout) {
      final color = b.color(colorScheme);
      final line = Paint()
        ..color = color.withValues(alpha: 0.55)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(b.badgeX, badgeBottom)
        ..lineTo(b.xTop, topBarY - 6)
        ..lineTo(b.xTop, topBarY + 4);
      final dot = Paint()..color = color;
      canvas.drawCircle(Offset(b.xTop, topBarY), 2.5, dot);
      final xBottom = b.xBottom;
      if (xBottom != null) {
        path.lineTo(xBottom, bottomBarY - 4);
        canvas.drawCircle(Offset(xBottom, bottomBarY), 2.5, dot);
      }
      canvas.drawPath(path, line);
    }
  }

  @override
  bool shouldRepaint(covariant _MarkerLinesPainter old) => true;
}
