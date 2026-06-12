import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_detail_pill.dart';

class OrderSavedWorkspaceDetailsFilterGrid extends StatelessWidget {
  final OrderSavedWorkspace workspace;

  const OrderSavedWorkspaceDetailsFilterGrid({
    super.key,
    required this.workspace,
  });

  @override
  Widget build(BuildContext context) {
    final detailItems = ecommerceOrderSavedWorkspaceDetailItems(workspace);

    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children: [
        for (final item in detailItems)
          OrderSavedWorkspaceDetailPill(
            key: ValueKey('order_saved_workspace_detail_${item.id}'),
            label: item.label,
            value: item.value,
          ),
      ],
    );
  }
}
