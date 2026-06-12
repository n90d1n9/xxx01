import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_stock_movement_report.dart';
import 'inventory_reset_filters_button.dart';
import 'inventory_separated_list.dart';
import 'stock_movement_report_tile.dart';

/// Panel that renders filtered stock movement report rows.
class InventoryStockMovementReportPanel extends StatelessWidget {
  const InventoryStockMovementReportPanel({
    super.key,
    required this.lines,
    required this.totalCount,
    this.onResetFilters,
  });

  final List<InventoryStockMovementReportLine> lines;
  final int totalCount;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Movement Ledger',
      subtitle: '${lines.length} of $totalCount movements visible',
      leadingIcon: Icons.receipt_long_rounded,
      trailing:
          lines.isEmpty
              ? null
              : AppStatusPill(
                label: '${lines.length} rows',
                icon: Icons.visibility_rounded,
                color: Theme.of(context).colorScheme.primary,
                maxWidth: 120,
              ),
      child:
          lines.isEmpty
              ? AppEmptyState(
                title: 'No matching movements',
                message: 'Try another date range, product, type, or warehouse.',
                icon: Icons.timeline_rounded,
                action:
                    onResetFilters == null
                        ? null
                        : InventoryResetFiltersButton(
                          onPressed: onResetFilters!,
                        ),
              )
              : InventorySeparatedList<InventoryStockMovementReportLine>(
                items: lines,
                itemBuilder: (context, line, index) {
                  return InventoryStockMovementReportTile(line: line);
                },
              ),
    );
  }
}
