import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_valuation_report.dart';
import 'inventory_filtered_empty_state.dart';
import 'inventory_separated_list.dart';
import 'valuation_line_tile.dart';

/// Panel that renders filtered inventory valuation report lines.
class InventoryValuationPanel extends StatelessWidget {
  const InventoryValuationPanel({
    super.key,
    required this.lines,
    this.totalCount,
    this.onResetFilters,
  });

  final List<InventoryValuationLine> lines;
  final int? totalCount;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    final totalCount = this.totalCount ?? lines.length;

    return AppContentPanel(
      title: 'Valuation Ledger',
      subtitle:
          '${lines.length} of $totalCount stock values by product, warehouse, and current unit cost',
      leadingIcon: Icons.account_balance_wallet_rounded,
      trailing: AppStatusPill(
        label: '${lines.length} lines',
        icon: Icons.table_rows_rounded,
        color: Colors.green.shade700,
        maxWidth: 120,
      ),
      child:
          lines.isEmpty
              ? InventoryFilteredEmptyState(
                totalCount: totalCount,
                emptyTitle: 'No inventory value yet',
                emptyMessage:
                    'Add stock lines before generating valuation reports.',
                filteredTitle: 'No value in this branch',
                filteredMessage: 'Try another branch or reset filters.',
                icon: Icons.payments_outlined,
                onResetFilters: onResetFilters,
              )
              : InventorySeparatedList<InventoryValuationLine>(
                items: lines,
                itemBuilder: (context, line, index) {
                  return InventoryValuationLineTile(line: line);
                },
              ),
    );
  }
}
