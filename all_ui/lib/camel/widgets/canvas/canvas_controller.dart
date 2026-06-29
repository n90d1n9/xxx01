import 'package:flutter/material.dart';

class CanvasController extends ChangeNotifier {
  Offset? selectionStart;
  Offset? selectionEnd;
  bool isSelecting = false;
  bool isGroupDragging = false;
  Offset? groupDragStart;
  double currentScale = 1.0;
  Offset currentFocalPoint = Offset.zero;
  Offset lastPanOffset = Offset.zero;
  bool isCtrlPressed = false;
  bool isShiftPressed = false;

  void updateModifierKeys(bool ctrl, bool shift) {
    isCtrlPressed = ctrl;
    isShiftPressed = shift;
    notifyListeners();
  }

  void startSelection(Offset start) {
    selectionStart = start;
    isSelecting = true;
    notifyListeners();
  }

  void updateSelection(Offset end) {
    selectionEnd = end;
    notifyListeners();
  }

  void endSelection() {
    isSelecting = false;
    selectionStart = null;
    selectionEnd = null;
    notifyListeners();
  }

  void startGroupDrag(Offset start) {
    isGroupDragging = true;
    groupDragStart = start;
    notifyListeners();
  }

  void updateGroupDrag(Offset current) {
    groupDragStart = current;
    notifyListeners();
  }

  void endGroupDrag() {
    isGroupDragging = false;
    groupDragStart = null;
    notifyListeners();
  }

  void updateScaleState(double scale, Offset focalPoint) {
    currentScale = scale;
    currentFocalPoint = focalPoint;
    notifyListeners();
  }

  void updatePanState(Offset offset) {
    lastPanOffset = offset;
    notifyListeners();
  }

  void reset() {
    selectionStart = null;
    selectionEnd = null;
    isSelecting = false;
    isGroupDragging = false;
    groupDragStart = null;
    currentScale = 1.0;
    currentFocalPoint = Offset.zero;
    lastPanOffset = Offset.zero;
    isCtrlPressed = false;
    isShiftPressed = false;
    notifyListeners();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}
