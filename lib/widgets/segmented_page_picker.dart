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

    // REDISTRIBUTION LOGIC: 
    // If we have segments but no segment progress was provided, 
    // but we have a total initial progress, distribute it.
    if (_segmentProgress.isEmpty && widget.initialProgress > 0 && _segments.isNotEmpty) {
      _segmentProgress = PaginationHelper.distributePhysicalPage(widget.initialProgress, _segments);
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
        _SegmentCarouselIndicators(
          pageController: _pageController,
          totalSegments: _segments.length,
        ),
        
        Flexible(
          child: SizedBox(
            height: 290,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        s.label ?? context.l10n.paginationSectionLabel(index + 1),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                      '${context.l10n.paginationCurrentPageShort} ${PaginationHelper.getVisualPageInSegment(s.startPhysical + currentInSegment - 1, s)} / $visualMax',
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
            int sumProgress = 0;
            bool allCompleted = true;

            for (int i = 0; i < _segments.length; i++) {
              final s = _segments[i];
              final progress = _segmentProgress[i] ?? 0;
              cleanedProgress[i] = progress;
              
              sumProgress += progress;

              final maxInSeg = s.endPhysical - s.startPhysical + 1;
              if (progress < maxInSeg) {
                allCompleted = false;
              }
            }

            int totalPhysRead = 0;
            if (_segments.length > 1 || widget.config?.segments.isNotEmpty == true) {
              totalPhysRead = allCompleted ? widget.totalPages : sumProgress;
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

class _SegmentCarouselIndicators extends StatelessWidget {
  final PageController pageController;
  final int totalSegments;
  static const int maxVisible = 7;

  const _SegmentCarouselIndicators({
    required this.pageController,
    required this.totalSegments,
  });

  @override
  Widget build(BuildContext context) {
    if (totalSegments <= 1) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        double currentPage = 0;
        if (pageController.hasClients && pageController.page != null) {
          currentPage = pageController.page!;
        } else {
          currentPage = pageController.initialPage.toDouble();
        }

        final int centerIndex = currentPage.round();

        int startIndex;
        int endIndex;
        bool showLeftEllipsis = false;
        bool showRightEllipsis = false;

        if (totalSegments <= maxVisible) {
          startIndex = 0;
          endIndex = totalSegments - 1;
        } else {
          final int half = maxVisible ~/ 2;
          if (centerIndex <= half) {
            startIndex = 0;
            endIndex = maxVisible - 1;
          } else if (centerIndex >= totalSegments - 1 - half) {
            startIndex = totalSegments - maxVisible;
            endIndex = totalSegments - 1;
          } else {
            startIndex = centerIndex - half;
            endIndex = startIndex + maxVisible - 1;
          }

          showLeftEllipsis = startIndex > 0;
          showRightEllipsis = endIndex < totalSegments - 1;
        }

        final int hiddenBefore = startIndex;
        final int hiddenAfter = totalSegments - 1 - endIndex;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showLeftEllipsis)
                InkWell(
                  onTap: () {
                    final target = (startIndex - 1).clamp(0, totalSegments - 1);
                    pageController.animateToPage(
                      target,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+$hiddenBefore',
                      style: TextStyle(
                        color: colorScheme.outline,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              for (int i = startIndex; i <= endIndex; i++) ...[
                Builder(
                  builder: (context) {
                    final double selected = (i - currentPage).abs();
                    final double weight = (1 - selected.clamp(0.0, 1.0));
                    final double width = 8 + (8 * weight);

                    return GestureDetector(
                      onTap: () {
                        pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: width,
                        height: 4,
                        decoration: BoxDecoration(
                          color: selected < 0.5
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ],
              if (showRightEllipsis)
                InkWell(
                  onTap: () {
                    final target = (endIndex + 1).clamp(0, totalSegments - 1);
                    pageController.animateToPage(
                      target,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+$hiddenAfter',
                      style: TextStyle(
                        color: colorScheme.outline,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

