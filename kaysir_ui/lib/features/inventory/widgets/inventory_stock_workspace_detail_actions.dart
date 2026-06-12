import 'package:flutter/material.dart';

import '../models/inventory_movement_record.dart';
import '../models/inventory_stock_record.dart';
import 'inventory_dialog.dart';
import 'inventory_stock_detail_components.dart';

void showInventoryStockDetailDialogAction({
  required BuildContext context,
  required InventoryStockRecord record,
  required List<InventoryMovementRecord> relatedMovements,
  required VoidCallback onIncreaseStock,
  required VoidCallback onDecreaseStock,
  required VoidCallback onTransferStock,
}) {
  final pageContext = context;
  showInventoryDialog<void>(
    context: pageContext,
    builder: (dialogContext) {
      void closeThen(VoidCallback action) {
        Navigator.of(dialogContext).pop();
        action();
      }

      return InventoryStockDetailSheet(
        record: record,
        movements: relatedMovements,
        onClose: () => Navigator.of(dialogContext).pop(),
        onIncreaseStock: () => closeThen(onIncreaseStock),
        onDecreaseStock: () => closeThen(onDecreaseStock),
        onTransferStock: () => closeThen(onTransferStock),
      );
    },
  );
}
