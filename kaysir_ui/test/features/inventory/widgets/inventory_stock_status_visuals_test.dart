import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_status_visuals.dart';

void main() {
  test('stock status labels remain stable for filters and badges', () {
    expect(
      inventoryStockStatusLabel(InventoryStockStatus.outOfStock),
      'Out of stock',
    );
    expect(
      inventoryStockStatusLabel(InventoryStockStatus.lowStock),
      'Low stock',
    );
    expect(inventoryStockStatusLabel(InventoryStockStatus.inStock), 'In stock');
  });

  test('stock status icons remain stable for reusable status UI', () {
    expect(
      inventoryStockStatusIcon(InventoryStockStatus.outOfStock),
      Icons.error_outline_rounded,
    );
    expect(
      inventoryStockStatusIcon(InventoryStockStatus.lowStock),
      Icons.warning_amber_rounded,
    );
    expect(
      inventoryStockStatusIcon(InventoryStockStatus.inStock),
      Icons.check_circle_outline_rounded,
    );
  });
}
