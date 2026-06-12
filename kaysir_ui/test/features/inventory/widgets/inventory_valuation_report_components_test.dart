import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_valuation_report.dart';
import 'package:kaysir/features/inventory/widgets/inventory_reset_filters_button.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';
import 'package:kaysir/features/inventory/widgets/inventory_valuation_report_components.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('valuation summary renders reusable metrics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryValuationSummaryGrid(
            summary: summarizeInventoryValuationLines(_lines),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Inventory Value'), findsOneWidget);
    expect(find.text('Units On Hand'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Avg Line Value'), findsOneWidget);
    expect(find.text(r'$600.00'), findsOneWidget);
  });

  testWidgets('valuation panel renders line tiles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: InventoryValuationPanel(lines: _lines))),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(InventoryValuationLineTile), findsNWidgets(2));
    expect(find.byType(InventoryTileSurface), findsAtLeastNWidgets(2));
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Main Warehouse'), findsWidgets);
    expect(find.text(r'$500.00'), findsOneWidget);
  });

  testWidgets('valuation panel shows empty state', (tester) async {
    var resetCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryValuationPanel(
            lines: const [],
            totalCount: 2,
            onResetFilters: () => resetCalled = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.byType(InventoryResetFiltersButton), findsOneWidget);
    expect(find.text('No value in this branch'), findsOneWidget);

    await tester.tap(find.text('Reset filters'));
    await tester.pump();

    expect(resetCalled, isTrue);
  });
}

const _lines = [
  InventoryValuationLine(
    inventoryItemId: 'i1',
    productId: 'p1',
    productName: 'Laptop',
    skuLabel: 'LT-001',
    categoryLabel: 'Electronics',
    warehouseId: 'w1',
    warehouseName: 'Main Warehouse',
    warehouseLocation: 'Jakarta',
    quantity: 5,
    unitPrice: 100,
  ),
  InventoryValuationLine(
    inventoryItemId: 'i2',
    productId: 'p2',
    productName: 'Cable',
    skuLabel: 'CB-001',
    categoryLabel: 'Accessories',
    warehouseId: 'w1',
    warehouseName: 'Main Warehouse',
    warehouseLocation: 'Jakarta',
    quantity: 4,
    unitPrice: 25,
  ),
];
