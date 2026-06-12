import 'package:flutter/material.dart';

import '../../ecommerce/order/order.dart';
import '../models/inventory_purchase_order_workspace.dart';
import '../utils/inventory_formatters.dart';

String inventoryPurchaseOrderExpectedLabel(
  InventoryPurchaseOrderRecord record,
) {
  if (record.expectedDeliveryDate == null) return 'No ETA';
  final formatted = formatInventoryDate(record.expectedDeliveryDate!);
  if (record.isOverdue) return 'Overdue since $formatted';
  final days = record.daysUntilExpected;
  if (days == null) return formatted;
  if (days == 0) return 'Due today';
  if (days == 1) return 'Due tomorrow';
  if (days > 1) return 'Due in $days days';
  return '$formatted received window';
}

String inventoryPurchaseOrderCompactExpectedLabel(
  InventoryPurchaseOrderRecord record,
) {
  if (record.expectedDeliveryDate == null) return 'No ETA';
  if (record.isOverdue) return 'Overdue';
  final days = record.daysUntilExpected;
  if (days == null) {
    return formatInventoryShortDate(record.expectedDeliveryDate!);
  }
  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  if (days > 1) return '$days days';
  return formatInventoryShortDate(record.expectedDeliveryDate!);
}

IconData inventoryPurchaseOrderStatusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.draft:
      return Icons.edit_note_rounded;
    case OrderStatus.pending:
      return Icons.hourglass_top_rounded;
    case OrderStatus.confirmed:
      return Icons.assignment_turned_in_rounded;
    case OrderStatus.received:
    case OrderStatus.completed:
      return Icons.check_circle_rounded;
    case OrderStatus.cancelled:
      return Icons.cancel_rounded;
  }
}

Color inventoryPurchaseOrderStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.draft:
      return Colors.blueGrey.shade700;
    case OrderStatus.pending:
      return Colors.orange.shade700;
    case OrderStatus.confirmed:
      return Colors.indigo.shade700;
    case OrderStatus.received:
    case OrderStatus.completed:
      return Colors.green.shade700;
    case OrderStatus.cancelled:
      return Colors.red.shade700;
  }
}
