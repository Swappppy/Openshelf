import 'dart:async';
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

  StreamSubscription<List<BookSearchResult>>? _streamSubscription;

  BookSearchController(this.ref) {
    titleController.addListener(notifyListeners);
    authorController.addListener(notifyListeners);
    publisherController.addListener(notifyListeners);
    isbnController.addListener(notifyListeners);
  }

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
    _streamSubscription?.cancel();
    titleController.clear();
    authorController.clear();
    publisherController.clear();
    isbnController.clear();
    _results = [];
    _searched = false;
    _error = null;
    _loading = false;
    notifyListeners();
  }

  void initQuery(String? initialQuery) {
    if (initialQuery != null && initialQuery.isNotEmpty && titleController.text.isEmpty) {
      titleController.text = initialQuery;
    }
  }

  Future<void> search(BuildContext context, {String? networkErrorMsg}) async {
    if (!hasAnyInput) return;

    _streamSubscription?.cancel();

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
    _results = [];
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

      final stream = BookSearchService.searchAllStructuredStream(
        searchQuery,
        servers: settings.searchServers,
        googleApiKey: settings.googleBooksApiKey,
        preferredLanguage: prefLang,
      );

      _streamSubscription = stream.listen(
        (partialResults) {
          _results = partialResults;
          notifyListeners();
        },
        onError: (e) {
          if (_results.isEmpty) {
            _error = defaultError;
          }
          _loading = false;
          notifyListeners();
        },
        onDone: () {
          _loading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      if (_results.isEmpty) {
        _error = defaultError;
      }
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    titleController.removeListener(notifyListeners);
    authorController.removeListener(notifyListeners);
    publisherController.removeListener(notifyListeners);
    isbnController.removeListener(notifyListeners);
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
