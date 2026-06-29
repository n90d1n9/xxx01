import 'package:flutter_riverpod/legacy.dart';

import '../models/menu_state.dart';

final menuStateProvider = StateNotifierProvider<MenuStateNotifier, MenuState>((
  ref,
) {
  return MenuStateNotifier();
});

class MenuStateNotifier extends StateNotifier<MenuState> {
  MenuStateNotifier() : super(MenuState());

  void zoomIn() {
    state = state.copyWith(zoomLevel: state.zoomLevel + 0.1);
  }

  void zoomOut() {
    state = state.copyWith(zoomLevel: state.zoomLevel - 0.1);
  }

  void fitScreen() {
    state = state.copyWith(zoomLevel: 1.0);
  }

  void addUndoAction() {
    state = state.copyWith(canUndo: true);
  }

  void addRedoAction() {
    state = state.copyWith(canRedo: true);
  }

  void undo() {
    // Implement undo logic
  }

  void redo() {
    // Implement redo logic
  }
}
