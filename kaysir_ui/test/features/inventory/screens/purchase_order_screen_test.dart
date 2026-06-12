import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/inventory/invent_apps.dart';
import 'package:kaysir/features/inventory/models/inventory_filter_deep_link.dart';
import 'package:kaysir/features/inventory/models/inventory_purchase_order_workspace.dart';
import 'package:kaysir/features/inventory/models/purchase_order.dart';
import 'package:kaysir/features/inventory/models/purchase_order_item.dart';
import 'package:kaysir/features/inventory/screens/purchase_order/purchase_order_detail_screen.dart';
import 'package:kaysir/features/inventory/screens/purchase_order/purchase_order_screen.dart';
import 'package:kaysir/features/inventory/states/purchase_order_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_purchase_order_components.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('purchase orders page composes command center workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_purchaseOrdersPage());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryPurchaseOrderSummaryGrid), findsOneWidget);
    expect(find.byType(InventoryPurchaseOrderToolbar), findsOneWidget);
    expect(find.byType(InventoryPurchaseOrderSchedulePanel), findsOneWidget);
    expect(find.byType(InventoryPurchaseOrderPanel), findsOneWidget);
    expect(find.text('Purchase Order Command Center'), findsOneWidget);
    expect(find.text('Receiving schedule'), findsOneWidget);
    expect(find.text('PO-OVERDUE'), findsOneWidget);
    expect(find.textContaining('Jakarta Supply'), findsOneWidget);
    expect(find.text('Overdue'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'network');
    await tester.pump();
    await _showPurchaseOrderQueue(tester);

    expect(find.text('PO-FUTURE'), findsOneWidget);
    expect(find.text('PO-OVERDUE'), findsNothing);
  });

  testWidgets('purchase orders page opens detail without null supplier crash', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_purchaseOrdersPage());

    await _showPurchaseOrderQueue(tester);
    await tester.tap(find.text('PO-OVERDUE'));
    await tester.pumpAndSettle();

    expect(find.byType(PurchaseOrderDetailScreen), findsOneWidget);
    expect(find.text('Purchase Order Details'), findsOneWidget);
    expect(find.text('Jakarta Supply'), findsWidgets);
    expect(find.text('Pending'), findsOneWidget);
  });

  testWidgets('purchase orders page applies initial query deep link', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_purchaseOrdersPage(initialQuery: 'PO-FUTURE'));
    await _showPurchaseOrderQueue(tester);

    expect(find.text('PO-FUTURE'), findsNWidgets(2));
    expect(find.text('PO-OVERDUE'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'PO-FUTURE',
    );
  });

  testWidgets(
    'purchase orders page surfaces and clears active search filters',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1180, 920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_purchaseOrdersPage(initialQuery: 'PO-FUTURE'));

      expect(find.text('Active controls'), findsOneWidget);
      expect(find.text('Search: PO-FUTURE'), findsOneWidget);

      await tester.tap(find.text('Reset queue'));
      await tester.pump();
      await _showPurchaseOrderQueue(tester);

      expect(find.text('Active controls'), findsNothing);
      expect(find.text('PO-FUTURE'), findsOneWidget);
      expect(find.text('PO-OVERDUE'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '',
      );
    },
  );

  testWidgets('purchase orders page recovers from no-match search', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_purchaseOrdersPage());

    await tester.enterText(find.byType(TextField), 'missing supplier');
    await tester.pump();
    await _showPurchaseOrderQueue(tester);

    expect(find.text('No purchase orders match these filters'), findsOneWidget);
    expect(find.text('Reset filters'), findsOneWidget);
    expect(find.text('PO-FUTURE'), findsNothing);

    await tester.ensureVisible(find.text('Reset filters'));
    await tester.pump();
    await tester.tap(find.text('Reset filters'));
    await tester.pump();
    await _showPurchaseOrderQueue(tester);

    expect(find.text('No purchase orders match these filters'), findsNothing);
    expect(find.text('PO-FUTURE'), findsOneWidget);
    expect(find.text('PO-OVERDUE'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
    );
  });

  testWidgets('purchase orders page filters overdue commitments', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_purchaseOrdersPage());

    await tester.tap(
      find
          .ancestor(of: find.text('Overdue'), matching: find.byType(ChoiceChip))
          .first,
    );
    await tester.pump();

    expect(find.text('Active controls'), findsOneWidget);
    expect(find.text('Status: Overdue'), findsOneWidget);
    await _showPurchaseOrderQueue(tester);
    expect(find.text('PO-OVERDUE'), findsOneWidget);
    expect(find.text('PO-FUTURE'), findsNothing);
  });

  testWidgets('purchase orders page sorts visible queue by value', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_purchaseOrdersPage());
    await _showPurchaseOrderQueue(tester);

    expect(
      tester.getTopLeft(find.text('PO-OVERDUE')).dy,
      lessThan(tester.getTopLeft(find.text('PO-FUTURE')).dy),
    );

    await _showPurchaseOrderToolbar(tester);
    await tester.tap(find.byType(DropdownButton<InventoryPurchaseOrderSort>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Highest value').last);
    await tester.pumpAndSettle();

    expect(find.text('Active controls'), findsOneWidget);
    expect(find.text('Sort: Highest value'), findsOneWidget);
    await _showPurchaseOrderQueue(tester);
    expect(
      tester.getTopLeft(find.text('PO-FUTURE')).dy,
      lessThan(tester.getTopLeft(find.text('PO-OVERDUE')).dy),
    );

    await _showPurchaseOrderToolbar(tester);
    await tester.tap(find.byTooltip('Reset purchase order sort'));
    await tester.pumpAndSettle();
    await _showPurchaseOrderQueue(tester);

    expect(find.text('Active controls'), findsNothing);
    expect(
      tester.getTopLeft(find.text('PO-OVERDUE')).dy,
      lessThan(tester.getTopLeft(find.text('PO-FUTURE')).dy),
    );
  });

  testWidgets('purchase orders page applies saved view presets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_purchaseOrdersPage());

    await tester.tap(find.byTooltip('Purchase order saved views'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Receiving now').last);
    await tester.pumpAndSettle();

    expect(find.text('Active controls'), findsOneWidget);
    expect(find.text('Receiving now'), findsOneWidget);
    expect(find.text('Status: Receiving'), findsOneWidget);
    expect(find.text('Sort: Expected date'), findsOneWidget);
    await _showPurchaseOrderQueue(tester);
    expect(find.text('PO-OVERDUE'), findsOneWidget);
    expect(find.text('PO-FUTURE'), findsOneWidget);
  });

  testWidgets('purchase orders route applies query deep link', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _purchaseOrdersRouteApp(
        inventoryPurchaseOrdersDeepLink(query: 'PO-FUTURE'),
      ),
    );

    expect(find.byType(PurchaseOrdersScreen), findsOneWidget);
    await _showPurchaseOrderQueue(tester);
    expect(find.text('PO-FUTURE'), findsNWidgets(2));
    expect(find.text('PO-OVERDUE'), findsNothing);
  });
}

