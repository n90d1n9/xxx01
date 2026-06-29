import 'package:flutter/material.dart';

import '../components/node/model/schema/node_data.dart';

class MultiSelectManager {
  final Set<String> selectedIds = {};
  Offset? selectionStart;
  Offset? selectionEnd;

  void startSelection(Offset position) {
    selectionStart = position;
    selectionEnd = position;
    selectedIds.clear();
  }

  void updateSelection(Offset position) {
    selectionEnd = position;
  }

  void endSelection(List<NodeData> nodes) {
    if (selectionStart == null || selectionEnd == null) return;

    final rect = Rect.fromPoints(selectionStart!, selectionEnd!);

    selectedIds.clear();
    for (final node in nodes) {
      if (rect.contains(node.position)) {
        selectedIds.add(node.id);
      }
    }

    selectionStart = null;
    selectionEnd = null;
  }

  Rect? getSelectionRect() {
    if (selectionStart == null || selectionEnd == null) return null;
    return Rect.fromPoints(selectionStart!, selectionEnd!);
  }

  void clearSelection() {
    selectedIds.clear();
    selectionStart = null;
    selectionEnd = null;
  }
}
