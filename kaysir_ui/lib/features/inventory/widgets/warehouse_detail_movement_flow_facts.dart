import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_warehouse_detail.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_warehouse_detail_support.dart';
import 'warehouse_detail_movement_flow_preview_data.dart';

/// Inline fact strip for events, activity units, and share in a movement flow.
class InventoryWarehouseMovementFlowFacts extends StatelessWidget {
  const InventoryWarehouseMovementFlowFacts({
    super.key,
    required this.line,
    required this.totalActivityUnits,
    required this.accent,
  });

  final InventoryWarehouseMovementFlowLine line;
  final int totalActivityUnits;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        InventoryWarehouseDetailInlineFact(
          icon: Icons.list_alt_rounded,
          label: 'events',
          value: formatInventoryNumber(line.movementCount),
          color: accent,
        ),
        InventoryWarehouseDetailInlineFact(
          icon: Icons.inventory_2_rounded,
          label: 'activity units',
          value: formatInventoryNumber(line.totalUnits),
          color: Colors.teal.shade700,
        ),
        InventoryWarehouseDetailInlineFact(
          icon: Icons.percent_rounded,
          label: 'unit share',
          value:
              '${(line.unitShare(totalActivityUnits).clamp(0, 1) * 100).round()}%',
          color: accent,
        ),
      ],
    );
  }
}

@Preview(name: 'Warehouse movement flow facts')
Widget inventoryWarehouseMovementFlowFactsPreview() {
  final detail = inventoryWarehouseMovementFlowPreviewDetail();
  final line = inventoryWarehouseMovementFlowPreviewLine(detail);

  return inventoryWarehouseMovementFlowPreviewScaffold(
    InventoryWarehouseMovementFlowFacts(
      line: line,
      totalActivityUnits: detail.movementActivityUnits,
      accent: Colors.green.shade700,
    ),
  );
}
