import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

class OrderSavedWorkspaceManagerEmptyState extends StatelessWidget {
  const OrderSavedWorkspaceManagerEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const ValueKey('order_saved_workspace_manager_empty'),
      padding: const EdgeInsets.all(POSUiTokens.gapLarge),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.manage_search_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: POSUiTokens.gap),
          Expanded(
            child: Text(
              'No saved workspaces match this search.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
