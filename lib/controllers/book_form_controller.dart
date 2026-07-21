import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collection/collection.dart';
import '../services/database.dart';
import '../services/cover_service.dart';
import '../services/permission_service.dart';
import 'database_provider.dart';
import 'shelf_automation_controller.dart';
import 'reading_log_controller.dart';
import '../utils/pagination_helper.dart';

final bookFormControllerProvider = Provider((ref) => BookFormController(ref));

class BookFormController {
  final Ref ref;
  BookFormController(this.ref);

  AppDatabase get _db => ref.read(databaseProvider);

  Future<String?> pickCoverFromGallery({
    required String cropTitle,
    required String doneTitle,
    required String cancelTitle,
  }) async {
    final result = await PermissionService.requestGallery();
    if (result != GalleryPermissionResult.granted) return null;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    final cropped = await CoverService.cropCover(
      picked.path,
      title: cropTitle,
      doneButtonTitle: doneTitle,
      cancelButtonTitle: cancelTitle,
    );

    if (cropped != null) {
      return await CoverService.saveLocalCover(cropped);
    }
    return null;
  }

  Future<String?> takePhoto({
    required String cropTitle,
    required String doneTitle,
    required String cancelTitle,
  }) async {
    final granted = await PermissionService.requestCamera();
    if (!granted) return null;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return null;

    final cropped = await CoverService.cropCover(
      picked.path,
      title: cropTitle,
      doneButtonTitle: doneTitle,
      cancelButtonTitle: cancelTitle,
    );

    if (cropped != null) {
      return await CoverService.saveLocalCover(cropped);
    }
    return null;
  }

  Future<String?> downloadCover(String url, {
    required String cropTitle,
    required String doneTitle,
    required String cancelTitle,
  }) async {
    return await CoverService.saveCoverFromUrl(
      url,
      cropTitle: cropTitle,
      doneButtonTitle: doneTitle,
      cancelButtonTitle: cancelTitle,
    );
  }

  Future<int> saveBook({
    Book? existingBook,
    required BooksCompanion companion,
    required List<int> tagIds,
    required int? newPage,
    required int? oldPage,
    required ReadingStatus status,
    required int totalPages,
    required DateTime? startedAt,
    required DateTime? finishedAt,
  }) async {
    int bookId;
    if (existingBook != null) {
      bookId = existingBook.id;
      await (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(companion);

      if (newPage != null && oldPage != null && newPage > oldPage) {
        await ref.read(readingLogControllerProvider.notifier).logPages(bookId, newPage - oldPage);
      }

      // Sync with ReadHistory
      final history = await _db.readHistoryDao.watchHistoryForBook(bookId).first;
      final completedReads = history.where((h) => h.finishedAt != null).length;
      final activeSessionNum = PaginationHelper.getActiveSessionNumber(status, completedReads);
      final activeSession = history.firstWhereOrNull((h) => h.readNumber == activeSessionNum);

      if (activeSession != null) {
        await _db.readHistoryDao.updateRead(activeSession.copyWith(
          progress: newPage ?? 0,
          finishedAt: Value(finishedAt),
          startedAt: Value(startedAt),
        ));
      } else if (status == ReadingStatus.reading || (newPage ?? 0) > 0 || status == ReadingStatus.read) {
        await _db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
          bookId: bookId,
          readNumber: activeSessionNum,
          startedAt: Value(startedAt ?? DateTime.now()),
          finishedAt: Value(finishedAt),
          progress: Value(newPage ?? 0),
        ));
      }
    } else {
      bookId = await _db.bookDao.insertBook(companion);
      
      if (status == ReadingStatus.read) {
        await _db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
          bookId: bookId,
          readNumber: 1,
          startedAt: Value(startedAt ?? DateTime.now()),
          finishedAt: Value(finishedAt ?? DateTime.now()),
          progress: Value(totalPages),
        ));
      } else if ((newPage ?? 0) > 0 || status == ReadingStatus.reading) {
        await _db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
          bookId: bookId,
          readNumber: 1,
          startedAt: Value(startedAt ?? DateTime.now()),
          progress: Value(newPage ?? 0),
        ));
      }

      if ((newPage ?? 0) > 0) {
        await ref.read(readingLogControllerProvider.notifier).logPages(bookId, newPage!);
      }
    }

    await _db.tagDao.setBookTags(bookId, tagIds);
    await _db.tagDao.pruneOrphanTags();
    ref.read(shelfAutomationProvider.notifier).checkNoCoverShelf();

    return bookId;
  }
}
