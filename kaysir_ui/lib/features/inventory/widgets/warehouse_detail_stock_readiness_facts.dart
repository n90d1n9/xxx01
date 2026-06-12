import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../utils/inventory_formatters.dart';
import 'inventory_warehouse_detail_support.dart';
import 'warehouse_detail_stock_readiness_preview_data.dart';

/// Inline fact strip that summarizes visible, attention, and hidden stock rows.
class InventoryWarehouseStockReadinessFacts extends StatelessWidget {
  const InventoryWarehouseStockReadinessFacts({
    super.key,
    required this.shownCount,
    required this.attentionCount,
    required this.hiddenCount,
  });

  final int shownCount;
  final int attentionCount;
  final int hiddenCount;

  bool get hasAttention => attentionCount > 0;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        InventoryWarehouseDetailInlineFact(
          icon: Icons.visibility_rounded,
          label: 'shown',
          value: formatInventoryNumber(shownCount),
          color: Colors.blue.shade700,
        ),
        InventoryWarehouseDetailInlineFact(
          icon: Icons.warning_amber_rounded,
          label: 'attention',
          value: formatInventoryNumber(attentionCount),
          color:
              hasAttention ? Colors.deepOrange.shade700 : Colors.green.shade700,
        ),
        InventoryWarehouseDetailInlineFact(
          icon: Icons.layers_rounded,
          label: 'hidden',
          value: formatInventoryNumber(hiddenCount),
          color: Colors.indigo.shade700,
        ),
      ],
    );
  }
}

@Preview(name: 'Warehouse stock readiness facts')
Widget inventoryWarehouseStockReadinessFactsPreview() {
  final detail = inventoryWarehouseStockReadinessPreviewDetail();

  return inventoryWarehouseStockReadinessPreviewScaffold(
    InventoryWarehouseStockReadinessFacts(
      shownCount: detail.focusStockRecords.length,
      attentionCount: detail.attentionStockRecords.length,
      hiddenCount: detail.hiddenFocusStockRecordCount,
    ),
  );
}
