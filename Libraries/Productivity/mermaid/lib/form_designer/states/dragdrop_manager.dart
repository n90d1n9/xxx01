import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/drag_drop_state.dart';

class DragDropManager extends StateNotifier<DragDropState> {
  DragDropManager() : super(const DragDropState());

  void startDrag(String fieldId, int index) {
    state = state.copyWith(
      draggedFieldId: fieldId,
      draggedIndex: index,
      showDropZones: true,
    );
  }

  void updateHover(String? targetId, DropPosition? position) {
    state = state.copyWith(hoverTargetId: targetId, dropPosition: position);
  }

  void updateCursor(Offset position) {
    state = state.copyWith(cursorPosition: position);
  }

  void endDrag() {
    state = const DragDropState();
  }

  void cancelDrag() {
    state = const DragDropState();
  }
}
