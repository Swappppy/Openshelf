import 'package:flutter/material.dart';
import '../services/database.dart';
import '../utils/pagination_helper.dart';
import '../l10n/l10n_extension.dart';
import 'page_picker.dart';
import 'roman_page_picker.dart';

class SegmentedPagePicker extends StatefulWidget {
  final int totalPages;
  final ReadingStatus? status;
  final PaginationConfig? config;
  final int initialProgress;
  final Map<int, int> initialSegmentProgress;
  final int? initialSegmentIndex;
  final Function(int, Map<int, int>, PaginationConfig) onSave;

  const SegmentedPagePicker({
    super.key,
    required this.totalPages,
    required this.onSave,
    this.initialProgress = 0,
    this.initialSegmentProgress = const {},
    this.initialSegmentIndex,
    this.status,
    this.config,
  });

  @override
  State<SegmentedPagePicker> createState() => _SegmentedPagePickerState();
}

class _SegmentedPagePickerState extends State<SegmentedPagePicker> {
  late List<PaginationSegment> _segments;
  late PageController _pageController;
  late int _selectedPhysicalPage;
  late Map<int, int> _segmentProgress;

  @override
  void initState() {
    super.initState();
    _segmentProgress = Map<int, int>.from(widget.initialSegmentProgress);
    
    // Sanitize segments: ensure they don't go past widget.totalPages
    final rawSegments = (widget.config?.segments.isEmpty ?? true)
        ? [PaginationSegment(
            startPhysical: 1, 
            endPhysical: widget.totalPages, 
            type: PageNumberingType.arabic,
          )]
        : widget.config!.segments;
        
    _segments = [];
    for (final s in rawSegments) {
      if (s.startPhysical > widget.totalPages) break;
      _segments.add(s.copyWith(
        endPhysical: s.endPhysical > widget.totalPages ? widget.totalPages : s.endPhysical,
      ));
      if (_segments.last.endPhysical == widget.totalPages) break;
    }
    
    // Ensure the last segment reaches the total if sanitized version cut it short
    if (_segments.isNotEmpty && _segments.last.endPhysical < widget.totalPages) {
       final last = _segments.removeLast();
       _segments.add(last.copyWith(endPhysical: widget.totalPages));
    } else if (_segments.isEmpty) {
       _segments.add(PaginationSegment(
         startPhysical: 1, 
         endPhysical: widget.totalPages, 
         type: PageNumberingType.arabic,
       ));
    }

    // Determine initial segment to show: 
    // 1. If explicit index provided, use it
    // 2. Otherwise, find the first incomplete one, or the first one
    int initialIdx = widget.initialSegmentIndex ?? -1;
    
    if (initialIdx == -1) {
      // Try to find the first incomplete segment
      for (int i = 0; i < _segments.length; i++) {
        final currentInSegment = _segmentProgress[i] ?? 0;
        final maxInSegment = _segments[i].endPhysical - _segments[i].startPhysical + 1;
        if (currentInSegment < maxInSegment) {
          initialIdx = i;
          break;
        }
      }
    }

    // 2. Fallback to physical page logic if everything is finished or none found
    if (initialIdx == -1 && widget.initialProgress > 0) {
      // Find segment containing the current physical page
      // Current physical page calculation from total progress is complex if not mapped.
      // We assume widget.initialProgress is absolute physical page if no segments,
      // but here we have segments.
      // Let's just use the first incomplete or first.
    }

    if (initialIdx == -1) initialIdx = 0;

    _pageController = PageController(initialPage: initialIdx);
    
    final initialSeg = _segments[initialIdx];
    final initialPagesInSeg = _segmentProgress[initialIdx] ?? 0;
    _selectedPhysicalPage = initialPagesInSeg > 0 
        ? initialPagesInSeg + initialSeg.startPhysical - 1
        : initialSeg.startPhysical - 1;
  }

