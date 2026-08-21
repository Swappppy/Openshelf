import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
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
    try {
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
    } catch (e) {
      debugPrint('BookFormController: Error picking cover from gallery: $e');
      rethrow;
    }
    return null;
  }

  Future<String?> takePhoto({
    required String cropTitle,
    required String doneTitle,
    required String cancelTitle,
  }) async {
    try {
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
    } catch (e) {
      debugPrint('BookFormController: Error taking photo: $e');
      rethrow;
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
    required String title,
    required String? subtitle,
    required String? author,
    required String? isbn,
    required String? publisher,
    required int totalPages,
    required int currentPage,
    required ReadingStatus status,
    required OwnershipStatus? ownershipStatus,
    required BookFormat? format,
    required double? rating,
    required String? notes,
    required String? description,
    required String? coverPath,
    required int? collectionId,
    required String? collectionName,
    required int? collectionNumber,
    required int? publishYear,
    String? translator,
    String? originalTitle,
    String? originalLanguage,
    required int copies,
    required PaginationConfig? paginationConfig,
    required DateTime? startedAt,
    required DateTime? finishedAt,
    required int? imprintId,
    required List<int> tagIds,
    required List<(int, int?)> collections,
    required String? personName,
    required String unknownAuthorLabel,
  }) async {
    // 1. Sanitize Pagination Config
    PaginationConfig? finalConfig = paginationConfig;
    if (finalConfig != null && finalConfig.segments.isNotEmpty) {
      final List<PaginationSegment> sanitizedSegments = [];
      for (final s in finalConfig.segments) {
        if (s.startPhysical > totalPages) continue;
        sanitizedSegments.add(s.copyWith(
          endPhysical: s.endPhysical > totalPages ? totalPages : s.endPhysical,
        ));
        if (sanitizedSegments.last.endPhysical == totalPages) break;
      }
      if (sanitizedSegments.isNotEmpty && sanitizedSegments.last.endPhysical < totalPages) {
        final last = sanitizedSegments.removeLast();
        sanitizedSegments.add(last.copyWith(endPhysical: totalPages));
      }
      finalConfig = PaginationConfig(
        segments: sanitizedSegments,
        markers: finalConfig.markers.where((m) => m.physicalPage <= totalPages).toList(),
        useVisualMode: finalConfig.useVisualMode,
      );
    }

    final companion = BooksCompanion(
      title: Value(title),
      subtitle: Value(subtitle),
      author: Value(author == null || author.isEmpty ? unknownAuthorLabel : author),
      isbn: Value(isbn),
      publisher: Value(publisher),
      totalPages: Value(totalPages),
      currentPage: Value(currentPage),
      status: Value(status),
      ownershipStatus: Value(ownershipStatus),
      bookFormat: Value(format),
      rating: Value(rating),
      notes: Value(notes),
      description: Value(description),
      coverPath: Value(coverPath),
      collectionName: Value(collectionName),
      collectionId: Value(collectionId),
      collectionNumber: Value(collectionNumber),
      publishYear: Value(publishYear),
      translator: Value(translator),
      originalTitle: Value(originalTitle),
      originalLanguage: Value(originalLanguage),
      copies: Value(copies),
      paginationConfig: Value(finalConfig),
      startedAt: Value(startedAt),
      finishedAt: Value(finishedAt),
      imprintId: Value(imprintId),
    );

    int bookId;
    if (existingBook != null) {
      bookId = existingBook.id;
      await (_db.update(_db.books)..where((b) => b.id.equals(bookId))).write(companion);

      if (currentPage > (existingBook.currentPage ?? 0)) {
        await ref.read(readingLogControllerProvider.notifier).logPages(bookId, currentPage - (existingBook.currentPage ?? 0));
      }

      // Sync with ReadHistory
      final history = await (_db.select(_db.readHistory)..where((h) => h.bookId.equals(bookId))).get();
      final completedReads = history.where((h) => h.finishedAt != null).length;
      final activeSessionNum = PaginationHelper.getActiveSessionNumber(status, completedReads);
      final activeSession = history.firstWhereOrNull((h) => h.readNumber == activeSessionNum);

      if (activeSession != null) {
        await _db.readHistoryDao.updateRead(activeSession.copyWith(
          progress: currentPage,
          finishedAt: Value(finishedAt),
          startedAt: Value(startedAt),
        ));
      } else if (status == ReadingStatus.reading || currentPage > 0 || status == ReadingStatus.read) {
        await _db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
          bookId: bookId,
          readNumber: activeSessionNum,
          startedAt: Value(startedAt ?? DateTime.now()),
          finishedAt: Value(finishedAt),
          progress: Value(currentPage),
        ));
      }

      // Sync with OwnershipLog
      if (ownershipStatus != null && ownershipStatus != existingBook.ownershipStatus) {
        await _db.ownershipDao.insertEvent(OwnershipLogCompanion.insert(
          bookId: bookId,
          eventType: ownershipStatus,
          personName: Value(personName),
          date: DateTime.now(),
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
      } else if (currentPage > 0 || status == ReadingStatus.reading) {
        await _db.readHistoryDao.insertRead(ReadHistoryCompanion.insert(
          bookId: bookId,
          readNumber: 1,
          startedAt: Value(startedAt ?? DateTime.now()),
          progress: Value(currentPage),
        ));
      }

      if (ownershipStatus != null) {
        await _db.ownershipDao.insertEvent(OwnershipLogCompanion.insert(
          bookId: bookId,
          eventType: ownershipStatus,
          personName: Value(personName),
          date: DateTime.now(),
        ));
      }

      if (currentPage > 0) {
        await ref.read(readingLogControllerProvider.notifier).logPages(bookId, currentPage);
      }
    }

    await _db.tagDao.setBookTags(bookId, tagIds, collections: collections);
    await _db.tagDao.pruneOrphanTags();
    ref.read(shelfAutomationProvider.notifier).checkNoCoverShelf();

    return bookId;
  }
}
