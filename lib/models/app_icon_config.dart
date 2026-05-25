import 'package:flutter/material.dart';
import '../theme/app_palette.dart';

/// Mapping between UI colors and native activity aliases.
class AppIconConfig {
  final String name; 
  final Color color;

  const AppIconConfig({required this.name, required this.color});

  /// Static list derived from the shared AppPalette.
  static List<AppIconConfig> get variants => [
    const AppIconConfig(name: 'default', color: AppPalette.defaultColor),
    ...List.generate(AppPalette.colors.length, (i) => AppIconConfig(
      name: 'color$i', 
      color: AppPalette.colors[i],
    )),
  ];

  static AppIconConfig? getByColor(Color color) {
    final name = AppPalette.getVariantName(color);
    if (name == null) return null;
    return AppIconConfig(name: name, color: color);
  }
}
