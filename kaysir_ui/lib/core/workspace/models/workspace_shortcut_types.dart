enum WorkspaceShortcutMoveDirection { earlier, later }

class WorkspaceShortcutDuplicateSpec {
  final String id;
  final String label;
  final bool isPinned;

  const WorkspaceShortcutDuplicateSpec({
    required this.id,
    required this.label,
    this.isPinned = false,
  });
}
