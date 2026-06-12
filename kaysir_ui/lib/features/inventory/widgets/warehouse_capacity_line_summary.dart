import 'package:flutter/material.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_warehouse_capacity_report.dart';

/// Warehouse identity summary for a capacity line tile.
class InventoryWarehouseCapacityLineSummary extends StatelessWidget {
  const InventoryWarehouseCapacityLineSummary({super.key, required this.line});

  final InventoryWarehouseCapacityLine line;

  @override
  Widget build(BuildContext context) {
    return AppInfoRow(
      icon: Icons.warehouse_rounded,
      iconStyle: AppInfoRowIconStyle.badge,
      title: line.warehouseName,
      subtitle: '${line.branchLabel} | ${line.locationLabel}',
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      padding: EdgeInsets.zero,
    );
  }
}
