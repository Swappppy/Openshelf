import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n_extension.dart';
import '../models/display_preferences.dart';
import '../controllers/display_preferences_controller.dart';

/// Reusable bottom sheet for managing cascading sorting criteria.
/// Reactive to changes in [displayPreferencesProvider].
class SortBottomSheet extends ConsumerStatefulWidget {
  final String title;
  final List<String> Function(DisplayPreferences) orderSelector;
  final Map<String, bool> Function(DisplayPreferences) directionsSelector;
  final Map<String, String> labels;
  final Function(int, int) onReorder;
  final Function(String) onToggleDirection;
  final bool showEmptyToggle;
  final bool Function(DisplayPreferences)? emptyAtEndSelector;
  final VoidCallback? onToggleEmpty;

  final bool showNumericField;
  final String? numericLabel;
  final int Function(DisplayPreferences)? numericValueSelector;
  final ValueChanged<int>? onNumericChanged;

  const SortBottomSheet({
    super.key,
    required this.title,
    required this.orderSelector,
    required this.directionsSelector,
    required this.labels,
    required this.onReorder,
    required this.onToggleDirection,
    this.showEmptyToggle = false,
    this.emptyAtEndSelector,
    this.onToggleEmpty,
    this.showNumericField = false,
    this.numericLabel,
    this.numericValueSelector,
    this.onNumericChanged,
  });

  static void show(
    BuildContext context, {
    required String title,
    required List<String> Function(DisplayPreferences) orderSelector,
    required Map<String, bool> Function(DisplayPreferences) directionsSelector,
    required Map<String, String> labels,
    required Function(int, int) onReorder,
    required Function(String) onToggleDirection,
    bool showEmptyToggle = false,
    bool Function(DisplayPreferences)? emptyAtEndSelector,
    VoidCallback? onToggleEmpty,
    bool showNumericField = false,
    String? numericLabel,
    int Function(DisplayPreferences)? numericValueSelector,
    ValueChanged<int>? onNumericChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SortBottomSheet(
        title: title,
        orderSelector: orderSelector,
        directionsSelector: directionsSelector,
        labels: labels,
        onReorder: onReorder,
        onToggleDirection: onToggleDirection,
        showEmptyToggle: showEmptyToggle,
        emptyAtEndSelector: emptyAtEndSelector,
        onToggleEmpty: onToggleEmpty,
        showNumericField: showNumericField,
        numericLabel: numericLabel,
        numericValueSelector: numericValueSelector,
        onNumericChanged: onNumericChanged,
      ),
    );
  }

  @override
  ConsumerState<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends ConsumerState<SortBottomSheet> {
  late TextEditingController _numericController;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.numericValueSelector?.call(ref.read(displayPreferencesProvider));
    _numericController = TextEditingController(text: initialValue?.toString() ?? '');
  }

  @override
  void dispose() {
    _numericController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final p = ref.watch(displayPreferencesProvider);
    
    final currentOrder = widget.orderSelector(p);
    final currentDirections = widget.directionsSelector(p);
    final emptyAtEnd = widget.emptyAtEndSelector?.call(p) ?? true;

    // Sync controller if external state changes (and user is not currently editing)
    final externalValue = widget.numericValueSelector?.call(p);
    if (externalValue != null && externalValue.toString() != _numericController.text && !FocusScope.of(context).hasFocus) {
      _numericController.text = externalValue.toString();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16, 16, 16,
        MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.showEmptyToggle && widget.onToggleEmpty != null)
                _SortOptionButton(
                  label: emptyAtEnd ? 'V-↓' : 'V-↑',
                  onPressed: widget.onToggleEmpty!,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.displaySettingsDragHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          ReorderableListView(
            onReorder: widget.onReorder,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: currentOrder.map((criteria) {
              final isAsc = currentDirections[criteria] ?? true;
              final isAlphabetical = ['name', 'title', 'author', 'publisher', 'collection', 'imprint'].contains(criteria);

              return ListTile(
                key: ValueKey(criteria),
                leading: ReorderableDragStartListener(
                  index: currentOrder.indexOf(criteria),
                  child: const Icon(Icons.drag_handle),
                ),
                title: Text(widget.labels[criteria] ?? criteria),
                trailing: TextButton.icon(
                  onPressed: () => widget.onToggleDirection(criteria),
                  label: Text(
                    isAsc
                        ? (isAlphabetical ? 'A-Z' : '0-9')
                        : (isAlphabetical ? 'Z-A' : '9-0'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  icon: Icon(
                    isAsc ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                ),
              );
            }).toList(),
          ),
          if (widget.showNumericField && widget.onNumericChanged != null) ...[
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.numericLabel ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 40,
                  child: TextField(
                    controller: _numericController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '50',
                      isDense: true,
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (val) {
                      final intVal = int.tryParse(val);
                      if (intVal != null && intVal > 0) {
                        widget.onNumericChanged!(intVal);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SortOptionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SortOptionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
