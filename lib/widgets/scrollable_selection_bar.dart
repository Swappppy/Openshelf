import 'package:flutter/material.dart';

/// Model representing an individual selectable item in the bar.
class SelectionItem<T> {
  final T value;
  final String label;
  final Color? color;

  const SelectionItem({
    required this.value,
    required this.label,
    this.color,
  });
}

/// A reusable horizontal selection bar with scrollable chips and an optional sort icon.
/// Designed to provide consistent filtering UI across different screens.
class ScrollableSelectionBar<T> extends StatelessWidget {
  final List<SelectionItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T> onSelected;
  final VoidCallback? onSortTap;

  const ScrollableSelectionBar({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        if (onSortTap != null) ...[
          GestureDetector(
            onTap: onSortTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
              child: Icon(Icons.sort, size: 22, color: colorScheme.outline),
            ),
          ),
        ],
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                left: onSortTap == null ? 16 : 0,
                right: 16,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedValue == item.value;
                final statusColor = item.color ?? colorScheme.outline;

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? statusColor : null,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => onSelected(item.value),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.transparent,
                    selectedColor: statusColor.withValues(alpha: 0.15),
                    side: BorderSide(
                      color: isSelected 
                          ? statusColor.withValues(alpha: 0.4) 
                          : colorScheme.outlineVariant.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
