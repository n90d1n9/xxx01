import 'package:flutter_riverpod/legacy.dart';

import '../models/history_entry.dart';

class RouteHistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  RouteHistoryNotifier() : super([]);
  int _currentIndex = -1;

  void push(HistoryEntry entry) {
    // Remove any future history if we're not at the end
    if (_currentIndex < state.length - 1) {
      state = state.sublist(0, _currentIndex + 1);
    }

    state = [...state, entry];
    _currentIndex = state.length - 1;

    // Keep only last 50 entries
    if (state.length > 50) {
      state = state.sublist(state.length - 50);
      _currentIndex = state.length - 1;
    }
  }

  HistoryEntry? undo() {
    if (_currentIndex > 0) {
      _currentIndex--;
      return state[_currentIndex];
    }
    return null;
  }

  HistoryEntry? redo() {
    if (_currentIndex < state.length - 1) {
      _currentIndex++;
      return state[_currentIndex];
    }
    return null;
  }

  bool get canUndo => _currentIndex > 0;
  bool get canRedo => _currentIndex < state.length - 1;
}

final routeHistoryProvider =
    StateNotifierProvider<RouteHistoryNotifier, List<HistoryEntry>>((ref) {
      return RouteHistoryNotifier();
    });
