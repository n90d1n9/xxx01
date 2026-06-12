import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/inventory/models/inventory_purchase_order_detail.dart';
import 'package:kaysir/features/inventory/models/purchase_order.dart';
import 'package:kaysir/features/inventory/models/purchase_order_item.dart';
import 'package:kaysir/features/inventory/widgets/inventory_purchase_order_detail_components.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('purchase order detail summary renders reusable metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryPurchaseOrderDetailSummaryGrid(detail: _detail),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Order Value'), findsOneWidget);
    expect(find.text('Units'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Expected'), findsOneWidget);
  });

  testWidgets(
    'purchase order detail panels render overview items and actions',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1180, 920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var received = false;
      var cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  InventoryPurchaseOrderOverviewPanel(detail: _detail),
                  InventoryPurchaseOrderItemsPanel(detail: _detail),
                  InventoryPurchaseOrderActionsPanel(
                    detail: _detail,
                    onReceive: () => received = true,
                    onCancel: () => cancelled = true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AppContentPanel), findsNWidgets(3));
      expect(find.text('Jakarta Supply'), findsWidgets);
      expect(find.text('Adapter'), findsOneWidget);
      expect(find.text('Cable'), findsOneWidget);
      expect(find.text('Mark as Received'), findsOneWidget);
      expect(find.text('Cancel Order'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Mark as Received'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel Order'));

      expect(received, isTrue);
      expect(cancelled, isTrue);
    },
  );

  testWidgets('purchase order detail actions show closed state', (
    tester,
  ) async {
    final closedDetail = buildInventoryPurchaseOrderDetail(
      order: _order.copyWith(status: OrderStatus.received),
      asOfDate: DateTime(2026, 5, 31),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryPurchaseOrderActionsPanel(detail: closedDetail),
        ),
      ),
    );

    expect(find.text('Order Closed'), findsOneWidget);
    expect(find.text('Received'), findsOneWidget);
    expect(find.text('Mark as Received'), findsNothing);
  });
}

final _detail = buildInventoryPurchaseOrderDetail(
  order: _order,
  asOfDate: DateTime(2026, 5, 31),
);

final _order = PurchaseOrder(
  id: 'PO-DETAIL',
  vendorName: 'Jakarta Supply',
  orderDate: DateTime(2026, 5, 28),
  totalAmount: 0,
  status: OrderStatus.confirmed,
  expectedDeliveryDate: DateTime(2026, 6, 2),
  notes: 'Deliver before noon',
  items: [
    PurchaseOrderItem(
      id: 'i1',
      name: 'Adapter',
      quantity: 3,
      unitPrice: 15,
      sku: 'AD-001',
    ),
    PurchaseOrderItem(id: 'i2', name: 'Cable', quantity: 2, unitPrice: 15),
  ],
);
