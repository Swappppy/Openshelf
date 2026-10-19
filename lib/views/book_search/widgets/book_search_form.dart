import 'package:flutter/material.dart';
import '../../../controllers/book_search_controller.dart';
import '../../../l10n/l10n_extension.dart';
import '../../barcode_scanner/barcode_scanner_view.dart';

/// Form inputs for searching books by Title, Author, Publisher, and ISBN matching the target design.
class BookSearchForm extends StatefulWidget {
  final BookSearchController controller;

  const BookSearchForm({super.key, required this.controller});

  @override
  State<BookSearchForm> createState() => _BookSearchFormState();
}

class _BookSearchFormState extends State<BookSearchForm> {
  bool _isbnActive = false;
  bool _publisherActive = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    if (widget.controller.publisherController.text.isNotEmpty) {
      _publisherActive = true;
    }
    if (widget.controller.isbnController.text.isNotEmpty) {
      _isbnActive = true;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.controller.publisherController.text.isNotEmpty && !_publisherActive) {
      setState(() {
        _publisherActive = true;
      });
    }
    if (widget.controller.isbnController.text.isNotEmpty && !_isbnActive) {
      setState(() {
        _isbnActive = true;
      });
    }
    setState(() {});
  }

  bool _isValidIsbn(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9X]'), '');
    return clean.length == 10 || clean.length == 13;
  }

  String? _isbnError(String text, BuildContext context) {
    final clean = text.trim();
    if (clean.isEmpty) return null;
    final digitsAndX = clean.replaceAll(RegExp(r'[^0-9X]'), '');
    if (digitsAndX.length != 10 && digitsAndX.length != 13) {
      return context.l10n.requiredField;
    }
    return null;
  }

  void _triggerSearch(BuildContext context) {
    widget.controller.search(context, networkErrorMsg: context.l10n.bookSearchErrorNetwork);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasInput = widget.controller.hasAnyInput;
    final isbnText = widget.controller.isbnController.text.trim();
    final isIsbnValid = _isValidIsbn(isbnText);

    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final maxHeight = keyboardVisible ? 200.0 : MediaQuery.of(context).size.height * 0.45;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Title Field (Attenuated if ISBN valid)
              Opacity(
                opacity: isIsbnValid ? 0.4 : 1.0,
                child: IgnorePointer(
                  ignoring: isIsbnValid,
                  child: TextField(
                    controller: widget.controller.titleController,
                    focusNode: widget.controller.titleFocusNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => widget.controller.authorFocusNode.requestFocus(),
                    decoration: InputDecoration(
                      labelText: context.l10n.fieldTitle,
                      prefixIcon: const Icon(Icons.title, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // 2. Author Field (Attenuated if ISBN valid)
              Opacity(
                opacity: isIsbnValid ? 0.4 : 1.0,
                child: IgnorePointer(
                  ignoring: isIsbnValid,
                  child: TextField(
                    controller: widget.controller.authorController,
                    focusNode: widget.controller.authorFocusNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      if (_isbnActive) {
                        widget.controller.isbnFocusNode.requestFocus();
                      } else if (_publisherActive) {
                        widget.controller.publisherFocusNode.requestFocus();
                      } else {
                        _triggerSearch(context);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: context.l10n.fieldAuthor,
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // 3. ISBN Field with Outlined Camera Button on Left and Outlined Close Button on Right
              if (_isbnActive) ...[
                Row(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () async {
                          final code = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BarcodeScannerView(),
                            ),
                          );
                          if (!context.mounted) return;
                          if (code != null && code.isNotEmpty) {
                            widget.controller.isbnController.text = code;
                            _triggerSearch(context);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
                        ),
                        child: const Icon(Icons.qr_code_scanner, size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: widget.controller.isbnController,
                        focusNode: widget.controller.isbnFocusNode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _triggerSearch(context),
                        decoration: InputDecoration(
                          labelText: context.l10n.fieldIsbn,
                          isDense: true,
                          errorText: _isbnError(isbnText, context),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          widget.controller.isbnController.clear();
                          setState(() {
                            _isbnActive = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],

              // 4. Editorial Field with Outlined Close Button on Right (if active)
              if (_publisherActive) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller.publisherController,
                        focusNode: widget.controller.publisherFocusNode,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _triggerSearch(context),
                        decoration: InputDecoration(
                          labelText: context.l10n.fieldPublisher,
                          prefixIcon: const Icon(Icons.business_outlined, size: 20),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          widget.controller.publisherController.clear();
                          setState(() {
                            _publisherActive = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],

              // 5. Chips always below the fields (with compact visual density and minimal spacing)
              if (!_isbnActive || !_publisherActive) ...[
                const SizedBox(height: 2),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (!_isbnActive)
                      ActionChip(
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        avatar: const Icon(Icons.qr_code_scanner, size: 16),
                        label: Text(context.l10n.fieldIsbn),
                        onPressed: () {
                          setState(() {
                            _isbnActive = true;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            widget.controller.isbnFocusNode.requestFocus();
                          });
                        },
                      ),
                    if (!_publisherActive)
                      ActionChip(
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        avatar: const Icon(Icons.business_outlined, size: 16),
                        label: Text(context.l10n.fieldPublisher),
                        onPressed: () {
                          setState(() {
                            _publisherActive = true;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            widget.controller.publisherFocusNode.requestFocus();
                          });
                        },
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 8),

              // Action Buttons: Limpiar todo and Buscar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: hasInput
                        ? () {
                            widget.controller.clearAll();
                            setState(() {
                              _isbnActive = false;
                              _publisherActive = false;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: Text(context.l10n.searchClearAll),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: hasInput ? () => _triggerSearch(context) : null,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(context.l10n.coverSearch),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
