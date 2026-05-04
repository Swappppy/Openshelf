import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/display_preferences.dart';

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
}

final displayPreferencesProvider =
NotifierProvider<DisplayPreferencesController, DisplayPreferences>(
  DisplayPreferencesController.new,
);