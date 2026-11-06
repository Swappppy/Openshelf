import 'package:flutter/material.dart';
import '../../../services/database.dart';
import '../../../utils/pagination_helper.dart';
import '../../../l10n/l10n_extension.dart';
import 'pagination_color_picker.dart';

class SegmentItem extends StatefulWidget {
  final int index;
  final PaginationSegment segment;
  final int totalPages;
  final bool useVisual;
  final Function(String?) onColorTap;
  final VoidCallback onDelete;
  final ValueChanged<String> onLabelChanged;
  final ValueChanged<PaginationSegment> onRangeChanged;
  final ValueChanged<PageNumberingType> onTypeChanged;
  final ValueChanged<int> onOffsetChanged;
  final VoidCallback onToggleRestartNumbering;

  const SegmentItem({
    super.key,
    required this.index,
    required this.segment,
    required this.totalPages,
    required this.useVisual,
    required this.onColorTap,
    required this.onDelete,
    required this.onLabelChanged,
    required this.onRangeChanged,
    required this.onTypeChanged,
    required this.onOffsetChanged,
    required this.onToggleRestartNumbering,
  });

  @override
  State<SegmentItem> createState() => _SegmentItemState();
}

class _SegmentItemState extends State<SegmentItem> {
  late TextEditingController _labelCtrl;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.segment.label);
  }

  @override
  void didUpdateWidget(SegmentItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segment.label != widget.segment.label && _labelCtrl.text != widget.segment.label) {
      _labelCtrl.text = widget.segment.label ?? '';
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final segment = widget.segment;
    final index = widget.index;

    return Card(
      key: ValueKey('segment_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.drag_handle,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _labelCtrl,
                    decoration: InputDecoration(labelText: context.l10n.paginationLabelOptional, isDense: true),
                    onChanged: widget.onLabelChanged,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.circle, color: (segment.color != null && segment.color!.isNotEmpty) ? Color(int.parse('0xFF${segment.color}')) : Colors.grey[600]),
                  onPressed: () => showPaginationColorPicker(context, segment.color, widget.onColorTap),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SegmentRangeInput(
              index: index,
              segment: segment,
              useVisual: widget.useVisual,
              onChanged: widget.onRangeChanged,
              onToggleRestartNumbering: widget.onToggleRestartNumbering,
              totalPages: widget.totalPages,
              isFirst: index == 0,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(context.l10n.paginationType),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: Text(context.l10n.paginationArabic),
                  selected: segment.type == PageNumberingType.arabic,
                  onSelected: (v) => widget.onTypeChanged(PageNumberingType.arabic),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(context.l10n.paginationRoman),
                  selected: segment.type == PageNumberingType.roman,
                  onSelected: (v) => widget.onTypeChanged(PageNumberingType.roman),
                ),
                const Spacer(),
                SizedBox(
                  width: 80,
                  child: _OffsetField(
                    value: segment.offset,
                    enabled: index == 0,
                    onChanged: widget.onOffsetChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OffsetField extends StatefulWidget {
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _OffsetField({required this.value, required this.onChanged, this.enabled = true});

  @override
  State<_OffsetField> createState() => _OffsetFieldState();
}

class _OffsetFieldState extends State<_OffsetField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _commit();
    }
  }

  void _commit() {
    final n = int.tryParse(_controller.text.trim());
    if (n != null && n != widget.value) {
      widget.onChanged(n);
    } else {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void didUpdateWidget(_OffsetField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: context.l10n.paginationOffset,
        isDense: true,
        border: const OutlineInputBorder(),
        filled: !widget.enabled,
      ),
      keyboardType: TextInputType.number,
      onFieldSubmitted: (_) => _commit(),
    );
  }
}

class _SegmentRangeInput extends StatefulWidget {
  final int index;
  final PaginationSegment segment;
  final int totalPages;
  final bool isFirst;
  final bool useVisual;
  final ValueChanged<PaginationSegment> onChanged;
  final VoidCallback onToggleRestartNumbering;

  const _SegmentRangeInput({
    required this.index,
    required this.segment,
    required this.onChanged,
    required this.onToggleRestartNumbering,
    required this.totalPages,
    required this.isFirst,
    required this.useVisual,
  });

  @override
  State<_SegmentRangeInput> createState() => _SegmentRangeInputState();
}

class _SegmentRangeInputState extends State<_SegmentRangeInput> {
  late TextEditingController _startCtrl;
  late TextEditingController _endCtrl;
  late FocusNode _startFocusNode;
  late FocusNode _endFocusNode;

  @override
  void initState() {
    super.initState();
    _startCtrl = TextEditingController(text: _getStartText());
    _endCtrl = TextEditingController(text: _getEndText());
    _startFocusNode = FocusNode();
    _endFocusNode = FocusNode();
    _startFocusNode.addListener(_onStartFocusChange);
    _endFocusNode.addListener(_onEndFocusChange);
  }

  void _onStartFocusChange() {
    if (!_startFocusNode.hasFocus) {
      _commitStart();
    }
  }

  void _onEndFocusChange() {
    if (!_endFocusNode.hasFocus) {
      _commitEnd();
    }
  }

  void _commitStart() {
    final s = widget.segment;
    final trimmed = _startCtrl.text.trim();
    int phys = 0;
    if (trimmed.isNotEmpty) {
      if (widget.useVisual) {
        phys = PaginationHelper.getPhysicalFromVisualInSegment(trimmed, s);
      } else {
        phys = int.tryParse(trimmed) ?? 0;
      }
    }

    if (phys > 0 && phys != s.startPhysical) {
      final currentLength = s.endPhysical - s.startPhysical;
      final newEnd = phys + (currentLength >= 0 ? currentLength : 0);
      widget.onChanged(s.copyWith(startPhysical: phys, endPhysical: newEnd));
    } else {
      _startCtrl.text = _getStartText();
    }
  }

  void _commitEnd() {
    final s = widget.segment;
    final trimmed = _endCtrl.text.trim();
    int phys = 0;
    if (trimmed.isNotEmpty) {
      if (widget.useVisual) {
        phys = PaginationHelper.getPhysicalFromVisualInSegment(trimmed, s);
      } else {
        phys = int.tryParse(trimmed) ?? 0;
      }
    }

    if (phys >= s.startPhysical && phys != s.endPhysical) {
      widget.onChanged(s.copyWith(endPhysical: phys));
    } else {
      _endCtrl.text = _getEndText();
    }
  }

  String _getStartText() {
    if (widget.useVisual) {
      return PaginationHelper.getVisualPageInSegment(widget.segment.startPhysical, widget.segment);
    }
    return widget.segment.startPhysical.toString();
  }

  String _getEndText() {
    if (widget.useVisual) {
      return PaginationHelper.getVisualPageInSegment(widget.segment.endPhysical, widget.segment);
    }
    return widget.segment.endPhysical.toString();
  }

  @override
  void dispose() {
    _startFocusNode.removeListener(_onStartFocusChange);
    _endFocusNode.removeListener(_onEndFocusChange);
    _startFocusNode.dispose();
    _endFocusNode.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_SegmentRangeInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_startFocusNode.hasFocus) {
      final newStart = _getStartText();
      if (_startCtrl.text.toUpperCase() != newStart.toUpperCase()) {
        _startCtrl.text = newStart;
      }
    }

    if (!_endFocusNode.hasFocus) {
      final newEnd = _getEndText();
      if (_endCtrl.text.toUpperCase() != newEnd.toUpperCase()) {
        _endCtrl.text = newEnd;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.segment;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _startCtrl,
                  focusNode: _startFocusNode,
                  enabled: widget.isFirst,
                  decoration: InputDecoration(
                    labelText: widget.useVisual ? context.l10n.paginationStartVisual : context.l10n.paginationStartPhysical,
                    isDense: true,
                    border: const OutlineInputBorder(),
                    filled: !widget.isFirst,
                  ),
                  keyboardType: widget.useVisual ? TextInputType.text : TextInputType.number,
                  onFieldSubmitted: (_) => _commitStart(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _endCtrl,
                  focusNode: _endFocusNode,
                  decoration: InputDecoration(
                    labelText: widget.useVisual ? context.l10n.paginationEndVisual : context.l10n.paginationEndPhysical,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: widget.useVisual ? TextInputType.text : TextInputType.number,
                  onFieldSubmitted: (_) => _commitEnd(),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: context.l10n.paginationRestartFromZero,
                child: InkWell(
                  onTap: widget.onToggleRestartNumbering,
                  borderRadius: BorderRadius.circular(4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    decoration: BoxDecoration(
                      color: s.restartNumbering
                          ? colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: s.restartNumbering
                            ? colorScheme.primary
                            : colorScheme.outline,
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.restart_alt,
                        size: 24,
                        color: s.restartNumbering
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.useVisual || !widget.isFirst)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!widget.isFirst)
                  Text(context.l10n.paginationAdjustsAutomatically, style: const TextStyle(fontSize: 8, color: Colors.grey)),
                if (widget.useVisual)
                  Text(
                    context.l10n.paginationEquivalentPhysical(s.startPhysical, s.endPhysical),
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
