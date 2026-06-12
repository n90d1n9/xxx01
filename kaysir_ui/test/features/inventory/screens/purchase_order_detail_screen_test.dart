import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/inventory/models/purchase_order.dart';
import 'package:kaysir/features/inventory/models/purchase_order_item.dart';
import 'package:kaysir/features/inventory/screens/purchase_order/purchase_order_detail_screen.dart';
import 'package:kaysir/features/inventory/states/purchase_order_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/inventory/widgets/inventory_purchase_order_detail_components.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('purchase order detail screen composes modern detail workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_detailPage(_confirmedOrder));

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(
      find.byType(InventoryPurchaseOrderDetailSummaryGrid),
      findsOneWidget,
    );
    expect(find.byType(InventoryPurchaseOrderOverviewPanel), findsOneWidget);
    expect(find.byType(InventoryPurchaseOrderItemsPanel), findsOneWidget);
    expect(find.text('Purchase Order Details'), findsOneWidget);
    expect(find.text('PO-DETAIL'), findsWidgets);
    expect(find.text('Jakarta Supply'), findsWidgets);
    expect(find.text('Adapter'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byType(InventoryPurchaseOrderActionsPanel),
      360,
    );

    expect(find.byType(InventoryPurchaseOrderActionsPanel), findsOneWidget);
    expect(find.text('Mark as Received'), findsOneWidget);
  });

  testWidgets('purchase order detail screen receives confirmed orders', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_detailPage(_confirmedOrder));

    await tester.scrollUntilVisible(find.text('Mark as Received'), 360);
    await tester.tap(find.widgetWithText(FilledButton, 'Mark as Received'));
    await tester.pumpAndSettle();

    expect(find.text('Received'), findsWidgets);
    expect(find.text('Order Closed'), findsOneWidget);
  });

  testWidgets('purchase order detail screen cancels pending orders', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _detailPage(_confirmedOrder.copyWith(status: OrderStatus.pending)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Cancel Order'), 360);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel Order'));
    await tester.pumpAndSettle();

    expect(find.text('Cancelled'), findsWidgets);
    expect(find.text('Order Closed'), findsOneWidget);
  });

  testWidgets(
    'purchase order detail screen uses shared inventory navigation drawer',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1180, 920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_detailPage(_confirmedOrder));

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      final drawer = tester.widget<NavigationDrawer>(
        find.byType(NavigationDrawer),
      );
      expect(
        drawer.selectedIndex,
        InventoryNavigationDrawer.destinations.indexOf(
          InventoryNavigationDestination.purchaseOrders,
        ),
      );
    },
  );
}

Widget _detailPage(PurchaseOrder order) {
  return ProviderScope(
    overrides: [
      purchaseOrdersProvider.overrideWith(
        (ref) => _SeededPurchaseOrders([order]),
      ),
    ],
    child: MaterialApp(home: PurchaseOrderDetailScreen(order: order)),
  );
}

class _SeededPurchaseOrders extends PurchaseOrdersNotifier {
  _SeededPurchaseOrders(List<PurchaseOrder> orders) : super() {
    state = orders;
  }
}

final _confirmedOrder = PurchaseOrder(
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
