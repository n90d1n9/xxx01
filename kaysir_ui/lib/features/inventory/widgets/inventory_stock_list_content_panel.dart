import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_stock_record.dart';
import 'inventory_stock_list.dart';
import 'inventory_stock_list_empty_state.dart';
import 'inventory_stock_list_state.dart';

class InventoryStockListPanel extends StatelessWidget {
  const InventoryStockListPanel({
    super.key,
    required this.records,
    required this.totalCount,
    this.onResetFilters,
    this.onViewDetails,
    this.onIncreaseStock,
    this.onDecreaseStock,
    this.onTransferStock,
    this.currencyFormat,
  });

  final List<InventoryStockRecord> records;
  final int totalCount;
  final VoidCallback? onResetFilters;
  final ValueChanged<InventoryStockRecord>? onViewDetails;
  final ValueChanged<InventoryStockRecord>? onIncreaseStock;
  final ValueChanged<InventoryStockRecord>? onDecreaseStock;
  final ValueChanged<InventoryStockRecord>? onTransferStock;
  final NumberFormat? currencyFormat;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Inventory Stock',
      subtitle: inventoryStockListSubtitle(
        visibleCount: records.length,
        totalCount: totalCount,
      ),
      leadingIcon: Icons.inventory_2_rounded,
      trailing:
          records.isEmpty
              ? null
              : AppStatusPill(
                label: inventoryStockListAttentionLabel(attentionCount),
                icon: Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                maxWidth: 180,
              ),
      child:
          records.isEmpty
              ? InventoryStockListEmptyState(onResetFilters: onResetFilters)
              : InventoryStockList(
                records: records,
                onViewDetails: onViewDetails,
                onIncreaseStock: onIncreaseStock,
                onDecreaseStock: onDecreaseStock,
                onTransferStock: onTransferStock,
                currencyFormat: currencyFormat,
              ),
    );
  }

  int get attentionCount {
    return inventoryStockListAttentionCount(records);
  }
}