  void _saveSegmentSession(int segmentIdx, int pagesInSegment) {
    setState(() {
      _segmentProgress[segmentIdx] = pagesInSegment;
      
      final s = _segments[segmentIdx];
      _selectedPhysicalPage = pagesInSegment > 0 
          ? pagesInSegment + s.startPhysical - 1 
          : s.startPhysical - 1;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_segments.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_segments.length, (index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (ctx, _) {
                    double selected = 0;
                    if (_pageController.hasClients && _pageController.page != null) {
                      selected = (index - _pageController.page!).abs();
                    } else if (index == _pageController.initialPage) {
                      selected = 0;
                    } else {
                      selected = 1;
                    }
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8 + (8 * (1 - selected.clamp(0.0, 1.0))),
                      height: 4,
                      decoration: BoxDecoration(
                        color: selected < 0.5 
                            ? Theme.of(context).colorScheme.primary 
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        
        Flexible(
          child: SizedBox(
            height: 250,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _segments.length,
              onPageChanged: (index) {
                final s = _segments[index];
                final currentInSegment = _segmentProgress[index] ?? 0;
                
                setState(() {
                  _selectedPhysicalPage = currentInSegment > 0 
                      ? currentInSegment + s.startPhysical - 1
                      : s.startPhysical - 1;
                });
              },
              itemBuilder: (context, index) {
                final s = _segments[index];
                
                // Max pages in this logical block
                final maxInSegment = s.endPhysical - s.startPhysical + 1;

                // Determine current physical page within this specific segment
                int currentInSegment = _segmentProgress[index] ?? 0;

                // Visual value for the wheel
                final localValueForWheel = currentInSegment + s.offset;
                final visualMax = PaginationHelper.getVisualPage(s.endPhysical, widget.config);

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          s.label ?? context.l10n.paginationSectionLabel(index + 1),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          s.type == PageNumberingType.roman
                              ? RomanPagePicker(
                                  initialValue: currentInSegment > 0 ? currentInSegment + s.offset : s.offset,
                                  minValue: s.offset,
                                  maxValue: maxInSegment + s.offset,
                                  onChanged: (val) {
                                    final physicalInSegment = val - s.offset;
                                    _saveSegmentSession(index, physicalInSegment);
                                  },
                                )
                              : PagePicker(
                                  initialValue: localValueForWheel >= s.offset ? localValueForWheel : s.offset,
                                  maxValue: maxInSegment + s.offset,
                                  minValue: s.offset,
                                  onChanged: (val) {
                                    final physicalInSegment = val - s.offset;
                                    _saveSegmentSession(index, physicalInSegment);
                                  },
                                ),
                        ],
                      ),
                    ),
                    Text(
                      currentInSegment == 0
                          ? context.l10n.paginationProgress(s.type == PageNumberingType.roman ? '-' : '0', visualMax)
                          : '${context.l10n.paginationCurrentPageShort} ${PaginationHelper.getVisualPageInSegment(s.startPhysical + currentInSegment - 1, s)} / $visualMax',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () {
            // Clean up _segmentProgress to only include current segments
            final Map<int, int> cleanedProgress = {};
            int maxPhysReached = 0;
            bool allCompleted = true;

            for (int i = 0; i < _segments.length; i++) {
              final s = _segments[i];
              final progress = _segmentProgress[i] ?? 0;
              cleanedProgress[i] = progress;
              
              if (progress > 0) {
                final phys = s.startPhysical + progress - 1;
                if (phys > maxPhysReached) maxPhysReached = phys;
              }

              final maxInSeg = s.endPhysical - s.startPhysical + 1;
              if (progress < maxInSeg) {
                allCompleted = false;
              }
            }

            int totalPhysRead = 0;
            if (_segments.length > 1 || widget.config?.segments.isNotEmpty == true) {
              totalPhysRead = allCompleted ? widget.totalPages : maxPhysReached;
            } else {
              // If no segments, _selectedPhysicalPage is the absolute page
              totalPhysRead = _selectedPhysicalPage;
            }

            final newConfig = PaginationConfig(
              segments: _segments,
              markers: widget.config?.markers ?? [],
            );

            widget.onSave(totalPhysRead, cleanedProgress, newConfig);
          },
          child: Text(context.l10n.paginationSaveProgress),
        ),
      ],
    );
  }
}
