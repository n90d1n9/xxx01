import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_replenishment_plan.dart';
import 'low_stock_replenishment_components.dart';
import 'warehouse_detail_replenishment_preview_data.dart';

/// List of replenishment plan tiles scoped to a single warehouse detail.
class InventoryWarehouseReplenishmentList extends StatelessWidget {
  const InventoryWarehouseReplenishmentList({super.key, required this.plans});

  final List<InventoryReplenishmentPlan> plans;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < plans.length; index += 1) ...[
          LowStockReplenishmentTile(
            plan: plans[index],
            showRestockAction: false,
          ),
          if (index != plans.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

@Preview(name: 'Warehouse replenishment list')
Widget inventoryWarehouseReplenishmentListPreview() {
  final detail = inventoryWarehouseReplenishmentPreviewDetail();

  return inventoryWarehouseReplenishmentPreviewScaffold(
    InventoryWarehouseReplenishmentList(plans: detail.replenishmentPlans),
  );
}
