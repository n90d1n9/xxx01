import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../models/inventory_replenishment_plan.dart';
import 'inventory_dialog_content_layout.dart';
import 'inventory_low_stock_alert_content.dart';
import 'inventory_low_stock_alert_dialog_state.dart';
import 'warehouse_detail_replenishment_preview_data.dart';

/// Notification icon that surfaces the current low-stock alert count.
class InventoryLowStockAlertIcon extends StatelessWidget {
  const InventoryLowStockAlertIcon({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(inventoryLowStockAlertIconData(count));

    if (!hasInventoryLowStockAlerts(count)) return icon;

    return Badge(
      label: Text(inventoryLowStockAlertBadgeLabel(count)),
      backgroundColor: Theme.of(context).colorScheme.error,
      child: icon,
    );
  }
}

/// Dialog that presents urgent replenishment plans from the stock workspace.
class InventoryLowStockAlertDialog extends StatelessWidget {
  const InventoryLowStockAlertDialog({
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
    return InventoryDialogContentLayout(
      maxWidth: 760,
      maxHeight: 780,
      eyebrow: 'Inventory Risk',
      title: 'Low Stock Alerts',
      subtitle: inventoryLowStockAlertSubtitle(plans.length),
      closeTooltip: 'Close low stock alerts',
      onClose: onClose,
      child: InventoryLowStockAlertContent(
        plans: plans,
        onRestock: onRestock,
        onClose: onClose,
        currencyFormat: currencyFormat,
      ),
    );
  }
}

@Preview(name: 'Low stock alert icon')
Widget inventoryLowStockAlertIconPreview() {
  return const MaterialApp(
    home: Scaffold(body: Center(child: InventoryLowStockAlertIcon(count: 3))),
  );
}

@Preview(name: 'Low stock alert dialog')
Widget inventoryLowStockAlertDialogPreview() {
  final detail = inventoryWarehouseReplenishmentPreviewDetail();

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Center(
        child: InventoryLowStockAlertDialog(
          plans: detail.replenishmentPlans,
          onRestock: (_) {},
          onClose: () {},
        ),
      ),
    ),
  );
}
