import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import 'inventory_warehouse_detail_support.dart';
import 'warehouse_detail_replenishment_preview_data.dart';

/// Status pill for healthy replenishment state or critical reorder pressure.
class InventoryWarehouseReplenishmentStatusPill extends StatelessWidget {
  const InventoryWarehouseReplenishmentStatusPill({
    super.key,
    required this.hasPlans,
    required this.criticalCount,
  });

  final bool hasPlans;
  final int criticalCount;

  @override
  Widget build(BuildContext context) {
    if (!hasPlans) {
      return AppStatusPill(
        label: 'Healthy',
        icon: Icons.check_circle_outline_rounded,
        color: Colors.green.shade700,
        maxWidth: 120,
      );
    }

    return AppStatusPill(
      label: compactInventoryWarehouseCount(
        criticalCount,
        'critical',
        'critical',
      ),
      icon: Icons.priority_high_rounded,
      color: criticalCount > 0 ? Colors.red.shade700 : Colors.orange.shade700,
      maxWidth: 130,
    );
  }
}

@Preview(name: 'Warehouse replenishment status')
Widget inventoryWarehouseReplenishmentStatusPillPreview() {
  return inventoryWarehouseReplenishmentPreviewScaffold(
    const InventoryWarehouseReplenishmentStatusPill(
      hasPlans: true,
      criticalCount: 2,
    ),
  );
}
