import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace.dart';
import '../models/order_saved_workspace_panel_view.dart';
import 'order_saved_workspace_chip_strip.dart';
import 'order_saved_workspace_empty_state.dart';
import 'order_saved_workspace_manager_dialog.dart';
import 'order_saved_workspace_modified_notice.dart';
import 'order_saved_workspace_panel_header.dart';

class OrderSavedWorkspacePanel extends StatelessWidget {
  final List<OrderSavedWorkspace> workspaces;
  final String? activeWorkspaceId;
  final bool isActiveWorkspaceModified;
  final String? activeWorkspaceChangeSummary;
  final bool canSaveCurrent;
  final VoidCallback? onSaveCurrent;
  final VoidCallback? onUpdateActive;
  final VoidCallback? onRevertActive;
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

  const OrderSavedWorkspacePanel({
    super.key,
    this.workspaces = const [],
    this.activeWorkspaceId,
    this.isActiveWorkspaceModified = false,
    this.activeWorkspaceChangeSummary,
    this.canSaveCurrent = false,
    this.onSaveCurrent,
    this.onUpdateActive,
    this.onRevertActive,
    this.onSelected,
    this.onDeleted,
    this.onDuplicated,
    this.onPinnedChanged,
    this.onRenamed,
    this.onDescriptionChanged,
    this.onDescriptionReset,
    this.onMoved,
  });

  @override
  Widget build(BuildContext context) {
    if (workspaces.isEmpty && !canSaveCurrent) {
      return const SizedBox.shrink();
    }

    final panelView = ecommerceOrderSavedWorkspacePanelView(
      workspaces: workspaces,
      activeWorkspaceId: activeWorkspaceId,
    );
    final canUpdateActive = isActiveWorkspaceModified && onUpdateActive != null;
    final canRevertActive = isActiveWorkspaceModified && onRevertActive != null;

    return Column(
      key: const ValueKey('order_saved_workspace_panel'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrderSavedWorkspacePanelHeader(
          view: panelView,
          isActiveWorkspaceModified: isActiveWorkspaceModified,
          canSaveCurrent: canSaveCurrent,
          onSaveCurrent: onSaveCurrent,
          onManage:
              panelView.hasWorkspaces
                  ? () => showOrderSavedWorkspaceManagerDialog(
                    context: context,
                    workspaces: workspaces,
                    activeWorkspaceId: activeWorkspaceId,
                    onSelected: onSelected,
                    onDeleted: onDeleted,
                    onDuplicated: onDuplicated,
                    onPinnedChanged: onPinnedChanged,
                    onRenamed: onRenamed,
                    onDescriptionChanged: onDescriptionChanged,
                    onDescriptionReset: onDescriptionReset,
                    onMoved: onMoved,
                  )
                  : null,
        ),
        if (canUpdateActive || canRevertActive) ...[
          const SizedBox(height: POSUiTokens.gap),
          OrderSavedWorkspaceModifiedNotice(
            workspaceLabel: panelView.activeWorkspaceLabel,
            changeSummary: activeWorkspaceChangeSummary,
            onRevertActive: canRevertActive ? onRevertActive : null,
            onUpdateActive: canUpdateActive ? onUpdateActive : null,
          ),
        ],
        if (workspaces.isEmpty && canSaveCurrent) ...[
          const SizedBox(height: POSUiTokens.gap),
          const OrderSavedWorkspaceEmptyState(),
        ] else if (workspaces.isNotEmpty) ...[
          const SizedBox(height: POSUiTokens.gap),
          OrderSavedWorkspaceChipStrip(
            workspaces: workspaces,
            activeWorkspaceId: activeWorkspaceId,
            onSelected: onSelected,
            onDeleted: onDeleted,
            onDuplicated: onDuplicated,
            onPinnedChanged: onPinnedChanged,
            onRenamed: onRenamed,
            onDescriptionChanged: onDescriptionChanged,
            onDescriptionReset: onDescriptionReset,
            onMoved: onMoved,
          ),
        ],
      ],
    );
  }
}
