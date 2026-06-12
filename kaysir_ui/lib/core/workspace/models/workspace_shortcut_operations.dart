import 'workspace_shortcut_identity.dart';
import 'workspace_shortcut_types.dart';

List<T> workspaceShortcutsWithSaved<T>({
  required List<T> shortcuts,
  required T shortcut,
  required bool Function(T existingShortcut, T targetShortcut) matchesState,
}) {
  if (shortcuts.any((existing) => matchesState(existing, shortcut))) {
    return List.unmodifiable(shortcuts);
  }

  return List.unmodifiable([...shortcuts, shortcut]);
}

List<T> workspaceShortcutsWithUpdated<T>({
  required List<T> shortcuts,
  required T updatedShortcut,
  required String Function(T shortcut) idOf,
}) {
  final index = shortcuts.indexWhere(
    (shortcut) => idOf(shortcut) == idOf(updatedShortcut),
  );
  if (index < 0) return List.unmodifiable(shortcuts);

  final updated = [...shortcuts];
  updated[index] = updatedShortcut;
  return List.unmodifiable(updated);
}

List<T> workspaceShortcutsWithDistinctUpdated<T>({
  required List<T> shortcuts,
  required T updatedShortcut,
  required String Function(T shortcut) idOf,
  required bool Function(T currentShortcut, T updatedShortcut) stateChanged,
  required bool Function(T existingShortcut, T targetShortcut) matchesState,
}) {
  final currentIndex = shortcuts.indexWhere(
    (shortcut) => idOf(shortcut) == idOf(updatedShortcut),
  );
  if (currentIndex < 0) return List.unmodifiable(shortcuts);

  final currentShortcut = shortcuts[currentIndex];
  if (!stateChanged(currentShortcut, updatedShortcut)) {
    return workspaceShortcutsWithUpdated(
      shortcuts: shortcuts,
      updatedShortcut: updatedShortcut,
      idOf: idOf,
    );
  }

  final hasDuplicateState = shortcuts.indexed.any((entry) {
    final index = entry.$1;
    final shortcut = entry.$2;
    return index != currentIndex && matchesState(shortcut, updatedShortcut);
  });
  if (hasDuplicateState) return List.unmodifiable(shortcuts);

  return workspaceShortcutsWithUpdated(
    shortcuts: shortcuts,
    updatedShortcut: updatedShortcut,
    idOf: idOf,
  );
}

List<T> workspaceShortcutsWithDuplicated<T>({
  required List<T> shortcuts,
  required String shortcutId,
  required String Function(T shortcut) idOf,
  required String Function(T shortcut) labelOf,
  required T Function(T shortcut, WorkspaceShortcutDuplicateSpec duplicateSpec)
  duplicateBuilder,
}) {
  final shortcut = workspaceShortcutById(
    shortcuts: shortcuts,
    shortcutId: shortcutId,
    idOf: idOf,
  );
  if (shortcut == null) return List.unmodifiable(shortcuts);

  final duplicateSpec = WorkspaceShortcutDuplicateSpec(
    id: workspaceShortcutUniqueDuplicateId(
      shortcutId: shortcutId,
      existingIds: shortcuts.map(idOf),
    ),
    label: workspaceShortcutUniqueDuplicateLabel(
      label: labelOf(shortcut),
      existingLabels: shortcuts.map(labelOf),
    ),
  );

  return List.unmodifiable([
    ...shortcuts,
    duplicateBuilder(shortcut, duplicateSpec),
  ]);
}

List<T> workspaceShortcutsWithRenamed<T>({
  required List<T> shortcuts,
  required String shortcutId,
  required String Function(T shortcut) idOf,
  required T Function(T shortcut, String label) labelBuilder,
  required String label,
}) {
  final normalizedLabel = label.trim();
  if (normalizedLabel.isEmpty) return List.unmodifiable(shortcuts);

  return _workspaceShortcutsWithMappedShortcut(
    shortcuts: shortcuts,
    shortcutId: shortcutId,
    idOf: idOf,
    mapper: (shortcut) => labelBuilder(shortcut, normalizedLabel),
  );
}

