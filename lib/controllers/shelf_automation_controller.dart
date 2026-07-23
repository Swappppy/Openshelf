import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../services/database.dart';
import 'database_provider.dart';
import 'app_settings_controller.dart';

/// Manages automatic creation and deletion of specialized shelves.
class ShelfAutomationController extends Notifier<void> {
  bool _isChecking = false;
  static const String internalName = '__auto_no_cover__';

  @override
  void build() {
    // We only need to listen to the automation toggle now.
    // The localized display name is handled in the UI layer.
    ref.listen(appSettingsProvider.select((s) => s.autoNoCoverShelf), (prev, next) {
      if (prev != next) {
        checkNoCoverShelf();
      }
    });

    // Run once on startup to ensure migration and cleanup
    Future.microtask(() => checkNoCoverShelf());
  }

  Future<void> checkNoCoverShelf() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final settings = ref.read(appSettingsProvider);
      final db = ref.read(databaseProvider);
      
      // 1. Get count of books without cover
      final noCoverBooks = await db.bookDao.watchBooksFiltered(noCover: true).first;
      final hasNoCover = noCoverBooks.isNotEmpty;

      // 2. Find all potential "No cover" shelves (flagged, named, or legacy names)
      final allShelves = await db.select(db.shelves).get();
      
      final legacyNames = {
        'Libros sin portada',
        'Books without cover',
        'Estantería sin portadas',
        'No cover shelf',
        'Llibres sense portada',
        'Bücher ohne Cover',
        'Ilma kaaneta raamatud',
        'Livres sans couverture',
        'Libri senza copertina',
        '表紙のない本',
        'Cărți fără copertă',
        'Книги без обложки',
      };

      final candidates = allShelves.where((s) {
        if (s.name == internalName) return true;
        if (s.filterNoCover == true) return true;
        final trimmedName = s.name.trim();
        return legacyNames.contains(trimmedName);
      }).toList();

      // Sort by ID to keep the oldest one
      candidates.sort((a, b) => a.id.compareTo(b.id));

      if (settings.autoNoCoverShelf && hasNoCover) {
        if (candidates.isEmpty) {
          // Create new with fixed internal name
          await db.shelfDao.insertShelf(ShelvesCompanion.insert(
            name: internalName,
            filterNoCover: const Value(true),
          ));
          debugPrint('ShelfAutomation: Created internal "No Cover" shelf');
        } else {
          // Use the oldest one and migrate it to internal name
          final primary = candidates.first;
          
          if (primary.name != internalName || primary.filterNoCover != true) {
            await db.shelfDao.updateShelf(primary.copyWith(
              name: internalName,
              filterNoCover: true,
            ));
            debugPrint('ShelfAutomation: Migrated shelf ${primary.id} ("${primary.name}") to internal name');
          }
          
          // Delete all other duplicates
          for (int i = 1; i < candidates.length; i++) {
            await db.shelfDao.deleteShelf(candidates[i].id);
            debugPrint('ShelfAutomation: Deleted duplicate shelf ${candidates[i].id} ("${candidates[i].name}")');
          }
        }
      } else {
        // Delete all if feature disabled or no books
        for (final s in candidates) {
          await db.shelfDao.deleteShelf(s.id);
          debugPrint('ShelfAutomation: Removed shelf ${s.id} ("${s.name}")');
        }
      }
    } catch (e, stack) {
      debugPrint('ShelfAutomation error: $e\n$stack');
    } finally {
      _isChecking = false;
    }
  }
}

final shelfAutomationProvider = NotifierProvider<ShelfAutomationController, void>(
  ShelfAutomationController.new,
);
