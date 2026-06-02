import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';

class LibraryNavigationController extends Notifier<int> {
  static const _keyLibraryTabIndex = 'library_active_tab_index';

  @override
  int build() {
    return ref.watch(sharedPrefsProvider).getInt(_keyLibraryTabIndex) ?? 0;
  }

  void setIndex(int index) {
    state = index;
    ref.read(sharedPrefsProvider).setInt(_keyLibraryTabIndex, index);
  }
}

final libraryNavigationProvider = NotifierProvider<LibraryNavigationController, int>(
  LibraryNavigationController.new,
);
