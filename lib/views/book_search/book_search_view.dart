import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/book_search_controller.dart';
import '../../l10n/l10n_extension.dart';
import 'widgets/book_search_body.dart';
import 'widgets/book_search_form.dart';

/// Screen for searching books across multiple online providers.
class BookSearchView extends ConsumerStatefulWidget {
  final String? initialQuery;
  const BookSearchView({super.key, this.initialQuery});

  @override
  ConsumerState<BookSearchView> createState() => _BookSearchViewState();
}

class _BookSearchViewState extends ConsumerState<BookSearchView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(bookSearchControllerProvider);
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        controller.initQuery(widget.initialQuery);
        controller.search(context, networkErrorMsg: context.l10n.bookSearchErrorNetwork);
      } else {
        controller.titleFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(bookSearchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.searchBook),
        actions: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (!controller.hasAnyInput) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: controller.clearAll,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          BookSearchForm(controller: controller),
          Expanded(child: BookSearchBody(controller: controller)),
        ],
      ),
    );
  }
}
