import 'builder_action.dart';

enum BuilderActionType {
  addSection,
  deleteSection,
  updateSection,
  addComponent,
  deleteComponent,
  updateComponent,
  moveComponent,
  updateStyles,
}

class UndoRedoState {
  final List<BuilderAction> history;
  final int currentIndex;

  UndoRedoState({this.history = const [], this.currentIndex = -1});

  UndoRedoState copyWith({List<BuilderAction>? history, int? currentIndex}) {
    return UndoRedoState(
      history: history ?? this.history,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}
