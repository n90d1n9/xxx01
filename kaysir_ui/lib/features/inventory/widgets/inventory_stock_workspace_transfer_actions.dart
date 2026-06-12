import 'package:flutter/material.dart';

import '../models/inventory_item.dart';
import '../models/inventory_stock_record.dart';
import '../models/warehouse.dart';
import '../services/inventory_stock_mutation_service.dart';
import 'inventory_dialog.dart';
import 'inventory_stock_transfer_dialog.dart';

void showInventoryStockTransferDialogAction({
  required BuildContext context,
  required InventoryStockRecord record,
  required List<Warehouse> warehouses,
  required List<InventoryStockRecord> records,
  required List<InventoryItem> inventoryItems,
  required ValueChanged<InventoryStockMutation> onApplyMutation,
}) {
  final pageContext = context;
  showInventoryDialog<void>(
    context: pageContext,
    builder: (dialogContext) {
      return InventoryStockTransferDialog(
        record: record,
        warehouses: warehouses,
        existingRecords: records.isEmpty ? [record] : records,
        onCancel: () => Navigator.of(dialogContext).pop(),
        onSubmit: (draft) {
          onApplyMutation(
            buildInventoryStockTransferMutation(
              record: record,
              draft: draft,
              inventoryItems: inventoryItems,
            ),
          );
          Navigator.of(dialogContext).pop();
          ScaffoldMessenger.of(
            pageContext,
          ).showSnackBar(SnackBar(content: Text(draft.successLabel)));
        },
      );
    },
  );
}
