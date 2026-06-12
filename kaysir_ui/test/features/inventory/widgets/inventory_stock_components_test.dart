import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_list_panel.dart';
import 'package:kaysir/features/inventory/widgets/inventory_metric_chip.dart';
import 'package:kaysir/features/inventory/widgets/inventory_reset_filters_button.dart';
import 'package:kaysir/features/inventory/widgets/inventory_row_actions.dart';
import 'package:kaysir/features/inventory/widgets/inventory_search_field.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_status_pill.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_summary.dart';
import 'package:kaysir/features/inventory/widgets/inventory_stock_toolbar.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_filter_bar.dart';
import 'package:kaysir/widgets/ui/app_icon_action_button.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('inventory stock summary renders reusable metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: InventoryStockSummary(records: _records())),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Stock Lines'), findsOneWidget);
    expect(find.text('Units On Hand'), findsOneWidget);
    expect(find.text('Needs Attention'), findsOneWidget);
    expect(find.text('Stock Value'), findsOneWidget);
    expect(find.text(r'$5,300.00'), findsOneWidget);
  });

  testWidgets('inventory stock toolbar emits search and status changes', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    var query = '';
    var filter = InventoryStockFilter.all;
    var copied = false;
    String? branchName;
    String? warehouseId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockToolbar(
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

    await tester.tap(find.text('Attention'));
    await tester.pump();
    expect(filter, InventoryStockFilter.needsAttention);

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

  testWidgets('inventory stock list panel renders rows and actions', (
    tester,
  ) async {
    var viewed = false;
    var increased = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockListPanel(
            records: [_records().first],
            totalCount: 2,
            onViewDetails: (_) => viewed = true,
            onIncreaseStock: (_) => increased = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(InventoryStockListItem), findsOneWidget);
    expect(find.byType(InventoryStockStatusPill), findsOneWidget);
    expect(find.byType(InventoryQuantityBadge), findsOneWidget);
    expect(find.byType(InventoryMetricChip), findsAtLeastNWidgets(2));
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Low stock'), findsOneWidget);
    expect(find.text(r'$300.00'), findsOneWidget);
    expect(find.byType(InventoryRowActions), findsOneWidget);
    expect(find.byType(AppIconActionButton), findsNWidgets(4));

    await tester.tap(find.byTooltip('View stock details'));
    expect(viewed, isTrue);

    await tester.tap(find.byTooltip('Increase stock'));
    expect(increased, isTrue);
  });

  testWidgets('inventory stock list panel shows empty state', (tester) async {
    var resetCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryStockListPanel(
            records: const [],
            totalCount: 2,
            onResetFilters: () => resetCalled = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.byType(InventoryResetFiltersButton), findsOneWidget);
    expect(find.text('No matching stock lines'), findsOneWidget);

    await tester.tap(find.text('Reset filters'));
    await tester.pump();

    expect(resetCalled, isTrue);
  });
}

List<InventoryStockRecord> _records() {
  return buildInventoryStockRecords(
    products: [
      Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
      Product(id: 'p2', name: 'Speaker', sku: 'SP-001', price: 250),
    ],
    warehouses: _warehouses(),
    inventoryItems: [
      InventoryItem(
        id: 'i1',
        productId: 'p1',
        warehouseId: 'w1',
        currentQuantity: 3,
        reorderPoint: 5,
        reorderQuantity: 10,
      ),
      InventoryItem(
        id: 'i2',
        productId: 'p2',
        warehouseId: 'w2',
        currentQuantity: 20,
        reorderPoint: 5,
        reorderQuantity: 10,
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
