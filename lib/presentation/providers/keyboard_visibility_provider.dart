import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final keyboardVisibilityProvider =
    StateNotifierProvider<KeyboardVisibilityNotifier, bool>((ref) {
  return KeyboardVisibilityNotifier();
});

class KeyboardVisibilityNotifier extends StateNotifier<bool>
    with WidgetsBindingObserver {
  KeyboardVisibilityNotifier() : super(false) {
    WidgetsBinding.instance.addObserver(this);
    _updateKeyboardVisibility();
  }

  void _updateKeyboardVisibility() {
    final viewInsets = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets;
    state = viewInsets.bottom > 0;
  }

  @override
  void didChangeMetrics() {
    _updateKeyboardVisibility();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
