import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_low_stock_report.dart';
import 'low_stock_report_status.dart';

/// Status pill for a low-stock report status.
class InventoryLowStockReportStatusPill extends StatelessWidget {
  const InventoryLowStockReportStatusPill({super.key, required this.status});

  final InventoryLowStockReportStatus status;

  @override
  Widget build(BuildContext context) {
    return AppStatusPill(
      label: inventoryLowStockReportStatusLabel(status),
      icon: inventoryLowStockReportStatusIcon(status),
      color: inventoryLowStockReportStatusColor(status),
      maxWidth: 150,
    );
  }
}
