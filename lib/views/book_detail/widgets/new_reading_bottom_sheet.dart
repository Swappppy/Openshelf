import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../controllers/reading_session_controller.dart';

class NewReadingBottomSheet extends ConsumerStatefulWidget {
  final Book book;
  final List<ReadHistoryData> history;

  const NewReadingBottomSheet({
    super.key,
    required this.book,
    required this.history,
  });

  @override
  ConsumerState<NewReadingBottomSheet> createState() => _NewReadingBottomSheetState();
}

class _NewReadingBottomSheetState extends ConsumerState<NewReadingBottomSheet> {
  bool _selectSections = false;
  late final List<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _selectedIndices = [];
  }

  void _onSave() {
    ref.read(readingSessionControllerProvider).startNewReading(
      book: widget.book,
      selectedIndices: _selectSections ? _selectedIndices : null,
      sectionLabelGetter: (idx) => context.l10n.paginationSectionLabel(idx),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final segments = widget.book.paginationConfig?.segments ?? [];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.bookDetailStartNewReadingTitle,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.book.title,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ToggleButton(
                  label: context.l10n.bookDetailNewReadingWholeBook,
                  icon: Icons.auto_stories_outlined,
                  isSelected: !_selectSections,
                  onTap: () => setState(() => _selectSections = false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ToggleButton(
                  label: context.l10n.bookDetailNewReadingSections,
                  icon: Icons.segment_rounded,
                  isSelected: _selectSections,
                  onTap: segments.isEmpty ? null : () => setState(() => _selectSections = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (!_selectSections) ...[
            const Divider(),
            const SizedBox(height: 16),
            Text(
              context.l10n.bookDetailNewReadingWholeBookDescription,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.bookDetailNewReadingSectionsCount(segments.length),
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedIndices.length == segments.length) {
                        _selectedIndices.clear();
                      } else {
                        _selectedIndices.clear();
                        _selectedIndices.addAll(List.generate(segments.length, (i) => i));
                      }
                    });
                  },
                  child: Text(context.l10n.selectAll),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(segments.length, (i) {
                    final s = segments[i];
                    final sectionLabel = s.label ?? context.l10n.paginationSectionLabel(i + 1);
                    final isSelected = _selectedIndices.contains(i);
                    
                    // Count how many times this specific section has been finished in history
                    final readCount = widget.history.where((h) {
                      if (h.finishedAt == null) return false;
                      if (h.sections == null) return true; // Whole book finished counts as all sections finished
                      return h.sections!.contains(sectionLabel);
                    }).length;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedIndices.remove(i);
                            } else {
                              _selectedIndices.add(i);
                              _selectedIndices.sort();
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected 
                                  ? colorScheme.primary.withValues(alpha: 0.5) 
                                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected 
                                ? colorScheme.primaryContainer.withValues(alpha: 0.1) 
                                : null,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) {
                                        _selectedIndices.add(i);
                                        _selectedIndices.sort();
                                      } else {
                                        _selectedIndices.remove(i);
                                      }
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  sectionLabel,
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  context.l10n.bookDetailNewReadingReadCount(readCount),
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(context.l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: (_selectSections && _selectedIndices.isEmpty) ? null : _onSave,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.onSurface,
                    foregroundColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _selectSections 
                        ? '${context.l10n.save} (${_selectedIndices.length})'
                        : context.l10n.save,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected 
                ? colorScheme.primaryContainer.withValues(alpha: 0.8) 
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? colorScheme.primary 
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
