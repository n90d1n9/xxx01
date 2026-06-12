import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../models/inventory_warehouse_detail.dart';
import 'inventory_warehouse_detail_support.dart';
import 'warehouse_detail_replenishment_action_footer.dart';
import 'warehouse_detail_replenishment_empty_state.dart';
import 'warehouse_detail_replenishment_facts.dart';
import 'warehouse_detail_replenishment_list.dart';
import 'warehouse_detail_replenishment_preview_data.dart';
import 'warehouse_detail_replenishment_status_pill.dart';

/// Warehouse detail panel that summarizes reorder needs and replenishment plans.
class InventoryWarehouseDetailReplenishmentPanel extends StatelessWidget {
  const InventoryWarehouseDetailReplenishmentPanel({
    super.key,
    required this.detail,
    this.onOpenStockQueue,
  });

  final InventoryWarehouseDetail detail;
  final VoidCallback? onOpenStockQueue;

  @override
  Widget build(BuildContext context) {
    final plans = detail.replenishmentPlans;

    return AppContentPanel(
      title: 'Replenishment Plan',
      subtitle:
          plans.isEmpty
              ? 'No replenishment needed for this warehouse'
              : '${compactInventoryWarehouseCount(plans.length, 'stock line', 'stock lines')} below reorder point',
      leadingIcon: Icons.add_shopping_cart_rounded,
      trailing: InventoryWarehouseReplenishmentStatusPill(
        hasPlans: plans.isNotEmpty,
        criticalCount: detail.criticalReplenishmentCount,
      ),
      child:
          plans.isEmpty
              ? InventoryWarehouseReplenishmentEmptyState(
                onOpenStockQueue: onOpenStockQueue,
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InventoryWarehouseReplenishmentFacts(
                    suggestedUnits: detail.replenishmentSuggestedUnits,
                    estimatedCost: detail.replenishmentEstimatedCost,
                  ),
                  const SizedBox(height: 14),
                  InventoryWarehouseReplenishmentList(plans: plans),
                  if (onOpenStockQueue != null) ...[
                    const SizedBox(height: 14),
                    InventoryWarehouseReplenishmentActionFooter(
                      onOpenStockQueue: onOpenStockQueue,
                    ),
                  ],
                ],
              ),
    );
  }
}

@Preview(name: 'Warehouse replenishment panel')
Widget inventoryWarehouseDetailReplenishmentPanelPreview() {
  return inventoryWarehouseReplenishmentPreviewScaffold(
    InventoryWarehouseDetailReplenishmentPanel(
      detail: inventoryWarehouseReplenishmentPreviewDetail(),
      onOpenStockQueue: () {},
    ),
  );
}
