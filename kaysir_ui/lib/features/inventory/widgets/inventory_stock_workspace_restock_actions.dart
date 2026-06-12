import 'package:flutter/material.dart';

import '../models/inventory_replenishment_plan.dart';
import '../services/inventory_stock_mutation_application_service.dart';
import '../services/inventory_stock_mutation_service.dart';
import 'inventory_dialog.dart';
import 'inventory_low_stock_alert_dialog.dart';
import 'low_stock_restock_dialog.dart';

void showInventoryLowStockDialogAction({
  required BuildContext context,
  required List<InventoryReplenishmentPlan> plans,
  required ValueChanged<InventoryReplenishmentPlan> onRestock,
}) {
  if (plans.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No low stock items at the moment')),
    );
    return;
  }

  final pageContext = context;
  showInventoryDialog<void>(
    context: pageContext,
    builder: (dialogContext) {
      return InventoryLowStockAlertDialog(
        plans: plans,
        onClose: () => Navigator.of(dialogContext).pop(),
        onRestock: (plan) {
          Navigator.of(dialogContext).pop();
          onRestock(plan);
        },
      );
    },
  );
}

void showInventoryRestockDialogAction({
  required BuildContext context,
  required InventoryReplenishmentPlan plan,
  required ValueChanged<InventoryStockMutation> onApplyMutation,
}) {
  final pageContext = context;
  showInventoryDialog<void>(
    context: pageContext,
    builder: (dialogContext) {
      return LowStockRestockDialog(
        plan: plan,
        onCancel: () => Navigator.of(dialogContext).pop(),
        onSubmit: (draft) {
          onApplyMutation(
            buildInventoryRestockMutation(plan: plan, draft: draft),
          );
          Navigator.of(dialogContext).pop();
          ScaffoldMessenger.of(pageContext).showSnackBar(
            SnackBar(
              content: Text(
                '${plan.record.productName} restocked successfully',
              ),
            ),
          );
        },
      );
    },
  );
}
