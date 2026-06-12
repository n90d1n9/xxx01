import 'package:flutter/material.dart';

import '../models/inventory_stock_adjustment_draft.dart';
import '../models/inventory_stock_record.dart';
import '../services/inventory_stock_mutation_service.dart';
import 'inventory_dialog.dart';
import 'inventory_stock_adjustment_dialog.dart';

void showInventoryStockAdjustmentDialogAction({
  required BuildContext context,
  required InventoryStockRecord record,
  required InventoryStockAdjustmentDirection direction,
  required ValueChanged<InventoryStockMutation> onApplyMutation,
}) {
  final pageContext = context;
  showInventoryDialog<void>(
    context: pageContext,
    builder: (dialogContext) {
      return InventoryStockAdjustmentDialog(
        record: record,
        direction: direction,
        onCancel: () => Navigator.of(dialogContext).pop(),
        onSubmit: (draft) {
          onApplyMutation(
            buildInventoryStockAdjustmentMutation(record: record, draft: draft),
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
