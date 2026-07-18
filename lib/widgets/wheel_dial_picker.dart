import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WheelDialPicker extends StatelessWidget {
  final int columnCount;
  final List<int> currentDigits;
  final List<FixedExtentScrollController> controllers;
  final List<String> columnLabels;
  final int Function(int column) maxDigitProvider;
  final String Function(int column, int index, bool isSelected) digitLabelProvider;
  final void Function(int column, int value) onDigitChanged;

  const WheelDialPicker({
    super.key,
    required this.columnCount,
    required this.currentDigits,
    required this.controllers,
    required this.columnLabels,
    required this.maxDigitProvider,
    required this.digitLabelProvider,
    required this.onDigitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Magnitude Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(columnCount, (i) {
            return SizedBox(
              width: 72,
              child: Center(
                child: Text(
                  columnLabels[i],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),

        // Picker Dials
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Visual selection highlight lines
              Positioned(
                top: 58,
                left: 16,
                right: 16,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: colorScheme.primary, width: 1.5),
                      bottom: BorderSide(color: colorScheme.primary, width: 1.5),
                    ),
                  ),
                ),
              ),

              // Columns for each digit
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(columnCount, (col) {
                  return SizedBox(
                    width: 72,
                    child: ListWheelScrollView.useDelegate(
                      controller: controllers[col],
                      itemExtent: 64,
                      perspective: 0.003,
                      diameterRatio: 1.8,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (val) {
                        HapticFeedback.selectionClick();
                        onDigitChanged(col, val);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: maxDigitProvider(col) + 1,
                        builder: (context, index) {
                          final isSelected = currentDigits[col] == index;
                          return Center(
                            child: Text(
                              digitLabelProvider(col, index, isSelected),
                              style: TextStyle(
                                fontSize: isSelected ? 36 : 24,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withValues(alpha: 0.4),
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
      ],
    );
  }
}
