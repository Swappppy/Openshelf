import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/display_preferences.dart';

/// Manages user preferences for the Library view, including layout and sorting.
class DisplayPreferencesController extends Notifier<DisplayPreferences> {
  @override
  DisplayPreferences build() => const DisplayPreferences();

  void toggleViewMode() {
    state = state.copyWith(
      viewMode: state.viewMode == LibraryViewMode.list
          ? LibraryViewMode.grid
          : LibraryViewMode.list,
    );
  }

  void toggleShowProgress() =>
      state = state.copyWith(showProgress: !state.showProgress);
  void toggleShowTags() =>
      state = state.copyWith(showTags: !state.showTags);
  void toggleShowRating() =>
      state = state.copyWith(showRating: !state.showRating);
  void toggleShowAuthor() =>
      state = state.copyWith(showAuthor: !state.showAuthor);
  void toggleShowStatusChip() =>
      state = state.copyWith(showStatusChip: !state.showStatusChip);
  void toggleShowPublisher() =>
      state = state.copyWith(showPublisher: !state.showPublisher);
  void toggleShowYear() =>
      state = state.copyWith(showYear: !state.showYear);
  void toggleShowSpacer() =>
      state = state.copyWith(showSpacer: !state.showSpacer);

  /// Changes the order of fields displayed in the Library tiles.
  void reorderFields(int oldIndex, int newIndex) {
    final order = List<String>.from(state.fieldOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    state = state.copyWith(fieldOrder: order);
  }

  /// Changes the hierarchy of criteria used to sort the library.
  void reorderSort(int oldIndex, int newIndex) {
    final order = List<String>.from(state.sortOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    state = state.copyWith(sortOrder: order);
  }

  /// Inverts the sorting direction for a specific field.
  void toggleFieldSortDirection(String field) {
    final newDirections = Map<String, bool>.from(state.sortDirections);
    newDirections[field] = !(newDirections[field] ?? true);
    state = state.copyWith(sortDirections: newDirections);
  }

  /// Toggles whether books with missing information appear at the end of the list.
  void toggleEmptyAtEnd() =>
      state = state.copyWith(emptyAtEnd: !state.emptyAtEnd);
}

final displayPreferencesProvider =
NotifierProvider<DisplayPreferencesController, DisplayPreferences>(
  DisplayPreferencesController.new,
);
