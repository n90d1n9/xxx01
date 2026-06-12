import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_warehouse_detail.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_warehouse_detail_support.dart';
import 'warehouse_detail_category_mix_preview_data.dart';

/// Inline fact strip for units, value, and attention in a category mix row.
class InventoryWarehouseCategoryMixFacts extends StatelessWidget {
  const InventoryWarehouseCategoryMixFacts({
    super.key,
    required this.line,
    required this.accent,
  });

  final InventoryWarehouseCategoryMixLine line;
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
        if (line.hasAttention)
          InventoryWarehouseDetailInlineFact(
            icon: Icons.warning_amber_rounded,
            label: 'attention',
            value: formatInventoryNumber(line.attentionCount),
            color: accent,
          ),
      ],
    );
  }
}

@Preview(name: 'Warehouse category mix facts')
Widget inventoryWarehouseCategoryMixFactsPreview() {
  final line = inventoryWarehouseCategoryMixPreviewLine();

  return inventoryWarehouseCategoryMixPreviewScaffold(
    InventoryWarehouseCategoryMixFacts(
      line: line,
      accent: Colors.deepOrange.shade700,
    ),
  );
}
