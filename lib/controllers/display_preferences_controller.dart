import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/display_preferences.dart';

/// Manages user preferences for the Library and Shelves views, including layout and sorting.
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

  // --- Reordering Logic ---

  void reorderFields(int oldIndex, int newIndex) {
    final order = List<String>.from(state.fieldOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    state = state.copyWith(fieldOrder: order);
  }

  void reorderSort(int oldIndex, int newIndex) {
    final order = List<String>.from(state.sortOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    state = state.copyWith(sortOrder: order);
  }

  void reorderShelfSort(int oldIndex, int newIndex) {
    final order = List<String>.from(state.shelfSortOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    state = state.copyWith(shelfSortOrder: order);
  }

  void reorderCategorySort(int oldIndex, int newIndex) {
    final order = List<String>.from(state.categorySortOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    state = state.copyWith(categorySortOrder: order);
  }

  void reorderImprintSort(int oldIndex, int newIndex) {
    final order = List<String>.from(state.imprintSortOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    state = state.copyWith(imprintSortOrder: order);
  }

  void reorderCollectionSort(int oldIndex, int newIndex) {
    final order = List<String>.from(state.collectionSortOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    state = state.copyWith(collectionSortOrder: order);
  }

  // --- Toggling Directions ---

  void toggleFieldSortDirection(String field) {
    final newDirections = Map<String, bool>.from(state.sortDirections);
    newDirections[field] = !(newDirections[field] ?? true);
    state = state.copyWith(sortDirections: newDirections);
  }

  void toggleShelfSortDirection(String field) {
    final newDirections = Map<String, bool>.from(state.shelfSortDirections);
    newDirections[field] = !(newDirections[field] ?? true);
    state = state.copyWith(shelfSortDirections: newDirections);
  }

  void toggleCategorySortDirection(String field) {
    final newDirections = Map<String, bool>.from(state.categorySortDirections);
    newDirections[field] = !(newDirections[field] ?? true);
    state = state.copyWith(categorySortDirections: newDirections);
  }

  void toggleImprintSortDirection(String field) {
    final newDirections = Map<String, bool>.from(state.imprintSortDirections);
    newDirections[field] = !(newDirections[field] ?? true);
    state = state.copyWith(imprintSortDirections: newDirections);
  }

  void toggleCollectionSortDirection(String field) {
    final newDirections = Map<String, bool>.from(state.collectionSortDirections);
    newDirections[field] = !(newDirections[field] ?? true);
    state = state.copyWith(collectionSortDirections: newDirections);
  }

  void toggleEmptyAtEnd() =>
      state = state.copyWith(emptyAtEnd: !state.emptyAtEnd);

  void setTagCloudMaxCount(int count) =>
      state = state.copyWith(tagCloudMaxCount: count);
}

final displayPreferencesProvider =
NotifierProvider<DisplayPreferencesController, DisplayPreferences>(
  DisplayPreferencesController.new,
);
