import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_low_stock_report.dart';
import 'package:kaysir/features/inventory/widgets/inventory_low_stock_report_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_reset_filters_button.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('low stock report summary renders reusable metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryLowStockReportSummaryGrid(
            summary: summarizeInventoryLowStockReportLines(_lines),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Active Alerts'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('Shortage'), findsOneWidget);
    expect(find.text('Suggested Units'), findsOneWidget);
  });

  testWidgets('low stock report panel renders line tiles', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: InventoryLowStockReportPanel(lines: _lines)),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(InventoryLowStockReportTile), findsNWidgets(3));
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Out of Stock'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('Low Stock'), findsOneWidget);
    expect(find.textContaining('No SKU'), findsOneWidget);
    expect(find.text('Jakarta Central'), findsWidgets);
    expect(find.text(r'$1,000.00'), findsOneWidget);
  });

  testWidgets('low stock report panel shows empty state', (tester) async {
    var resetCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryLowStockReportPanel(
            lines: const [],
            totalCount: 3,
            onResetFilters: () => resetCalled = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.byType(InventoryResetFiltersButton), findsOneWidget);
    expect(find.text('No alerts in this branch'), findsOneWidget);

    await tester.tap(find.text('Reset filters'));
    await tester.pump();

    expect(resetCalled, isTrue);
  });
}

const _lines = [
  InventoryLowStockReportLine(
    inventoryItemId: 'i1',
    productId: 'p1',
    productName: 'Laptop',
    skuLabel: 'LT-001',
    categoryLabel: 'Electronics',
    currentQuantity: 0,
    reorderPoint: 5,
    reorderQuantity: 10,
    unitPrice: 100,
    warehouseId: 'w1',
    warehouseName: 'Main Warehouse',
    warehouseBranch: 'Jakarta Central',
    warehouseLocation: 'Jakarta',
  ),
  InventoryLowStockReportLine(
    inventoryItemId: 'i2',
    productId: 'p2',
    productName: 'Cable',
    skuLabel: 'CB-001',
    categoryLabel: 'Accessories',
    currentQuantity: 2,
    reorderPoint: 5,
    reorderQuantity: 3,
    unitPrice: 20,
    warehouseId: 'w1',
    warehouseName: 'Main Warehouse',
    warehouseBranch: 'Jakarta Central',
    warehouseLocation: 'Jakarta',
  ),
  InventoryLowStockReportLine(
    inventoryItemId: 'i3',
    productId: 'p3',
    productName: 'Notebook',
    skuLabel: 'No SKU',
    categoryLabel: 'Stationery',
    currentQuantity: 4,
    reorderPoint: 5,
    reorderQuantity: 8,
    unitPrice: 5,
    warehouseId: 'w1',
    warehouseName: 'Main Warehouse',
    warehouseBranch: 'Surabaya North',
    warehouseLocation: 'Surabaya',
  ),
];
