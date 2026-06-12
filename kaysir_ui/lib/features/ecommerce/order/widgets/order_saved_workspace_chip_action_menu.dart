import 'package:flutter/material.dart';

import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_action.dart';
import 'order_saved_workspace_action_handler.dart';
import 'order_saved_workspace_accessibility.dart';
import 'order_saved_workspace_popup_menu_item.dart';

class OrderSavedWorkspaceChipActionMenu extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final Color foregroundColor;
  final VoidCallback? onDeleted;
  final VoidCallback? onDuplicated;
  final ValueChanged<bool>? onPinnedChanged;
  final ValueChanged<String>? onRenamed;
  final ValueChanged<String>? onDescriptionChanged;
  final VoidCallback? onDescriptionReset;
  final ValueChanged<OrderSavedWorkspaceMoveDirection>? onMoved;
  final bool canMoveEarlier;
  final bool canMoveLater;

  const OrderSavedWorkspaceChipActionMenu({
    super.key,
    required this.workspace,
    required this.foregroundColor,
    required this.onDeleted,
    required this.onDuplicated,
    required this.onPinnedChanged,
    required this.onRenamed,
    required this.onDescriptionChanged,
    required this.onDescriptionReset,
    required this.onMoved,
    required this.canMoveEarlier,
    required this.canMoveLater,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: PopupMenuButton<OrderSavedWorkspaceAction>(
        key: ValueKey('order_saved_workspace_actions_${workspace.id}'),
        tooltip: orderSavedWorkspaceActionsTooltip(workspace),
        onSelected: (action) => _handleAction(context, action),
        icon: Icon(Icons.more_horiz_rounded, color: foregroundColor),
        iconSize: 18,
        padding: EdgeInsets.zero,
        itemBuilder: _actionMenuItems,
      ),
    );
  }

  List<PopupMenuEntry<OrderSavedWorkspaceAction>> _actionMenuItems(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    const keyPrefix = 'order_saved_workspace';
    final actionContext = _actionContext();
    final actionEntries = orderSavedWorkspaceActionEntries(
      workspace: workspace,
      order: orderSavedWorkspaceChipActionOrder,
      capabilities: actionContext.toCapabilities(includeDetails: true),
    );

    return [
      for (final entry in actionEntries)
        orderSavedWorkspacePopupMenuItem(
          keyPrefix: keyPrefix,
          workspace: workspace,
          action: entry.action,
          enabled: entry.enabled,
          duplicateIcon: Icons.content_copy_rounded,
          deleteIcon: Icons.close_rounded,
          deleteLabel: 'Remove',
          deleteColor: theme.colorScheme.error,
        ),
    ];
  }

  Future<void> _handleAction(
    BuildContext context,
    OrderSavedWorkspaceAction action,
  ) async {
    await handleOrderSavedWorkspaceAction(
      context: context,
      workspace: workspace,
      action: action,
      actionContext: _actionContext(),
    );
  }

  OrderSavedWorkspaceActionContext _actionContext() {
    return OrderSavedWorkspaceActionContext(
      onDeleted: onDeleted == null ? null : (_) => onDeleted!(),
      onDuplicated: onDuplicated == null ? null : (_) => onDuplicated!(),
      onPinnedChanged:
          onPinnedChanged == null
              ? null
              : (_, isPinned) => onPinnedChanged!(isPinned),
      onRenamed: onRenamed == null ? null : (_, label) => onRenamed!(label),
      onDescriptionChanged:
          onDescriptionChanged == null
              ? null
              : (_, description) => onDescriptionChanged!(description),
      onDescriptionReset:
          onDescriptionReset == null ? null : (_) => onDescriptionReset!(),
      onMoved: onMoved == null ? null : (_, direction) => onMoved!(direction),
      canMoveEarlier: canMoveEarlier,
      canMoveLater: canMoveLater,
    );
  }
}
