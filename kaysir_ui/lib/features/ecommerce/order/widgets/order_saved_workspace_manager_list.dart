import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace.dart';
import '../models/order_saved_workspace_manager_view.dart';
import 'order_saved_workspace_manager_empty_state.dart';
import 'order_saved_workspace_manager_callbacks.dart';
import 'order_saved_workspace_manager_row.dart';

class OrderSavedWorkspaceManagerList extends StatelessWidget {
  final OrderSavedWorkspaceManagerView managerView;
  final List<OrderSavedWorkspace> workspaces;
  final String? activeWorkspaceId;
  final OrderSavedWorkspaceManagerCallbacks callbacks;

  const OrderSavedWorkspaceManagerList({
    super.key,
    required this.managerView,
    required this.workspaces,
    required this.activeWorkspaceId,
    required this.callbacks,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 204),
      child:
          managerView.isEmpty
              ? const OrderSavedWorkspaceManagerEmptyState()
              : ListView.separated(
                scrollCacheExtent: const ScrollCacheExtent.pixels(600),
                shrinkWrap: true,
                itemCount: managerView.visibleWorkspaces.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: POSUiTokens.gap),
                itemBuilder: (context, index) {
                  final workspace = managerView.visibleWorkspaces[index];

                  return OrderSavedWorkspaceManagerRow(
                    workspace: workspace,
                    isActive: workspace.id == activeWorkspaceId,
                    callbacks: callbacks,
                    canMoveEarlier: ecommerceOrderSavedWorkspaceCanMove(
                      workspaces: workspaces,
                      workspaceId: workspace.id,
                      direction: OrderSavedWorkspaceMoveDirection.earlier,
                    ),
                    canMoveLater: ecommerceOrderSavedWorkspaceCanMove(
                      workspaces: workspaces,
                      workspaceId: workspace.id,
                      direction: OrderSavedWorkspaceMoveDirection.later,
                    ),
                  );
                },
              ),
    );
  }
}
