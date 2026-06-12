import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_low_stock_alert_dialog_state.dart';

void main() {
  test('low stock alert state formats badge labels', () {
    expect(hasInventoryLowStockAlerts(0), isFalse);
    expect(hasInventoryLowStockAlerts(3), isTrue);
    expect(inventoryLowStockAlertBadgeLabel(3), '3');
    expect(inventoryLowStockAlertBadgeLabel(120), '99+');
  });

  test('low stock alert state resolves icon data', () {
    expect(inventoryLowStockAlertIconData(0), Icons.notifications_none_rounded);
    expect(
      inventoryLowStockAlertIconData(1),
      Icons.notification_important_rounded,
    );
  });

  test('low stock alert state resolves subtitle copy', () {
    expect(inventoryLowStockAlertSubtitle(0), inventoryLowStockHealthySubtitle);
    expect(
      inventoryLowStockAlertSubtitle(1),
      '1 stock line needs replenishment',
    );
    expect(
      inventoryLowStockAlertSubtitle(3),
      '3 stock lines need replenishment',
    );
  });
}
