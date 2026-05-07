import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import 'database_provider.dart';

// Stream de todos los libros
final allBooksProvider = StreamProvider<List<Book>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllBooks();
});

// Stream por estado
final booksByStatusProvider =
StreamProvider.family<List<Book>, ReadingStatus>((ref, status) {
  final db = ref.watch(databaseProvider);
  return db.watchBooksByStatus(status);
});

// Conteo por estado (para las estanterías)
final bookCountByStatusProvider =
Provider.family<AsyncValue<int>, ReadingStatus>((ref, status) {
  return ref.watch(booksByStatusProvider(status)).whenData((books) => books.length);
});

final bookByIdProvider = StreamProvider.family<Book?, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return db.watchBookById(id);
});

final bookTagsProvider = StreamProvider.family<List<Tag>, int>((ref, bookId) {
  return ref.watch(databaseProvider).watchTagsForBook(bookId);
});

final allTagsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).watchTagsByType('tag');
});

final allImprintsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).watchTagsByType('imprint');
});

final allCollectionsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(databaseProvider).watchTagsByType('collection');
});

final bookImprintProvider = StreamProvider.family<Tag?, int>((ref, bookId) {
  return ref.watch(databaseProvider).watchImprintForBook(bookId);
});