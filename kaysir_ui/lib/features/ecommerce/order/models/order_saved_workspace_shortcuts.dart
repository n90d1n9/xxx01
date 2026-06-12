import 'package:kaysir/core/workspace/models/saved_workspace_shortcut.dart';

import 'order_active_filter_summary.dart';
import 'order_filter.dart';
import 'order_saved_workspace_model.dart';
import 'order_saved_workspace_state.dart';
import 'order_sort.dart';

List<OrderSavedWorkspace> ecommerceOrderSavedWorkspacesWithSaved(
  List<OrderSavedWorkspace> workspaces,
  OrderSavedWorkspace workspace,
) {
  return _savedWorkspaceShortcuts.save(
    shortcuts: workspaces,
    shortcut: workspace,
  );
}

List<OrderSavedWorkspace> ecommerceOrderSavedWorkspacesWithUpdated(
  List<OrderSavedWorkspace> workspaces,
  OrderSavedWorkspace updatedWorkspace,
) {
  return _savedWorkspaceShortcuts.update(
    shortcuts: workspaces,
    updatedShortcut: updatedWorkspace,
  );
}

List<OrderSavedWorkspace> ecommerceOrderSavedWorkspacesWithDistinctUpdated(
  List<OrderSavedWorkspace> workspaces,
  OrderSavedWorkspace updatedWorkspace,
) {
  return _savedWorkspaceShortcuts.updateDistinct(
    shortcuts: workspaces,
    updatedShortcut: updatedWorkspace,
  );
}

OrderSavedWorkspace? ecommerceOrderSavedWorkspaceDuplicate({
  required List<OrderSavedWorkspace> workspaces,
  required String workspaceId,
}) {
  return _savedWorkspaceShortcuts.duplicate(
    shortcuts: workspaces,
    shortcutId: workspaceId,
  );
}

List<OrderSavedWorkspace> ecommerceOrderSavedWorkspacesWithDuplicated({
  required List<OrderSavedWorkspace> workspaces,
  required String workspaceId,
}) {
  return _savedWorkspaceShortcuts.duplicateIn(
    shortcuts: workspaces,
    shortcutId: workspaceId,
  );
}

List<OrderSavedWorkspace> ecommerceOrderSavedWorkspacesWithState({
  required List<OrderSavedWorkspace> workspaces,
  required String workspaceId,
  required OrderFilter filter,
  required OrderSortMode sortMode,
  required List<OrderActiveFilterSummaryItem> summaryItems,
}) {
  final workspace = _savedWorkspaceById(workspaces, workspaceId);
  if (workspace == null) return List.unmodifiable(workspaces);

  return ecommerceOrderSavedWorkspacesWithDistinctUpdated(
    workspaces,
    ecommerceOrderSavedWorkspaceWithState(
      workspace: workspace,
      filter: filter,
      sortMode: sortMode,
      summaryItems: summaryItems,
    ),
  );
}

List<OrderSavedWorkspace> ecommerceOrderSavedWorkspacesWithPinned({
  required List<OrderSavedWorkspace> workspaces,
  required String workspaceId,
  required bool isPinned,
}) {
  return _savedWorkspaceShortcuts.pin(
    shortcuts: workspaces,
    shortcutId: workspaceId,
    isPinned: isPinned,
  );
}

List<OrderSavedWorkspace> ecommerceOrderSavedWorkspacesWithRenamed({
  required List<OrderSavedWorkspace> workspaces,
  required String workspaceId,
  required String label,
}) {
  return _savedWorkspaceShortcuts.rename(
    shortcuts: workspaces,
    shortcutId: workspaceId,
    label: label,
  );
}

List<OrderSavedWorkspace> ecommerceOrderSavedWorkspacesWithDescription({
  required List<OrderSavedWorkspace> workspaces,
  required String workspaceId,
  required String description,
}) {
  final normalizedDescription = description.trim();
  final workspace = _savedWorkspaceById(workspaces, workspaceId);
  if (workspace == null || normalizedDescription.isEmpty) {
    return List.unmodifiable(workspaces);
  }

  if (workspace.description == normalizedDescription) {
    return List.unmodifiable(workspaces);
  }

  return ecommerceOrderSavedWorkspacesWithUpdated(
    workspaces,
    workspace.copyWith(
      description: normalizedDescription,
      isDescriptionCustom: true,
    ),
  );
}

List<OrderSavedWorkspace> ecommerceOrderSavedWorkspacesWithAutoDescription({
  required List<OrderSavedWorkspace> workspaces,
  required String workspaceId,
  required List<OrderActiveFilterSummaryItem> summaryItems,
}) {
  final workspace = _savedWorkspaceById(workspaces, workspaceId);
  if (workspace == null) return List.unmodifiable(workspaces);

  return ecommerceOrderSavedWorkspacesWithUpdated(
    workspaces,
    ecommerceOrderSavedWorkspaceWithAutoDescription(
      workspace: workspace,
      summaryItems: summaryItems,
    ),
  );
}

