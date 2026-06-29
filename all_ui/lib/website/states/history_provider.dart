import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/layout_element.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((
  ref,
) {
  return HistoryNotifier();
});

class HistoryState {
  final List<List<LayoutElement>> past;
  final List<List<LayoutElement>> future;

  HistoryState({this.past = const [], this.future = const []});

  HistoryState copyWith({
    List<List<LayoutElement>>? past,
    List<List<LayoutElement>>? future,
  }) {
    return HistoryState(past: past ?? this.past, future: future ?? this.future);
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(HistoryState());

  void recordState(List<LayoutElement> elements) {
    state = state.copyWith(past: [...state.past, elements], future: []);
  }

  List<LayoutElement>? undo(List<LayoutElement> currentElements) {
    if (state.past.isEmpty) return null;

    final pastStates = [...state.past];
    final lastState = pastStates.removeLast();

    state = state.copyWith(
      past: pastStates,
      future: [...state.future, currentElements],
    );

    return lastState;
  }

  List<LayoutElement>? redo(List<LayoutElement> currentElements) {
    if (state.future.isEmpty) return null;

    final futureStates = [...state.future];
    final nextState = futureStates.removeLast();

    state = state.copyWith(
      past: [...state.past, currentElements],
      future: futureStates,
    );

    return nextState;
  }
}
