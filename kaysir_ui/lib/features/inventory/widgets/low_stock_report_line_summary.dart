import 'package:flutter/material.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_low_stock_report.dart';

/// Product and warehouse summary for a low-stock report line.
class InventoryLowStockReportLineSummary extends StatelessWidget {
  const InventoryLowStockReportLineSummary({super.key, required this.line});

  final InventoryLowStockReportLine line;

  @override
  Widget build(BuildContext context) {
    return AppInfoRow(
      icon: Icons.inventory_2_rounded,
      iconStyle: AppInfoRowIconStyle.badge,
      title: line.productName,
      subtitle:
          '${line.skuLabel} | ${line.categoryLabel} | ${line.warehouseName}',
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      padding: EdgeInsets.zero,
    );
  }
}
