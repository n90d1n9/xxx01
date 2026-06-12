import 'package:flutter_riverpod/legacy.dart';

import 'form_command.dart';
import 'history_state.dart';

class HistoryManager extends StateNotifier<HistoryState> {
  HistoryManager() : super(HistoryState());

  void executeCommand(FormCommand command) {
    command.execute();

    // Remove any commands after current position
    final newHistory = state.history.sublist(0, state.currentIndex + 1);
    newHistory.add(command);

    // Limit history to 50 commands
    if (newHistory.length > 50) {
      newHistory.removeAt(0);
    }

    state = HistoryState(
      history: newHistory,
      currentIndex: newHistory.length - 1,
    );
  }

  void undo() {
    if (canUndo) {
      state.history[state.currentIndex].undo();
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void redo() {
    if (canRedo) {
      state.history[state.currentIndex + 1].execute();
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  bool get canUndo => state.currentIndex >= 0;
  bool get canRedo => state.currentIndex < state.history.length - 1;

  void clear() {
    state = HistoryState();
  }
}
