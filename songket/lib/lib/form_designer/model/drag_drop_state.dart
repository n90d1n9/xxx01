import 'package:flutter/widgets.dart';

class DragDropState {
  final String? draggedFieldId;
  final int? draggedIndex;
  final String? hoverTargetId;
  final DropPosition? dropPosition;
  final bool showDropZones;
  final Offset? cursorPosition;

  const DragDropState({
    this.draggedFieldId,
    this.draggedIndex,
    this.hoverTargetId,
    this.dropPosition,
    this.showDropZones = false,
    this.cursorPosition,
  });

  DragDropState copyWith({
    String? draggedFieldId,
    int? draggedIndex,
    String? hoverTargetId,
    DropPosition? dropPosition,
    bool? showDropZones,
    Offset? cursorPosition,
  }) {
    return DragDropState(
      draggedFieldId: draggedFieldId ?? this.draggedFieldId,
      draggedIndex: draggedIndex ?? this.draggedIndex,
      hoverTargetId: hoverTargetId ?? this.hoverTargetId,
      dropPosition: dropPosition ?? this.dropPosition,
      showDropZones: showDropZones ?? this.showDropZones,
      cursorPosition: cursorPosition ?? this.cursorPosition,
    );
  }

  bool get isDragging => draggedFieldId != null;
}

enum DropPosition { before, after, inside }
