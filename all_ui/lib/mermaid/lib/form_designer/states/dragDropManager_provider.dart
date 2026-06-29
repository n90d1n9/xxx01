import 'package:flutter_riverpod/legacy.dart';

import '../model/drag_drop_state.dart';
import '../model/field_config.dart';
import 'dragdrop_manager.dart';
import 'form_field_provider.dart';

final dragDropManagerProvider =
    StateNotifierProvider<DragDropManager, DragDropState>((ref) {
      return DragDropManager();
    });

final showGridProvider = StateProvider<bool>((ref) => false);
final snapToGridProvider = StateProvider<bool>((ref) => true);

// Extension for FormFieldsNotifier
/* extension FormFieldsNotifierDragDrop on FormFieldsNotifier {
  void insertFieldAt(FieldConfig field, int index) {
    final newState = List<FieldConfig>.from(state);
    newState.insert(index, field);
    state = newState;
  }
} */
