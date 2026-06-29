// History Manager
import '../models/design_component.dart';

class HistoryManager {
  final List<List<DesignComponent>> _history = [];
  int _currentIndex = -1;
  static const int maxHistorySize = 100;

  void addState(List<DesignComponent> components) {
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }
    _history.add(_deepCopyComponents(components));
    _currentIndex++;
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
      _currentIndex--;
    }
  }

  List<DesignComponent>? undo() {
    if (canUndo()) {
      _currentIndex--;
      return _deepCopyComponents(_history[_currentIndex]);
    }
    return null;
  }

  List<DesignComponent>? redo() {
    if (canRedo()) {
      _currentIndex++;
      return _deepCopyComponents(_history[_currentIndex]);
    }
    return null;
  }

  bool canUndo() => _currentIndex > 0;
  bool canRedo() => _currentIndex < _history.length - 1;

  void clear() {
    _history.clear();
    _currentIndex = -1;
  }

  List<DesignComponent> _deepCopyComponents(List<DesignComponent> components) {
    return components.map((c) => c.copyWith()).toList();
  }
}
