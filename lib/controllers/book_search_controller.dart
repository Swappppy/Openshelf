import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/l10n_extension.dart';
import '../models/book_search_result.dart';
import '../services/book_search_service.dart';
import 'app_settings_controller.dart';

final bookSearchControllerProvider =
    Provider.autoDispose((ref) => BookSearchController(ref));

class BookSearchController extends ChangeNotifier {
  final Ref ref;

  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final publisherController = TextEditingController();
  final isbnController = TextEditingController();

  final titleFocusNode = FocusNode();
  final authorFocusNode = FocusNode();
  final publisherFocusNode = FocusNode();
  final isbnFocusNode = FocusNode();

  List<BookSearchResult> _results = [];
  bool _loading = false;
  String? _error;
  bool _searched = false;

  BookSearchController(this.ref);

  List<BookSearchResult> get results => _results;
  bool get loading => _loading;
  String? get error => _error;
  bool get searched => _searched;

  bool get hasAnyInput =>
      titleController.text.trim().isNotEmpty ||
      authorController.text.trim().isNotEmpty ||
      publisherController.text.trim().isNotEmpty ||
      isbnController.text.trim().isNotEmpty;

  void clearAll() {
    titleController.clear();
    authorController.clear();
    publisherController.clear();
    isbnController.clear();
    _results = [];
    _searched = false;
    _error = null;
    notifyListeners();
  }

  void initQuery(String? initialQuery) {
    if (initialQuery != null && initialQuery.isNotEmpty && titleController.text.isEmpty) {
      titleController.text = initialQuery;
    }
  }

  Future<void> search(BuildContext context, {String? networkErrorMsg}) async {
    if (!hasAnyInput) return;

    final defaultError = networkErrorMsg ?? context.l10n.bookSearchErrorNetwork;
    final prefLang = ref.read(appSettingsProvider).locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    titleFocusNode.unfocus();
    authorFocusNode.unfocus();
    publisherFocusNode.unfocus();
    isbnFocusNode.unfocus();

    _loading = true;
    _error = null;
    _searched = true;
    notifyListeners();

    try {
      final settings = ref.read(appSettingsProvider);

      final title = titleController.text.trim();
      final author = authorController.text.trim();
      final publisher = publisherController.text.trim();
      final isbn = isbnController.text.trim();

      final searchQuery = BookSearchQuery(
        title: title.isNotEmpty ? title : null,
        author: author.isNotEmpty ? author : null,
        publisher: publisher.isNotEmpty ? publisher : null,
        isbn: isbn.isNotEmpty ? isbn : null,
      );

      final searchResults = await BookSearchService.searchAllStructured(
        searchQuery,
        servers: settings.searchServers,
        googleApiKey: settings.googleBooksApiKey,
        preferredLanguage: prefLang,
      );

      _results = searchResults;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = defaultError;
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    publisherController.dispose();
    isbnController.dispose();
    titleFocusNode.dispose();
    authorFocusNode.dispose();
    publisherFocusNode.dispose();
    isbnFocusNode.dispose();
    super.dispose();
  }
}
