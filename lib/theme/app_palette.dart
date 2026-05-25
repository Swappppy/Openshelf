import 'package:flutter/material.dart';

/// Single source of truth for the application's color palette.
/// This palette is used for the app's seed color, tag/category selection,
/// and dynamic app icon generation.
class AppPalette {
  /// The default primary/seed color of the application.
  static const Color defaultColor = Color(0xFF6750A4);

  /// The 24 standard colors available for selection.
  static const List<Color> colors = [
    Color(0xFFE53935), // color0: Red
    Color(0xFFD81B60), // color1: Pink
    Color(0xFF8E24AA), // color2: Purple
    Color(0xFF3949AB), // color3: Indigo
    Color(0xFF1E88E5), // color4: Blue
    Color(0xFF00ACC1), // color5: Cyan
    Color(0xFF00897B), // color6: Teal
    Color(0xFF43A047), // color7: Green
    Color(0xFFC0CA33), // color8: Lime
    Color(0xFFFB8C00), // color9: Orange
    Color(0xFF6D4C41), // color10: Brown
    Color(0xFF757575), // color11: Grey
    Color(0xFFF4511E), // color12: Deep Orange
    Color(0xFF5E35B1), // color13: Deep Purple
    Color(0xFF039BE5), // color14: Light Blue
    Color(0xFF7CB342), // color15: Light Green
    Color(0xFFFDD835), // color16: Yellow
    Color(0xFF546E7A), // color17: Blue Grey
    Color(0xFFB71C1C), // color18: Dark Red
    Color(0xFF1B5E20), // color19: Dark Green
    Color(0xFF0D47A1), // color20: Dark Blue
    Color(0xFF4A148C), // color21: Dark Purple
    Color(0xFFE65100), // color22: Dark Orange
    Color(0xFF263238), // color23: Near Black
  ];

  /// Returns the internal variant name for a given color.
  /// Matches the 'colorX' scheme used in AndroidManifest aliases.
  static String? getVariantName(Color color) {
    if (color.toARGB32() == defaultColor.toARGB32()) return 'default';
    
    for (int i = 0; i < colors.length; i++) {
      if (colors[i].toARGB32() == color.toARGB32()) {
        return 'color$i';
      }
    }
    return null;
  }
}
