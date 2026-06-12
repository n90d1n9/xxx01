import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_stock_record.dart';
import '../models/inventory_warehouse_detail.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_warehouse_detail_support.dart';
import 'warehouse_detail_stock_health_preview_data.dart';

/// Inline fact strip for units, value, and value share in a stock-health row.
class InventoryWarehouseStockHealthFacts extends StatelessWidget {
  const InventoryWarehouseStockHealthFacts({
    super.key,
    required this.line,
    required this.totalValue,
    required this.accent,
  });

  final InventoryWarehouseStockHealthLine line;
  final double totalValue;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        InventoryWarehouseDetailInlineFact(
          icon: Icons.inventory_2_rounded,
          label: 'units',
          value: formatInventoryNumber(line.totalUnits),
          color: Colors.teal.shade700,
        ),
        InventoryWarehouseDetailInlineFact(
          icon: Icons.payments_rounded,
          label: 'value',
          value: formatInventoryCurrency(line.stockValue),
          color: Colors.green.shade700,
        ),
        InventoryWarehouseDetailInlineFact(
          icon: Icons.percent_rounded,
          label: 'value share',
          value: '${(line.valueShare(totalValue).clamp(0, 1) * 100).round()}%',
          color: accent,
        ),
      ],
    );
  }
}

@Preview(name: 'Warehouse stock health facts')
Widget inventoryWarehouseStockHealthFactsPreview() {
  final detail = inventoryWarehouseStockHealthPreviewDetail();

  return inventoryWarehouseStockHealthPreviewScaffold(
    InventoryWarehouseStockHealthFacts(
      line: detail.stockHealthLineFor(InventoryStockStatus.lowStock),
      totalValue: detail.stockValue,
      accent: Colors.orange.shade700,
    ),
  );
}
