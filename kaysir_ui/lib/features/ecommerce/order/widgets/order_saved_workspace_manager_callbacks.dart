import 'package:flutter/foundation.dart';

import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_action.dart';
import 'order_saved_workspace_action_context.dart';

class OrderSavedWorkspaceManagerCallbacks {
  final ValueChanged<OrderSavedWorkspace>? onSelected;
  final ValueChanged<OrderSavedWorkspace>? onDeleted;
  final ValueChanged<OrderSavedWorkspace>? onDuplicated;
  final void Function(OrderSavedWorkspace workspace, bool isPinned)?
  onPinnedChanged;
  final void Function(OrderSavedWorkspace workspace, String label)? onRenamed;
  final void Function(OrderSavedWorkspace workspace, String description)?
  onDescriptionChanged;
  final ValueChanged<OrderSavedWorkspace>? onDescriptionReset;
  final void Function(
    OrderSavedWorkspace workspace,
    OrderSavedWorkspaceMoveDirection direction,
  )?
  onMoved;

  const OrderSavedWorkspaceManagerCallbacks({
    this.onSelected,
    this.onDeleted,
    this.onDuplicated,
    this.onPinnedChanged,
    this.onRenamed,
    this.onDescriptionChanged,
    this.onDescriptionReset,
    this.onMoved,
  });

  static const empty = OrderSavedWorkspaceManagerCallbacks();

  bool get canSelect => onSelected != null;

  bool get hasRowActions =>
      onDeleted != null ||
      onDuplicated != null ||
      onPinnedChanged != null ||
      onRenamed != null ||
      onDescriptionChanged != null ||
      onDescriptionReset != null ||
      onMoved != null;

  OrderSavedWorkspaceActionCapabilities actionCapabilities({
    required bool canMoveEarlier,
    required bool canMoveLater,
  }) {
    return actionContext(
      canMoveEarlier: canMoveEarlier,
      canMoveLater: canMoveLater,
    ).capabilities;
  }

  OrderSavedWorkspaceActionContext actionContext({
    required bool canMoveEarlier,
    required bool canMoveLater,
    VoidCallback? onActionHandled,
  }) {
    return OrderSavedWorkspaceActionContext(
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
  }
}
