import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import '../controllers/database_provider.dart';
import '../l10n/l10n_extension.dart';
import 'tag_chip.dart';
import 'tag_form_dialog.dart';

/// A field-based selector with chips for Tags, Imprints, or Collections.
class EntityFieldSelector extends ConsumerStatefulWidget {
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
  ConsumerState<EntityFieldSelector> createState() => _EntityFieldSelectorState();
}

class _EntityFieldSelectorState extends ConsumerState<EntityFieldSelector> {
  TextEditingController? _capturedController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.selected.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.selected.map((tag) => TagChip(
              label: tag.name,
              colorHex: tag.color,
              onTap: () async {
                final updated = await showTagFormDialog(
                  context, 
                  ref, 
                  existing: tag, 
                  title: context.l10n.edit, 
                  type: widget.type,
                );
                if (updated != null) {
                  final newList = widget.selected.map((t) => t.id == updated.id ? updated : t).toList();
                  widget.onChanged(newList);
                }
              },
              onDeleted: () {
                if (widget.multiSelection) {
                  final newList = List<Tag>.from(widget.selected);
                  newList.remove(tag);
                  widget.onChanged(newList);
                } else {
                  widget.onChanged([]);
                }
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
                  final results = await ref.read(databaseProvider).searchTags(input, widget.type);
                  return results.where((t) => !widget.selected.any((s) => s.id == t.id)).toList();
                },
                onSelected: (tag) {
                  if (_capturedController != null) {
                    _selectTag(tag, _capturedController!);
                  }
                },
                fieldViewBuilder: (ctx, controller, focusNode, onFieldSubmitted) {
                  _capturedController = controller;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: widget.label,
                      prefixIcon: Icon(widget.icon),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          final name = controller.text.trim();
                          final newTag = await showTagFormDialog(
                            context, 
                            ref, 
                            title: context.l10n.create, 
                            type: widget.type,
                            initialName: name.isNotEmpty ? name : null,
                          );
                          if (newTag != null) {
                            _selectTag(newTag, controller);
                          }
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      final name = value.trim();
                      if (name.isEmpty) return;
                      _handleNewTag(context, ref, name, controller);
                    },
                  );
                },
              ),
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: 8),
              widget.trailing!,
            ],
          ],
        ),
      ],
    );
  }

  void _selectTag(Tag tag, TextEditingController controller) {
    if (widget.multiSelection) {
      if (!widget.selected.any((s) => s.id == tag.id)) {
        widget.onChanged([...widget.selected, tag]);
      }
    } else {
      widget.onChanged([tag]);
    }
    
    // Clear controller in the next frame to avoid Autocomplete setting it back to tag.name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clear();
    });
  }

  Future<void> _handleNewTag(BuildContext context, WidgetRef ref, String name, TextEditingController controller) async {
    final db = ref.read(databaseProvider);
    final results = await db.searchTags(name, widget.type);
    final existing = results.where((t) => t.name.toLowerCase() == name.toLowerCase()).firstOrNull;
    
    if (existing != null) {
      _selectTag(existing, controller);
      return;
    }

    if (context.mounted) {
       final newTag = await showTagFormDialog(
        context, 
        ref, 
        title: context.l10n.create,
        type: widget.type,
        initialName: name,
      );
      if (newTag != null) {
        _selectTag(newTag, controller);
      }
    }
  }
}
