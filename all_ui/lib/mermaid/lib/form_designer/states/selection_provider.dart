import 'package:flutter_riverpod/legacy.dart';

import '../model/field_config.dart';

final selectionManagerProvider =
    StateNotifierProvider<SelectionManager, SelectionState>((ref) {
      return SelectionManager();
    });

final showBulkPanelProvider = StateProvider<bool>((ref) {
  final selection = ref.watch(selectionManagerProvider);
  return selection.hasSelection;
});

class SelectionManager extends StateNotifier<SelectionState> {
  SelectionManager() : super(SelectionState());

  void toggleSelection(String id) {
    final newSet = Set<String>.from(state.selectedIds);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    state = state.copyWith(selectedIds: newSet, lastSelectedId: id);
  }

  void rangeSelect(List<FieldConfig> fields, String fromId, String toId) {
    final fromIndex = fields.indexWhere((f) => f.id == fromId);
    final toIndex = fields.indexWhere((f) => f.id == toId);

    if (fromIndex != -1 && toIndex != -1) {
      final start = fromIndex < toIndex ? fromIndex : toIndex;
      final end = fromIndex > toIndex ? fromIndex : toIndex;

      final rangeIds = fields.sublist(start, end + 1).map((f) => f.id).toSet();

      state = state.copyWith(selectedIds: rangeIds, lastSelectedId: toId);
    }
  }

  void selectAll(List<FieldConfig> fields) {
    final allIds = fields.map((f) => f.id).toSet();
    state = state.copyWith(selectedIds: allIds);
  }

  void selectByType(List<FieldConfig> fields, String type) {
    final matchingIds = fields
        .where((f) => f.type == type)
        .map((f) => f.id)
        .toSet();
    state = state.copyWith(selectedIds: matchingIds);
  }

  void invertSelection(List<FieldConfig> fields) {
    final allIds = fields.map((f) => f.id).toSet();
    final inverted = allIds.difference(state.selectedIds);
    state = state.copyWith(selectedIds: inverted);
  }

  void clearSelection() {
    state = SelectionState();
  }

  void setSingleSelection(String id) {
    state = state.copyWith(selectedIds: {id}, lastSelectedId: id);
  }
}

class SelectionState {
  final Set<String> selectedIds;
  final String? lastSelectedId;

  SelectionState({this.selectedIds = const {}, this.lastSelectedId});

  SelectionState copyWith({Set<String>? selectedIds, String? lastSelectedId}) {
    return SelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      lastSelectedId: lastSelectedId ?? this.lastSelectedId,
    );
  }

  bool get hasSelection => selectedIds.isNotEmpty;
  int get count => selectedIds.length;
}
