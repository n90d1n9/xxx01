import 'package:flutter_riverpod/legacy.dart';

import '../models/undo_redo_state.dart';
import '../services/undo_redo_manager.dart';

final undoRedoProvider = StateNotifierProvider<UndoRedoManager, UndoRedoState>((
  ref,
) {
  return UndoRedoManager();
});
