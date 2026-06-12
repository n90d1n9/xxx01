import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/inventory_stock_record.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_metric_chip.dart';
import 'inventory_quantity_badge.dart';

class InventoryStockDetailStrip extends StatelessWidget {
  const InventoryStockDetailStrip({
    super.key,
    required this.record,
    this.currencyFormat,
  });

  final InventoryStockRecord record;
  final NumberFormat? currencyFormat;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InventoryQuantityBadge(record: record),
        InventoryMetricChip(
          label: 'Reorder qty',
          value: record.reorderQuantity.toString(),
          icon: Icons.playlist_add_rounded,
        ),
        InventoryMetricChip(
          label: 'Value',
          value: formatInventoryCurrency(
            record.inventoryValue,
            formatter: currencyFormat,
          ),
          icon: Icons.payments_rounded,
        ),
      ],
    );
  }
}
