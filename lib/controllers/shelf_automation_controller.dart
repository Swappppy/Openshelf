import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../services/database.dart';
import 'database_provider.dart';
import 'app_settings_controller.dart';
import 'books_controller.dart';

/// Gestiona la creación y eliminación automática de la estantería de libros sin portada.
class ShelfAutomationController extends Notifier<void> {
  static const String internalName = '__auto_no_cover__';
  bool _isChecking = false;
  bool _pendingCheck = false;

  @override
  void build() {
    // Observamos los factores que activan la automatización
    // Usamos watch para reaccionar a cambios, pero controlamos la ejecución
    ref.watch(appSettingsProvider.select((s) => s.autoNoCoverShelf));
    final booksAsync = ref.watch(allBooksProvider);

    // Solo disparamos si tenemos datos válidos y no hay una ejecución en curso
    if (booksAsync.hasValue && booksAsync.value != null) {
      // Usamos un microtask para no bloquear el build actual
      Future.microtask(() => checkNoCoverShelf());
    }
  }

  Future<void> checkNoCoverShelf() async {
    // Si ya estamos comprobando, marcamos como pendiente para re-ejecutar al terminar
    if (_isChecking) {
      _pendingCheck = true;
      return;
    }
    
    _isChecking = true;
    _pendingCheck = false;

    try {
      final settings = ref.read(appSettingsProvider);
      final db = ref.read(databaseProvider);
      
      // Obtenemos el valor actual de los libros
      final books = ref.read(allBooksProvider).value;
      if (books == null) return;

      final autoShelf = await db.shelfDao.getShelfByName(internalName);

      if (settings.autoNoCoverShelf) {
        final noCoverBooks = books.where((b) => 
          (b.coverPath == null || b.coverPath!.isEmpty) && 
          (b.coverUrl == null || b.coverUrl!.isEmpty)
        ).toList();

        final hasNoCover = noCoverBooks.isNotEmpty;

        if (hasNoCover) {
          if (autoShelf == null) {
            await db.shelfDao.insertShelf(ShelvesCompanion.insert(
              name: internalName,
              filterNoCover: const Value(true),
            ));
            debugPrint('ShelfAutomation: Created auto-shelf for ${noCoverBooks.length} books.');
          } else if (!autoShelf.filterNoCover) {
            await db.shelfDao.updateShelf(autoShelf.copyWith(filterNoCover: true));
          }
        } else {
          if (autoShelf != null) {
            await db.shelfDao.deleteShelf(autoShelf.id);
            debugPrint('ShelfAutomation: Deleted auto-shelf (all books have covers).');
          }
        }
      } else {
        if (autoShelf != null) {
          await db.shelfDao.deleteShelf(autoShelf.id);
          debugPrint('ShelfAutomation: Deleted auto-shelf (settings disabled).');
        }
      }
    } catch (e, stack) {
      debugPrint('ShelfAutomation error: $e\n$stack');
    } finally {
      // Pequeña espera para evitar saturar el loop de microtasks en cambios masivos
      await Future.delayed(const Duration(milliseconds: 100));
      _isChecking = false;
      
      // Si hubo cambios mientras procesábamos, volvemos a comprobar
      if (_pendingCheck) {
        checkNoCoverShelf();
      }
    }
  }
}

final shelfAutomationProvider = NotifierProvider<ShelfAutomationController, void>(
  ShelfAutomationController.new,
);
