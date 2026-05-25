import 'package:flutter/material.dart';

/// A custom-painted icon representing a bookshelf with books.
/// One of the books dynamically changes color based on the [accentColor].
class BookshelfIcon extends StatelessWidget {
  final double size;
  final Color? accentColor;

  const BookshelfIcon({super.key, this.size = 64, this.accentColor});

  @override
  Widget build(BuildContext context) {
    // If no accentColor is provided, fallback to the theme's primary color.
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;
    
    return CustomPaint(
      size: Size(size, size),
      painter: _BookshelfPainter(
        accentColor: color,
        brightness: theme.brightness,
        themePrimary: theme.colorScheme.primary,
        themeOnSurface: theme.colorScheme.onSurface,
      ),
    );
  }
}

class _BookshelfPainter extends CustomPainter {
  final Color accentColor;
  final Brightness brightness;
  final Color themePrimary;
  final Color themeOnSurface;

  _BookshelfPainter({
    required this.accentColor,
    required this.brightness,
    required this.themePrimary,
    required this.themeOnSurface,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background: Use the actual theme colors to ensure visibility
    final bgPaint = Paint()
      ..color = brightness == Brightness.dark 
          ? const Color(0xFF1A1A2E) // Deep dark blue for dark mode
          : const Color(0xFFEEEEF2); // Light grey for light mode
    
    // Neutral books: Use muted versions of onSurface
    final neutralBookPaint = Paint()
      ..color = themeOnSurface.withValues(alpha: brightness == Brightness.dark ? 0.2 : 0.15);
    
    // Shelf: Use a solid muted tone
    final shelfPaint = Paint()
      ..color = themeOnSurface.withValues(alpha: brightness == Brightness.dark ? 0.3 : 0.4);

    final accentPaint = Paint()..color = accentColor;
    final stripePaint = Paint()..color = Colors.black.withValues(alpha: 0.15); // Darker stripe for texture

    // Rounded background square
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        Radius.circular(w * 0.22),
      ),
      bgPaint,
    );

    // Left book (neutral)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.23, h * 0.34, w * 0.17, h * 0.44),
        const Radius.circular(2),
      ),
      neutralBookPaint,
    );

    // Middle book (Accent color)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.43, h * 0.22, w * 0.20, h * 0.56),
        const Radius.circular(2),
      ),
      accentPaint,
    );
    
    // Decorative stripe on the middle book
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.43, h * 0.32, w * 0.20, h * 0.03),
        const Radius.circular(1),
      ),
      stripePaint,
    );

    // Right book (neutral)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.65, h * 0.40, w * 0.16, h * 0.38),
        const Radius.circular(2),
      ),
      neutralBookPaint,
    );

    // Shelf base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.19, h * 0.78, w * 0.62, h * 0.04),
        const Radius.circular(1),
      ),
      shelfPaint,
    );
  }

  @override
  bool shouldRepaint(_BookshelfPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor || 
           oldDelegate.brightness != brightness;
  }
}
