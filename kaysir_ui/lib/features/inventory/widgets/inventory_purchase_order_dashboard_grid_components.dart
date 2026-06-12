import 'package:flutter/material.dart';

import '../models/inventory_purchase_order_dashboard.dart';
import '../models/inventory_purchase_order_workspace.dart';
import 'inventory_purchase_order_dashboard_low_stock_components.dart';
import 'inventory_purchase_order_dashboard_movement_components.dart';
import 'inventory_purchase_order_dashboard_receiving_components.dart';

class InventoryPurchaseOrderDashboardGrid extends StatelessWidget {
  const InventoryPurchaseOrderDashboardGrid({
    super.key,
    required this.dashboard,
    this.onOpenProduct,
    this.onOpenOrder,
  });

  final InventoryPurchaseOrderDashboard dashboard;
  final ValueChanged<InventoryPurchaseOrderLowStockProduct>? onOpenProduct;
  final ValueChanged<InventoryPurchaseOrderRecord>? onOpenOrder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lowStockPanel = InventoryPurchaseOrderLowStockPanel(
          products: dashboard.lowStockProducts,
          onOpenProduct: onOpenProduct,
        );
        final movementPanel = InventoryPurchaseOrderMovementPanel(
          movements: dashboard.recentMovements,
        );
        final receivingPanel = InventoryPurchaseOrderReceivingPanel(
          records: dashboard.receivingOrders,
          onOpenOrder: onOpenOrder,
        );

        if (constraints.maxWidth < 980) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              lowStockPanel,
              const SizedBox(height: 16),
              movementPanel,
              const SizedBox(height: 16),
              receivingPanel,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: lowStockPanel),
                const SizedBox(width: 16),
                Expanded(child: movementPanel),
              ],
            ),
            const SizedBox(height: 16),
            receivingPanel,
          ],
        );
      },
    );
  }
}
