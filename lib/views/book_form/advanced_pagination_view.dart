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

  @override
  void initState() {
    super.initState();
    _segments = List.from(widget.initialConfig.segments);
    _markers = List.from(widget.initialConfig.markers);
  }

  void _addSegment() {
    final start = _segments.isEmpty ? 1 : _segments.last.endPhysical + 1;
    if (start > widget.totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.paginationAllPagesAssigned)),
      );
      return;
    }
    
    setState(() {
      _segments.add(PaginationSegment(
        startPhysical: start,
        endPhysical: widget.totalPages,
        type: PageNumberingType.arabic,
        color: null,
      ));
    });
  }

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
    }

    return errors;
  }

  @override
  Widget build(BuildContext context) {
    final validationErrors = _getValidationErrors();
    final bool allPagesAssigned = _segments.isNotEmpty && _segments.last.endPhysical >= widget.totalPages;

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
          _buildSectionHeader(context.l10n.paginationBlocksSegments, Icons.view_column_outlined),
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

          if (_segments.isNotEmpty && _segments.last.endPhysical < widget.totalPages)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.l10n.paginationPagesRemainingWarning(widget.totalPages - _segments.last.endPhysical),
                style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
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
                  onPressed: () => setState(() => _segments.removeAt(index)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SegmentRangeInput(
              segment: segment,
              onChanged: (newSeg) => setState(() => _segments[index] = newSeg),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(context.l10n.paginationType),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: Text(context.l10n.paginationArabic),
                  selected: segment.type == PageNumberingType.arabic,
                  onSelected: (v) => setState(() => _segments[index] = segment.copyWith(type: PageNumberingType.arabic)),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(context.l10n.paginationRoman),
                  selected: segment.type == PageNumberingType.roman,
                  onSelected: (v) => setState(() => _segments[index] = segment.copyWith(type: PageNumberingType.roman)),
                ),
                const Spacer(),
                SizedBox(
                  width: 80,
                  child: _NumberField(
                    label: context.l10n.paginationOffset,
                    value: segment.offset,
                    onChanged: (v) => setState(() => _segments[index] = segment.copyWith(offset: v)),
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
    
    return Card(
      key: ValueKey('marker_$index'),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(hintText: context.l10n.paginationMarkerLabel, isDense: true, border: InputBorder.none),
                    initialValue: marker.label,
                    onChanged: (v) => _markers[index] = PaginationMarker(physicalPage: marker.physicalPage, label: v, color: marker.color),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.circle, color: (marker.color != null && marker.color!.isNotEmpty) ? Color(int.parse('0xFF${marker.color}')) : Colors.grey[600]),
                  onPressed: () => _showColorPicker(context, marker.color, (c) => setState(() => _markers[index] = PaginationMarker(physicalPage: marker.physicalPage, label: marker.label, color: c))),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => setState(() => _markers.removeAt(index)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: context.l10n.paginationVisualPage, isDense: true, border: const OutlineInputBorder(), hintText: context.l10n.paginationVisualPageHint),
                    initialValue: visualPage,
                    keyboardType: TextInputType.text,
                    onChanged: (v) {
                      final phys = PaginationHelper.getPhysicalFromVisual(v, PaginationConfig(segments: _segments));
                      _markers[index] = PaginationMarker(physicalPage: phys, label: _markers[index].label, color: _markers[index].color);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(context.l10n.paginationPhysicalLabel(marker.physicalPage), style: const TextStyle(fontSize: 10, color: Colors.grey)),
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

class _NumberField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _NumberField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder()),
      keyboardType: TextInputType.number,
      initialValue: value.toString(),
      onChanged: (v) {
        final n = int.tryParse(v);
        if (n != null) onChanged(n);
      },
    );
  }
}

class _SegmentRangeInput extends StatefulWidget {
  final PaginationSegment segment;
  final ValueChanged<PaginationSegment> onChanged;

  const _SegmentRangeInput({required this.segment, required this.onChanged});

  @override
  State<_SegmentRangeInput> createState() => _SegmentRangeInputState();
}

class _SegmentRangeInputState extends State<_SegmentRangeInput> {
  bool _useVisual = false;
  late TextEditingController _startCtrl;
  late TextEditingController _endCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.segment;
    _startCtrl = TextEditingController(text: s.startPhysical.toString());
    _endCtrl = TextEditingController(text: s.endPhysical.toString());
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
    if (!_useVisual && oldWidget.segment.startPhysical != widget.segment.startPhysical) {
      _startCtrl.text = widget.segment.startPhysical.toString();
    }
    if (!_useVisual && oldWidget.segment.endPhysical != widget.segment.endPhysical) {
      _endCtrl.text = widget.segment.endPhysical.toString();
    }
  }

  void _onToggleMode(bool visual) {
    setState(() {
      _useVisual = visual;
      final s = widget.segment;
      if (visual) {
        _startCtrl.text = PaginationHelper.getVisualPageInSegment(s.startPhysical, s);
        _endCtrl.text = PaginationHelper.getVisualPageInSegment(s.endPhysical, s);
      } else {
        _startCtrl.text = s.startPhysical.toString();
        _endCtrl.text = s.endPhysical.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.segment;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(context.l10n.paginationVisualMode, style: const TextStyle(fontSize: 10)),
            Switch(
              value: _useVisual,
              onChanged: _onToggleMode,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _startCtrl,
                decoration: InputDecoration(
                  labelText: _useVisual ? context.l10n.paginationStartVisual : context.l10n.paginationStartPhysical,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: _useVisual ? TextInputType.text : TextInputType.number,
                onChanged: (v) {
                  int phys;
                  if (_useVisual) {
                    phys = PaginationHelper.getPhysicalFromVisual(v, PaginationConfig(segments: [s]));
                  } else {
                    phys = int.tryParse(v) ?? 0;
                  }
                  widget.onChanged(s.copyWith(startPhysical: phys));
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _endCtrl,
                decoration: InputDecoration(
                  labelText: _useVisual ? context.l10n.paginationEndVisual : context.l10n.paginationEndPhysical,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: _useVisual ? TextInputType.text : TextInputType.number,
                onChanged: (v) {
                  int phys;
                  if (_useVisual) {
                    phys = PaginationHelper.getPhysicalFromVisual(v, PaginationConfig(segments: [s]));
                  } else {
                    phys = int.tryParse(v) ?? 0;
                  }
                  widget.onChanged(s.copyWith(endPhysical: phys));
                },
              ),
            ),
          ],
        ),
        if (_useVisual)
           Padding(
             padding: const EdgeInsets.only(top: 4),
             child: Text(context.l10n.paginationEquivalentPhysical(s.startPhysical, s.endPhysical), style: const TextStyle(fontSize: 9, color: Colors.grey)),
           ),
      ],
    );
  }
}

