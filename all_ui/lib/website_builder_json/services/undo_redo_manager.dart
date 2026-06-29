import 'package:flutter_riverpod/legacy.dart';

import '../models/builder_action.dart';
import '../models/undo_redo_state.dart';

class UndoRedoManager extends StateNotifier<UndoRedoState> {
  UndoRedoManager() : super(UndoRedoState());

  void recordAction(BuilderActionType type, Map<String, dynamic> data) {
    final action = BuilderAction(
      type: type.toString(),
      data: data,
      timestamp: DateTime.now(),
    );

    // Remove any actions after current index
    final newHistory = state.history.sublist(0, state.currentIndex + 1);
    newHistory.add(action);

    // Limit history to 50 actions
    if (newHistory.length > 50) {
      newHistory.removeAt(0);
    }

    state = state.copyWith(
      history: newHistory,
      currentIndex: newHistory.length - 1,
    );
  }

  void undo() {
    if (canUndo) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void redo() {
    if (canRedo) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  bool get canUndo => state.currentIndex > 0;
  bool get canRedo => state.currentIndex < state.history.length - 1;

  BuilderAction? get currentAction {
    if (state.currentIndex >= 0 && state.currentIndex < state.history.length) {
      return state.history[state.currentIndex];
    }
    return null;
  }
}