List<T> workspaceShortcutsWithPinned<T>({
  required List<T> shortcuts,
  required String shortcutId,
  required String Function(T shortcut) idOf,
  required T Function(T shortcut, bool isPinned) pinnedBuilder,
  required bool isPinned,
}) {
  return _workspaceShortcutsWithMappedShortcut(
    shortcuts: shortcuts,
    shortcutId: shortcutId,
    idOf: idOf,
    mapper: (shortcut) => pinnedBuilder(shortcut, isPinned),
  );
}

List<T> workspaceShortcutsWithMoved<T>({
  required List<T> shortcuts,
  required String shortcutId,
  required String Function(T shortcut) idOf,
  required bool Function(T shortcut) isPinned,
  required WorkspaceShortcutMoveDirection direction,
}) {
  final fromIndex = shortcuts.indexWhere(
    (shortcut) => idOf(shortcut) == shortcutId,
  );
  if (fromIndex < 0) return List.unmodifiable(shortcuts);

  final toIndex = _workspaceShortcutMoveTargetIndex(
    shortcuts: shortcuts,
    fromIndex: fromIndex,
    isPinned: isPinned,
    direction: direction,
  );
  if (toIndex == null) return List.unmodifiable(shortcuts);

  final updated = [...shortcuts];
  final movingShortcut = updated[fromIndex];
  updated[fromIndex] = updated[toIndex];
  updated[toIndex] = movingShortcut;
  return List.unmodifiable(updated);
}

bool workspaceShortcutCanMove<T>({
  required List<T> shortcuts,
  required String shortcutId,
  required String Function(T shortcut) idOf,
  required bool Function(T shortcut) isPinned,
  required WorkspaceShortcutMoveDirection direction,
}) {
  final fromIndex = shortcuts.indexWhere(
    (shortcut) => idOf(shortcut) == shortcutId,
  );
  if (fromIndex < 0) return false;

  return _workspaceShortcutMoveTargetIndex(
        shortcuts: shortcuts,
        fromIndex: fromIndex,
        isPinned: isPinned,
        direction: direction,
      ) !=
      null;
}

List<T> workspaceShortcutsForDisplay<T>({
  required List<T> shortcuts,
  required bool Function(T shortcut) isPinned,
}) {
  return List.unmodifiable([
    ...shortcuts.where(isPinned),
    ...shortcuts.where((shortcut) => !isPinned(shortcut)),
  ]);
}

List<T> workspaceShortcutsWithout<T>({
  required List<T> shortcuts,
  required String shortcutId,
  required String Function(T shortcut) idOf,
}) {
  return List.unmodifiable(
    shortcuts.where((shortcut) => idOf(shortcut) != shortcutId),
  );
}

T? workspaceShortcutById<T>({
  required List<T> shortcuts,
  required String shortcutId,
  required String Function(T shortcut) idOf,
}) {
  for (final shortcut in shortcuts) {
    if (idOf(shortcut) == shortcutId) return shortcut;
  }

  return null;
}

T? workspaceShortcutForState<T>({
  required List<T> shortcuts,
  required bool Function(T shortcut) matchesState,
}) {
  for (final shortcut in shortcuts) {
    if (matchesState(shortcut)) return shortcut;
  }

  return null;
}

List<T> _workspaceShortcutsWithMappedShortcut<T>({
  required List<T> shortcuts,
  required String shortcutId,
  required String Function(T shortcut) idOf,
  required T Function(T shortcut) mapper,
}) {
  final index = shortcuts.indexWhere(
    (shortcut) => idOf(shortcut) == shortcutId,
  );
  if (index < 0) return List.unmodifiable(shortcuts);

  final updated = [...shortcuts];
  updated[index] = mapper(updated[index]);
  return List.unmodifiable(updated);
}

int? _workspaceShortcutMoveTargetIndex<T>({
  required List<T> shortcuts,
  required int fromIndex,
  required bool Function(T shortcut) isPinned,
  required WorkspaceShortcutMoveDirection direction,
}) {
  final movingPinnedState = isPinned(shortcuts[fromIndex]);

  if (direction == WorkspaceShortcutMoveDirection.earlier) {
    for (var index = fromIndex - 1; index >= 0; index -= 1) {
      if (isPinned(shortcuts[index]) == movingPinnedState) return index;
    }
    return null;
  }

  for (var index = fromIndex + 1; index < shortcuts.length; index += 1) {
    if (isPinned(shortcuts[index]) == movingPinnedState) return index;
  }
  return null;
}
