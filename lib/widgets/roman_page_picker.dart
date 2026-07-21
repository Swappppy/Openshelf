import 'package:flutter/material.dart';
import '../utils/pagination_helper.dart';
import 'wheel_dial_picker.dart';

class RomanPagePicker extends StatefulWidget {
  final int initialValue;
  final int maxValue;
  final int minValue;
  final ValueChanged<int> onChanged;

  const RomanPagePicker({
    super.key,
    required this.initialValue,
    required this.maxValue,
    required this.onChanged,
    this.minValue = 1,
  });

  @override
  State<RomanPagePicker> createState() => _RomanPagePickerState();
}

class _RomanPagePickerState extends State<RomanPagePicker> {
  late List<int> _digits; // [hundreds, tens, units]
  late List<FixedExtentScrollController> _controllers;
  final int _columnCount = 3;

  @override
  void initState() {
    super.initState();
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

  List<int> _toDigits(int value) {
    final clamped = value.clamp(widget.minValue, widget.maxValue);
    return [
      (clamped ~/ 100) % 10,
      (clamped ~/ 10) % 10,
      clamped % 10,
    ];
  }

  int _toValue() {
    return _digits[0] * 100 + _digits[1] * 10 + _digits[2];
  }

  int _maxDigit(int column) {
    if (column == 0) return (widget.maxValue ~/ 100).clamp(0, 9);
    return 9;
  }

  void _onDigitChanged(int column, int value) {
    setState(() => _digits[column] = value);
    final result = _toValue().clamp(widget.minValue, widget.maxValue);
    widget.onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['C', 'X', 'I']; // Hundreds, Tens, Units

    return WheelDialPicker(
      columnCount: _columnCount,
      currentDigits: _digits,
      controllers: _controllers,
      columnLabels: labels,
      maxDigitProvider: _maxDigit,
      digitLabelProvider: (col, index, isSelected) {
        final multiplier = col == 0 ? 100 : (col == 1 ? 10 : 1);
        final value = index * multiplier;
        if (value == 0) return "—";
        return PaginationHelper.getVisualPage(value, null, forceRoman: true);
      },
      onDigitChanged: _onDigitChanged,
    );
  }
}
