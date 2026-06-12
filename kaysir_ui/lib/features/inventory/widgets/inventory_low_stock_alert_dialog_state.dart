import 'package:flutter/material.dart';

const inventoryLowStockHealthySubtitle =
    'All tracked stock lines are above reorder point';
const inventoryLowStockHealthyTitle = 'Stock is healthy';
const inventoryLowStockHealthyMessage =
    'No products are below reorder point right now.';

bool hasInventoryLowStockAlerts(int count) => count > 0;

String inventoryLowStockAlertBadgeLabel(int count) {
  return count > 99 ? '99+' : count.toString();
}

IconData inventoryLowStockAlertIconData(int count) {
  return hasInventoryLowStockAlerts(count)
      ? Icons.notification_important_rounded
      : Icons.notifications_none_rounded;
}

String inventoryLowStockAlertSubtitle(int count) {
  if (!hasInventoryLowStockAlerts(count)) {
    return inventoryLowStockHealthySubtitle;
  }
  if (count == 1) return '1 stock line needs replenishment';
  return '$count stock lines need replenishment';
}
