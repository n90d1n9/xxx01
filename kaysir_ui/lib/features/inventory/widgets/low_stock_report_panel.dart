import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_low_stock_report.dart';
import 'inventory_filtered_empty_state.dart';
import 'inventory_separated_list.dart';
import 'low_stock_report_tile.dart';

/// Panel that renders filtered low-stock report lines.
class InventoryLowStockReportPanel extends StatelessWidget {
  const InventoryLowStockReportPanel({
    super.key,
    required this.lines,
    this.totalCount,
    this.onResetFilters,
  });

  final List<InventoryLowStockReportLine> lines;
  final int? totalCount;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    final totalCount = this.totalCount ?? lines.length;
    final criticalCount = lowStockReportCriticalLineCount(lines);

    return AppContentPanel(
      title: 'Low Stock Ledger',
      subtitle:
          '${lines.length} of $totalCount shortage, reorder threshold, and recovery rows',
      leadingIcon: Icons.notification_important_rounded,
      trailing:
          lines.isEmpty
              ? null
              : AppStatusPill(
                label: '$criticalCount critical',
                icon: Icons.priority_high_rounded,
                color:
                    criticalCount == 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                maxWidth: 140,
              ),
      child:
          lines.isEmpty
              ? InventoryLowStockReportEmptyState(
                totalCount: totalCount,
                onResetFilters: onResetFilters,
              )
              : InventoryLowStockReportList(lines: lines),
    );
  }
}

/// List wrapper for low-stock report line tiles.
class InventoryLowStockReportList extends StatelessWidget {
  const InventoryLowStockReportList({super.key, required this.lines});

  final List<InventoryLowStockReportLine> lines;

  @override
  Widget build(BuildContext context) {
    return InventorySeparatedList<InventoryLowStockReportLine>(
      items: lines,
      itemBuilder: (context, line, index) {
        return InventoryLowStockReportTile(line: line);
      },
    );
  }
}

/// Empty or filtered state for the low-stock report panel.
class InventoryLowStockReportEmptyState extends StatelessWidget {
  const InventoryLowStockReportEmptyState({
    super.key,
    required this.totalCount,
    this.onResetFilters,
  });

  final int totalCount;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    return InventoryFilteredEmptyState(
      totalCount: totalCount,
      emptyTitle: 'No low stock alerts',
      emptyMessage: 'All tracked stock lines are above reorder point.',
      filteredTitle: 'No alerts in this branch',
      filteredMessage: 'Try another branch or reset filters.',
      icon: Icons.check_circle_outline_rounded,
      onResetFilters: onResetFilters,
    );
  }
}

/// Counts report lines that are critical or out of stock.
int lowStockReportCriticalLineCount(List<InventoryLowStockReportLine> lines) {
  return lines
      .where((line) => line.status != InventoryLowStockReportStatus.lowStock)
      .length;
}
