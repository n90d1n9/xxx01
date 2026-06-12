import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_warehouse_capacity_report.dart';
import '../models/inventory_warehouse_detail.dart';
import 'inventory_warehouse_capacity_report_components.dart';
import 'warehouse_detail_overview_preview_data.dart';

/// Capacity panel that embeds the warehouse capacity tile in detail context.
class InventoryWarehouseDetailCapacityPanel extends StatelessWidget {
  const InventoryWarehouseDetailCapacityPanel({
    super.key,
    required this.detail,
  });

  final InventoryWarehouseDetail detail;

  @override
  Widget build(BuildContext context) {
    final line = detail.capacityLine;

    return AppContentPanel(
      title: 'Capacity Readiness',
      subtitle:
          '${line.warehouseName} capacity, utilization, and available space',
      leadingIcon: Icons.space_dashboard_rounded,
      trailing: AppStatusPill(
        label: inventoryWarehouseCapacityStatusLabel(line.status),
        icon: inventoryWarehouseCapacityStatusIcon(line.status),
        color: inventoryWarehouseCapacityStatusColor(line.status),
        maxWidth: 140,
      ),
      child: InventoryWarehouseCapacityTile(line: line),
    );
  }
}

@Preview(name: 'Warehouse detail capacity')
Widget inventoryWarehouseDetailCapacityPanelPreview() {
  return inventoryWarehouseOverviewPreviewScaffold(
    InventoryWarehouseDetailCapacityPanel(
      detail: inventoryWarehouseOverviewPreviewDetail(),
    ),
  );
}
