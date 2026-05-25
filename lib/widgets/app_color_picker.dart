import 'package:flutter/material.dart';

/// A reusable color picker widget with a predefined palette.
/// Used in settings for accent color and in tag/category forms.
class AppColorPicker extends StatelessWidget {
  final Color? selectedColor;
  final ValueChanged<Color?> onColorSelected;
  final double circleSize;
  final double spacing;
  final bool allowNoColor;

  const AppColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.circleSize = 40.0,
    this.spacing = 12.0,
    this.allowNoColor = false,
  });

  /// The standard application color palette.
  static const List<Color> palette = [
    Color(0xFFE53935), // Red
    Color(0xFFD81B60), // Pink
    Color(0xFF8E24AA), // Purple
    Color(0xFF3949AB), // Indigo
    Color(0xFF1E88E5), // Blue
    Color(0xFF00ACC1), // Cyan
    Color(0xFF00897B), // Teal
    Color(0xFF43A047), // Green
    Color(0xFFC0CA33), // Lime
    Color(0xFFFB8C00), // Orange
    Color(0xFF6D4C41), // Brown
    Color(0xFF757575), // Grey
    Color(0xFFF4511E), // Deep Orange
    Color(0xFF5E35B1), // Deep Purple
    Color(0xFF039BE5), // Light Blue
    Color(0xFF7CB342), // Light Green
    Color(0xFFFDD835), // Yellow
    Color(0xFF546E7A), // Blue Grey
    Color(0xFFB71C1C), // Dark Red
    Color(0xFF1B5E20), // Dark Green
    Color(0xFF0D47A1), // Dark Blue
    Color(0xFF4A148C), // Dark Purple
    Color(0xFFE65100), // Dark Orange
    Color(0xFF263238), // Near Black
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        if (allowNoColor)
          _ColorCircle(
            color: null,
            isSelected: selectedColor == null,
            size: circleSize,
            onTap: () => onColorSelected(null),
          ),
        ...palette.map((color) => _ColorCircle(
              color: color,
              isSelected: selectedColor?.toARGB32() == color.toARGB32(),
              size: circleSize,
              onTap: () => onColorSelected(color),
            )),
      ],
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final Color? color;
  final bool isSelected;
  final double size;
  final VoidCallback onTap;

  const _ColorCircle({
    required this.color,
    required this.isSelected,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? Colors.transparent,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : color == null 
                  ? Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1)
                  : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (color ?? Colors.grey).withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: _getContrastColor(color),
                size: size * 0.5,
              )
            : color == null 
                ? Icon(Icons.block, size: size * 0.5, color: Theme.of(context).colorScheme.outline)
                : null,
      ),
    );
  }

  Color _getContrastColor(Color? background) {
    if (background == null) return Colors.grey;
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
