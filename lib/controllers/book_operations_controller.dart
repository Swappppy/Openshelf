import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';

/// Provider for handling complex book-related UI operations like duplication.
final bookOperationsProvider = Provider((ref) => BookOperationsController(ref));

class BookOperationsController {
  final Ref ref;
  BookOperationsController(this.ref);

  /// Performs the duplication logic in a transaction.
  Future<void> duplicate(int bookId) async {
    final db = ref.read(databaseProvider);
    await db.bookDao.duplicateBook(bookId);
  }
}
