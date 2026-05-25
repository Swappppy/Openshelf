import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tag_type.dart';
import '../services/database.dart';
import '../controllers/books_controller.dart';
import '../l10n/l10n_extension.dart';
import 'tag_chip.dart';

class TagGridSelector extends ConsumerWidget {
  final List<Tag> selected;
  final TagType type;
  final ValueChanged<List<Tag>> onChanged;

  const TagGridSelector({
    super.key,
    required this.selected,
    required this.type,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _showPicker(context, ref),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.grid_view_rounded),
      ),
    );
  }

  void _showPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TagPickerSheet(
        type: type,
        selected: selected,
        onChanged: onChanged,
      ),
    );
  }
}

class _TagPickerSheet extends ConsumerStatefulWidget {
  final TagType type;
  final List<Tag> selected;
  final ValueChanged<List<Tag>> onChanged;

  const _TagPickerSheet({
    required this.type,
    required this.selected,
    required this.onChanged,
  });

  @override
  ConsumerState<_TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends ConsumerState<_TagPickerSheet> {
  late List<Tag> _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = List.from(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = widget.type == TagType.tag 
        ? ref.watch(allTagsProvider)
        : widget.type == TagType.imprint
            ? ref.watch(allImprintsProvider)
            : ref.watch(allCollectionsProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              context.l10n.sectionCategories,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: tagsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(context.l10n.errorPrefix(e.toString()))),
                data: (allTags) {
                  if (allTags.isEmpty) {
                    return Center(child: Text(context.l10n.tagNoCategories));
                  }
                  return SingleChildScrollView(
                    controller: scrollController,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allTags.map((tag) {
                        final isSelected = _localSelected.any((s) => s.id == tag.id);
                        return Stack(
                          children: [
                            TagChip(
                              label: tag.name,
                              colorHex: tag.color,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _localSelected.removeWhere((s) => s.id == tag.id);
                                  } else {
                                    _localSelected.add(tag);
                                  }
                                });
                                widget.onChanged(_localSelected);
                              },
                            ),
                            if (isSelected)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.done),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
