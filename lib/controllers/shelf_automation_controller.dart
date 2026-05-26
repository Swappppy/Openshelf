import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:collection/collection.dart';
import '../services/database.dart';
import '../l10n/app_localizations.dart';
import 'database_provider.dart';
import 'app_settings_controller.dart';

/// Manages automatic creation and deletion of specialized shelves.
class ShelfAutomationController extends Notifier<void> {
  @override
  void build() {}

  Future<void> checkNoCoverShelf() async {
    final settings = ref.read(appSettingsProvider);
    final db = ref.read(databaseProvider);
    
    // Get localization for the shelf name
    final locale = settings.locale ?? const Locale('en');
    final l10n = await AppLocalizations.delegate.load(locale);
    final noCoverShelfName = l10n.noCoverShelfTitle;
    
    // 1. Get count of books without cover
    final noCoverBooks = await db.watchBooksFiltered(noCover: true).first;
    final hasNoCover = noCoverBooks.isNotEmpty;

    // 2. Find the shelf if it exists
    final allShelves = await db.select(db.shelves).get();
    final existingShelf = allShelves.firstWhereOrNull((s) => s.name == noCoverShelfName);

    if (settings.autoNoCoverShelf && hasNoCover) {
      if (existingShelf == null) {
        await db.insertShelf(ShelvesCompanion.insert(
          name: noCoverShelfName,
          filterNoCover: const Value(true),
        ));
      }
    } else if (existingShelf != null) {
      await db.deleteShelf(existingShelf.id);
    }
  }
}

final shelfAutomationProvider = NotifierProvider<ShelfAutomationController, void>(
  ShelfAutomationController.new,
);
