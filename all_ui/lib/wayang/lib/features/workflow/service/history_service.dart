import '../components/history/history_action.dart';
import '../state/workflow_state.dart';

class HistoryService {
  final List<HistoryAction> _history = [];
  int _historyIndex = -1;

  bool get canUndo => _historyIndex >= 0;
  bool get canRedo => _historyIndex < _history.length - 1;

  List<HistoryAction> get history => List.unmodifiable(_history);
  int get historyIndex => _historyIndex;

  void record(HistoryAction action) {
    // Remove redo history if we're not at the end
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    _history.add(action);
    _historyIndex = _history.length - 1;

    // Limit history size to 100 actions
    if (_history.length > 100) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  WorkflowState undo(WorkflowState state) {
    if (!canUndo) return state;

    final action = _history[_historyIndex];
    _historyIndex--;
    return action.undo(state);
  }

  WorkflowState redo(WorkflowState state) {
    if (!canRedo) return state;

    _historyIndex++;
    final action = _history[_historyIndex];
    return action.apply(state);
  }

  void clear() {
    _history.clear();
    _historyIndex = -1;
  }

  // For state restoration
  void restoreFrom(WorkflowState state) {
    _history.clear();
    _history.addAll(state.history);
    _historyIndex = state.historyIndex;
  }

  // Convert history to JSON for persistence
  List<Map<String, dynamic>> toJson() {
    return _history.map((action) => action.toJson()).toList();
  }

  // Restore history from JSON
  void fromJson(List<dynamic> jsonList) {
    _history.clear();
    _history.addAll(jsonList.map((json) => HistoryAction.fromJson(json)));
    _historyIndex = _history.length - 1;
  }
}
