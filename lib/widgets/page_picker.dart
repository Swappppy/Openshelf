import 'package:flutter/material.dart';
import 'wheel_dial_picker.dart';

/// A wheel-based number picker for selecting page numbers.
/// Uses multiple dials (thousands, hundreds, tens, units) for ergonomic high-number input.
class PagePicker extends StatefulWidget {
  final int initialValue;
  final int maxValue;
  final int minValue;
  final ValueChanged<int> onChanged;

  const PagePicker({
    super.key,
    required this.initialValue,
    required this.maxValue,
    required this.onChanged,
    this.minValue = 0,
  });

  @override
  State<PagePicker> createState() => _PagePickerState();
}

class _PagePickerState extends State<PagePicker> {
  late List<int> _digits; // Stores [thousands, hundreds, tens, units]
  late List<FixedExtentScrollController> _controllers;
  late int _columnCount;

  @override
  void initState() {
    super.initState();
    // Decide if we need 3 or 4 columns based on the book's total pages.
    _columnCount = widget.maxValue >= 1000 ? 4 : 3;
    _digits = _toDigits(widget.initialValue);
    _controllers = List.generate(
      _columnCount,
          (i) => FixedExtentScrollController(initialItem: _digits[i]),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// Breaks down an integer into its component digits based on column count.
  List<int> _toDigits(int value) {
    final clamped = value.clamp(widget.minValue, widget.maxValue);
    if (_columnCount == 4) {
      return [
        (clamped ~/ 1000) % 10,
        (clamped ~/ 100) % 10,
        (clamped ~/ 10) % 10,
        clamped % 10,
      ];
    }
    return [
      (clamped ~/ 100) % 10,
      (clamped ~/ 10) % 10,
      clamped % 10,
    ];
  }

  /// Reconstructs the total integer value from the currently selected digits.
  int _toValue() {
    if (_columnCount == 4) {
      return _digits[0] * 1000 +
          _digits[1] * 100 +
          _digits[2] * 10 +
          _digits[3];
    }
    return _digits[0] * 100 + _digits[1] * 10 + _digits[2];
  }

  /// Calculates the maximum allowed digit for the first column to prevent exceeding maxValue.
  /// Calculates the maximum allowed digit for the first column to prevent exceeding maxValue.
  int _maxDigit(int column) {
    if (_columnCount == 4) {
      if (column == 0) return (widget.maxValue ~/ 1000).clamp(0, 9);
    } else {
      if (column == 0) return (widget.maxValue ~/ 100).clamp(0, 9);
    }
    return 9;
  }

  void _onDigitChanged(int column, int value) {
    setState(() => _digits[column] = value);
    final result = _toValue().clamp(widget.minValue, widget.maxValue);
    widget.onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final labels = _columnCount == 4
        ? ['×1000', '×100', '×10', '×1']
        : ['×100', '×10', '×1'];

    return WheelDialPicker(
      columnCount: _columnCount,
      currentDigits: _digits,
      controllers: _controllers,
      columnLabels: labels,
      maxDigitProvider: _maxDigit,
      digitLabelProvider: (col, index, _) => '$index',
      onDigitChanged: _onDigitChanged,
    );
  }
}