List<OrderSavedWorkspace> ecommerceOrderSavedWorkspacesWithMoved({
  required List<OrderSavedWorkspace> workspaces,
  required String workspaceId,
  required OrderSavedWorkspaceMoveDirection direction,
}) {
  return _savedWorkspaceShortcuts.move(
    shortcuts: workspaces,
    shortcutId: workspaceId,
    direction: _workspaceShortcutMoveDirection(direction),
  );
}

List<OrderSavedWorkspace> ecommerceOrderSavedWorkspacesWithout({
  required List<OrderSavedWorkspace> workspaces,
  required String workspaceId,
}) {
  return _savedWorkspaceShortcuts.remove(
    shortcuts: workspaces,
    shortcutId: workspaceId,
  );
}

OrderSavedWorkspace? ecommerceOrderSavedWorkspaceForState({
  required List<OrderSavedWorkspace> workspaces,
  required OrderFilter filter,
  required OrderSortMode sortMode,
}) {
  return _savedWorkspaceShortcuts.forState(
    shortcuts: workspaces,
    matchesState: (workspace) => workspace.matches(filter, sortMode),
  );
}

OrderSavedWorkspace? ecommerceOrderSavedWorkspaceById({
  required List<OrderSavedWorkspace> workspaces,
  required String workspaceId,
}) {
  return _savedWorkspaceShortcuts.byId(
    shortcuts: workspaces,
    shortcutId: workspaceId,
  );
}

bool ecommerceOrderSavedWorkspaceCanMove({
  required List<OrderSavedWorkspace> workspaces,
  required String workspaceId,
  required OrderSavedWorkspaceMoveDirection direction,
}) {
  return _savedWorkspaceShortcuts.canMove(
    shortcuts: workspaces,
    shortcutId: workspaceId,
    direction: _workspaceShortcutMoveDirection(direction),
  );
}

List<OrderSavedWorkspace> ecommerceOrderSavedWorkspacesForDisplay(
  List<OrderSavedWorkspace> workspaces,
) {
  return _savedWorkspaceShortcuts.forDisplay(workspaces);
}

OrderSavedWorkspace? _savedWorkspaceById(
  List<OrderSavedWorkspace> workspaces,
  String workspaceId,
) {
  return ecommerceOrderSavedWorkspaceById(
    workspaces: workspaces,
    workspaceId: workspaceId,
  );
}

String _savedWorkspaceIdOf(OrderSavedWorkspace workspace) => workspace.id;

String _savedWorkspaceLabelOf(OrderSavedWorkspace workspace) => workspace.label;

bool _savedWorkspaceIsPinned(OrderSavedWorkspace workspace) =>
    workspace.isPinned;

final _savedWorkspaceShortcuts =
    WorkspaceShortcutDefinition<OrderSavedWorkspace>(
      idOf: _savedWorkspaceIdOf,
      labelOf: _savedWorkspaceLabelOf,
      isPinned: _savedWorkspaceIsPinned,
      matchesState: _savedWorkspaceMatchesShortcutState,
      stateChanged: _savedWorkspaceStateChanged,
      duplicateBuilder: _savedWorkspaceDuplicateBuilder,
      pinnedBuilder: _savedWorkspacePinnedBuilder,
      labelBuilder: _savedWorkspaceLabelBuilder,
    );

bool _savedWorkspaceMatchesShortcutState(
  OrderSavedWorkspace existingWorkspace,
  OrderSavedWorkspace targetWorkspace,
) {
  return existingWorkspace.matches(
    targetWorkspace.filter,
    targetWorkspace.sortMode,
  );
}

bool _savedWorkspaceStateChanged(
  OrderSavedWorkspace currentWorkspace,
  OrderSavedWorkspace updatedWorkspace,
) {
  return !currentWorkspace.matches(
    updatedWorkspace.filter,
    updatedWorkspace.sortMode,
  );
}

OrderSavedWorkspace _savedWorkspaceDuplicateBuilder(
  OrderSavedWorkspace workspace,
  WorkspaceShortcutDuplicateSpec duplicateSpec,
) {
  return workspace.copyWith(
    id: duplicateSpec.id,
    label: duplicateSpec.label,
    isPinned: duplicateSpec.isPinned,
  );
}

OrderSavedWorkspace _savedWorkspacePinnedBuilder(
  OrderSavedWorkspace workspace,
  bool isPinned,
) {
  return workspace.copyWith(isPinned: isPinned);
}

OrderSavedWorkspace _savedWorkspaceLabelBuilder(
  OrderSavedWorkspace workspace,
  String label,
) {
  return workspace.copyWith(label: label);
}

WorkspaceShortcutMoveDirection _workspaceShortcutMoveDirection(
  OrderSavedWorkspaceMoveDirection direction,
) {
  return switch (direction) {
    OrderSavedWorkspaceMoveDirection.earlier =>
      WorkspaceShortcutMoveDirection.earlier,
    OrderSavedWorkspaceMoveDirection.later =>
      WorkspaceShortcutMoveDirection.later,
  };
}
