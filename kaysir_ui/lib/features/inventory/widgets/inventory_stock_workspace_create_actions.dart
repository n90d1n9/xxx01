import 'package:flutter/material.dart';

import '../../product/models/product.dart';
import '../models/inventory_stock_record.dart';
import '../models/warehouse.dart';
import '../services/inventory_stock_mutation_service.dart';
import 'inventory_dialog.dart';
import 'inventory_stock_create_dialog.dart';
import 'inventory_stock_workspace_state.dart';

void showInventoryStockCreateDialogAction({
  required BuildContext context,
  required List<Product> products,
  required List<Warehouse> warehouses,
  required List<InventoryStockRecord> records,
  required ValueChanged<InventoryStockMutation> onApplyMutation,
}) {
  final pageContext = context;
  showInventoryDialog<void>(
    context: pageContext,
    builder: (dialogContext) {
      return InventoryStockCreateDialog(
        products: products,
        warehouses: warehouses,
        existingRecords: records,
        onCancel: () => Navigator.of(dialogContext).pop(),
        onSubmit: (draft) {
          onApplyMutation(buildInventoryStockCreateMutation(draft: draft));
          Navigator.of(dialogContext).pop();
          final productName = inventoryStockWorkspaceProductName(
            products,
            draft.productId,
          );
          final warehouseName = inventoryStockWorkspaceWarehouseName(
            warehouses,
            draft.warehouseId,
          );
          ScaffoldMessenger.of(pageContext).showSnackBar(
            SnackBar(
              content: Text(
                '$productName stock line created for $warehouseName',
              ),
            ),
          );
        },
      );
    },
  );
}
