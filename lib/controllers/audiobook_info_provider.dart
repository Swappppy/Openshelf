import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import 'database_provider.dart';

/// Audio data of one book (null when it has none).
final audiobookInfoProvider = StreamProvider.family<AudiobookInfoData?, int>((ref, bookId) {
  return ref.watch(databaseProvider).audiobookInfoDao.watchForBook(bookId);
});
