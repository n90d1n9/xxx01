import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'canvas_state.dart';

class SelectedComponentNotifier extends StateNotifier<Set<String>> {
  SelectedComponentNotifier() : super({});

  void select(String id, {bool multi = false}) {
    if (multi) {
      state = {...state, id};
    } else {
      state = {id};
    }
  }

  void deselect(String id) {
    state = {...state}..remove(id);
  }

  void clear() {
    state = {};
  }

  void toggle(String id) {
    if (state.contains(id)) {
      deselect(id);
    } else {
      state = {...state, id};
    }
  }
}

class CanvasStateNotifier extends StateNotifier<CanvasState> {
  CanvasStateNotifier() : super(CanvasState());

  void setScale(double scale) {
    state = state.copyWith(scale: scale);
  }

  void setOffset(Offset offset) {
    state = state.copyWith(offset: offset);
  }

  void setGridVisible(bool visible) {
    state = state.copyWith(gridVisible: visible);
  }

  void setSnapToGrid(bool snap) {
    state = state.copyWith(snapToGrid: snap);
  }

  void toggleMinimap() {
    state = state.copyWith(minimapVisible: !state.minimapVisible);
  }
}
