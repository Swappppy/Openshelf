import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_filters.dart';
import '../services/database.dart';
import '../controllers/books_controller.dart';
import '../l10n/l10n_extension.dart';
import 'filter_grid_box.dart';
import 'entity_selector_grid.dart';

class FilterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const FilterTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.38)),
        isDense: true,
        filled: true,
        fillColor: colorScheme.primary.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
    );
  }
}

class FilterDateSelector extends StatelessWidget {
  final String label;
  final DateTime? value;
  final BooleanOperator operator;
  final ValueChanged<DateTime?> onChanged;
  final ValueChanged<BooleanOperator> onOpChanged;

  const FilterDateSelector({
    super.key,
    required this.label,
    required this.value,
    required this.operator,
    required this.onChanged,
    required this.onOpChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          height: 32,
          padding: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: value ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    onChanged(date);
                  },
                  child: Text(
                    value != null ? "${value!.day}/${value!.month}/${value!.year}" : "...",
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final next = switch (operator) {
                    BooleanOperator.greaterThan => BooleanOperator.equals,
                    BooleanOperator.equals => BooleanOperator.lessThan,
                    _ => BooleanOperator.greaterThan,
                  };
                  onOpChanged(next);
                },
                child: Container(
                  width: 30,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                  ),
                  child: Text(
                    switch (operator) {
                      BooleanOperator.greaterThan => ">",
                      BooleanOperator.equals => "=",
                      BooleanOperator.lessThan => "<",
                      _ => "=",
                    },
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatusFiltersTab extends StatelessWidget {
  final ReadingStatus? status;
  final BookFormat? format;
  final OwnershipStatus? ownership;
  final Function(ReadingStatus?, bool clear) onStatusChanged;
  final Function(BookFormat?, bool clear) onFormatChanged;
  final Function(OwnershipStatus?, bool clear) onOwnershipChanged;

  const StatusFiltersTab({
    super.key,
    this.status,
    this.format,
    this.ownership,
    required this.onStatusChanged,
    required this.onFormatChanged,
    required this.onOwnershipChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statusOptions = [
      (ReadingStatus.reading, context.l10n.statusReading, Colors.blue),
      (ReadingStatus.wantToRead, context.l10n.statusWantToRead, Colors.orange),
      (ReadingStatus.read, context.l10n.statusRead, Colors.green),
      (ReadingStatus.paused, context.l10n.statusPaused, const Color(0xFFB39DDB)),
      (ReadingStatus.abandoned, context.l10n.statusAbandoned, Colors.red),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(label: context.l10n.searchTabStatus),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: statusOptions.map<Widget>((opt) {
              final isSelected = status == opt.$1;
              return FilterGridBox(
                label: opt.$2,
                isSelected: isSelected,
                color: opt.$3,
                onTap: () => onStatusChanged(opt.$1, isSelected),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _SectionHeader(label: context.l10n.sectionFormat),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: BookFormat.values.map<Widget>((f) {
              final isSelected = format == f;
              return FilterGridBox(
                label: _formatLabel(context, f),
                isSelected: isSelected,
                onTap: () => onFormatChanged(f, isSelected),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _SectionHeader(label: context.l10n.fieldOwnershipStatus),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: OwnershipStatus.values.map<Widget>((s) {
              final isSelected = ownership == s;
              return FilterGridBox(
                label: _ownershipLabel(context, s),
                isSelected: isSelected,
                onTap: () => onOwnershipChanged(s, isSelected),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatLabel(BuildContext context, BookFormat format) {
    switch (format) {
      case BookFormat.paperback: return context.l10n.formatPaperback;
      case BookFormat.hardcover: return context.l10n.formatHardcover;
      case BookFormat.rustic: return context.l10n.formatRustic;
      case BookFormat.digital: return context.l10n.formatDigital;
      case BookFormat.leatherbound: return context.l10n.formatLeatherbound;
      case BookFormat.other: return context.l10n.formatOther;
    }
  }

  String _ownershipLabel(BuildContext context, OwnershipStatus status) {
    switch (status) {
      case OwnershipStatus.bought: return context.l10n.ownershipStatusBought;
      case OwnershipStatus.gifted: return context.l10n.ownershipStatusGifted;
      case OwnershipStatus.borrowed: return context.l10n.ownershipStatusBorrowed;
      case OwnershipStatus.returned: return context.l10n.ownershipStatusReturned;
      case OwnershipStatus.sold: return context.l10n.ownershipStatusSold;
      case OwnershipStatus.other: return context.l10n.ownershipStatusOther;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.primary.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              fontSize: 9,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: colorScheme.primary.withValues(alpha: 0.1), height: 1)),
        ],
      ),
    );
  }
}

class BooleanQueryPanel extends StatelessWidget {
  final BooleanQuery query;
  final ValueChanged<BooleanQuery> onChanged;

  const BooleanQueryPanel({super.key, required this.query, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 160),
          child: SingleChildScrollView(
            child: Column(
              children: query.conditions.asMap().entries.map((entry) {
                final idx = entry.key;
                final cond = entry.value;
                return Column(
                  children: [
                    if (idx > 0)
                      _ConnectorPill(
                        connector: cond.connector ?? BooleanConnector.and,
                        onChanged: (c) {
                          final newList = List<BooleanCondition>.from(query.conditions);
                          newList[idx] = cond.copyWith(connector: c);
                          onChanged(query.copyWith(conditions: newList));
                        },
                      ),
                    BooleanConditionRow(
                      condition: cond,
                      onChanged: (newCond) {
                        final newList = List<BooleanCondition>.from(query.conditions);
                        newList[idx] = newCond;
                        onChanged(query.copyWith(conditions: newList));
                      },
                      onDelete: () {
                        final newList = List<BooleanCondition>.from(query.conditions)..removeAt(idx);
                        if (newList.isNotEmpty && newList[0].connector != null) {
                          newList[0] = newList[0].copyWith(clearConnector: true);
                        }
                        onChanged(query.copyWith(conditions: newList));
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            final newList = List<BooleanCondition>.from(query.conditions)
              ..add(BooleanCondition(
                field: SearchField.title,
                operator: BooleanOperator.contains,
                connector: query.conditions.isEmpty ? null : BooleanConnector.and,
              ));
            onChanged(query.copyWith(conditions: newList));
          },
          icon: const Icon(Icons.add, size: 16),
          label: Text(context.l10n.searchAddCondition, style: const TextStyle(fontSize: 11)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

class BooleanConditionRow extends StatelessWidget {
  final BooleanCondition condition;
  final ValueChanged<BooleanCondition> onChanged;
  final VoidCallback onDelete;

  const BooleanConditionRow({super.key, required this.condition, required this.onChanged, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: FieldSelector<SearchField>(
              value: condition.field,
              options: SearchField.values,
              labelBuilder: (f) => f.label(context),
              onChanged: (f) => onChanged(condition.copyWith(
                field: f,
                operator: f.operators().first,
                value: null,
              )),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: FieldSelector<BooleanOperator>(
              value: condition.operator,
              options: condition.field.operators(),
              labelBuilder: (o) => o.label(context),
              onChanged: (o) => onChanged(condition.copyWith(operator: o)),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 4,
            child: ValueEditor(condition: condition, onChanged: (v) => onChanged(condition.copyWith(value: v))),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class FieldSelector<T> extends StatelessWidget {
  final T value;
  final List<T> options;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  const FieldSelector({super.key, required this.value, required this.options, required this.labelBuilder, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButton<T>(
        value: value,
        menuMaxHeight: 200,
        items: options.map((opt) => DropdownMenuItem(
          value: opt,
          child: Text(
            labelBuilder(opt), 
            style: const TextStyle(fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        )).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, size: 16),
      ),
    );
  }
}

class ValueEditor extends ConsumerWidget {
  final BooleanCondition condition;
  final ValueChanged<dynamic> onChanged;

  const ValueEditor({super.key, required this.condition, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final field = condition.field;

    if (field == SearchField.status) {
      return FieldSelector<ReadingStatus>(
        value: ReadingStatus.values.where((v) => v.name == (condition.value ?? 'reading')).firstOrNull ?? ReadingStatus.reading,
        options: ReadingStatus.values,
        labelBuilder: (v) => _statusLabel(context, v.name),
        onChanged: (v) => onChanged(v.name),
      );
    }

    if (field == SearchField.format) {
      return FieldSelector<BookFormat>(
        value: BookFormat.values.where((v) => v.name == (condition.value ?? 'paperback')).firstOrNull ?? BookFormat.paperback,
        options: BookFormat.values,
        labelBuilder: (v) => _formatLabel(context, v),
        onChanged: (v) => onChanged(v.name),
      );
    }

    if (field == SearchField.ownership) {
      return FieldSelector<OwnershipStatus>(
        value: OwnershipStatus.values.where((v) => v.name == (condition.value ?? 'bought')).firstOrNull ?? OwnershipStatus.bought,
        options: OwnershipStatus.values,
        labelBuilder: (v) => _ownershipLabel(context, v),
        onChanged: (v) => onChanged(v.name),
      );
    }

    if (field == SearchField.startedAt || field == SearchField.finishedAt) {
      return FilterDatePickerValue(
        value: DateTime.tryParse(condition.value?.toString() ?? ''),
        onChanged: (d) => onChanged(d?.toIso8601String()),
      );
    }

    if (field == SearchField.noCover || field == SearchField.hasNotes) {
      return SizedBox(
        height: 28,
        child: Center(
          child: Switch(
            value: condition.value == true,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    }

    if (field == SearchField.category || field == SearchField.imprint || field == SearchField.collection) {
      return EntityPickerValue(condition: condition, onChanged: onChanged);
    }

    // Default text input
    return SizedBox(
      height: 28,
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 11),
        decoration: InputDecoration(
          hintText: '...',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
        controller: TextEditingController(text: condition.value?.toString() ?? '')..selection = TextSelection.collapsed(offset: (condition.value?.toString() ?? '').length),
      ),
    );
  }

  String _statusLabel(BuildContext context, String status) {
    switch (status) {
      case 'reading': return context.l10n.shelfStatusLabelReading;
      case 'read': return context.l10n.shelfStatusLabelRead;
      case 'wantToRead': return context.l10n.shelfStatusLabelWantToRead;
      case 'abandoned': return context.l10n.shelfStatusLabelAbandoned;
      case 'paused': return context.l10n.shelfStatusLabelPaused;
      default: return status;
    }
  }

  String _formatLabel(BuildContext context, BookFormat format) {
    switch (format) {
      case BookFormat.paperback: return context.l10n.formatPaperback;
      case BookFormat.hardcover: return context.l10n.formatHardcover;
      case BookFormat.rustic: return context.l10n.formatRustic;
      case BookFormat.digital: return context.l10n.formatDigital;
      case BookFormat.leatherbound: return context.l10n.formatLeatherbound;
      case BookFormat.other: return context.l10n.formatOther;
    }
  }

  String _ownershipLabel(BuildContext context, OwnershipStatus status) {
    switch (status) {
      case OwnershipStatus.bought: return context.l10n.ownershipStatusBought;
      case OwnershipStatus.gifted: return context.l10n.ownershipStatusGifted;
      case OwnershipStatus.borrowed: return context.l10n.ownershipStatusBorrowed;
      case OwnershipStatus.returned: return context.l10n.ownershipStatusReturned;
      case OwnershipStatus.sold: return context.l10n.ownershipStatusSold;
      case OwnershipStatus.other: return context.l10n.ownershipStatusOther;
    }
  }
}

class FilterDatePickerValue extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const FilterDatePickerValue({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        onChanged(date);
      },
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null ? "${value!.day}/${value!.month}/${value!.year}" : "...",
                style: const TextStyle(fontSize: 10),
              ),
            ),
            const Icon(Icons.calendar_today, size: 14),
          ],
        ),
      ),
    );
  }
}

class EntityPickerValue extends ConsumerWidget {
  final BooleanCondition condition;
  final ValueChanged<dynamic> onChanged;

  const EntityPickerValue({super.key, required this.condition, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final int? entityId = int.tryParse(condition.value?.toString() ?? '');
    
    // Determine provider based on field
    final provider = switch (condition.field) {
      SearchField.category => allTagsProvider,
      SearchField.imprint => allImprintsProvider,
      SearchField.collection => allCollectionsProvider,
      _ => allTagsProvider,
    };

    final entitiesAsync = ref.watch(provider);

    return InkWell(
      onTap: () => _showPicker(context, ref, provider),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: entitiesAsync.when(
                data: (list) {
                  final entity = list.where((t) => t.id == entityId).firstOrNull;
                  if (entity == null) return const Text('...', style: TextStyle(fontSize: 10, color: Colors.grey));
                  return Text(entity.name, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis);
                },
                loading: () => const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, _) => const Text('Error', style: TextStyle(fontSize: 10)),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, WidgetRef ref, StreamProvider<List<Tag>> provider) async {
    await ref.read(provider.future);
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(condition.field.label(context)),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: double.maxFinite,
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: SingleChildScrollView(
            child: EntitySelectorGrid(
              selected: const [],
              onChanged: (list) {
                if (list.isNotEmpty) {
                  onChanged(list.last.id);
                  Navigator.pop(context);
                }
              },
              provider: provider,
              type: switch (condition.field) {
                SearchField.imprint => TagType.imprint,
                SearchField.collection => TagType.collection,
                _ => TagType.tag,
              },
              isImprint: condition.field == SearchField.imprint,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }
}

class _ConnectorPill extends StatelessWidget {
  final BooleanConnector connector;
  final ValueChanged<BooleanConnector> onChanged;

  const _ConnectorPill({required this.connector, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => onChanged(connector == BooleanConnector.and ? BooleanConnector.or : BooleanConnector.and),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            connector.name.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.onSecondaryContainer),
          ),
        ),
      ),
    );
  }
}
