import 'package:flutter/material.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';

class SectionHeader extends StatelessWidget {
  final String label;
  const SectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

class FormFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool required;
  final TextInputType keyboardType;
  final int maxLines;
  final bool readOnly;

  const FormFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
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

  static const _options = [
    (ReadingStatus.wantToRead, Icons.bookmark_outline, Colors.orange),
    (ReadingStatus.reading, Icons.auto_stories, Colors.blue),
    (ReadingStatus.read, Icons.check_circle_outline, Colors.green),
    (ReadingStatus.abandoned, Icons.close, Colors.red),
    (ReadingStatus.paused, Icons.pause_circle_outline, Color(0xFFB39DDB)),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((opt) {
        final (status, icon, color) = opt;
        final isSelected = selected == status;
        final label = switch (status) {
          ReadingStatus.wantToRead => context.l10n.statusWantToRead,
          ReadingStatus.reading => context.l10n.statusReading,
          ReadingStatus.read => context.l10n.statusRead,
          ReadingStatus.abandoned => context.l10n.statusAbandoned,
          ReadingStatus.paused => context.l10n.statusPaused,
        };
        return ChoiceChip(
          avatar: Icon(icon, size: 16, color: isSelected ? color : null),
          label: Text(label),
          selected: isSelected,
          selectedColor: color.withValues(alpha: 0.15),
          onSelected: (_) => onChanged(status),
        );
      }).toList(),
    );
  }
}

class FormatSelector extends StatelessWidget {
  final BookFormat? selected;
  final ValueChanged<BookFormat?> onChanged;

  const FormatSelector({super.key, this.selected, required this.onChanged});

  static const _options = [
    BookFormat.paperback,
    BookFormat.hardcover,
    BookFormat.leatherbound,
    BookFormat.rustic,
    BookFormat.digital,
    BookFormat.other,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((format) {
        final label = switch (format) {
          BookFormat.paperback => context.l10n.formatPaperback,
          BookFormat.hardcover => context.l10n.formatHardcover,
          BookFormat.leatherbound => context.l10n.formatLeatherbound,
          BookFormat.rustic => context.l10n.formatRustic,
          BookFormat.digital => context.l10n.formatDigital,
          BookFormat.other => context.l10n.formatOther,
        };
        final isSelected = selected == format;
        final color = Theme.of(context).colorScheme.primary;
        return ChoiceChip(
          label: Text(label),
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

class CoverPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double iconSize;

  const CoverPlaceholder({
    super.key,
    this.width = 90,
    this.height = 130,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book,
        size: iconSize,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final IconData icon;

  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onChanged(null),
                )
              : null,
        ),
        child: Text(
          value != null
              ? '${value!.day}/${value!.month}/${value!.year}'
              : '—',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
