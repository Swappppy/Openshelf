class Book {
  final int? id;
  final String title;
  final String author;
  final String? isbn;
  final String? publisher;
  final String? coverUrl;
  final int? totalPages;
  final int? currentPage;
  final ReadingStatus status;
  final double? rating;
  final String? notes;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime? createdAt;
  final bool isDigital;

  const Book({
    this.id,
    required this.title,
    required this.author,
    this.isbn,
    this.publisher,
    this.coverUrl,
    this.totalPages,
    this.currentPage,
    this.status = ReadingStatus.wantToRead,
    this.rating,
    this.notes,
    this.startedAt,
    this.finishedAt,
    this.createdAt,
    this.isDigital = false,
  });
}

enum ReadingStatus {
  wantToRead,
  reading,
  read,
  abandoned,
}