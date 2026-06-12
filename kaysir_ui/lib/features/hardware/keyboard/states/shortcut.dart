import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class KeyboardShortcutState {
  final String lastPressedShortcut;
  final bool isControlPressed;
  final bool isShiftPressed;
  final bool isAltPressed;

  KeyboardShortcutState({
    this.lastPressedShortcut = '',
    this.isControlPressed = false,
    this.isShiftPressed = false,
    this.isAltPressed = false,
  });

  KeyboardShortcutState copyWith({
    String? lastPressedShortcut,
    bool? isControlPressed,
    bool? isShiftPressed,
    bool? isAltPressed,
  }) {
    return KeyboardShortcutState(
      lastPressedShortcut: lastPressedShortcut ?? this.lastPressedShortcut,
      isControlPressed: isControlPressed ?? this.isControlPressed,
      isShiftPressed: isShiftPressed ?? this.isShiftPressed,
      isAltPressed: isAltPressed ?? this.isAltPressed,
    );
  }
}

class KeyboardShortcutNotifier extends StateNotifier<KeyboardShortcutState> {
  KeyboardShortcutNotifier() : super(KeyboardShortcutState());

  void updateShortcut(String shortcut) {
    state = state.copyWith(lastPressedShortcut: shortcut);
  }

  void updateModifierKeys({
    bool? isControlPressed,
    bool? isShiftPressed,
    bool? isAltPressed,
  }) {
    state = state.copyWith(
      isControlPressed: isControlPressed,
      isShiftPressed: isShiftPressed,
      isAltPressed: isAltPressed,
    );
  }
}

final keyboardShortcutProvider =
    StateNotifierProvider<KeyboardShortcutNotifier, KeyboardShortcutState>(
      (ref) => KeyboardShortcutNotifier(),
    );
