import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/inventory/models/inventory_purchase_order_saved_view.dart';
import 'package:kaysir/features/inventory/models/inventory_purchase_order_workspace.dart';
import 'package:kaysir/features/inventory/models/purchase_order.dart';
import 'package:kaysir/features/inventory/models/purchase_order_item.dart';
import 'package:kaysir/features/inventory/widgets/inventory_purchase_order_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_search_field.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('purchase order summary renders reusable metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryPurchaseOrderSummaryGrid(summary: _summary),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Purchase Orders'), findsOneWidget);
    expect(find.text('Open Value'), findsOneWidget);
    expect(find.text('Needs Receiving'), findsOneWidget);
    expect(find.text('Received Value'), findsOneWidget);
  });

  testWidgets('purchase order toolbar emits search and filter changes', (
    tester,
  ) async {
    final searchController = TextEditingController();
    addTearDown(searchController.dispose);
    var query = '';
    var filter = InventoryPurchaseOrderFilter.all;
    var sort = InventoryPurchaseOrderSort.urgency;
    var selectedSavedViewId = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return InventoryPurchaseOrderToolbar(
                searchController: searchController,
                filter: filter,
                sort: sort,
                summary: _summary,
                onSearchChanged: (value) => setState(() => query = value),
                onFilterChanged: (value) => setState(() => filter = value),
                onSortChanged: (value) => setState(() => sort = value),
                activeSavedViewId:
                    selectedSavedViewId.isEmpty ? null : selectedSavedViewId,
                onSavedViewSelected:
                    (value) => setState(() => selectedSavedViewId = value.id),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(InventorySearchField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'router');
    await tester.pump();
    expect(query, 'router');

    await tester.tap(find.text('Receiving'));
    await tester.pump();
    expect(filter, InventoryPurchaseOrderFilter.needsReceiving);

    await tester.tap(find.text('Overdue'));
    await tester.pump();
    expect(filter, InventoryPurchaseOrderFilter.overdue);

    await tester.tap(find.byType(DropdownButton<InventoryPurchaseOrderSort>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Highest value').last);
    await tester.pumpAndSettle();

    expect(sort, InventoryPurchaseOrderSort.valueHigh);

    await tester.tap(find.byTooltip('Purchase order saved views'));
    await tester.pumpAndSettle();
    expect(find.text('Status: Receiving'), findsWidgets);
    expect(find.text('Status: Overdue'), findsOneWidget);
    expect(find.text('Sort: Expected date'), findsOneWidget);
    await tester.tap(find.text('Receiving now').last);
    await tester.pumpAndSettle();

    expect(selectedSavedViewId, 'receiving-now');
    expect(find.text('Receiving now'), findsOneWidget);
  });

  testWidgets('purchase order schedule panel renders receiving buckets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryPurchaseOrderSchedulePanel(
            buckets: buildInventoryPurchaseOrderScheduleBuckets(_records),
          ),
        ),
      ),
    );

    expect(find.text('Receiving schedule'), findsOneWidget);
    expect(find.text('2 orders'), findsOneWidget);
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text('Due today'), findsOneWidget);
    expect(find.text('Next 7 days'), findsOneWidget);
    expect(find.text('No ETA'), findsOneWidget);
    expect(find.text('2 units'), findsOneWidget);
    expect(find.text(r'$20.00'), findsOneWidget);
    expect(find.text(r'$200.00'), findsOneWidget);
  });

  testWidgets('purchase order saved view button names active preset', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryPurchaseOrderSavedViewButton(
            savedViews: inventoryPurchaseOrderSavedViews,
            activeSavedViewId: 'highest-value',
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Highest value'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_added_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Purchase order saved views'));
    await tester.pumpAndSettle();

    expect(find.text('Sort: Highest value'), findsOneWidget);
  });

  testWidgets('purchase order active filters render clear actions', (
    tester,
  ) async {
    var queryCleared = false;
    var filterCleared = false;
    var sortCleared = false;
    var allCleared = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryPurchaseOrderActiveFilterBar(
            query: 'PO-FUTURE',
            filter: InventoryPurchaseOrderFilter.overdue,
            sort: InventoryPurchaseOrderSort.valueHigh,
            onQueryCleared: () => queryCleared = true,
            onFilterCleared: () => filterCleared = true,
            onSortCleared: () => sortCleared = true,
            onClearAll: () => allCleared = true,
          ),
        ),
      ),
    );

    expect(find.text('Active controls'), findsOneWidget);
    expect(find.text('Search: PO-FUTURE'), findsOneWidget);
    expect(find.text('Status: Overdue'), findsOneWidget);
    expect(find.text('Sort: Highest value'), findsOneWidget);
    expect(find.text('Reset queue'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear purchase order search'));
    await tester.tap(find.byTooltip('Clear purchase order status filter'));
    await tester.tap(find.byTooltip('Reset purchase order sort'));
    await tester.tap(find.text('Reset queue'));

    expect(queryCleared, isTrue);
    expect(filterCleared, isTrue);
    expect(sortCleared, isTrue);
    expect(allCleared, isTrue);
  });

  test('purchase order active filter predicate detects visible filters', () {
    expect(
      hasActiveInventoryPurchaseOrderFilters(
        query: '',
        filter: InventoryPurchaseOrderFilter.all,
      ),
      isFalse,
    );
    expect(
      hasActiveInventoryPurchaseOrderFilters(
        query: 'network',
        filter: InventoryPurchaseOrderFilter.all,
      ),
      isTrue,
    );
    expect(
      hasActiveInventoryPurchaseOrderFilters(
        query: '',
        filter: InventoryPurchaseOrderFilter.cancelled,
      ),
      isTrue,
    );
    expect(
      hasActiveInventoryPurchaseOrderControls(
        query: '',
        filter: InventoryPurchaseOrderFilter.all,
        sort: InventoryPurchaseOrderSort.valueHigh,
      ),
      isTrue,
    );
  });

  testWidgets('purchase order panel renders modern queue tiles', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: InventoryPurchaseOrderPanel(records: _records)),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(InventoryPurchaseOrderTile), findsNWidgets(3));
    expect(find.text('3 visible, 1 overdue'), findsOneWidget);
    expect(find.text('PO-OVERDUE'), findsOneWidget);
    expect(find.text('Overdue'), findsWidgets);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('Received'), findsOneWidget);
    expect(find.text(r'$200.00'), findsOneWidget);
  });

  testWidgets('purchase order panel shows empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: InventoryPurchaseOrderPanel(records: [])),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No purchase orders yet'), findsOneWidget);
  });

  testWidgets('purchase order panel clears filtered empty state', (
    tester,
  ) async {
    var cleared = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryPurchaseOrderPanel(
            records: const [],
            hasActiveFilters: true,
            onClearFilters: () => cleared = true,
          ),
        ),
      ),
    );

    expect(find.byType(InventoryPurchaseOrderEmptyState), findsOneWidget);
    expect(find.text('No purchase orders match these filters'), findsOneWidget);
    expect(find.text('Reset filters'), findsOneWidget);

    await tester.tap(find.text('Reset filters'));

    expect(cleared, isTrue);
  });
}

