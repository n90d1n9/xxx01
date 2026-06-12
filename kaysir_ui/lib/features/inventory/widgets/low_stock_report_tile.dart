import 'package:flutter/material.dart';

import '../models/inventory_low_stock_report.dart';
import 'inventory_tile_surface.dart';
import 'low_stock_report_line_summary.dart';
import 'low_stock_report_metrics.dart';
import 'low_stock_report_status.dart';
import 'low_stock_report_status_pill.dart';
import 'low_stock_report_tile_layout.dart';

/// Ledger tile for a single low-stock report line.
class InventoryLowStockReportTile extends StatelessWidget {
  const InventoryLowStockReportTile({super.key, required this.line});

  final InventoryLowStockReportLine line;

  @override
  Widget build(BuildContext context) {
    final statusColor = inventoryLowStockReportStatusColor(line.status);

    return LayoutBuilder(
      builder: (context, constraints) {
        return InventoryTileSurface(
          backgroundColor: statusColor.withValues(alpha: 0.07),
          child: InventoryLowStockReportTileLayout(
            isCompact: constraints.maxWidth < 860,
            summary: InventoryLowStockReportLineSummary(line: line),
            status: InventoryLowStockReportStatusPill(status: line.status),
            metrics: InventoryLowStockReportMetricStrip(line: line),
          ),
        );
      },
    );
  }
}
