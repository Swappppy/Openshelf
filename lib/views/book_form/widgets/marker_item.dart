import 'package:flutter/material.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../utils/media_progress.dart';

class MarkerItem extends StatefulWidget {
  final int index;
  final PaginationMarker marker;
  final String visualPage;
  final bool useVisual;
  final List<PaginationSegment> segments;
  final VoidCallback onColorTap;
  final VoidCallback onDelete;
  final ValueChanged<String> onLabelChanged;
  final ValueChanged<String> onVisualPageChanged;

  /// Audiobook markers: the position is a time (`hh:mm`).
  final bool timeMode;

  const MarkerItem({
    super.key,
    required this.index,
    required this.marker,
    required this.visualPage,
    required this.useVisual,
    required this.segments,
    required this.onColorTap,
    required this.onDelete,
    required this.onLabelChanged,
    required this.onVisualPageChanged,
    this.timeMode = false,
  });

  @override
  State<MarkerItem> createState() => _MarkerItemState();
}

class _MarkerItemState extends State<MarkerItem> {
  late TextEditingController _labelCtrl;
  late TextEditingController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.marker.label);
    _pageCtrl = TextEditingController(text: _positionText());
  }

  @override
  void didUpdateWidget(MarkerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.marker.label != widget.marker.label && _labelCtrl.text != widget.marker.label) {
      _labelCtrl.text = widget.marker.label;
    }
    
    final expectedPageText = _positionText();
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

  String _positionText() {
    if (widget.timeMode) return formatDuration(widget.marker.physicalPage - 1);
    return widget.useVisual ? widget.visualPage : widget.marker.physicalPage.toString();
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
                      labelText: widget.timeMode
                          ? context.l10n.audioAnchorMarker
                          : (widget.useVisual ? context.l10n.paginationVisualPage : context.l10n.paginationStartPhysical),
                      isDense: true, 
                      border: const OutlineInputBorder(), 
                      hintText: widget.timeMode ? 'hh:mm' : context.l10n.paginationVisualPageHint,
                      suffixText: widget.timeMode ? durationUnit : null,
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: widget.onVisualPageChanged,
                  ),
                ),
                const SizedBox(width: 12),
                if (!widget.timeMode) Column(
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
