import '../models/order_saved_workspace.dart';

String orderSavedWorkspaceChipTooltip(OrderSavedWorkspace workspace) {
  final description = workspace.description.trim();
  if (description.isEmpty) return 'Open ${workspace.label} workspace';

  return '${workspace.label}: $description';
}

String orderSavedWorkspaceChipSemanticsLabel({
  required OrderSavedWorkspace workspace,
  required bool selected,
}) {
  final state = selected ? 'Selected saved workspace' : 'Saved workspace';
  final pinned = workspace.isPinned ? ', pinned' : '';
  return '$state: ${workspace.label}$pinned';
}

String orderSavedWorkspaceChipSemanticsHint(OrderSavedWorkspace workspace) {
  final description = workspace.description.trim();
  final action = 'Open this saved order workspace';
  if (description.isEmpty) return action;

  return '$description. $action';
}

String orderSavedWorkspaceActionsTooltip(OrderSavedWorkspace workspace) {
  return 'Manage ${workspace.label} workspace';
}

String orderSavedWorkspaceNoteTooltip(OrderSavedWorkspace workspace) {
  final description = workspace.description.trim();
  if (description.isEmpty) return 'Custom note for ${workspace.label}';

  return 'Custom note for ${workspace.label}: $description';
}

String orderSavedWorkspaceNoteSemanticsLabel(OrderSavedWorkspace workspace) {
  return 'Custom note for ${workspace.label} workspace';
}

String orderSavedWorkspaceNoteSemanticsHint(OrderSavedWorkspace workspace) {
  final description = workspace.description.trim();
  if (description.isEmpty) return 'This workspace has a custom note.';

  return description;
}

String orderSavedWorkspaceStripSemanticsLabel(
  List<OrderSavedWorkspace> workspaces,
) {
  final workspaceCount = workspaces.length;
  final pinnedCount =
      workspaces.where((workspace) => workspace.isPinned).length;
  final noteCount =
      workspaces.where((workspace) => workspace.isDescriptionCustom).length;

  final parts = [
    '$workspaceCount saved ${workspaceCount == 1 ? 'workspace' : 'workspaces'}',
    if (pinnedCount > 0) '$pinnedCount pinned',
    if (noteCount > 0) '$noteCount with custom notes',
  ];

  return 'Saved order workspace shortcuts, ${parts.join(', ')}';
}
