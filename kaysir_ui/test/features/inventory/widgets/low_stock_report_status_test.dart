import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_low_stock_report.dart';
import 'package:kaysir/features/inventory/widgets/low_stock_report_status.dart';

void main() {
  test('low stock report status icons remain stable', () {
    expect(
      inventoryLowStockReportStatusIcon(
        InventoryLowStockReportStatus.outOfStock,
      ),
      Icons.remove_circle_outline_rounded,
    );
    expect(
      inventoryLowStockReportStatusIcon(InventoryLowStockReportStatus.critical),
      Icons.priority_high_rounded,
    );
    expect(
      inventoryLowStockReportStatusIcon(InventoryLowStockReportStatus.lowStock),
      Icons.warning_amber_rounded,
    );
  });

  test('low stock report status colors resolve every status', () {
    for (final status in InventoryLowStockReportStatus.values) {
      expect(inventoryLowStockReportStatusColor(status), isA<Color>());
    }
  });
}
