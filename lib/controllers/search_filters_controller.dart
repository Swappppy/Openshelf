import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_filters.dart';
import '../services/database.dart';
import 'shared_prefs_provider.dart';

/// Manages the state of search and library status filters with persistence for critical UI states.
class SearchFiltersController extends Notifier<SearchFilters> {
  static const _keyStatus = 'library_filter_status';
  static const _keyShelvesTab = 'shelves_active_tab';
  static const _keyLibraryTabIndex = 'library_active_tab_index';

  @override
  SearchFilters build() {
    final prefs = ref.watch(sharedPrefsProvider);
    
    final statusStr = prefs.getString(_keyStatus);
    final status = statusStr != null 
        ? ReadingStatus.values.where((v) => v.name == statusStr).firstOrNull 
        : null;

    return SearchFilters(status: status);
  }

  void setStatus(ReadingStatus? status) {
    state = state.copyWith(status: status, clearStatus: status == null);
    if (status == null) {
      ref.read(sharedPrefsProvider).remove(_keyStatus);
    } else {
      ref.read(sharedPrefsProvider).setString(_keyStatus, status.name);
    }
  }

  void setQuery(String query) => state = state.copyWith(query: query);
  
  void setFilters(SearchFilters filters) {
    state = filters;
    // Persist status if it changed
    if (filters.status == null) {
       ref.read(sharedPrefsProvider).remove(_keyStatus);
    } else {
       ref.read(sharedPrefsProvider).setString(_keyStatus, filters.status!.name);
    }
  }

  void clearAll() {
    state = const SearchFilters();
    ref.read(sharedPrefsProvider).remove(_keyStatus);
  }

  // --- UI State Persistence ---

  int getActiveLibraryTabIndex() {
    return ref.read(sharedPrefsProvider).getInt(_keyLibraryTabIndex) ?? 0;
  }

  void setActiveLibraryTabIndex(int index) {
    ref.read(sharedPrefsProvider).setInt(_keyLibraryTabIndex, index);
  }

  int getActiveShelvesTab() {
    return ref.read(sharedPrefsProvider).getInt(_keyShelvesTab) ?? 0;
  }

  void setActiveShelvesTab(int index) {
    ref.read(sharedPrefsProvider).setInt(_keyShelvesTab, index);
  }
}

final searchFiltersProvider =
    NotifierProvider<SearchFiltersController, SearchFilters>(
  SearchFiltersController.new,
);
