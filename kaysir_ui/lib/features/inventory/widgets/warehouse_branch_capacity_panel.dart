import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../models/inventory_warehouse_dashboard.dart';
import 'warehouse_branch_capacity_empty_state.dart';
import 'warehouse_branch_capacity_list.dart';
import 'warehouse_branch_capacity_status_pill.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Branch-level capacity panel listing every warehouse capacity row.
class InventoryWarehouseBranchCapacityPanel extends StatelessWidget {
  const InventoryWarehouseBranchCapacityPanel({
    super.key,
    required this.detail,
  });

  final InventoryWarehouseBranchDetail detail;

  @override
  Widget build(BuildContext context) {
    final lines = detail.capacityLines;

    return AppContentPanel(
      title: 'Warehouse Capacity',
      subtitle:
          '${lines.length} warehouse capacity rows in ${detail.summary.branchName}',
      leadingIcon: Icons.space_dashboard_rounded,
      trailing:
          lines.isEmpty
              ? null
              : InventoryWarehouseBranchCapacityStatusPill(
                trackedWarehouseCount: detail.summary.trackedWarehouseCount,
              ),
      child:
          lines.isEmpty
              ? const InventoryWarehouseBranchCapacityEmptyState()
              : InventoryWarehouseBranchCapacityList(lines: lines),
    );
  }
}

@Preview(name: 'Warehouse branch capacity panel')
Widget inventoryWarehouseBranchCapacityPanelPreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseBranchCapacityPanel(
      detail: inventoryWarehouseBranchDetailPreviewDetail(),
    ),
  );
}