Future<void> _showPurchaseOrderQueue(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byType(InventoryPurchaseOrderPanel),
    420,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
}

Future<void> _showPurchaseOrderToolbar(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byType(InventoryPurchaseOrderToolbar),
    -420,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
}

Widget _purchaseOrdersPage({String initialQuery = ''}) {
  return ProviderScope(
    overrides: [
      purchaseOrdersProvider.overrideWith(
        (ref) => _SeededPurchaseOrders(_orders),
      ),
    ],
    child: MaterialApp(
      home: PurchaseOrdersScreen(
        initialQuery: initialQuery,
        asOfDate: DateTime(2026, 5, 31),
      ),
    ),
  );
}

Widget _purchaseOrdersRouteApp(String initialRoute) {
  return ProviderScope(
    overrides: [
      purchaseOrdersProvider.overrideWith(
        (ref) => _SeededPurchaseOrders(_orders),
      ),
    ],
    child: MaterialApp(
      initialRoute: initialRoute,
      onGenerateRoute: inventoryRouteFromSettings,
    ),
  );
}

class _SeededPurchaseOrders extends PurchaseOrdersNotifier {
  _SeededPurchaseOrders(List<PurchaseOrder> orders) : super() {
    state = orders;
  }
}

final _orders = [
  PurchaseOrder(
    id: 'PO-OVERDUE',
    vendorName: 'Jakarta Supply',
    orderDate: DateTime(2026, 5, 26),
    totalAmount: 35,
    status: OrderStatus.pending,
    expectedDeliveryDate: DateTime(2026, 5, 30),
    items: [
      PurchaseOrderItem(
        id: 'i1',
        name: 'Adapter',
        quantity: 2,
        unitPrice: 10,
        sku: 'AD-001',
      ),
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
];
