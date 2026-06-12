import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import 'inventory_warehouse_detail_support.dart';
import 'warehouse_detail_stock_readiness_preview_data.dart';

/// Status pill for the stock readiness panel's healthy or attention state.
class InventoryWarehouseStockReadinessStatusPill extends StatelessWidget {
  const InventoryWarehouseStockReadinessStatusPill({
    super.key,
    required this.hasAttention,
    required this.attentionCount,
  });

  final bool hasAttention;
  final int attentionCount;

  @override
  Widget build(BuildContext context) {
    if (hasAttention) {
      return AppStatusPill(
        label: compactInventoryWarehouseCount(
          attentionCount,
          'alert',
          'alerts',
        ),
        icon: Icons.warning_amber_rounded,
        color: Colors.deepOrange.shade700,
        maxWidth: 120,
      );
    }

    return AppStatusPill(
      label: 'Healthy',
      icon: Icons.check_circle_outline_rounded,
      color: Colors.green.shade700,
      maxWidth: 120,
    );
  }
}

@Preview(name: 'Warehouse stock readiness status')
Widget inventoryWarehouseStockReadinessStatusPillPreview() {
  return inventoryWarehouseStockReadinessPreviewScaffold(
    const InventoryWarehouseStockReadinessStatusPill(
      hasAttention: true,
      attentionCount: 2,
    ),
  );
}
