import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_palette.dart';

/// A reusable color picker widget with a predefined palette.
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
            onTap: () {
              HapticFeedback.selectionClick();
              onColorSelected(null);
            },
          ),
        ...AppPalette.colors.map((color) => _ColorCircle(
              color: color,
              isSelected: selectedColor?.toARGB32() == color.toARGB32(),
              size: circleSize,
              onTap: () {
                HapticFeedback.selectionClick();
                onColorSelected(color);
              },
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
