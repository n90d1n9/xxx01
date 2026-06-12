import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_warehouse_detail.dart';
import 'inventory_separated_list.dart';
import 'inventory_warehouse_detail_support.dart';
import 'warehouse_detail_stock_health_preview_data.dart';
import 'warehouse_detail_stock_health_status.dart';
import 'warehouse_detail_stock_health_tile.dart';

/// Warehouse detail panel that summarizes stock-health pressure by status.
class InventoryWarehouseDetailStockHealthPanel extends StatelessWidget {
  const InventoryWarehouseDetailStockHealthPanel({
    super.key,
    required this.detail,
  });

  final InventoryWarehouseDetail detail;

  @override
  Widget build(BuildContext context) {
    final isEmpty = detail.stockRecords.isEmpty;
    final healthLines = detail.stockHealthLines;
    final attentionCount =
        detail.lowStockLineCount + detail.outOfStockLineCount;
    final tone = inventoryWarehouseStockHealthTone(context, detail);

    return AppContentPanel(
      title: 'Stock Health',
      subtitle:
          isEmpty
              ? 'Stock health will appear once products are assigned here'
              : attentionCount == 0
              ? 'All stock lines are above reorder thresholds'
              : '${compactInventoryWarehouseCount(attentionCount, 'line', 'lines')} need replenishment attention',
      leadingIcon: Icons.health_and_safety_rounded,
      trailing:
          isEmpty
              ? null
              : AppStatusPill(
                label: tone.label,
                icon: tone.icon,
                color: tone.color,
                maxWidth: 120,
              ),
      child:
          isEmpty
              ? const AppEmptyState(
                title: 'No stock health yet',
                message:
                    'Create stock lines in this warehouse to monitor reorder pressure.',
                icon: Icons.health_and_safety_outlined,
              )
              : InventorySeparatedList<InventoryWarehouseStockHealthLine>(
                items: healthLines,
                itemBuilder: (context, line, index) {
                  return InventoryWarehouseStockHealthTile(
                    line: line,
                    totalStockLines: detail.stockLineCount,
                    totalUnits: detail.totalUnits,
                    totalValue: detail.stockValue,
                  );
                },
              ),
    );
  }
}

@Preview(name: 'Warehouse stock health panel')
Widget inventoryWarehouseDetailStockHealthPanelPreview() {
  return inventoryWarehouseStockHealthPreviewScaffold(
    InventoryWarehouseDetailStockHealthPanel(
      detail: inventoryWarehouseStockHealthPreviewDetail(),
    ),
  );
}
