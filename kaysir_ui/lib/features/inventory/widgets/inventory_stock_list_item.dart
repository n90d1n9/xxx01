import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/inventory_stock_record.dart';
import 'inventory_stock_list_actions.dart';
import 'inventory_stock_list_item_layout.dart';
import 'inventory_stock_list_item_state.dart';
import 'inventory_stock_list_metrics.dart';
import 'inventory_stock_list_styles.dart';
import 'inventory_stock_product_summary.dart';

class InventoryStockListItem extends StatelessWidget {
  const InventoryStockListItem({
    super.key,
    required this.record,
    this.onViewDetails,
    this.onIncreaseStock,
    this.onDecreaseStock,
    this.onTransferStock,
    this.currencyFormat,
  });

  final InventoryStockRecord record;
  final VoidCallback? onViewDetails;
  final VoidCallback? onIncreaseStock;
  final VoidCallback? onDecreaseStock;
  final VoidCallback? onTransferStock;
  final NumberFormat? currencyFormat;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final colorScheme = Theme.of(context).colorScheme;
        final isCompact = inventoryStockListItemIsCompact(constraints.maxWidth);
        final details = InventoryStockDetailStrip(
          record: record,
          currencyFormat: currencyFormat,
        );
        final actions = InventoryStockRowActions(
          onViewDetails: onViewDetails,
          onIncreaseStock: onIncreaseStock,
          onDecreaseStock: onDecreaseStock,
          onTransferStock: onTransferStock,
        );
        final productSummary = InventoryStockProductSummary(record: record);

        return Material(
          color:
              inventoryStockListRowBackgroundColor(context, record) ??
              colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            child: InventoryStockListItemLayout(
              isCompact: isCompact,
              productSummary: productSummary,
              details: details,
              actions: actions,
              status: record.status,
            ),
          ),
        );
      },
    );
  }
}
