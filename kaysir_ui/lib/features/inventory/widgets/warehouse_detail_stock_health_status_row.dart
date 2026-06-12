import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_stock_record.dart';
import '../models/inventory_warehouse_detail.dart';
import 'inventory_stock_status_pill.dart';
import 'inventory_warehouse_detail_support.dart';
import 'warehouse_detail_stock_health_preview_data.dart';

/// Header row for a stock-health bucket with status and line count.
class InventoryWarehouseStockHealthStatusRow extends StatelessWidget {
  const InventoryWarehouseStockHealthStatusRow({
    super.key,
    required this.line,
    required this.accent,
  });

  final InventoryWarehouseStockHealthLine line;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: InventoryStockStatusPill(status: line.status),
          ),
        ),
        const SizedBox(width: 12),
        AppStatusPill(
          label: compactInventoryWarehouseCount(
            line.stockLineCount,
            'line',
            'lines',
          ),
          color: accent,
          showDot: true,
          maxWidth: 94,
        ),
      ],
    );
  }
}

@Preview(name: 'Warehouse stock health status row')
Widget inventoryWarehouseStockHealthStatusRowPreview() {
  final detail = inventoryWarehouseStockHealthPreviewDetail();

  return inventoryWarehouseStockHealthPreviewScaffold(
    InventoryWarehouseStockHealthStatusRow(
      line: detail.stockHealthLineFor(InventoryStockStatus.outOfStock),
      accent: Colors.red.shade700,
    ),
  );
}
