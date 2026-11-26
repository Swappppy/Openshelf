import 'package:flutter/material.dart';
import 'wheel_dial_picker.dart';

/// Wheel picker for a listening position, the time counterpart of
/// [PagePicker]: hour dials plus tens/units of minutes. Values are seconds
/// with minute precision, clamped to [minValue]..[maxValue].
class TimePickerWheel extends StatefulWidget {
  final int initialValue;
  final int maxValue;
  final int minValue;
  final ValueChanged<int> onChanged;

  const TimePickerWheel({
    super.key,
    required this.initialValue,
    required this.maxValue,
    required this.onChanged,
    this.minValue = 0,
  });

  @override
  State<TimePickerWheel> createState() => _TimePickerWheelState();
}

class _TimePickerWheelState extends State<TimePickerWheel> {
  late final int _hourColumns;
  late List<int> _digits; // hour digits..., minute tens, minute units
  late List<FixedExtentScrollController> _controllers;

  int get _columnCount => _hourColumns + 2;

  @override
  void initState() {
    super.initState();
    final maxHours = widget.maxValue ~/ 3600;
    _hourColumns = maxHours >= 100 ? 3 : 2;
    _digits = _toDigits(widget.initialValue);
    _controllers = List.generate(_columnCount, (i) => FixedExtentScrollController(initialItem: _digits[i]));
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<int> _toDigits(int seconds) {
    final clamped = seconds.clamp(widget.minValue, widget.maxValue);
    final hours = clamped ~/ 3600;
    final minutes = (clamped % 3600) ~/ 60;
    final hourDigits = [
      for (var i = _hourColumns - 1; i >= 0; i--) (hours ~/ _pow10(i)) % 10,
    ];
    return [...hourDigits, minutes ~/ 10, minutes % 10];
  }

  int _toSeconds() {
    var hours = 0;
    for (var i = 0; i < _hourColumns; i++) {
      hours = hours * 10 + _digits[i];
    }
    final minutes = _digits[_hourColumns] * 10 + _digits[_hourColumns + 1];
    return hours * 3600 + minutes * 60;
  }

  static int _pow10(int e) => e == 0 ? 1 : 10 * _pow10(e - 1);

  int _maxDigit(int column) {
    if (column == 0) return ((widget.maxValue ~/ 3600) ~/ _pow10(_hourColumns - 1)).clamp(0, 9);
    if (column == _hourColumns) return 5; // tens of minutes
    return 9;
  }

  void _onDigitChanged(int column, int value) {
    setState(() => _digits[column] = value);
    widget.onChanged(_toSeconds().clamp(widget.minValue, widget.maxValue));
  }

  @override
  Widget build(BuildContext context) {
    final hourLabels = [for (var i = _hourColumns - 1; i >= 0; i--) '×${_pow10(i)} h'];
    return WheelDialPicker(
      columnCount: _columnCount,
      currentDigits: _digits,
      controllers: _controllers,
      columnLabels: [...hourLabels, '×10 min', '×1 min'],
      maxDigitProvider: _maxDigit,
      digitLabelProvider: (col, index, _) => '$index',
      onDigitChanged: _onDigitChanged,
    );
  }
}
