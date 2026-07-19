import 'package:flutter/material.dart';
import '../services/database.dart';
import '../utils/pagination_helper.dart';
import '../l10n/l10n_extension.dart';
import 'page_picker.dart';
import 'roman_page_picker.dart';

class SegmentedPagePicker extends StatefulWidget {
  final int initialPhysicalPage;
  final int totalPages;
  final int currentReads;
  final PaginationConfig? config;
  final Map<int, int> initialSessions;
  final Function(int, PaginationConfig) onSave;

  const SegmentedPagePicker({
    super.key,
    required this.initialPhysicalPage,
    required this.totalPages,
    required this.onSave,
    this.currentReads = 0,
    this.initialSessions = const {},
    this.config,
  });

  @override
  State<SegmentedPagePicker> createState() => _SegmentedPagePickerState();
}

class _SegmentedPagePickerState extends State<SegmentedPagePicker> {
  late List<PaginationSegment> _segments;
  late PageController _pageController;
  late int _selectedPhysicalPage;

  @override
  void initState() {
    super.initState();
    _selectedPhysicalPage = widget.initialPhysicalPage;
    
    // Sanitize segments: ensure they don't go past widget.totalPages
    final rawSegments = (widget.config?.segments.isEmpty ?? true)
        ? [PaginationSegment(
            startPhysical: 1, 
            endPhysical: widget.totalPages, 
            type: PageNumberingType.arabic,
            sessions: widget.initialSessions,
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
         sessions: widget.initialSessions,
       ));
    }

    // Determine initial segment to show: 
    // "the first incomplete one, or the first one, or the last one if it has been started"
    int initialIdx = -1;
    
    // 1. Try to find the first incomplete segment
    for (int i = 0; i < _segments.length; i++) {
      final s = _segments[i];
      final currentInSegment = s.sessions[widget.currentReads + 1] ?? 0;
      final maxInSegment = s.endPhysical - s.startPhysical + 1;
      if (currentInSegment < maxInSegment) {
        initialIdx = i;
        break;
      }
    }

    // 2. Fallback to physical page logic if everything is finished or none found
    if (initialIdx == -1 && widget.initialPhysicalPage > 0) {
      for (int i = _segments.length - 1; i >= 0; i--) {
        if (widget.initialPhysicalPage >= _segments[i].startPhysical) {
          initialIdx = i;
          break;
        }
      }
    }

    if (initialIdx == -1) initialIdx = 0;

    _pageController = PageController(initialPage: initialIdx);
  }

  void _saveSegmentSession(int segmentIdx, int pagesInSegment) {
    final s = _segments[segmentIdx];
    final updatedSessions = Map<int, int>.from(s.sessions);
    
    updatedSessions[widget.currentReads + 1] = pagesInSegment;

    setState(() {
      _segments[segmentIdx] = s.copyWith(sessions: updatedSessions);
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
                final maxInSegment = s.endPhysical - s.startPhysical + 1;
                int currentInSegment = s.sessions[widget.currentReads + 1] ?? 0;
                
                // If it's the first time entering this segment and it hasn't been started
                if (currentInSegment == 0) {
                  if (widget.initialPhysicalPage >= s.startPhysical) {
                    if (widget.initialPhysicalPage > s.endPhysical) {
                      currentInSegment = maxInSegment;
                    } else {
                      currentInSegment = widget.initialPhysicalPage - s.startPhysical + 1;
                    }
                  } else {
                    currentInSegment = 1;
                  }
                }
                
                setState(() {
                  _selectedPhysicalPage = currentInSegment + s.startPhysical - 1;
                });
              },
              itemBuilder: (context, index) {
                final s = _segments[index];
                
                // Max pages in this logical block
                final maxInSegment = s.endPhysical - s.startPhysical + 1;

                // Determine current physical page within this specific segment
                // Source of truth: use the session map if it exists, otherwise initialPhysical
                int currentInSegment = s.sessions[widget.currentReads + 1] ?? 0;
                if (currentInSegment == 0 && widget.initialPhysicalPage >= s.startPhysical) {
                   if (widget.initialPhysicalPage > s.endPhysical) {
                      currentInSegment = maxInSegment;
                   } else {
                      currentInSegment = widget.initialPhysicalPage - s.startPhysical + 1;
                   }
                }

                // Visual value for the wheel
                final localValueForWheel = currentInSegment + s.offset;
                final visualMax = PaginationHelper.getVisualPage(s.endPhysical, widget.config);

                return Column(
                  children: [
                    Text(
                      s.label ?? context.l10n.paginationSectionLabel(index + 1),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: s.type == PageNumberingType.roman
                          ? RomanPagePicker(
                              initialValue: currentInSegment > 0 ? currentInSegment : 1,
                              maxValue: maxInSegment,
                              onChanged: (val) {
                                setState(() {
                                  _saveSegmentSession(index, val);
                                  _selectedPhysicalPage = val + s.startPhysical - 1;
                                });
                              },
                            )
                          : PagePicker(
                              initialValue: localValueForWheel > 0 ? localValueForWheel : s.offset + 1,
                              maxValue: maxInSegment + s.offset,
                              minValue: s.offset,
                              onChanged: (val) {
                                final physicalInSegment = val - s.offset;
                                setState(() {
                                  _saveSegmentSession(index, physicalInSegment);
                                  _selectedPhysicalPage = physicalInSegment + s.startPhysical - 1;
                                });
                              },
                            ),
                    ),
                    Text(
                      '${context.l10n.fieldCurrentPage.substring(0, 1).toUpperCase()}${context.l10n.fieldCurrentPage.substring(1).toLowerCase()}. ${PaginationHelper.getVisualPageInSegment(_selectedPhysicalPage, s)} / $visualMax',
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
            // Find current active segment based on _selectedPhysicalPage
            final activeIdx = _segments.indexWhere(
              (s) => _selectedPhysicalPage >= s.startPhysical && _selectedPhysicalPage <= s.endPhysical,
            );
            
            final activeSeg = activeIdx != -1 ? _segments[activeIdx] : _segments.last;
            final targetIdx = activeIdx != -1 ? activeIdx : _segments.length - 1;
            
            // Ensure the active segment's session is updated to the latest physical selection
            final localPhysical = _selectedPhysicalPage - activeSeg.startPhysical + 1;
            
            final updatedSessions = Map<int, int>.from(activeSeg.sessions);
            updatedSessions[widget.currentReads + 1] = localPhysical;
            
            _segments[targetIdx] = activeSeg.copyWith(sessions: updatedSessions);

            final newConfig = PaginationConfig(
              segments: _segments,
              markers: widget.config?.markers ?? [],
            );

            widget.onSave(_selectedPhysicalPage, newConfig);
          },
          child: Text(context.l10n.paginationSaveProgress),
        ),
      ],
    );
  }
}
