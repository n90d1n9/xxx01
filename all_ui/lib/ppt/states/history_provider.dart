// Undo/Redo History
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/presentation.dart';
import 'presentation_provider.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((
  ref,
) {
  return HistoryNotifier(ref);
});

class HistoryState {
  final List<Presentation> states;
  final int currentIndex;

  HistoryState({required this.states, required this.currentIndex});

  bool get canUndo => currentIndex > 0;
  bool get canRedo => currentIndex < states.length - 1;
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final Ref ref;

  HistoryNotifier(this.ref) : super(HistoryState(states: [], currentIndex: -1));

  void addState(Presentation presentation) {
    final states =
        state.currentIndex < state.states.length - 1
            ? state.states.sublist(0, state.currentIndex + 1)
            : List<Presentation>.from(state.states);

    states.add(presentation);

    if (states.length > 50) {
      states.removeAt(0);
      state = HistoryState(states: states, currentIndex: states.length - 1);
    } else {
      state = HistoryState(states: states, currentIndex: states.length - 1);
    }
  }

  void undo() {
    if (state.canUndo) {
      final newIndex = state.currentIndex - 1;
      ref
          .read(presentationProvider.notifier)
          .loadPresentation(state.states[newIndex]);
      state = HistoryState(states: state.states, currentIndex: newIndex);
    }
  }

  void redo() {
    if (state.canRedo) {
      final newIndex = state.currentIndex + 1;
      ref
          .read(presentationProvider.notifier)
          .loadPresentation(state.states[newIndex]);
      state = HistoryState(states: state.states, currentIndex: newIndex);
    }
  }
}
