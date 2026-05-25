import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/app_settings_controller.dart';
import '../../../models/app_settings.dart';
import '../../../l10n/l10n_extension.dart';
import '../widgets/section_header.dart';

class SearchSection extends ConsumerWidget {
  const SearchSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchServers = ref.watch(appSettingsProvider.select((s) => s.searchServers));
    final googleBooksApiKey = ref.watch(appSettingsProvider.select((s) => s.googleBooksApiKey));
    final controller = ref.read(appSettingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(context.l10n.settingsSectionSearch),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.settingsSearchServer,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  context.l10n.settingsSearchServerHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 12),
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: (oldIndex, newIndex) {
                    final list = List<BookSearchServer>.from(searchServers);
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = list.removeAt(oldIndex);
                    list.insert(newIndex, item);
                    controller.setSearchServers(list);
                  },
                  children: searchServers.map((server) => ListTile(
                    key: ValueKey(server),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.drag_handle),
                    title: Text(_SearchServerHelper.label(context, server)),
                    subtitle: Text(_SearchServerHelper.url(server),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colorScheme.outline)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _GoogleBooksApiKeyCard(
          currentKey: googleBooksApiKey,
          onSave: (key) => controller.setGoogleBooksApiKey(key),
        ),
      ],
    );
  }
}

class _SearchServerHelper {
  static String label(BuildContext context, BookSearchServer server) {
    switch (server) {
      case BookSearchServer.openLibrary:
        return 'Open Library';
      case BookSearchServer.googleBooks:
        return 'Google Books';
      case BookSearchServer.inventaire:
        return 'Inventaire.io';
    }
  }

  static String url(BookSearchServer server) {
    switch (server) {
      case BookSearchServer.openLibrary:
        return 'openlibrary.org';
      case BookSearchServer.googleBooks:
        return 'books.googleapis.com';
      case BookSearchServer.inventaire:
        return 'inventaire.io';
    }
  }
}

class _GoogleBooksApiKeyCard extends StatefulWidget {
  final String? currentKey;
  final ValueChanged<String?> onSave;

  const _GoogleBooksApiKeyCard({
    required this.currentKey,
    required this.onSave,
  });

  @override
  State<_GoogleBooksApiKeyCard> createState() => _GoogleBooksApiKeyCardState();
}

class _GoogleBooksApiKeyCardState extends State<_GoogleBooksApiKeyCard> {
  late final TextEditingController _ctrl;
  bool _obscure = true;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentKey ?? '');
    _ctrl.addListener(() {
      final changed = _ctrl.text.trim() != (widget.currentKey ?? '');
      if (changed != _dirty) setState(() => _dirty = changed);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final value = _ctrl.text.trim().isEmpty ? null : _ctrl.text.trim();
    widget.onSave(value);
    setState(() => _dirty = false);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.settingsApiKeySaved)),
    );
  }

  void _showInstructions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        builder: (context, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
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
              context.l10n.settingsApiKeyInstructionsTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _Step(number: '1', text: context.l10n.settingsApiKeyStep1),
            _Step(number: '2', text: context.l10n.settingsApiKeyStep2),
            _Step(number: '3', text: context.l10n.settingsApiKeyStep3),
            _Step(number: '4', text: context.l10n.settingsApiKeyStep4),
            _Step(number: '5', text: context.l10n.settingsApiKeyStep5),
            _Step(number: '6', text: context.l10n.settingsApiKeyStep6),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.l10n.settingsApiKeyNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasKey = widget.currentKey != null && widget.currentKey!.isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(context.l10n.settingsApiKeyTitle,
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.help_outline, size: 16),
                  label: Text(context.l10n.settingsApiKeyHowTo),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: _showInstructions,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              hasKey
                  ? context.l10n.settingsApiKeyConfigured
                  : context.l10n.settingsApiKeyMissing,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: hasKey
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: context.l10n.settingsApiKeyHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    if (_ctrl.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _ctrl.clear();
                          widget.onSave(null);
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (_dirty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(context.l10n.settingsApiKeySave),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 12, top: 1),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
