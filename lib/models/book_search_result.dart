class BookSearchResult {
  final String title;
  final String author;
  final String? isbn;
  final String? publisher;
  final int? publishYear;
  final int? totalPages;
  final String? coverUrl;
  final String? openLibraryKey;

  const BookSearchResult({
    required this.title,
    required this.author,
    this.isbn,
    this.publisher,
    this.publishYear,
    this.totalPages,
    this.coverUrl,
    this.openLibraryKey,
  });

  factory BookSearchResult.fromOpenLibraryDoc(Map<String, dynamic> doc) {
    final authors = doc['author_name'];
    final isbns = doc['isbn'];
    final publishers = doc['publisher'];
    final coverId = doc['cover_i'];

    return BookSearchResult(
      title: doc['title'] as String? ?? '',
      author: (authors is List && authors.isNotEmpty)
          ? authors.first as String
          : '',
      isbn: (isbns is List && isbns.isNotEmpty) ? isbns.first as String : null,
      publisher: (publishers is List && publishers.isNotEmpty)
          ? publishers.first as String
          : null,
      publishYear: doc['first_publish_year'] as int?,
      totalPages: doc['number_of_pages_median'] as int?,
      coverUrl: coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
          : null,
      openLibraryKey: doc['key'] as String?,
    );
  }
}