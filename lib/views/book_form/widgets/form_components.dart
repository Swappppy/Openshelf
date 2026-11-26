import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/database.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../models/extensions/reading_status_ext.dart';
import '../../../models/extensions/book_format_ext.dart';
import '../../../models/extensions/media_type_ext.dart';
import '../../../utils/media_progress.dart';
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

/// Reading / audio selector. Mixed mode (`both`) is not offered until it is
/// implemented, but a book already stored as `both` still shows it.
class MediaTypeSelector extends StatelessWidget {
  final MediaType selected;
  final ValueChanged<MediaType> onChanged;

  const MediaTypeSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [MediaType.reading, MediaType.audio, if (selected == MediaType.both) MediaType.both];
    return SegmentedButton<MediaType>(
      segments: [
        for (final t in options)
          ButtonSegment(value: t, label: Text(t.label(context)), icon: Icon(t.icon, size: 18)),
      ],
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

/// Text field for a duration or position. Accepts `hh:mm`, `h:mm:ss` or a
/// bare number of hours, and normalizes the text to `hh:mm` when it loses
/// focus (`10` becomes `10:00`). Shows the hour unit as a suffix.
class DurationFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool isRequired;
  final bool autofocus;

  /// Extra validation on the parsed value (in seconds); returns an error or null.
  final String? Function(int seconds)? extraValidator;

  const DurationFormField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.extraValidator,
    this.isRequired = false,
    this.autofocus = false,
  });

  @override
  State<DurationFormField> createState() => _DurationFormFieldState();
}

class _DurationFormFieldState extends State<DurationFormField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_normalize);
  }

  void _normalize() {
    if (_focusNode.hasFocus) return;
    final seconds = parseDuration(widget.controller.text);
    if (seconds != null) widget.controller.text = formatDuration(seconds);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_normalize);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: 'hh:mm',
        suffixText: durationUnit,
        prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
        border: const OutlineInputBorder(),
      ),
      onFieldSubmitted: (_) => _normalize(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return widget.isRequired ? context.l10n.durationInvalid : null;
        }
        final seconds = parseDuration(value);
        if (seconds == null) return context.l10n.durationInvalid;
        return widget.extraValidator?.call(seconds);
      },
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

/// A text field that provides DB-backed autocompletion with multi-value delimiter support
/// (e.g. ';' or '/' or ','). Optionally displays a '?' help button to explain multi-value separation.
class DelimitedAutocompleteFormField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Future<List<String>> Function(String query) optionsBuilder;
  final bool required;
  final bool showHelp;
  final String? helpTitle;
  final String? helpContent;

  const DelimitedAutocompleteFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.optionsBuilder,
    this.required = false,
    this.showHelp = false,
    this.helpTitle,
    this.helpContent,
  });

  /// Extracts the current active segment after the last delimiter (; / ,).
  static String getCurrentQuerySegment(String text) {
    final delimiters = [';', '/', ','];
    int lastIdx = -1;
    for (final d in delimiters) {
      final idx = text.lastIndexOf(d);
      if (idx > lastIdx) lastIdx = idx;
    }
    if (lastIdx == -1) return text.trim();
    return text.substring(lastIdx + 1).trim();
  }

  /// Replaces the active segment after the last delimiter with the selected option.
  static String applySelection(String currentText, String selectedOption) {
    final delimiters = [';', '/', ','];
    int lastIdx = -1;
    for (final d in delimiters) {
      final idx = currentText.lastIndexOf(d);
      if (idx > lastIdx) lastIdx = idx;
    }
    if (lastIdx == -1) return selectedOption;
    final prefix = currentText.substring(0, lastIdx);
    final delimiterChar = currentText[lastIdx];
    final hasSpaceBefore = prefix.endsWith(' ');
    final cleanPrefix = prefix.trimRight();
    final leadSpace = hasSpaceBefore ? ' ' : '';
    return '$cleanPrefix$leadSpace$delimiterChar $selectedOption';
  }

  @override
  ConsumerState<DelimitedAutocompleteFormField> createState() =>
      _DelimitedAutocompleteFormFieldState();
}

class _DelimitedAutocompleteFormFieldState
    extends ConsumerState<DelimitedAutocompleteFormField> {
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    } else {
      _onTextChanged(widget.controller.text);
    }
  }

  Future<void> _onTextChanged(String text) async {
    final segment = DelimitedAutocompleteFormField.getCurrentQuerySegment(text);
    if (segment.isEmpty) {
      _removeOverlay();
      return;
    }

    final results = await widget.optionsBuilder(segment);
    if (!mounted || !_focusNode.hasFocus) return;

    setState(() {
      _options = results;
    });

    if (_options.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectOption(String option) {
    final newText = DelimitedAutocompleteFormField.applySelection(
      widget.controller.text,
      option,
    );
    widget.controller.text = newText;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
    _removeOverlay();
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _options.length,
                itemBuilder: (context, index) {
                  final option = _options[index];
                  return ListTile(
                    dense: true,
                    title: Text(option),
                    onTap: () => _selectOption(option),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: (val) {
          _onTextChanged(val);
        },
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: Icon(widget.icon),
          suffixIcon: widget.showHelp
              ? IconButton(
                  icon: const Icon(Icons.help_outline, size: 20),
                  tooltip: widget.helpTitle,
                  onPressed: () {
                    _showHelpDialog(context, widget.helpTitle, widget.helpContent);
                  },
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        validator: widget.required
            ? (v) => (v == null || v.trim().isEmpty) ? context.l10n.requiredField : null
            : null,
      ),
    );
  }

  void _showHelpDialog(BuildContext context, String? title, String? content) {
    if (title == null || content == null) return;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(dialogCtx).colorScheme.primary),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(context.l10n.done),
          ),
        ],
      ),
    );
  }
}

