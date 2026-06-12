import 'package:flutter/foundation.dart';

import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_action.dart';

typedef OrderSavedWorkspaceActionDeleted =
    void Function(OrderSavedWorkspace workspace);
typedef OrderSavedWorkspaceActionDuplicated =
    void Function(OrderSavedWorkspace workspace);
typedef OrderSavedWorkspaceActionPinnedChanged =
    void Function(OrderSavedWorkspace workspace, bool isPinned);
typedef OrderSavedWorkspaceActionRenamed =
    void Function(OrderSavedWorkspace workspace, String label);
typedef OrderSavedWorkspaceActionDescriptionChanged =
    void Function(OrderSavedWorkspace workspace, String description);
typedef OrderSavedWorkspaceActionDescriptionReset =
    void Function(OrderSavedWorkspace workspace);
typedef OrderSavedWorkspaceActionMoved =
    void Function(
      OrderSavedWorkspace workspace,
      OrderSavedWorkspaceMoveDirection direction,
    );

class OrderSavedWorkspaceActionContext {
  final OrderSavedWorkspaceActionDeleted? onDeleted;
  final OrderSavedWorkspaceActionDuplicated? onDuplicated;
  final OrderSavedWorkspaceActionPinnedChanged? onPinnedChanged;
  final OrderSavedWorkspaceActionRenamed? onRenamed;
  final OrderSavedWorkspaceActionDescriptionChanged? onDescriptionChanged;
  final OrderSavedWorkspaceActionDescriptionReset? onDescriptionReset;
  final OrderSavedWorkspaceActionMoved? onMoved;
  final bool canMoveEarlier;
  final bool canMoveLater;
  final VoidCallback? onActionHandled;

  const OrderSavedWorkspaceActionContext({
    this.onDeleted,
    this.onDuplicated,
    this.onPinnedChanged,
    this.onRenamed,
    this.onDescriptionChanged,
    this.onDescriptionReset,
    this.onMoved,
    this.canMoveEarlier = true,
    this.canMoveLater = true,
    this.onActionHandled,
  });

  static const empty = OrderSavedWorkspaceActionContext();

  OrderSavedWorkspaceActionCapabilities get capabilities => toCapabilities();

  OrderSavedWorkspaceActionCapabilities toCapabilities({
    bool includeDetails = false,
  }) {
    return OrderSavedWorkspaceActionCapabilities(
      includeDetails: includeDetails,
      canEditNote: onDescriptionChanged != null,
      canResetNote: onDescriptionReset != null,
      canMove: onMoved != null,
      canMoveEarlier: canMoveEarlier,
      canMoveLater: canMoveLater,
      canDuplicate: onDuplicated != null,
      canRename: onRenamed != null,
      canTogglePin: onPinnedChanged != null,
      canDelete: onDeleted != null,
    );
  }
}
