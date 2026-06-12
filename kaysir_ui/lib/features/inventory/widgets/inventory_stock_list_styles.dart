import 'package:flutter/material.dart';

import '../models/inventory_stock_record.dart';

Color? inventoryStockListRowBackgroundColor(
  BuildContext context,
  InventoryStockRecord record,
) {
  final colorScheme = Theme.of(context).colorScheme;

  switch (record.status) {
    case InventoryStockStatus.outOfStock:
      return colorScheme.errorContainer.withValues(alpha: 0.18);
    case InventoryStockStatus.lowStock:
      return Colors.orange.shade50;
    case InventoryStockStatus.inStock:
      return null;
  }
}
