import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../models/inventory_warehouse_dashboard.dart';
import 'warehouse_branch_detail_preview_data.dart';
import 'warehouse_branch_stock_pressure_empty_state.dart';
import 'warehouse_branch_stock_pressure_list.dart';
import 'warehouse_branch_stock_pressure_status_pill.dart';

/// Branch-level stock pressure panel focused on low and out-of-stock records.
class InventoryWarehouseBranchStockPressurePanel extends StatelessWidget {
  const InventoryWarehouseBranchStockPressurePanel({
    super.key,
    required this.detail,
  });

  final InventoryWarehouseBranchDetail detail;

  @override
  Widget build(BuildContext context) {
    final records = detail.attentionStockRecords;

    return AppContentPanel(
      title: 'Stock Pressure',
      subtitle:
          '${records.length} of ${detail.stockLineCount} stock lines need attention',
      leadingIcon: Icons.notification_important_rounded,
      trailing: InventoryWarehouseBranchStockPressureStatusPill(
        alertCount: records.length,
      ),
      child:
          records.isEmpty
              ? const InventoryWarehouseBranchStockPressureEmptyState()
              : InventoryWarehouseBranchStockPressureList(records: records),
    );
  }
}

@Preview(name: 'Warehouse branch stock pressure panel')
Widget inventoryWarehouseBranchStockPressurePanelPreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseBranchStockPressurePanel(
      detail: inventoryWarehouseBranchDetailPreviewDetail(),
    ),
  );
}
