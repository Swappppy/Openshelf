import 'package:flutter/material.dart';

class StatsScaleHelper {
  /// Reference width of a standard 1x1 tile on a typical phone screen.
  static const double referenceWidth = 158.0;

  /// Calculates a scale factor based on the current widget width.
  static double getScale(BoxConstraints constraints) {
    return (constraints.maxWidth / referenceWidth).clamp(1.0, 2.5);
  }

  /// Returns a proportionally scaled font size.
  static double scaledFontSize(double baseSize, BoxConstraints constraints) {
    return baseSize * getScale(constraints);
  }

  /// Scales a standard header icon size.
  static double scaledIconSize(double baseSize, BoxConstraints constraints) {
    return baseSize * (getScale(constraints) * 0.8).clamp(1.0, 2.0);
  }
}
