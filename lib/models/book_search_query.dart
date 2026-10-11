/// Represents a structured search query with field-specific parameters.
class BookSearchQuery {
  final String? title;
  final String? author;
  final String? publisher;
  final String? isbn;
  final String? rawQuery;

  const BookSearchQuery({
    this.title,
    this.author,
    this.publisher,
    this.isbn,
    this.rawQuery,
  });

  factory BookSearchQuery.fromRawQuery(String query) {
    final cleanIsbn = query.replaceAll(RegExp(r'[^0-9X]'), '');
    final isIsbn = (cleanIsbn.length == 10 || cleanIsbn.length == 13) &&
        RegExp(r'^[0-9]+X?$').hasMatch(cleanIsbn);

    if (isIsbn) {
      return BookSearchQuery(isbn: cleanIsbn, rawQuery: query);
    }
    return BookSearchQuery(rawQuery: query);
  }

  bool get hasIsbn => isbn != null && _cleanDigits(isbn!).isNotEmpty;
  bool get hasTitle => title != null && title!.trim().isNotEmpty;
  bool get hasAuthor => author != null && author!.trim().isNotEmpty;
  bool get isEmpty => !hasIsbn && !hasTitle && !hasAuthor && (rawQuery == null || rawQuery!.trim().isEmpty);

  static String _cleanDigits(String s) => s.replaceAll(RegExp(r'[^0-9X]'), '');
}

/// Represents a potential cover image found online.
class CoverCandidate {
  final String url;
  final String source;
  CoverCandidate({required this.url, required this.source});
}
