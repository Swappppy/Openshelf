import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/database.dart';
import '../../utils/pagination_helper.dart';
import '../../l10n/l10n_extension.dart';
import 'widgets/marker_item.dart';
import 'widgets/pagination_color_picker.dart';
import 'widgets/segment_item.dart';

class AdvancedPaginationView extends StatefulWidget {
  final PaginationConfig initialConfig;
  final Map<int, int>? initialSegmentProgress;
  final int totalPages;
  final OnSavePaginationConfig onSave;

  const AdvancedPaginationView({
    super.key,
    required this.initialConfig,
    this.initialSegmentProgress,
    required this.totalPages,
    required this.onSave,
  });

  @override
  State<AdvancedPaginationView> createState() => _AdvancedPaginationViewState();
}

class _AdvancedPaginationViewState extends State<AdvancedPaginationView> {
  late List<PaginationSegment> _segments;
  late List<PaginationMarker> _markers;
  late Map<int, int>? _segmentProgress;
  bool _useVisual = false;

  @override
  void initState() {
    super.initState();
    _segments = List.from(widget.initialConfig.segments);
    _markers = List.from(widget.initialConfig.markers);
    _segmentProgress = widget.initialSegmentProgress != null
        ? Map<int, int>.from(widget.initialSegmentProgress!)
        : null;
    _useVisual = widget.initialConfig.useVisualMode;
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
    
    setState(() {
      _segments.add(PaginationSegment(
        startPhysical: firstAvailable,
        endPhysical: firstAvailable + 9, // Default to a 10-page block
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
          final currentLength = current.endPhysical - current.startPhysical;
          final newStart = prev.endPhysical + 1;
          final newEnd = newStart + (currentLength >= 0 ? currentLength : 0);
          
          current = current.copyWith(
            startPhysical: newStart,
            endPhysical: newEnd,
          );
        }

        // B) Recalculate offset based on mode and restartNumbering
        int newOffset = current.offset;
        if (current.restartNumbering) {
          newOffset = 0;
        } else if (i > 0) {
          if (_useVisual) {
            // Visual Mode: Partitioned continuity
            // Search backwards for the last segment of the same type
            newOffset = 0;
            for (int j = i - 1; j >= 0; j--) {
              if (_segments[j].type == current.type) {
                newOffset = (_segments[j].endPhysical - _segments[j].startPhysical + 1) + _segments[j].offset;
                break;
              }
            }
          } else {
            // Physical Mode: Strict sequential continuity
            final prev = _segments[i - 1];
            newOffset = (prev.endPhysical - prev.startPhysical + 1) + prev.offset;
          }
        } else {
          newOffset = 0;
        }
        
        _segments[i] = current.copyWith(offset: newOffset);
      }
    });
  }

  void _handleToggleRestartNumbering(int index) {
    final currentSeg = _segments[index];
    final newRestart = !currentSeg.restartNumbering;

    setState(() {
      if (!_useVisual && newRestart) {
        _useVisual = true;
      }
    });

    _updateSegment(index, currentSeg.copyWith(restartNumbering: newRestart));
  }

  void _onReorderSegments(int oldIndex, int newIndex) {
    setState(() {
      final item = _segments.removeAt(oldIndex);
      _segments.insert(newIndex, item);

      // Reorder segment progress map accordingly
      if (_segmentProgress != null && _segmentProgress!.isNotEmpty) {
        final List<int?> list = List.generate(_segments.length, (i) => _segmentProgress![i]);
        if (oldIndex < list.length) {
          final prog = list.removeAt(oldIndex);
          if (newIndex <= list.length) {
            list.insert(newIndex, prog);
          } else {
            list.add(prog);
          }
        }
        final Map<int, int> newMap = {};
        for (int i = 0; i < list.length; i++) {
          if (list[i] != null) {
            newMap[i] = list[i]!;
          }
        }
        _segmentProgress = newMap;
      }

      // Recalculate physical page bounds starting from index 0
      if (_segments.isNotEmpty) {
        final firstLength = _segments[0].endPhysical - _segments[0].startPhysical;
        _segments[0] = _segments[0].copyWith(
          startPhysical: 1,
          endPhysical: 1 + firstLength,
        );
        _updateSegment(0, _segments[0]);
      }
    });
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

      // Check for overlaps with previous segments
      for (int j = 0; j < i; j++) {
        final prev = _segments[j];
        if (s.startPhysical <= prev.endPhysical && s.endPhysical >= prev.startPhysical) {
          errors.add(context.l10n.paginationSegmentOverlap((i + 1) as String, (j + 1) as String));
        }
      }
    }

