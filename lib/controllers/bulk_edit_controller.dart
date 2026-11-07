import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State wrapper for an individual editable field in bulk edit mode.
class BulkFieldState<T> {
  final T value;
  final bool isLocked;

  const BulkFieldState({
    required this.value,
    this.isLocked = true,
  });

  BulkFieldState<T> copyWith({T? value, bool? isLocked}) {
    return BulkFieldState(
      value: value ?? this.value,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

/// Controller managing all bulk edit field states and lock toggles.
class BulkEditStateNotifier extends Notifier<void> {
  @override
  void build() {}
}
