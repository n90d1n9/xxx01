import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_action.dart';
import 'order_saved_workspace_action_presentation.dart';

typedef OrderSavedWorkspaceDetailsActionSelected =
    Future<void> Function(OrderSavedWorkspaceAction action);

class OrderSavedWorkspaceDetailsActionBar extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final List<OrderSavedWorkspaceActionEntry> actionEntries;
  final OrderSavedWorkspaceDetailsActionSelected? onActionSelected;

  const OrderSavedWorkspaceDetailsActionBar({
    super.key,
    required this.workspace,
    this.actionEntries = const [],
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final callback = onActionSelected;
    if (actionEntries.isEmpty || callback == null) {
      return const SizedBox.shrink();
    }

    return Wrap(
      key: const ValueKey('order_saved_workspace_details_actions'),
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children: [
        for (final entry in actionEntries)
          _OrderSavedWorkspaceDetailsActionButton(
            workspace: workspace,
            entry: entry,
            onSelected: callback,
          ),
      ],
    );
  }
}

class _OrderSavedWorkspaceDetailsActionButton extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final OrderSavedWorkspaceActionEntry entry;
  final OrderSavedWorkspaceDetailsActionSelected onSelected;

  const _OrderSavedWorkspaceDetailsActionButton({
    required this.workspace,
    required this.entry,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presentation = orderSavedWorkspaceActionPresentation(
      action: entry.action,
      workspace: workspace,
      deleteColor: theme.colorScheme.error,
      duplicateIcon: Icons.content_copy_rounded,
      isDeleteDestructive: true,
    );
    final foregroundColor =
        presentation.isDestructive ? theme.colorScheme.error : null;

    return OutlinedButton.icon(
      key: ValueKey(
        'order_saved_workspace_details_action_'
        '${entry.action.keySuffix}_${workspace.id}',
      ),
      onPressed: entry.enabled ? () => onSelected(entry.action) : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        side:
            foregroundColor == null
                ? null
                : BorderSide(color: foregroundColor.withValues(alpha: 0.5)),
      ),
      icon: Icon(presentation.icon, size: 18),
      label: Text(presentation.label),
    );
  }
}