    return errors;
  }

  @override
  Widget build(BuildContext context) {
    final validationErrors = _getValidationErrors();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.paginationAdvancedConfig),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: validationErrors.isNotEmpty ? null : () {
              HapticFeedback.selectionClick();
              widget.onSave(
                PaginationConfig(
                  segments: _segments, 
                  markers: _markers,
                  useVisualMode: _useVisual,
                ),
                _segmentProgress,
              );
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
            Text(context.l10n.paginationNoSegmentsDefined, style: const TextStyle(color: Colors.grey, fontSize: 12))
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: _segments.length,
              onReorderItem: _onReorderSegments,
              itemBuilder: (context, index) {
                final segment = _segments[index];
                return SegmentItem(
                  key: ValueKey('segment_${segment.startPhysical}_${segment.endPhysical}_$index'),
                  index: index,
                  segment: segment,
                  totalPages: widget.totalPages,
                  useVisual: _useVisual,
                  onColorTap: (c) => setState(() => _segments[index] = segment.copyWith(color: c, clearColor: c == null)),
                  onDelete: () {
                    setState(() {
                      _segments.removeAt(index);
                      if (_segmentProgress != null) {
                        final List<int?> list = List.generate(_segments.length + 1, (i) => _segmentProgress![i]);
                        if (index < list.length) {
                          list.removeAt(index);
                        }
                        final Map<int, int> newMap = {};
                        for (int i = 0; i < list.length; i++) {
                          if (list[i] != null) {
                            newMap[i] = list[i]!;
                          }
                        }
                        _segmentProgress = newMap;
                      }
                      if (_segments.isNotEmpty && index < _segments.length) {
                        final triggerIdx = index > 0 ? index - 1 : 0;
                        _updateSegment(triggerIdx, _segments[triggerIdx]);
                      }
                    });
                  },
                  onLabelChanged: (v) => setState(() => _segments[index] = segment.copyWith(label: v)),
                  onRangeChanged: (newSeg) => _updateSegment(index, newSeg),
                  onTypeChanged: (type) => _updateSegment(index, segment.copyWith(type: type)),
                  onOffsetChanged: (v) => _updateSegment(index, segment.copyWith(offset: v)),
                  onToggleRestartNumbering: () => _handleToggleRestartNumbering(index),
                );
              },
            ),
          
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _addSegment,
            icon: const Icon(Icons.add),
            label: Text(context.l10n.paginationAddBlock),
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
    
    return MarkerItem(
      index: index,
      marker: marker,
      visualPage: visualPage,
      useVisual: _useVisual,
      segments: _segments,
      onColorTap: () => showPaginationColorPicker(context, marker.color, (c) => setState(() => _markers[index] = marker.copyWith(color: c, clearColor: c == null))),
      onDelete: () => setState(() => _markers.removeAt(index)),
      onLabelChanged: (v) => setState(() => _markers[index] = marker.copyWith(label: v)),
      onVisualPageChanged: (v) {
        final trimmed = v.trim();
        if (trimmed.isEmpty) return;
        final phys = PaginationHelper.getPhysicalFromVisual(trimmed, PaginationConfig(segments: _segments));
        setState(() => _markers[index] = marker.copyWith(physicalPage: phys));
      },
    );
  }
}
