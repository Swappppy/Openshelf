import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../models/display_preferences.dart';
import 'shared_prefs_provider.dart';

/// Manages user preferences for the Library and Shelves views, including layout and sorting.
class DisplayPreferencesController extends Notifier<DisplayPreferences> {
  static const _key = 'display_preferences_json';

  @override
  DisplayPreferences build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return const DisplayPreferences();
    
    try {
      return DisplayPreferences.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      return const DisplayPreferences();
    }
  }

  void _save(DisplayPreferences newState) {
    state = newState;
    final jsonStr = jsonEncode(state.toJson());
    ref.read(sharedPrefsProvider).setString(_key, jsonStr);
  }

  void toggleViewMode() {
    _save(state.copyWith(
      viewMode: state.viewMode == LibraryViewMode.list
          ? LibraryViewMode.grid
          : LibraryViewMode.list,
    ));
  }

  void toggleShowProgress() =>
      _save(state.copyWith(showProgress: !state.showProgress));
  void toggleShowTags() =>
      _save(state.copyWith(showTags: !state.showTags));
  void toggleShowRating() =>
      _save(state.copyWith(showRating: !state.showRating));
  void toggleShowAuthor() =>
      _save(state.copyWith(showAuthor: !state.showAuthor));
  void toggleShowStatusChip() =>
      _save(state.copyWith(showStatusChip: !state.showStatusChip));
  void toggleShowPublisher() =>
      _save(state.copyWith(showPublisher: !state.showPublisher));
  void toggleShowYear() =>
      _save(state.copyWith(showYear: !state.showYear));
  void toggleShowSpacer() =>
      _save(state.copyWith(showSpacer: !state.showSpacer));

  // --- Reordering Logic ---

  void reorderFields(int oldIndex, int newIndex) {
    final order = List<String>.from(state.fieldOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    _save(state.copyWith(fieldOrder: order));
  }

  void reorderShelvesSections(int oldIndex, int newIndex) {
    final order = List<String>.from(state.shelvesSectionOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    _save(state.copyWith(shelvesSectionOrder: order));
  }

  void reorderSort(int oldIndex, int newIndex) {
    final order = List<String>.from(state.sortOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    _save(state.copyWith(sortOrder: order));
  }

  void reorderShelfSort(int oldIndex, int newIndex) {
    final order = List<String>.from(state.shelfSortOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    _save(state.copyWith(shelfSortOrder: order));
  }

  void reorderCategorySort(int oldIndex, int newIndex) {
    final order = List<String>.from(state.categorySortOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    _save(state.copyWith(categorySortOrder: order));
  }

  void reorderImprintSort(int oldIndex, int newIndex) {
    final order = List<String>.from(state.imprintSortOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    _save(state.copyWith(imprintSortOrder: order));
  }

  void reorderCollectionSort(int oldIndex, int newIndex) {
    final order = List<String>.from(state.collectionSortOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    _save(state.copyWith(collectionSortOrder: order));
  }

  // --- Toggling Directions ---

  void toggleFieldSortDirection(String field) {
    final newDirections = Map<String, bool>.from(state.sortDirections);
    newDirections[field] = !(newDirections[field] ?? true);
    _save(state.copyWith(sortDirections: newDirections));
  }

  void toggleShelfSortDirection(String field) {
    final newDirections = Map<String, bool>.from(state.shelfSortDirections);
    newDirections[field] = !(newDirections[field] ?? true);
    _save(state.copyWith(shelfSortDirections: newDirections));
  }

  void toggleCategorySortDirection(String field) {
    final newDirections = Map<String, bool>.from(state.categorySortDirections);
    newDirections[field] = !(newDirections[field] ?? true);
    _save(state.copyWith(categorySortDirections: newDirections));
  }

  void toggleImprintSortDirection(String field) {
    final newDirections = Map<String, bool>.from(state.imprintSortDirections);
    newDirections[field] = !(newDirections[field] ?? true);
    _save(state.copyWith(imprintSortDirections: newDirections));
  }

  void toggleCollectionSortDirection(String field) {
    final newDirections = Map<String, bool>.from(state.collectionSortDirections);
    newDirections[field] = !(newDirections[field] ?? true);
    _save(state.copyWith(collectionSortDirections: newDirections));
  }

  void toggleEmptyAtEnd() =>
      _save(state.copyWith(emptyAtEnd: !state.emptyAtEnd));

  void setTagCloudMaxCount(int count) =>
      _save(state.copyWith(tagCloudMaxCount: count));
}

final displayPreferencesProvider =
NotifierProvider<DisplayPreferencesController, DisplayPreferences>(
  DisplayPreferencesController.new,
);
