import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/inventory_movement_record.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_inline_meta_pill.dart';
import 'package:kaysir/features/inventory/widgets/inventory_movement_history_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_reset_filters_button.dart';
import 'package:kaysir/features/inventory/widgets/inventory_search_field.dart';
import 'package:kaysir/features/inventory/widgets/inventory_separated_list.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_filter_bar.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('inventory movement summary renders movement metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryMovementHistorySummary(records: _records()),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Movements'), findsOneWidget);
    expect(find.text('Inbound Qty'), findsOneWidget);
    expect(find.text('Outbound Qty'), findsOneWidget);
    expect(find.text('Transfers'), findsOneWidget);
  });

  testWidgets('inventory movement toolbar emits search and filter changes', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    var query = '';
    var filter = InventoryMovementFilter.all;
    var copied = false;
    String? branchName;
    String? warehouseId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryMovementHistoryToolbar(
            searchController: controller,
            records: _records(),
            branchLabels: const ['Jakarta Central', 'Surabaya North'],
            warehouses: _warehouses(),
            selectedBranch: null,
            selectedWarehouseId: null,
            filter: filter,
            onSearchChanged: (value) => query = value,
            onBranchChanged: (value) => branchName = value,
            onWarehouseChanged: (value) => warehouseId = value,
            onFilterChanged: (value) => filter = value,
            onCopyLink: () => copied = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppFilterBar), findsOneWidget);
    expect(find.byType(InventorySearchField), findsOneWidget);
    expect(find.byType(AppSelectField<String>), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'speaker');
    await tester.pump();
    expect(query, 'speaker');

    await tester.tap(find.text('Outbound'));
    await tester.pump();
    expect(filter, InventoryMovementFilter.outbound);

    await tester.tap(find.text('All branches'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Surabaya North').last);
    await tester.pumpAndSettle();
    expect(branchName, 'Surabaya North');

    await tester.tap(find.text('All warehouses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('North Warehouse').last);
    await tester.pumpAndSettle();
    expect(warehouseId, 'w2');

    await tester.tap(find.byTooltip('Copy filtered link'));
    await tester.pump();
    expect(copied, isTrue);
  });

  testWidgets('inventory movement panel renders timeline rows', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryMovementHistoryPanel(
            records: _records(),
            totalCount: _records().length,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(
      find.byType(InventorySeparatedList<InventoryMovementRecord>),
      findsOneWidget,
    );
    expect(find.byType(InventoryMovementTimelineTile), findsNWidgets(3));
    expect(find.byType(InventoryInlineMetaPill), findsNWidgets(6));
    expect(find.byType(InventoryTileSurface), findsAtLeastNWidgets(9));
    expect(find.text('Movement Timeline'), findsOneWidget);
    expect(find.text('Speaker'), findsOneWidget);
    expect(find.text('Laptop'), findsNWidgets(2));
    expect(find.text('Transfer'), findsOneWidget);
    expect(find.text('Inbound'), findsOneWidget);
    expect(find.text('Outbound'), findsOneWidget);
  });

  testWidgets('inventory movement panel renders empty state', (tester) async {
    var resetCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryMovementHistoryPanel(
            records: const [],
            totalCount: 3,
            onResetFilters: () => resetCalled = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.byType(InventoryResetFiltersButton), findsOneWidget);
    expect(find.text('No matching movements'), findsOneWidget);

    await tester.tap(find.text('Reset filters'));
    await tester.pump();

    expect(resetCalled, isTrue);
  });
}

List<InventoryMovementRecord> _records() {
  return buildInventoryMovementRecords(
    products: [
      Product(id: 'p1', name: 'Laptop', sku: 'LT-001'),
      Product(id: 'p2', name: 'Speaker', sku: 'SP-001'),
    ],
    warehouses: _warehouses(),
    movements: [
      InventoryMovement(
        id: 'm1',
        productId: 'p2',
        sourceWarehouseId: 'w1',
        destinationWarehouseId: 'w2',
        quantity: 2,
        type: MovementType.transfer,
        date: DateTime(2026, 5, 31, 9),
        reference: 'TRF-001',
      ),
      InventoryMovement(
        id: 'm2',
        productId: 'p1',
        sourceWarehouseId: 'w1',
        quantity: 3,
        type: MovementType.purchase,
        date: DateTime(2026, 5, 30, 8),
        reference: 'PO-001',
      ),
      InventoryMovement(
        id: 'm3',
        productId: 'p1',
        sourceWarehouseId: 'w1',
        quantity: 1,
        type: MovementType.sale,
        date: DateTime(2026, 5, 29, 8),
        reference: 'SO-001',
      ),
    ],
  );
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
