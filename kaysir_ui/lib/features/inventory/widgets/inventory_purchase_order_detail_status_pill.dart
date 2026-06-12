import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_purchase_order_detail.dart';
import 'inventory_purchase_order_detail_status_styles.dart';

class InventoryPurchaseOrderDetailStatusPill extends StatelessWidget {
  const InventoryPurchaseOrderDetailStatusPill({
    super.key,
    required this.detail,
  });

  final InventoryPurchaseOrderDetail detail;

  @override
  Widget build(BuildContext context) {
    final color = purchaseOrderDetailStatusColor(
      detail.status,
      detail.isOverdue,
    );

    return AppStatusPill(
      label: detail.isOverdue ? 'Overdue' : detail.statusLabel,
      color: color,
      icon:
          detail.isOverdue
              ? Icons.priority_high_rounded
              : purchaseOrderDetailStatusIcon(detail.status),
      maxWidth: 160,
    );
  }
}
