import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';

import '../../../l10n/l10n_extension.dart';
import '../../../services/database.dart';
import '../../book_form/widgets/form_components.dart';

/// Bottom sheet to edit an ownership history entry: type, person and date.
/// Returns the edited entry, or null when cancelled.
class OwnershipEventSheet extends StatefulWidget {
  final OwnershipLogData entry;

  const OwnershipEventSheet({super.key, required this.entry});

  static Future<OwnershipLogData?> show(BuildContext context, OwnershipLogData entry) {
    return showModalBottomSheet<OwnershipLogData>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => OwnershipEventSheet(entry: entry),
    );
  }

  @override
  State<OwnershipEventSheet> createState() => _OwnershipEventSheetState();
}

class _OwnershipEventSheetState extends State<OwnershipEventSheet> {
  late OwnershipStatus _type = widget.entry.eventType;
  late DateTime _date = widget.entry.date;
  late final TextEditingController _personCtrl = TextEditingController(text: widget.entry.personName ?? '');

  @override
  void dispose() {
    _personCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    // Keep the original time of day so ordering among same-day entries holds.
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute, _date.second));
    }
  }

  void _save() {
    final person = _personCtrl.text.trim();
    Navigator.pop(
      context,
      widget.entry.copyWith(
        eventType: _type,
        date: _date,
        personName: Value(person.isEmpty ? null : person),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16, 16, 16,
        MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.ownershipHistoryTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          OwnershipStatusSelector(
            selected: _type,
            // An entry always has a type: tapping the selected chip keeps it.
            onChanged: (s) => setState(() => _type = s ?? _type),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _personCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.ownershipEventPerson,
              prefixIcon: const Icon(Icons.person_outline),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(l10n.ownershipEventDate),
            subtitle: Text(DateFormat.yMd(locale).format(_date)),
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
              const SizedBox(width: 8),
              FilledButton(onPressed: _save, child: Text(l10n.save)),
            ],
          ),
        ],
      ),
    );
  }
}
