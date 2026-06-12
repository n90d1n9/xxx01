import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_stock_opname_session.dart';
import 'inventory_stock_opname_display_utils.dart';
import 'stock_opname_line_preview_data.dart';

/// Variance indicator for a stock opname worksheet row.
class InventoryStockOpnameVariancePill extends StatelessWidget {
  const InventoryStockOpnameVariancePill({super.key, required this.line});

  final InventoryStockOpnameLine line;

  @override
  Widget build(BuildContext context) {
    if (line.discrepancy == 0) {
      return AppStatusPill(
        label: 'Matched',
        icon: Icons.check_circle_outline_rounded,
        color: Colors.green.shade700,
        maxWidth: 130,
      );
    }

    return AppStatusPill(
      label: stockOpnameSignedQuantityLabel(line.discrepancy),
      icon:
          line.discrepancy > 0
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded,
      color:
          line.discrepancy > 0 ? Colors.orange.shade700 : Colors.red.shade700,
      maxWidth: 130,
    );
  }
}

@Preview(name: 'Inventory stock opname variance pill')
Widget inventoryStockOpnameVariancePillPreview() {
  return inventoryStockOpnameLinePreviewScaffold(
    Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        InventoryStockOpnameVariancePill(
          line: inventoryStockOpnamePreviewLine(actualQuantity: 5),
        ),
        InventoryStockOpnameVariancePill(
          line: inventoryStockOpnamePreviewLine(actualQuantity: 8),
        ),
        InventoryStockOpnameVariancePill(
          line: inventoryStockOpnamePreviewLine(actualQuantity: 3),
        ),
      ],
    ),
  );
}
