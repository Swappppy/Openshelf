import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../l10n/l10n_extension.dart';
import '../models/book_search_result.dart';
import '../services/book_search_service.dart';
import '../services/database.dart';
import 'app_settings_controller.dart';
import 'database_provider.dart';

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

  void initStructuredQuery({
    String? query,
    String? title,
    String? author,
    String? publisher,
    String? isbn,
  }) {
    if (title != null && title.isNotEmpty && titleController.text.isEmpty) {
      titleController.text = title;
    }
    if (author != null && author.isNotEmpty && authorController.text.isEmpty) {
      authorController.text = author;
    }
    if (publisher != null && publisher.isNotEmpty && publisherController.text.isEmpty) {
      publisherController.text = publisher;
    }
    if (isbn != null && isbn.isNotEmpty && isbnController.text.isEmpty) {
      isbnController.text = isbn;
    }

    if (!hasAnyInput && query != null && query.trim().isNotEmpty) {
      initQuery(query);
    }
  }

  void initQuery(String? initialQuery) {
    if (initialQuery == null || initialQuery.trim().isEmpty) return;

    final cleanIsbn = initialQuery.replaceAll(RegExp(r'[^0-9X]'), '');
    final isIsbn = (cleanIsbn.length == 10 || cleanIsbn.length == 13) &&
        RegExp(r'^[0-9]+X?$').hasMatch(cleanIsbn);

    if (isIsbn) {
      if (isbnController.text.isEmpty) {
        isbnController.text = cleanIsbn;
      }
    } else {
      if (titleController.text.isEmpty) {
        titleController.text = initialQuery;
      }
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

      final cleanQuery = isbn.isNotEmpty
          ? isbn
          : (title.isNotEmpty
              ? title
              : (author.isNotEmpty ? author : publisher));

      final historyDao = ref.read(searchHistoryDaoProvider);
      final historyId = await historyDao.insertEntry(SearchHistoryCompanion.insert(
        query: cleanQuery,
        type: isbn.isNotEmpty ? 'isbn_scan' : 'text_search',
        status: 'pending',
        title: Value(title.isNotEmpty ? title : null),
        author: Value(author.isNotEmpty ? author : null),
        publisher: Value(publisher.isNotEmpty ? publisher : null),
        timestamp: DateTime.now(),
      ));

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
        onError: (e) async {
          if (_results.isEmpty) {
            _error = defaultError;
          }
          _loading = false;
          final entry = await (historyDao.select(historyDao.searchHistory)..where((h) => h.id.equals(historyId))).getSingleOrNull();
          if (entry != null) {
            await historyDao.updateEntry(entry.copyWith(status: 'failed'));
          }
          notifyListeners();
        },
        onDone: () async {
          _loading = false;
          final status = _results.isNotEmpty ? 'success' : 'failed';
          final entry = await (historyDao.select(historyDao.searchHistory)..where((h) => h.id.equals(historyId))).getSingleOrNull();
          if (entry != null) {
            await historyDao.updateEntry(entry.copyWith(status: status));
          }
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
