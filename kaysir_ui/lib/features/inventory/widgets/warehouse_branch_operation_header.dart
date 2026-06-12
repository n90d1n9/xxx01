import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_warehouse_capacity_report.dart';
import 'inventory_warehouse_capacity_status_visuals.dart';
import 'warehouse_branch_detail_preview_data.dart';

/// Responsive warehouse operation header with location and capacity status.
class InventoryWarehouseOperationHeader extends StatelessWidget {
  const InventoryWarehouseOperationHeader({super.key, required this.line});

  final InventoryWarehouseCapacityLine line;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final header = AppInfoRow(
          icon: Icons.warehouse_rounded,
          iconStyle: AppInfoRowIconStyle.badge,
          title: line.warehouseName,
          subtitle: '${line.branchLabel} | ${line.locationLabel}',
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          padding: EdgeInsets.zero,
        );
        final status = InventoryWarehouseCapacityStatusPill(
          status: line.status,
        );

        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: status),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: header),
            const SizedBox(width: 12),
            status,
          ],
        );
      },
    );
  }
}

@Preview(name: 'Warehouse branch operation header')
Widget inventoryWarehouseOperationHeaderPreview() {
  return inventoryWarehouseBranchDetailPreviewScaffold(
    InventoryWarehouseOperationHeader(
      line: inventoryWarehouseBranchOperationPreview().capacityLine,
    ),
  );
}
