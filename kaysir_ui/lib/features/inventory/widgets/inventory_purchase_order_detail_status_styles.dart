import 'package:flutter/material.dart';

import '../../ecommerce/order/order.dart';
import '../models/inventory_purchase_order_detail.dart';
import '../utils/inventory_formatters.dart';

Color purchaseOrderDetailStatusColor(OrderStatus status, bool isOverdue) {
  if (isOverdue) return Colors.red.shade700;

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

IconData purchaseOrderDetailStatusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.draft:
      return Icons.edit_note_rounded;
    case OrderStatus.pending:
      return Icons.hourglass_top_rounded;
    case OrderStatus.confirmed:
      return Icons.thumb_up_alt_rounded;
    case OrderStatus.received:
    case OrderStatus.completed:
      return Icons.check_circle_rounded;
    case OrderStatus.cancelled:
      return Icons.cancel_rounded;
  }
}

String purchaseOrderDetailExpectedDateMetric(
  InventoryPurchaseOrderDetail detail,
) {
  final expected = detail.expectedDeliveryDate;
  if (expected == null) return 'Unscheduled';
  return formatInventoryShortDate(expected);
}

String purchaseOrderDetailExpectedDateLabel(
  InventoryPurchaseOrderDetail detail,
) {
  final expected = detail.expectedDeliveryDate;
  if (expected == null) return 'No expected delivery date set';
  final formatted = formatInventoryDate(expected);
  if (detail.isOverdue) return 'Expected $formatted';
  final days = detail.record.daysUntilExpected;
  if (days == null) return 'Expected $formatted';
  if (days == 0) return 'Due today';
  if (days == 1) return 'Due tomorrow';
  if (days > 1) return 'Due in $days days';
  return 'Expected $formatted';
}
