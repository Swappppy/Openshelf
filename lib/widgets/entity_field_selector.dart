import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import '../controllers/database_provider.dart';
import '../l10n/l10n_extension.dart';
import 'tag_chip.dart';
import 'tag_form_dialog.dart';

/// A field-based selector with chips for Tags, Imprints, or Collections.
class EntityFieldSelector extends ConsumerWidget {
  final List<Tag> selected;
  final ValueChanged<List<Tag>> onChanged;
  final String type;
  final String label;
  final IconData icon;
  final bool multiSelection;
  final Widget? trailing;

  const EntityFieldSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.type,
    required this.label,
    required this.icon,
    this.multiSelection = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selected.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: selected.map((tag) => TagChip(
              label: tag.name,
              colorHex: tag.color,
              onTap: () => showTagFormDialog(
                context, 
                ref, 
                existing: tag, 
                title: context.l10n.edit, 
                type: type,
              ),
              onDeleted: () {
                final newList = List<Tag>.from(selected);
                newList.remove(tag);
                onChanged(newList);
              },
            )).toList(),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Autocomplete<Tag>(
                displayStringForOption: (t) => t.name,
                optionsBuilder: (textEditingValue) async {
                  final input = textEditingValue.text.trim();
                  if (input.isEmpty) return [];
                  final results = await ref.read(databaseProvider).searchTags(input, type);
                  return results.where((t) => !selected.any((s) => s.id == t.id)).toList();
                },
                onSelected: (tag) {
                  if (multiSelection) {
                    onChanged([...selected, tag]);
                  } else {
                    onChanged([tag]);
                  }
                },
                fieldViewBuilder: (ctx, controller, focusNode, onFieldSubmitted) => TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: label,
                    prefixIcon: Icon(icon),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final name = controller.text.trim();
                        showTagFormDialog(
                          context, 
                          ref, 
                          title: context.l10n.create, 
                          type: type,
                          initialName: name.isNotEmpty ? name : null,
                        );
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    final name = value.trim();
                    if (name.isEmpty) return;
                    _handleNewTag(context, ref, name, controller);
                  },
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _handleNewTag(BuildContext context, WidgetRef ref, String name, TextEditingController controller) async {
    final db = ref.read(databaseProvider);
    final results = await db.searchTags(name, type);
    final existing = results.where((t) => t.name.toLowerCase() == name.toLowerCase()).firstOrNull;
    
    if (existing != null) {
      if (!selected.any((s) => s.id == existing.id)) {
        if (multiSelection) {
          onChanged([...selected, existing]);
        } else {
          onChanged([existing]);
        }
      }
      controller.clear();
      return;
    }

    if (context.mounted) {
       showTagFormDialog(
        context, 
        ref, 
        title: context.l10n.create,
        type: type,
        initialName: name,
      );
    }
  }
}
