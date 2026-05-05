import 'package:flutter/material.dart';

class PagePicker extends StatefulWidget {
  final int initialValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const PagePicker({
    super.key,
    required this.initialValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  State<PagePicker> createState() => _PagePickerState();
}

class _PagePickerState extends State<PagePicker> {
  late List<int> _digits; // [millares, centenas, decenas, unidades]
  late List<FixedExtentScrollController> _controllers;
  late int _columnCount;

  @override
  void initState() {
    super.initState();
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

  List<int> _toDigits(int value) {
    final clamped = value.clamp(0, widget.maxValue);
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

  int _toValue() {
    if (_columnCount == 4) {
      return _digits[0] * 1000 +
          _digits[1] * 100 +
          _digits[2] * 10 +
          _digits[3];
    }
    return _digits[0] * 100 + _digits[1] * 10 + _digits[2];
  }

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
    final result = _toValue().clamp(0, widget.maxValue);
    widget.onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labels = _columnCount == 4
        ? ['×1000', '×100', '×10', '×1']
        : ['×100', '×10', '×1'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_columnCount, (i) {
            return SizedBox(
              width: 72,
              child: Center(
                child: Text(
                  labels[i],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),

        // Dials
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Líneas de selección
              Positioned(
                top: 68,
                left: 16,
                right: 16,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: colorScheme.primary, width: 1.5),
                      bottom: BorderSide(
                          color: colorScheme.primary, width: 1.5),
                    ),
                  ),
                ),
              ),

              // Columnas
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_columnCount, (col) {
                  return SizedBox(
                    width: 72,
                    child: ListWheelScrollView.useDelegate(
                      controller: _controllers[col],
                      itemExtent: 64,
                      perspective: 0.003,
                      diameterRatio: 1.8,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (val) =>
                          _onDigitChanged(col, val),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _maxDigit(col) + 1,
                        builder: (context, index) {
                          final isSelected = _digits[col] == index;
                          return Center(
                            child: Text(
                              '$index',
                              style: TextStyle(
                                fontSize: isSelected ? 36 : 24,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // Valor actual
        Text(
          '${_toValue()} / ${widget.maxValue} páginas',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.outline,
          ),
        ),
      ],
    );
  }
}