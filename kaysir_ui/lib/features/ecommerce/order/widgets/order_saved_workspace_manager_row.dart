import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_action.dart';
import 'order_saved_workspace_action_handler.dart';
import 'order_saved_workspace_manager_badge.dart';
import 'order_saved_workspace_manager_callbacks.dart';
import 'order_saved_workspace_manager_row_action_menu.dart';
import 'order_saved_workspace_manager_row_presentation.dart';
import 'order_saved_workspace_note_marker.dart';

class OrderSavedWorkspaceManagerRow extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final bool isActive;
  final OrderSavedWorkspaceManagerCallbacks callbacks;
  final bool canMoveEarlier;
  final bool canMoveLater;

  const OrderSavedWorkspaceManagerRow({
    super.key,
    required this.workspace,
    required this.isActive,
    required this.callbacks,
    required this.canMoveEarlier,
    required this.canMoveLater,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presentation = OrderSavedWorkspaceManagerRowPresentation(
      workspace: workspace,
      isActive: isActive,
      canSelect: callbacks.canSelect,
    );
    final colors = presentation.colorsFor(theme);

    return Container(
      key: ValueKey('order_saved_workspace_manager_${workspace.id}'),
      padding: const EdgeInsets.all(POSUiTokens.gap),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(presentation.leadingIcon, size: 18, color: colors.leading),
          const SizedBox(width: POSUiTokens.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        workspace.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.title,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (presentation.showNoteMarker) ...[
                      const SizedBox(width: 6),
                      OrderSavedWorkspaceNoteMarker(
                        workspace: workspace,
                        selected: isActive,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  workspace.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.description,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final badge in presentation.badges)
                      OrderSavedWorkspaceManagerBadge(label: badge),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: POSUiTokens.gap),
          IconButton(
            key: ValueKey(
              'order_saved_workspace_manager_details_${workspace.id}',
            ),
            tooltip: 'Details',
            onPressed: () => _showDetails(context),
            icon: const Icon(Icons.info_outline_rounded),
          ),
          OrderSavedWorkspaceManagerRowActionMenu(
            workspace: workspace,
            callbacks: callbacks,
            canMoveEarlier: canMoveEarlier,
            canMoveLater: canMoveLater,
          ),
          TextButton.icon(
            key: ValueKey(
              'order_saved_workspace_manager_apply_${workspace.id}',
            ),
            onPressed:
                !presentation.canApply
                    ? null
                    : () {
                      callbacks.onSelected!(workspace);
                      Navigator.of(context).pop();
                    },
            icon: Icon(presentation.applyIcon, size: 16),
            label: Text(presentation.applyLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _showDetails(BuildContext context) {
    return handleOrderSavedWorkspaceAction(
      context: context,
      workspace: workspace,
      action: OrderSavedWorkspaceAction.details,
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
