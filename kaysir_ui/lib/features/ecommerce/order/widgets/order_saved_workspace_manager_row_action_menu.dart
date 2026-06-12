import 'package:flutter/material.dart';

import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_action.dart';
import 'order_saved_workspace_action_handler.dart';
import 'order_saved_workspace_manager_callbacks.dart';
import 'order_saved_workspace_popup_menu_item.dart';

class OrderSavedWorkspaceManagerRowActionMenu extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final OrderSavedWorkspaceManagerCallbacks callbacks;
  final bool canMoveEarlier;
  final bool canMoveLater;

  const OrderSavedWorkspaceManagerRowActionMenu({
    super.key,
    required this.workspace,
    required this.callbacks,
    required this.canMoveEarlier,
    required this.canMoveLater,
  });

  @override
  Widget build(BuildContext context) {
    final actionEntries = orderSavedWorkspaceActionEntries(
      workspace: workspace,
      order: orderSavedWorkspaceManagerActionOrder,
      capabilities: callbacks.actionCapabilities(
        canMoveEarlier: canMoveEarlier,
        canMoveLater: canMoveLater,
      ),
    );
    if (actionEntries.isEmpty) return const SizedBox.shrink();

    const keyPrefix = 'order_saved_workspace_manager';

    return PopupMenuButton<OrderSavedWorkspaceAction>(
      key: ValueKey('order_saved_workspace_manager_actions_${workspace.id}'),
      tooltip: 'Workspace actions',
      onSelected: (action) => _handleAction(context, action),
      itemBuilder:
          (context) => [
            for (final entry in actionEntries)
              orderSavedWorkspacePopupMenuItem(
                keyPrefix: keyPrefix,
                workspace: workspace,
                action: entry.action,
                enabled: entry.enabled,
                isDeleteDestructive: true,
              ),
          ],
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    OrderSavedWorkspaceAction action,
  ) async {
    await handleOrderSavedWorkspaceAction(
      context: context,
      workspace: workspace,
      action: action,
      actionContext: callbacks.actionContext(
        canMoveEarlier: canMoveEarlier,
        canMoveLater: canMoveLater,
        onActionHandled: () {
          if (!context.mounted) return;
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
