import 'form_command.dart';

class HistoryState {
  final List<FormCommand> history;
  final int currentIndex;
  final bool canUndo;
  final bool canRedo;

  HistoryState({
    this.history = const [],
    this.currentIndex = -1,
    this.canUndo = false,
    this.canRedo = false,
  });

  HistoryState copyWith({List<FormCommand>? history, int? currentIndex}) {
    return HistoryState(
      history: history ?? this.history,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}
