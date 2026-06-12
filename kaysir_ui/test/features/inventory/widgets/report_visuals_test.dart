import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_report_catalog.dart';
import 'package:kaysir/features/inventory/widgets/report_visuals.dart';

void main() {
  test('report icons remain stable for catalog cards', () {
    expect(
      inventoryReportIconFor(InventoryReportType.valuation),
      Icons.payments_rounded,
    );
    expect(
      inventoryReportIconFor(InventoryReportType.movementHistory),
      Icons.timeline_rounded,
    );
    expect(
      inventoryReportIconFor(InventoryReportType.lowStock),
      Icons.warning_amber_rounded,
    );
    expect(
      inventoryReportIconFor(InventoryReportType.warehouseCapacity),
      Icons.warehouse_rounded,
    );
  });

  test('report visuals resolve every catalog type', () {
    for (final type in InventoryReportType.values) {
      final visuals = inventoryReportVisualsFor(type);
      expect(visuals.icon, inventoryReportIconFor(type));
      expect(visuals.color, inventoryReportColorFor(type));
    }
  });
}
