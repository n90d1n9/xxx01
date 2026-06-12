import 'workspace_shortcut_operations.dart';
import 'workspace_shortcut_types.dart';

class WorkspaceShortcutDefinition<T> {
  final String Function(T shortcut) idOf;
  final String Function(T shortcut) labelOf;
  final bool Function(T shortcut) isPinned;
  final bool Function(T existingShortcut, T targetShortcut) matchesState;
  final bool Function(T currentShortcut, T updatedShortcut) stateChanged;
  final T Function(T shortcut, WorkspaceShortcutDuplicateSpec duplicateSpec)
  duplicateBuilder;
  final T Function(T shortcut, bool isPinned) pinnedBuilder;
  final T Function(T shortcut, String label) labelBuilder;

  const WorkspaceShortcutDefinition({
    required this.idOf,
    required this.labelOf,
    required this.isPinned,
    required this.matchesState,
    required this.stateChanged,
    required this.duplicateBuilder,
    required this.pinnedBuilder,
    required this.labelBuilder,
  });

  List<T> save({required List<T> shortcuts, required T shortcut}) {
    return workspaceShortcutsWithSaved(
      shortcuts: shortcuts,
      shortcut: shortcut,
      matchesState: matchesState,
    );
  }

  List<T> update({required List<T> shortcuts, required T updatedShortcut}) {
    return workspaceShortcutsWithUpdated(
      shortcuts: shortcuts,
      updatedShortcut: updatedShortcut,
      idOf: idOf,
    );
  }

  List<T> updateDistinct({
    required List<T> shortcuts,
    required T updatedShortcut,
  }) {
    return workspaceShortcutsWithDistinctUpdated(
      shortcuts: shortcuts,
      updatedShortcut: updatedShortcut,
      idOf: idOf,
      stateChanged: stateChanged,
      matchesState: matchesState,
    );
  }

  List<T> duplicateIn({
    required List<T> shortcuts,
    required String shortcutId,
  }) {
    return workspaceShortcutsWithDuplicated(
      shortcuts: shortcuts,
      shortcutId: shortcutId,
      idOf: idOf,
      labelOf: labelOf,
      duplicateBuilder: duplicateBuilder,
    );
  }

  T? duplicate({required List<T> shortcuts, required String shortcutId}) {
    final updatedShortcuts = duplicateIn(
      shortcuts: shortcuts,
      shortcutId: shortcutId,
    );
    if (updatedShortcuts.length == shortcuts.length) return null;

    return updatedShortcuts.last;
  }

  List<T> pin({
    required List<T> shortcuts,
    required String shortcutId,
    required bool isPinned,
  }) {
    return workspaceShortcutsWithPinned(
      shortcuts: shortcuts,
      shortcutId: shortcutId,
      idOf: idOf,
      pinnedBuilder: pinnedBuilder,
      isPinned: isPinned,
    );
  }

  List<T> rename({
    required List<T> shortcuts,
    required String shortcutId,
    required String label,
  }) {
    return workspaceShortcutsWithRenamed(
      shortcuts: shortcuts,
      shortcutId: shortcutId,
      idOf: idOf,
      labelBuilder: labelBuilder,
      label: label,
    );
  }

  List<T> move({
    required List<T> shortcuts,
    required String shortcutId,
    required WorkspaceShortcutMoveDirection direction,
  }) {
    return workspaceShortcutsWithMoved(
      shortcuts: shortcuts,
      shortcutId: shortcutId,
      idOf: idOf,
      isPinned: isPinned,
      direction: direction,
    );
  }

  bool canMove({
    required List<T> shortcuts,
    required String shortcutId,
    required WorkspaceShortcutMoveDirection direction,
  }) {
    return workspaceShortcutCanMove(
      shortcuts: shortcuts,
      shortcutId: shortcutId,
      idOf: idOf,
      isPinned: isPinned,
      direction: direction,
    );
  }

  List<T> forDisplay(List<T> shortcuts) {
    return workspaceShortcutsForDisplay(
      shortcuts: shortcuts,
      isPinned: isPinned,
    );
  }

  List<T> remove({required List<T> shortcuts, required String shortcutId}) {
    return workspaceShortcutsWithout(
      shortcuts: shortcuts,
      shortcutId: shortcutId,
      idOf: idOf,
    );
  }

  T? byId({required List<T> shortcuts, required String shortcutId}) {
    return workspaceShortcutById(
      shortcuts: shortcuts,
      shortcutId: shortcutId,
      idOf: idOf,
    );
  }

  T? forState({
    required List<T> shortcuts,
    required bool Function(T shortcut) matchesState,
  }) {
    return workspaceShortcutForState(
      shortcuts: shortcuts,
      matchesState: matchesState,
    );
  }
}
