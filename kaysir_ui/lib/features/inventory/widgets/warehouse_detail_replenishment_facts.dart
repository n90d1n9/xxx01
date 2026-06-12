import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../utils/inventory_formatters.dart';
import 'inventory_warehouse_detail_support.dart';
import 'warehouse_detail_replenishment_preview_data.dart';

/// Inline fact strip for suggested units and estimated reorder cost.
class InventoryWarehouseReplenishmentFacts extends StatelessWidget {
  const InventoryWarehouseReplenishmentFacts({
    super.key,
    required this.suggestedUnits,
    required this.estimatedCost,
  });

  final int suggestedUnits;
  final double estimatedCost;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        InventoryWarehouseDetailInlineFact(
          icon: Icons.add_shopping_cart_rounded,
          label: 'suggested units',
          value: formatInventoryNumber(suggestedUnits),
          color: Colors.blue.shade700,
        ),
        InventoryWarehouseDetailInlineFact(
          icon: Icons.payments_rounded,
          label: 'estimated cost',
          value: formatInventoryCurrency(estimatedCost),
          color: Colors.green.shade700,
        ),
      ],
    );
  }
}

@Preview(name: 'Warehouse replenishment facts')
Widget inventoryWarehouseReplenishmentFactsPreview() {
  final detail = inventoryWarehouseReplenishmentPreviewDetail();

  return inventoryWarehouseReplenishmentPreviewScaffold(
    InventoryWarehouseReplenishmentFacts(
      suggestedUnits: detail.replenishmentSuggestedUnits,
      estimatedCost: detail.replenishmentEstimatedCost,
    ),
  );
}
