// services/history_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/design_component.dart';

class HistoryService {
  final List<List<DesignComponent>> _history = [];
  int _historyIndex = -1;
  static const int _maxHistorySize = 100;

  void addToHistory(List<DesignComponent> components) {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(List.from(components));
    _historyIndex++;

    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  List<DesignComponent>? undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      return List.from(_history[_historyIndex]);
    }
    return null;
  }

  List<DesignComponent>? redo() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      return List.from(_history[_historyIndex]);
    }
    return null;
  }

  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;
  void clear() {
    _history.clear();
    _historyIndex = -1;
  }
}
