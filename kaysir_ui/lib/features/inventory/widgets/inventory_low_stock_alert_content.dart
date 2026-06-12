import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../widgets/ui/app_dialog_actions.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../models/inventory_replenishment_plan.dart';
import 'inventory_low_stock_alert_dialog_state.dart';
import 'low_stock_replenishment_components.dart';
import 'warehouse_detail_replenishment_preview_data.dart';

/// Body content for the low-stock alert dialog, including summary, alert rows,
/// and close action.
class InventoryLowStockAlertContent extends StatelessWidget {
  const InventoryLowStockAlertContent({
    super.key,
    required this.plans,
    this.onRestock,
    this.onClose,
    this.currencyFormat,
  });

  final List<InventoryReplenishmentPlan> plans;
  final ValueChanged<InventoryReplenishmentPlan>? onRestock;
  final VoidCallback? onClose;
  final NumberFormat? currencyFormat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (plans.isEmpty)
          const AppEmptyState(
            title: inventoryLowStockHealthyTitle,
            message: inventoryLowStockHealthyMessage,
            icon: Icons.check_circle_outline_rounded,
          )
        else ...[
          LowStockReplenishmentSummary(
            plans: plans,
            currencyFormat: currencyFormat,
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < plans.length; index += 1) ...[
            LowStockReplenishmentTile(
              plan: plans[index],
              onRestock:
                  onRestock == null ? null : () => onRestock!(plans[index]),
              currencyFormat: currencyFormat,
            ),
            if (index != plans.length - 1) const SizedBox(height: 10),
          ],
        ],
        const SizedBox(height: 20),
        AppDialogActions(
          confirmLabel: 'Close',
          confirmIcon: Icons.check_rounded,
          onConfirm: onClose,
        ),
      ],
    );
  }
}

@Preview(name: 'Low stock alert content')
Widget inventoryLowStockAlertContentPreview() {
  final detail = inventoryWarehouseReplenishmentPreviewDetail();

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: InventoryLowStockAlertContent(
              plans: detail.replenishmentPlans,
              onRestock: (_) {},
              onClose: () {},
            ),
          ),
        ),
      ),
    ),
  );
}
