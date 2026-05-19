import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import 'filter_grid_box.dart';
import 'tag_form_dialog.dart';
import '../l10n/l10n_extension.dart';

/// A generic grid for selecting multiple entities (Tags, Imprints, Collections).
class EntitySelectorGrid extends ConsumerWidget {
  final List<Tag> selected;
  final ValueChanged<List<Tag>> onChanged;
  final StreamProvider<List<Tag>> provider;
  final bool isImprint;
  final String type;

  const EntitySelectorGrid({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.provider,
    required this.type,
    this.isImprint = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(provider);

    return asyncData.maybeWhen(
      data: (all) => Wrap(
        spacing: 6,
        runSpacing: 6,
        children: all.map((item) {
          final isSelected = selected.any((t) => t.id == item.id);
          final color = item.color != null ? Color(int.parse('0xFF${item.color}')) : null;

          return FilterGridBox(
            label: item.name,
            isSelected: isSelected,
            color: color,
            imagePath: item.imagePath,
            isImprint: isImprint,
            onTap: () {
              final newList = List<Tag>.from(selected);
              if (isSelected) {
                newList.removeWhere((t) => t.id == item.id);
              } else {
                newList.add(item);
              }
              onChanged(newList);
            },
            onLongPress: () => showTagFormDialog(
              context, 
              ref, 
              existing: item, 
              title: context.l10n.edit, 
              type: type,
            ),
          );
        }).toList(),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
