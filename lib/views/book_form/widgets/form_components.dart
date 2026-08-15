import 'package:flutter/material.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../models/extensions/reading_status_ext.dart';
import '../../../models/extensions/book_format_ext.dart';
import '../../../models/extensions/ownership_status_ext.dart';
import '../../../widgets/section_header.dart' as shared;

class SectionHeader extends StatelessWidget {
  final String label;
  const SectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return shared.SectionHeader(label: label);
  }
}

class FormFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final Widget? suffixIcon;
  final bool required;
  final TextInputType keyboardType;
  final int maxLines;
  final bool readOnly;

  const FormFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.suffixIcon,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        filled: readOnly,
        fillColor: readOnly ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : null,
      ),
      validator: required
          ? (v) =>
      (v == null || v.trim().isEmpty) ? context.l10n.requiredField : null
          : null,
    );
  }
}

class StatusSelector extends StatelessWidget {
  final ReadingStatus selected;
  final ValueChanged<ReadingStatus> onChanged;

  const StatusSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReadingStatus.values.map((status) {
        final isSelected = selected == status;
        final color = status.color;
        
        return ChoiceChip(
          avatar: Icon(status.icon, size: 16, color: isSelected ? color : null),
          label: Text(status.label(context)),
          selected: isSelected,
          selectedColor: color.withValues(alpha: 0.15),
          onSelected: (_) => onChanged(status),
        );
      }).toList(),
    );
  }
}

class OwnershipStatusSelector extends StatelessWidget {
  final OwnershipStatus? selected;
  final ValueChanged<OwnershipStatus?> onChanged;

  const OwnershipStatusSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: OwnershipStatus.values.map((status) {
        final isSelected = selected == status;
        final color = status.color;

        return ChoiceChip(
          avatar: Icon(status.icon, size: 16, color: isSelected ? color : null),
          label: Text(status.label(context)),
          selected: isSelected,
          selectedColor: color.withValues(alpha: 0.15),
          onSelected: (_) => onChanged(isSelected ? null : status),
        );
      }).toList(),
    );
  }
}

class FormatSelector extends StatelessWidget {
  final BookFormat? selected;
  final ValueChanged<BookFormat?> onChanged;

  const FormatSelector({super.key, this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: BookFormat.values.map((format) {
        final isSelected = selected == format;
        final color = Theme.of(context).colorScheme.primary;
        return ChoiceChip(
          label: Text(format.label(context)),
          selected: isSelected,
          selectedColor: color.withValues(alpha: 0.15),
          onSelected: (_) => onChanged(isSelected ? null : format),
        );
      }).toList(),
    );
  }
}

class RatingSelector extends StatelessWidget {
  final double? rating;
  final ValueChanged<double?> onChanged;

  const RatingSelector({super.key, this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          final star = i + 1;
          return IconButton(
            icon: Icon(
              rating != null && rating! >= star
                  ? Icons.star
                  : Icons.star_border,
              color: Colors.amber[700],
            ),
            onPressed: () => onChanged(
                rating == star.toDouble() ? null : star.toDouble()),
          );
        }),
        if (rating != null)
          Text(
            rating!.toStringAsFixed(0),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    );
  }
}
