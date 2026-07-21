import 'package:flutter/material.dart';
import '../../services/database.dart';
import '../../utils/pagination_helper.dart';
import '../../widgets/app_color_picker.dart';
import '../../l10n/l10n_extension.dart';

class AdvancedPaginationView extends StatefulWidget {
  final PaginationConfig initialConfig;
  final int totalPages;
  final Function(PaginationConfig) onSave;

  const AdvancedPaginationView({
    super.key,
    required this.initialConfig,
    required this.totalPages,
    required this.onSave,
  });

  @override
  State<AdvancedPaginationView> createState() => _AdvancedPaginationViewState();
}

class _AdvancedPaginationViewState extends State<AdvancedPaginationView> {
  late List<PaginationSegment> _segments;
  late List<PaginationMarker> _markers;
  bool _useVisual = false;

  @override
  void initState() {
    super.initState();
    _segments = List.from(widget.initialConfig.segments);
    _markers = List.from(widget.initialConfig.markers);
  }

  void _addSegment() {
    // Find the first physical page not covered by any segment
    int firstAvailable = 1;
    
    // Sort segments by startPhysical to find gaps efficiently
    final sorted = List<PaginationSegment>.from(_segments)
      ..sort((a, b) => a.startPhysical.compareTo(b.startPhysical));
      
    for (final s in sorted) {
      if (firstAvailable >= s.startPhysical && firstAvailable <= s.endPhysical) {
        firstAvailable = s.endPhysical + 1;
      }
    }

    if (firstAvailable > widget.totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.paginationAllPagesAssigned)),
      );
      return;
    }
    
    setState(() {
      _segments.add(PaginationSegment(
        startPhysical: firstAvailable,
        endPhysical: widget.totalPages,
        type: PageNumberingType.arabic,
        color: null,
      ));
      // Trigger cascade starting from the second to last segment
      final triggerIdx = _segments.length - 2 >= 0 ? _segments.length - 2 : 0;
      _updateSegment(triggerIdx, _segments[triggerIdx]);
    });
  }

  void _updateSegment(int index, PaginationSegment newSeg) {
    setState(() {
      // Step 1: Update the targeted segment
      _segments[index] = newSeg;
      
      // Step 2: Cascade updates from index to the end
      for (int i = index; i < _segments.length; i++) {
        PaginationSegment current = _segments[i];
        
        // A) Adjust physical bounds for segments after the changed one
        if (i > index) {
          final prev = _segments[i - 1];
          final newStart = prev.endPhysical + 1;
          int newEnd = current.endPhysical;
          if (newEnd < newStart) newEnd = newStart;
          if (newEnd > widget.totalPages) newEnd = widget.totalPages;
          
          current = current.copyWith(
            startPhysical: newStart,
            endPhysical: newEnd,
          );
        }

        // B) Recalculate offset based on mode
        int newOffset = 0;
        if (_useVisual) {
          // Visual Mode: Partitioned continuity
          // Search backwards for the last segment of the same type
          for (int j = i - 1; j >= 0; j--) {
            if (_segments[j].type == current.type) {
              newOffset = (_segments[j].endPhysical - _segments[j].startPhysical + 1) + _segments[j].offset;
              break;
            }
          }
          // If no previous segment of same type found, newOffset remains 0 (starts at 1)
        } else {
          // Physical Mode: Strict sequential continuity
          if (i > 0) {
            final prev = _segments[i - 1];
            newOffset = (prev.endPhysical - prev.startPhysical + 1) + prev.offset;
          }
        }
        
        _segments[i] = current.copyWith(offset: newOffset);
      }
    });
  }

  // Remove the old _ensureContinuity as it's now integrated and safer
  
  void _showColorPicker(BuildContext context, String? initialColor, Function(String?) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.paginationChooseColor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            AppColorPicker(
              selectedColor: (initialColor != null && initialColor.isNotEmpty) 
                  ? Color(int.parse('0xFF$initialColor')) 
                  : null,
              allowNoColor: true,
              onColorSelected: (color) {
                if (color == null) {
                  onSelected(null);
                } else {
                  final hex = color.toARGB32().toRadixString(16).substring(2).toUpperCase();
                  onSelected(hex);
                }
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _addMarker() {
    setState(() {
      _markers.add(PaginationMarker(
        physicalPage: 1,
        label: '${context.l10n.paginationMarkerDefaultName} ${_markers.length + 1}',
      ));
    });
  }

  List<String> _getValidationErrors() {
    final errors = <String>[];
    
    for (int i = 0; i < _segments.length; i++) {
      final s = _segments[i];
      if (s.startPhysical <= 0 || s.endPhysical <= 0) {
        errors.add(context.l10n.paginationSegmentRequired(i + 1));
        continue;
      }
      if (s.startPhysical > s.endPhysical) {
        errors.add(context.l10n.paginationSegmentStartGreater(i + 1));
      }
      if (s.startPhysical > widget.totalPages || s.endPhysical > widget.totalPages) {
        errors.add(context.l10n.paginationSegmentExceedsTotal(i + 1, widget.totalPages));
      }

      // Check for overlaps with previous segments
      for (int j = 0; j < i; j++) {
        final prev = _segments[j];
        if (s.startPhysical <= prev.endPhysical && s.endPhysical >= prev.startPhysical) {
          errors.add(context.l10n.paginationSegmentOverlap(i + 1, j + 1));
        }
      }
    }

    return errors;
  }

  @override
  Widget build(BuildContext context) {
    final validationErrors = _getValidationErrors();
    
    // Calculate unassigned pages by checking all physical pages covered
    int assignedCount = 0;
    for (final s in _segments) {
      if (s.startPhysical > 0 && s.endPhysical >= s.startPhysical) {
        assignedCount += (s.endPhysical - s.startPhysical + 1);
      }
    }
    final int unassignedCount = widget.totalPages - assignedCount;
    final bool allPagesAssigned = unassignedCount <= 0 && _segments.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.paginationAdvancedConfig),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: validationErrors.isNotEmpty ? null : () {
              widget.onSave(PaginationConfig(segments: _segments, markers: _markers));
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionHeader(context.l10n.paginationBlocksSegments, Icons.view_column_outlined),
              ),
              Text(context.l10n.paginationVisualMode, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: _useVisual,
                  onChanged: (v) {
                    setState(() => _useVisual = v);
                    // Trigger a full update to recalculate offsets for the entire list
                    if (_segments.isNotEmpty) {
                      _updateSegment(0, _segments[0]);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_segments.isEmpty)
             Text(context.l10n.paginationNoSegmentsDefined, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          
          ..._segments.asMap().entries.map((e) => _buildSegmentItem(e.key, e.value)),
          
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _addSegment,
            icon: const Icon(Icons.add),
            label: Text(context.l10n.paginationAddBlock),
          ),
          
          if (allPagesAssigned)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.l10n.paginationAllPagesAssignedNote,
                style: const TextStyle(color: Colors.blue, fontSize: 10),
              ),
            ),

          if (unassignedCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.paginationPagesRemainingWarning(unassignedCount),
                    style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.paginationPhysicalTotalNote,
                    style: const TextStyle(color: Colors.grey, fontSize: 9, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            
          if (validationErrors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.paginationCorrectErrors, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 4),
                    ...validationErrors.map((e) => Text('• $e', style: const TextStyle(color: Colors.red, fontSize: 10))),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 32),
          _buildSectionHeader(context.l10n.paginationMarkersLabels, Icons.label_outline),
          const SizedBox(height: 8),
          ..._markers.asMap().entries.map((e) => _buildMarkerItem(e.key, e.value)),
          
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _addMarker,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text(context.l10n.paginationAddMarker),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
      ],
    );
  }

  Widget _buildSegmentItem(int index, PaginationSegment segment) {
    return Card(
      key: ValueKey('segment_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: context.l10n.paginationLabelOptional, isDense: true),
                    initialValue: segment.label,
                    onChanged: (v) => _segments[index] = segment.copyWith(label: v),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.circle, color: (segment.color != null && segment.color!.isNotEmpty) ? Color(int.parse('0xFF${segment.color}')) : Colors.grey[600]),
                  onPressed: () => _showColorPicker(context, segment.color, (c) => setState(() => _segments[index] = segment.copyWith(color: c))),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _segments.removeAt(index);
                      if (_segments.isNotEmpty && index < _segments.length) {
                        // Trigger cascade starting from the previous segment or the new one at the same index
                        final triggerIdx = index > 0 ? index - 1 : 0;
                        _updateSegment(triggerIdx, _segments[triggerIdx]);
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SegmentRangeInput(
              index: index,
              segment: segment,
              useVisual: _useVisual,
              onChanged: (newSeg) => _updateSegment(index, newSeg),
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
                  onSelected: (v) => _updateSegment(index, segment.copyWith(type: PageNumberingType.arabic)),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(context.l10n.paginationRoman),
                  selected: segment.type == PageNumberingType.roman,
                  onSelected: (v) => _updateSegment(index, segment.copyWith(type: PageNumberingType.roman)),
                ),
                const Spacer(),
                SizedBox(
                  width: 80,
                  child: _OffsetField(
                    value: segment.offset,
                    enabled: index == 0,
                    onChanged: (v) => _updateSegment(index, segment.copyWith(offset: v)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkerItem(int index, PaginationMarker marker) {
    // Only calculate visual page if segments are valid to avoid internal crashes
    String visualPage = '—';
    try {
      if (_segments.isNotEmpty && _segments.any((s) => s.startPhysical <= s.endPhysical)) {
         visualPage = PaginationHelper.getVisualPage(marker.physicalPage, PaginationConfig(segments: _segments));
      } else {
         visualPage = marker.physicalPage.toString();
      }
    } catch (_) {}
    
    return _MarkerItem(
      index: index,
      marker: marker,
      visualPage: visualPage,
      useVisual: _useVisual,
      segments: _segments,
      onColorTap: () => _showColorPicker(context, marker.color, (c) => setState(() => _markers[index] = PaginationMarker(physicalPage: marker.physicalPage, label: marker.label, color: c))),
      onDelete: () => setState(() => _markers.removeAt(index)),
      onLabelChanged: (v) => setState(() => _markers[index] = PaginationMarker(physicalPage: marker.physicalPage, label: v, color: marker.color)),
      onVisualPageChanged: (v) {
        final trimmed = v.trim();
        if (trimmed.isEmpty) return;
        final phys = PaginationHelper.getPhysicalFromVisual(trimmed, PaginationConfig(segments: _segments));
        setState(() => _markers[index] = PaginationMarker(physicalPage: phys, label: _markers[index].label, color: _markers[index].color));
      },
    );
  }
}

class _MarkerItem extends StatefulWidget {
  final int index;
  final PaginationMarker marker;
  final String visualPage;
  final bool useVisual;
  final List<PaginationSegment> segments;
  final VoidCallback onColorTap;
  final VoidCallback onDelete;
  final ValueChanged<String> onLabelChanged;
  final ValueChanged<String> onVisualPageChanged;

  const _MarkerItem({
    required this.index,
    required this.marker,
    required this.visualPage,
    required this.useVisual,
    required this.segments,
    required this.onColorTap,
    required this.onDelete,
    required this.onLabelChanged,
    required this.onVisualPageChanged,
  });

  @override
  State<_MarkerItem> createState() => _MarkerItemState();
}

class _MarkerItemState extends State<_MarkerItem> {
  late TextEditingController _labelCtrl;
  late TextEditingController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.marker.label);
    _pageCtrl = TextEditingController(text: widget.useVisual ? widget.visualPage : widget.marker.physicalPage.toString());
  }

  @override
  void didUpdateWidget(_MarkerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.marker.label != widget.marker.label && _labelCtrl.text != widget.marker.label) {
      _labelCtrl.text = widget.marker.label;
    }
    
    final expectedPageText = widget.useVisual ? widget.visualPage : widget.marker.physicalPage.toString();
    if (_pageCtrl.text.toUpperCase() != expectedPageText.toUpperCase()) {
      _pageCtrl.text = expectedPageText;
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey('marker_${widget.index}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _labelCtrl,
                    decoration: InputDecoration(hintText: context.l10n.paginationMarkerLabel, isDense: true, border: InputBorder.none),
                    onChanged: widget.onLabelChanged,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.circle, color: (widget.marker.color != null && widget.marker.color!.isNotEmpty) ? Color(int.parse('0xFF${widget.marker.color}')) : Colors.grey[600]),
                  onPressed: widget.onColorTap,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pageCtrl,
                    decoration: InputDecoration(
                      labelText: widget.useVisual ? context.l10n.paginationVisualPage : context.l10n.paginationStartPhysical, 
                      isDense: true, 
                      border: const OutlineInputBorder(), 
                      hintText: context.l10n.paginationVisualPageHint
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: widget.onVisualPageChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(context.l10n.paginationPhysicalLabel(widget.marker.physicalPage), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(context.l10n.paginationAdjustsAutomatically, style: const TextStyle(fontSize: 8, color: Colors.grey)),
                  ],
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(_OffsetField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: context.l10n.paginationOffset,
        isDense: true,
        border: const OutlineInputBorder(),
        filled: !widget.enabled,
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) {
        final n = int.tryParse(v.trim());
        if (n != null) widget.onChanged(n);
      },
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

  const _SegmentRangeInput({
    required this.index,
    required this.segment,
    required this.onChanged,
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

  @override
  void initState() {
    super.initState();
    _startCtrl = TextEditingController(text: _getStartText());
    _endCtrl = TextEditingController(text: _getEndText());
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
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_SegmentRangeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final newStart = _getStartText();
    if (_startCtrl.text.toUpperCase() != newStart.toUpperCase()) {
      _startCtrl.text = newStart;
    }
    
    final newEnd = _getEndText();
    if (_endCtrl.text.toUpperCase() != newEnd.toUpperCase()) {
      _endCtrl.text = newEnd;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.segment;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _startCtrl,
                enabled: widget.isFirst,
                decoration: InputDecoration(
                  labelText: widget.useVisual ? context.l10n.paginationStartVisual : context.l10n.paginationStartPhysical,
                  isDense: true,
                  border: const OutlineInputBorder(),
                  filled: !widget.isFirst,
                ),
                keyboardType: widget.useVisual ? TextInputType.text : TextInputType.number,
                onChanged: (v) {
                  final trimmed = v.trim();
                  int phys = 0;
                  if (trimmed.isNotEmpty) {
                    if (widget.useVisual) {
                      phys = PaginationHelper.getPhysicalFromVisualInSegment(trimmed, s);
                    } else {
                      phys = int.tryParse(trimmed) ?? 0;
                    }
                  }
                  if (phys != s.startPhysical) {
                    widget.onChanged(s.copyWith(startPhysical: phys));
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _endCtrl,
                decoration: InputDecoration(
                  labelText: widget.useVisual ? context.l10n.paginationEndVisual : context.l10n.paginationEndPhysical,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: widget.useVisual ? TextInputType.text : TextInputType.number,
                onChanged: (v) {
                  final trimmed = v.trim();
                  int phys = 0;
                  if (trimmed.isNotEmpty) {
                    if (widget.useVisual) {
                      // Important: use current segment to resolve visual page
                      phys = PaginationHelper.getPhysicalFromVisualInSegment(trimmed, s);
                    } else {
                      phys = int.tryParse(trimmed) ?? 0;
                    }
                  }
                  if (phys != s.endPhysical) {
                    widget.onChanged(s.copyWith(endPhysical: phys));
                  }
                },
              ),
            ),
          ],
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
                    context.l10n.paginationEquivalentPhysical(s.endPhysical, s.startPhysical),
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

