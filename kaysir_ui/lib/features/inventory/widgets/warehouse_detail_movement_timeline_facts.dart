import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../utils/inventory_formatters.dart';
import 'inventory_warehouse_detail_support.dart';
import 'warehouse_detail_movement_timeline_preview_data.dart';

/// Inline fact strip for visible and hidden movement timeline rows.
class InventoryWarehouseMovementTimelineFacts extends StatelessWidget {
  const InventoryWarehouseMovementTimelineFacts({
    super.key,
    required this.shownCount,
    required this.hiddenCount,
  });

  final int shownCount;
  final int hiddenCount;

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
          icon: Icons.layers_rounded,
          label: 'hidden',
          value: formatInventoryNumber(hiddenCount),
          color: Colors.indigo.shade700,
        ),
      ],
    );
  }
}

@Preview(name: 'Warehouse movement timeline facts')
Widget inventoryWarehouseMovementTimelineFactsPreview() {
  final detail = inventoryWarehouseMovementTimelinePreviewDetail();

  return inventoryWarehouseMovementTimelinePreviewScaffold(
    InventoryWarehouseMovementTimelineFacts(
      shownCount: detail.recentMovementRecords.length,
      hiddenCount: detail.hiddenRecentMovementRecordCount,
    ),
  );
}
