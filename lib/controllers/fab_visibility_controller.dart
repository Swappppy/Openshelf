import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A notifier to manage FAB visibility based on scroll behavior.
/// Hides during active scrolling and automatically shows when idle.
class FabVisibilityController extends Notifier<bool> {
  Timer? _debounceTimer;

  @override
  bool build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return true;
  }

  void handleScroll(ScrollController scrollController) {
    if (!scrollController.hasClients) return;

    final isScrollable = scrollController.position.maxScrollExtent > 0;
    if (!isScrollable) {
      if (!state) state = true;
      return;
    }

    final isAtEnd = scrollController.position.pixels >= scrollController.position.maxScrollExtent - 50;
    final isAtTop = scrollController.position.pixels <= 50;
    final isScrolling = scrollController.position.userScrollDirection != ScrollDirection.idle;

    // 1. Hide immediately when starting to scroll in any direction
    if (isScrolling && !isAtEnd && !isAtTop) {
      if (state) state = false;
    } 
    // 2. Always show at boundaries
    else if (isAtEnd || isAtTop) {
      if (!state) state = true;
    }

    // 3. Debounce timer to show FAB after scrolling stops
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      if (!state) state = true;
    });
  }

  void show() {
    _debounceTimer?.cancel();
    if (!state) state = true;
  }
}

final fabVisibilityProvider = NotifierProvider<FabVisibilityController, bool>(
  FabVisibilityController.new,
);
