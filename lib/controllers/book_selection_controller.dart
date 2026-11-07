import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages multi-selection state (set of selected book IDs) across library and shelf views.
class BookSelectionController extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    return const {};
  }

  /// Toggles selection state for a specific book ID.
  void toggle(int bookId) {
    if (state.contains(bookId)) {
      state = Set.unmodifiable({...state}..remove(bookId));
    } else {
      state = Set.unmodifiable({...state, bookId});
    }
  }

  /// Explicitly selects a book ID.
  void select(int bookId) {
    if (!state.contains(bookId)) {
      state = Set.unmodifiable({...state, bookId});
    }
  }

  /// Explicitly deselects a book ID.
  void deselect(int bookId) {
    if (state.contains(bookId)) {
      state = Set.unmodifiable({...state}..remove(bookId));
    }
  }

  /// Toggles selection between all provided book IDs and none.
  void toggleAll(List<int> bookIds) {
    if (bookIds.isEmpty) return;
    final allSelected = bookIds.every((id) => state.contains(id));
    if (allSelected) {
      state = Set.unmodifiable({...state}..removeAll(bookIds));
    } else {
      state = Set.unmodifiable({...state, ...bookIds});
    }
  }

  /// Selects all provided book IDs.
  void selectAll(List<int> bookIds) {
    if (bookIds.isEmpty) return;
    state = Set.unmodifiable({...state, ...bookIds});
  }

  /// Clears all selections.
  void clear() {
    if (state.isNotEmpty) {
      state = const {};
    }
  }
}

final bookSelectionProvider =
    NotifierProvider<BookSelectionController, Set<int>>(
  BookSelectionController.new,
);
