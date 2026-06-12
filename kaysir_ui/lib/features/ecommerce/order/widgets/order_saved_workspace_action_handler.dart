import 'package:flutter/material.dart';

import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_action.dart';
import 'order_saved_workspace_action_context.dart';
import 'order_saved_workspace_description_dialog.dart';
import 'order_saved_workspace_details_surface.dart';
import 'order_saved_workspace_rename_dialog.dart';

export 'order_saved_workspace_action_context.dart';

Future<bool> handleOrderSavedWorkspaceAction({
  required BuildContext context,
  required OrderSavedWorkspace workspace,
  required OrderSavedWorkspaceAction action,
  OrderSavedWorkspaceActionContext? actionContext,
  OrderSavedWorkspaceActionDeleted? onDeleted,
  OrderSavedWorkspaceActionDuplicated? onDuplicated,
  OrderSavedWorkspaceActionPinnedChanged? onPinnedChanged,
  OrderSavedWorkspaceActionRenamed? onRenamed,
  OrderSavedWorkspaceActionDescriptionChanged? onDescriptionChanged,
  OrderSavedWorkspaceActionDescriptionReset? onDescriptionReset,
  OrderSavedWorkspaceActionMoved? onMoved,
  bool canMoveEarlier = true,
  bool canMoveLater = true,
  VoidCallback? onActionHandled,
}) async {
  final effectiveContext =
      actionContext ??
      OrderSavedWorkspaceActionContext(
        onDeleted: onDeleted,
        onDuplicated: onDuplicated,
        onPinnedChanged: onPinnedChanged,
        onRenamed: onRenamed,
        onDescriptionChanged: onDescriptionChanged,
        onDescriptionReset: onDescriptionReset,
        onMoved: onMoved,
        canMoveEarlier: canMoveEarlier,
        canMoveLater: canMoveLater,
        onActionHandled: onActionHandled,
      );

  switch (action) {
    case OrderSavedWorkspaceAction.details:
      await showOrderSavedWorkspaceDetailsSurface(
        context: context,
        workspace: workspace,
        actionEntries: orderSavedWorkspaceActionEntries(
          workspace: workspace,
          order: orderSavedWorkspaceDetailsActionOrder,
          capabilities: effectiveContext.capabilities,
        ),
        onActionSelected:
            (selectedAction) => _handleDetailsSelectedAction(
              context: context,
              workspace: workspace,
              action: selectedAction,
              actionContext: effectiveContext,
            ),
      );
      return true;
    case OrderSavedWorkspaceAction.editNote:
      final callback = effectiveContext.onDescriptionChanged;
      if (callback == null) return false;

      final description = await showOrderSavedWorkspaceDescriptionDialog(
        context: context,
        workspace: workspace,
      );
      if (description == null || !context.mounted) return false;

      callback(workspace, description);
      effectiveContext.onActionHandled?.call();
      return true;
    case OrderSavedWorkspaceAction.resetNote:
      final callback = effectiveContext.onDescriptionReset;
      if (callback == null) return false;

      callback(workspace);
      effectiveContext.onActionHandled?.call();
      return true;
    case OrderSavedWorkspaceAction.moveEarlier:
      return _moveSavedWorkspace(
        workspace: workspace,
        direction: OrderSavedWorkspaceMoveDirection.earlier,
        canMove: effectiveContext.canMoveEarlier,
        actionContext: effectiveContext,
      );
    case OrderSavedWorkspaceAction.moveLater:
      return _moveSavedWorkspace(
        workspace: workspace,
        direction: OrderSavedWorkspaceMoveDirection.later,
        canMove: effectiveContext.canMoveLater,
        actionContext: effectiveContext,
      );
    case OrderSavedWorkspaceAction.duplicate:
      final callback = effectiveContext.onDuplicated;
      if (callback == null) return false;

      callback(workspace);
      effectiveContext.onActionHandled?.call();
      return true;
    case OrderSavedWorkspaceAction.rename:
      final callback = effectiveContext.onRenamed;
      if (callback == null) return false;

      final label = await showOrderSavedWorkspaceRenameDialog(
        context: context,
        workspace: workspace,
      );
      if (label == null || !context.mounted) return false;

      callback(workspace, label);
      effectiveContext.onActionHandled?.call();
      return true;
    case OrderSavedWorkspaceAction.togglePin:
      final callback = effectiveContext.onPinnedChanged;
      if (callback == null) return false;

      callback(workspace, !workspace.isPinned);
      effectiveContext.onActionHandled?.call();
      return true;
    case OrderSavedWorkspaceAction.delete:
      final callback = effectiveContext.onDeleted;
      if (callback == null) return false;

      callback(workspace);
      effectiveContext.onActionHandled?.call();
      return true;
  }
}

Future<void> _handleDetailsSelectedAction({
  required BuildContext context,
  required OrderSavedWorkspace workspace,
  required OrderSavedWorkspaceAction action,
  required OrderSavedWorkspaceActionContext actionContext,
}) async {
  Navigator.of(context).pop();
  await Future<void>.delayed(Duration.zero);
  if (!context.mounted) return;

  await handleOrderSavedWorkspaceAction(
    context: context,
    workspace: workspace,
    action: action,
    actionContext: actionContext,
  );
}

bool _moveSavedWorkspace({
  required OrderSavedWorkspace workspace,
  required OrderSavedWorkspaceMoveDirection direction,
  required bool canMove,
  required OrderSavedWorkspaceActionContext actionContext,
}) {
  final callback = actionContext.onMoved;
  if (!canMove || callback == null) return false;

  callback(workspace, direction);
  actionContext.onActionHandled?.call();
  return true;
}
