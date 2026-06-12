import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_details_header_presentation.dart';
import 'order_saved_workspace_manager_badge.dart';

class OrderSavedWorkspaceDetailsHeader extends StatelessWidget {
  final OrderSavedWorkspace workspace;

  const OrderSavedWorkspaceDetailsHeader({super.key, required this.workspace});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presentation =
        OrderSavedWorkspaceDetailsHeaderPresentation.fromWorkspace(workspace);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: POSUiTokens.gap,
          runSpacing: POSUiTokens.gap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              presentation.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            for (final badge in presentation.badges)
              OrderSavedWorkspaceManagerBadge(
                icon: badge.icon,
                label: badge.label,
              ),
          ],
        ),
        const SizedBox(height: POSUiTokens.gap),
        Text(
          presentation.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
