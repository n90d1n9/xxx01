import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_stock_opname_session.dart';
import 'inventory_stock_opname_summary_metrics.dart';
import 'stock_opname_line_preview_data.dart';
import 'stock_opname_worksheet_preview_data.dart';

/// Summary metric grid for a stock opname count sheet.
class InventoryStockOpnameSummary extends StatelessWidget {
  const InventoryStockOpnameSummary({super.key, required this.lines});

  final List<InventoryStockOpnameLine> lines;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(metrics: inventoryStockOpnameSummaryMetrics(lines));
  }
}

@Preview(name: 'Inventory stock opname summary')
Widget inventoryStockOpnameSummaryPreview() {
  return inventoryStockOpnameWorksheetPreviewScaffold(
    InventoryStockOpnameSummary(
      lines: [
        inventoryStockOpnamePreviewLine(),
        inventoryStockOpnamePreviewLine(id: 'i2', actualQuantity: 5),
      ],
    ),
  );
}
