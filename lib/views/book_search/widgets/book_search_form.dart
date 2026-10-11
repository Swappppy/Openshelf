import 'package:flutter/material.dart';
import '../../../controllers/book_search_controller.dart';
import '../../../l10n/l10n_extension.dart';

/// Form inputs for searching books by Title, Author, Publisher, and ISBN.
class BookSearchForm extends StatelessWidget {
  final BookSearchController controller;

  const BookSearchForm({super.key, required this.controller});

  void _triggerSearch(BuildContext context) {
    controller.search(context, networkErrorMsg: context.l10n.bookSearchErrorNetwork);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final hasInput = controller.hasAnyInput;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Line 1: Title
              TextField(
                controller: controller.titleController,
                focusNode: controller.titleFocusNode,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => controller.authorFocusNode.requestFocus(),
                decoration: InputDecoration(
                  labelText: context.l10n.fieldTitle,
                  prefixIcon: const Icon(Icons.title, size: 20),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: controller.titleController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            controller.titleController.clear();
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),

              // Line 2: Author
              TextField(
                controller: controller.authorController,
                focusNode: controller.authorFocusNode,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => controller.publisherFocusNode.requestFocus(),
                decoration: InputDecoration(
                  labelText: context.l10n.fieldAuthor,
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: controller.authorController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            controller.authorController.clear();
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),

              // Line 3: Publisher & ISBN
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.publisherController,
                      focusNode: controller.publisherFocusNode,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => controller.isbnFocusNode.requestFocus(),
                      decoration: InputDecoration(
                        labelText: context.l10n.fieldPublisher,
                        prefixIcon: const Icon(Icons.business_outlined, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixIcon: controller.publisherController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  controller.publisherController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller.isbnController,
                      focusNode: controller.isbnFocusNode,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _triggerSearch(context),
                      decoration: InputDecoration(
                        labelText: context.l10n.fieldIsbn,
                        prefixIcon: const Icon(Icons.qr_code_outlined, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixIcon: controller.isbnController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  controller.isbnController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (hasInput)
                    TextButton.icon(
                      onPressed: controller.clearAll,
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: Text(context.l10n.searchClearAll),
                    ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: hasInput ? () => _triggerSearch(context) : null,
                    icon: const Icon(Icons.search, size: 18),
                    label: Text(context.l10n.searchBook),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
