import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../schema/workflow/workflow_node.dart';

final uiProvider = StateNotifierProvider<UINotifier, UIState>((ref) {
  return UINotifier();
});

class UINotifier extends StateNotifier<UIState> {
  UINotifier() : super(UIState());

  void setCursor(MouseCursor cursor) {
    state = state.copyWith(cursor: cursor);
  }

  void updateCursorPosition(Offset? cursorPosition) {
    state = state.copyWith(cursorPosition: cursorPosition);
  }

  void toggleLeftPanel() {
    state = state.copyWith(isLeftPanelVisible: !state.isLeftPanelVisible);
  }

  void toggleRightPanel() {
    state = state.copyWith(isRightPanelVisible: !state.isRightPanelVisible);
  }

  void selectNodeForConfig(String? nodeId) {
    state = state.copyWith(selectedNodeForConfig: nodeId);
  }

  void setHoveredNode(String? nodeId) {
    state = state.copyWith(hoveredNodeId: nodeId);
  }

  void setHoveredEdge(String? edgeId) {
    state = state.copyWith(hoveredEdgeId: edgeId);
  }

  void setPaletteCategory(NodeCategory? category) {
    state = state.copyWith(selectedPaletteCategory: category);
  }
}

class UIState {
  final bool isLeftPanelVisible;
  final bool isRightPanelVisible;
  final String? selectedNodeForConfig;
  final String? hoveredNodeId;
  final String? hoveredEdgeId;
  final NodeCategory? selectedPaletteCategory;
  final MouseCursor cursor;
  final Offset? cursorPosition; // Add this field

  UIState({
    this.isLeftPanelVisible = true,
    this.isRightPanelVisible = true,
    this.selectedNodeForConfig,
    this.hoveredNodeId,
    this.hoveredEdgeId,
    this.selectedPaletteCategory,
    this.cursor = SystemMouseCursors.basic,
    this.cursorPosition, // Add to constructor
  });

  UIState copyWith({
    bool? isLeftPanelVisible,
    bool? isRightPanelVisible,
    String? selectedNodeForConfig,
    String? hoveredNodeId,
    String? hoveredEdgeId,
    NodeCategory? selectedPaletteCategory,
    MouseCursor? cursor,
    Offset? cursorPosition, // Add this parameter
  }) {
    return UIState(
      isLeftPanelVisible: isLeftPanelVisible ?? this.isLeftPanelVisible,
      isRightPanelVisible: isRightPanelVisible ?? this.isRightPanelVisible,
      selectedNodeForConfig:
          selectedNodeForConfig ?? this.selectedNodeForConfig,
      hoveredNodeId: hoveredNodeId ?? this.hoveredNodeId,
      hoveredEdgeId: hoveredEdgeId ?? this.hoveredEdgeId,
      selectedPaletteCategory:
          selectedPaletteCategory ?? this.selectedPaletteCategory,
      cursor: cursor ?? this.cursor,
      cursorPosition: cursorPosition ?? this.cursorPosition, // Add this line
    );
  }
}