final _records = buildInventoryPurchaseOrderRecords(
  orders: _orders,
  asOfDate: DateTime(2026, 5, 31),
);

final _summary = summarizeInventoryPurchaseOrderRecords(_records);

final _orders = [
  PurchaseOrder(
    id: 'PO-OVERDUE',
    vendorName: 'Jakarta Supply',
    orderDate: DateTime(2026, 5, 26),
    totalAmount: 0,
    status: OrderStatus.pending,
    expectedDeliveryDate: DateTime(2026, 5, 30),
    items: [
      PurchaseOrderItem(id: 'i1', name: 'Adapter', quantity: 2, unitPrice: 10),
    ],
  ),
  PurchaseOrder(
    id: 'PO-FUTURE',
    supplierName: 'Network Partner',
    orderDate: DateTime(2026, 5, 28),
    totalAmount: 200,
    status: OrderStatus.confirmed,
    expectedDeliveryDate: DateTime(2026, 6, 5),
    items: [
      PurchaseOrderItem(id: 'i2', name: 'Router', quantity: 4, unitPrice: 50),
    ],
  ),
  PurchaseOrder(
    id: 'PO-RECEIVED',
    supplierName: 'Office Vendor',
    orderDate: DateTime(2026, 5, 20),
    totalAmount: 100,
    status: OrderStatus.received,
    expectedDeliveryDate: DateTime(2026, 5, 25),
    items: [
      PurchaseOrderItem(
        id: 'i3',
        name: 'Notebook',
        quantity: 8,
        unitPrice: 12.5,
      ),
    ],
  ),
];
