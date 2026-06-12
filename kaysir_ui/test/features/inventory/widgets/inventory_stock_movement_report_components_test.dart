import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_movement_report.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_date_picker_button.dart';
import 'package:kaysir/features/inventory/widgets/inventory_inline_meta_pill.dart';
import 'package:kaysir/features/inventory/widgets/inventory_reset_filters_button.dart';
import 'package:kaysir/features/inventory/widgets/inventory_separated_list.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_movement_report_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('stock movement report summary renders reusable metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockMovementReportSummaryGrid(
            summary: summarizeInventoryStockMovementReportLines(_lines()),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Movements'), findsOneWidget);
    expect(find.text('Inbound'), findsOneWidget);
    expect(find.text('Outbound'), findsOneWidget);
    expect(find.text('Net Change'), findsOneWidget);
  });

  testWidgets('stock movement report filters render controls and reset', (
    tester,
  ) async {
    var resetCalled = false;
    var startDateCalled = false;
    String? selectedProductId;
    String? selectedBranch;
    MovementType? selectedMovementType;
    String? selectedWarehouseId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockMovementReportFilters(
            products: _products(),
            branchLabels: const ['Jakarta Central', 'Surabaya North'],
            warehouses: _warehouses(),
            startDate: DateTime(2026, 5, 1),
            endDate: DateTime(2026, 5, 31),
            productId: null,
            branchName: null,
            movementType: null,
            warehouseId: null,
            onSelectStartDate: () => startDateCalled = true,
            onSelectEndDate: () {},
            onProductChanged: (value) => selectedProductId = value,
            onBranchChanged: (value) => selectedBranch = value,
            onMovementTypeChanged: (value) => selectedMovementType = value,
            onWarehouseChanged: (value) => selectedWarehouseId = value,
            onResetFilters: () => resetCalled = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(InventoryDatePickerButton), findsNWidgets(2));
    expect(find.byType(InventoryResetFiltersButton), findsOneWidget);
    expect(find.text('Report Filters'), findsOneWidget);
    expect(find.byType(AppSelectField<String>), findsNWidgets(4));
    expect(find.text('Start date'), findsOneWidget);
    expect(find.text('End date'), findsOneWidget);

    await tester.tap(find.text('All products'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cable').last);
    await tester.pumpAndSettle();
    expect(selectedProductId, 'p2');

    await tester.tap(find.text('All branches'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Surabaya North').last);
    await tester.pumpAndSettle();
    expect(selectedBranch, 'Surabaya North');

    await tester.tap(find.text('All types'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sale').last);
    await tester.pumpAndSettle();
    expect(selectedMovementType, MovementType.sale);

    await tester.tap(find.text('All warehouses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('North Warehouse').last);
    await tester.pumpAndSettle();
    expect(selectedWarehouseId, 'w2');

    await tester.tap(find.text('Start date'));
    await tester.pump();
    expect(startDateCalled, isTrue);

    await tester.tap(find.text('Reset filters'));
    await tester.pump();
    expect(resetCalled, isTrue);
  });

  testWidgets('stock movement report panel renders movement rows', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockMovementReportPanel(
            lines: _lines(),
            totalCount: _lines().length,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(
      find.byType(InventorySeparatedList<InventoryStockMovementReportLine>),
      findsOneWidget,
    );
    expect(find.byType(InventoryStockMovementReportTile), findsNWidgets(3));
    expect(find.byType(InventoryInlineMetaPill), findsNWidgets(9));
    expect(find.byType(InventoryTileSurface), findsAtLeastNWidgets(12));
    expect(find.text('Movement Ledger'), findsOneWidget);
    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Laptop'), findsNWidgets(2));
    expect(find.text('Transfer'), findsOneWidget);
    expect(find.text('Purchase'), findsOneWidget);
    expect(find.text('Sale'), findsOneWidget);
    expect(find.text(r'$100.00'), findsWidgets);
  });

  testWidgets('stock movement report panel shows empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryStockMovementReportPanel(lines: [], totalCount: 3),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No matching movements'), findsOneWidget);
  });
}

List<InventoryStockMovementReportLine> _lines() {
  return buildInventoryStockMovementReportLines(
    products: _products(),
    warehouses: _warehouses(),
    movements: [
      InventoryMovement(
        id: 'm1',
        productId: 'p2',
        sourceWarehouseId: 'w1',
        destinationWarehouseId: 'w2',
        quantity: 4,
        type: MovementType.transfer,
        date: DateTime(2026, 5, 31, 9),
        reference: 'TRF-001',
      ),
      InventoryMovement(
        id: 'm2',
        productId: 'p1',
        sourceWarehouseId: 'w1',
        quantity: 5,
        type: MovementType.purchase,
        date: DateTime(2026, 5, 30, 8),
        reference: 'PO-001',
      ),
      InventoryMovement(
        id: 'm3',
        productId: 'p1',
        sourceWarehouseId: 'w1',
        quantity: 2,
        type: MovementType.sale,
        date: DateTime(2026, 5, 29, 8),
        reference: 'SO-001',
      ),
    ],
  );
}

List<Product> _products() {
  return [
    Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
    Product(id: 'p2', name: 'Cable', sku: 'CB-001', price: 25),
  ];
}

List<Warehouse> _warehouses() {
  return [
    Warehouse(
      id: 'w1',
      name: 'Main Warehouse',
      branchName: 'Jakarta Central',
      location: 'Jakarta',
    ),
    Warehouse(
      id: 'w2',
      name: 'North Warehouse',
      branchName: 'Surabaya North',
      location: 'Surabaya',
    ),
  ];
}
