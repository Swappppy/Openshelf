import 'package:flutter/material.dart';

/// Defines the available alternate app icons based on the app's full color palette.
class AppIconConfig {
  final String name; // ID for the activity-alias
  final Color color; // Matching palette color

  const AppIconConfig({required this.name, required this.color});

  /// Full mapping of the 24 palette colors to their icon variant names.
  static const List<AppIconConfig> variants = [
    AppIconConfig(name: 'default', color: Color(0xFF6750A4)), // Note: mapped to our main seed if needed
    AppIconConfig(name: 'color0', color: Color(0xFFE53935)),
    AppIconConfig(name: 'color1', color: Color(0xFFD81B60)),
    AppIconConfig(name: 'color2', color: Color(0xFF8E24AA)),
    AppIconConfig(name: 'color3', color: Color(0xFF3949AB)),
    AppIconConfig(name: 'color4', color: Color(0xFF1E88E5)),
    AppIconConfig(name: 'color5', color: Color(0xFF00ACC1)),
    AppIconConfig(name: 'color6', color: Color(0xFF00897B)),
    AppIconConfig(name: 'color7', color: Color(0xFF43A047)),
    AppIconConfig(name: 'color8', color: Color(0xFFC0CA33)),
    AppIconConfig(name: 'color9', color: Color(0xFFFB8C00)),
    AppIconConfig(name: 'color10', color: Color(0xFF6D4C41)),
    AppIconConfig(name: 'color11', color: Color(0xFF757575)),
    AppIconConfig(name: 'color12', color: Color(0xFFF4511E)),
    AppIconConfig(name: 'color13', color: Color(0xFF5E35B1)),
    AppIconConfig(name: 'color14', color: Color(0xFF039BE5)),
    AppIconConfig(name: 'color15', color: Color(0xFF7CB342)),
    AppIconConfig(name: 'color16', color: Color(0xFFFDD835)),
    AppIconConfig(name: 'color17', color: Color(0xFF546E7A)),
    AppIconConfig(name: 'color18', color: Color(0xFFB71C1C)),
    AppIconConfig(name: 'color19', color: Color(0xFF1B5E20)),
    AppIconConfig(name: 'color20', color: Color(0xFF0D47A1)),
    AppIconConfig(name: 'color21', color: Color(0xFF4A148C)),
    AppIconConfig(name: 'color22', color: Color(0xFFE65100)),
    AppIconConfig(name: 'color23', color: Color(0xFF263238)),
  ];

  static AppIconConfig? getByColor(Color color) {
    final target = color.toARGB32();
    for (final v in variants) {
      if (v.color.toARGB32() == target) return v;
    }
    return null;
  }
}
