import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/purchase_order.dart';
import 'package:kaysir/features/inventory/models/purchase_order_item.dart';
import 'package:kaysir/features/inventory/models/stock_movement.dart';
import 'package:kaysir/features/inventory/inventory_routes.dart';
import 'package:kaysir/features/inventory/screens/purchase_order/dashboard_screen.dart';
import 'package:kaysir/features/inventory/screens/purchase_order/purchase_order_detail_screen.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/purchase_order_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/inventory/widgets/inventory_purchase_order_dashboard_components.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/states/stock_movement_provider.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('purchase order dashboard composes buying workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_dashboardPage());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(
      find.byType(InventoryPurchaseOrderDashboardSummaryGrid),
      findsOneWidget,
    );
    expect(find.byType(InventoryPurchaseOrderDashboardGrid), findsOneWidget);
    expect(find.text('Purchase Order Dashboard'), findsWidgets);
    expect(find.text('Cable'), findsWidgets);
    expect(find.text('Sale'), findsOneWidget);
    expect(find.text('-2 units'), findsOneWidget);
    expect(find.text('PO-PENDING'), findsOneWidget);
  });

  testWidgets('purchase order dashboard opens receiving order detail', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_dashboardPage());

    await tester.tap(find.text('PO-PENDING'));
    await tester.pumpAndSettle();

    expect(find.byType(PurchaseOrderDetailScreen), findsOneWidget);
    expect(find.text('Purchase Order Details'), findsOneWidget);
    expect(find.text('Jakarta Supply'), findsWidgets);
    expect(find.byTooltip('Open inventory navigation'), findsOneWidget);

    await tester.tap(find.byTooltip('Open inventory navigation'));
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

    await tester.tap(find.text('Purchase Orders').last);
    await tester.pumpAndSettle();

    expect(find.text('Purchase orders route'), findsOneWidget);
  });

  testWidgets(
    'purchase order dashboard uses shared inventory navigation drawer',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1180, 920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_dashboardPage());

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

Widget _dashboardPage() {
  return ProviderScope(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(_products)),
      stockMovementsProvider.overrideWith(
        (ref) => _SeededStockMovements(_movements),
      ),
      purchaseOrdersProvider.overrideWith(
        (ref) => _SeededPurchaseOrders(_orders),
      ),
    ],
    child: MaterialApp(
      routes: {
        InventoryRoutes.purchaseOrders:
            (context) => const Scaffold(body: Text('Purchase orders route')),
      },
      home: const DashboardScreen(),
    ),
  );
}

class _SeededProducts extends ProductsNotifier {
  _SeededProducts(List<Product> products) {
    state = products;
  }
}

class _SeededStockMovements extends StockMovementsNotifier {
  _SeededStockMovements(List<StockMovement> movements) {
    state = movements;
  }
}

class _SeededPurchaseOrders extends PurchaseOrdersNotifier {
  _SeededPurchaseOrders(List<PurchaseOrder> orders) : super() {
    state = orders;
  }
}

final _products = [
  Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100, currentStock: 8),
  Product(id: 'p2', name: 'Cable', sku: 'CB-001', price: 20, currentStock: 3),
  Product(id: 'p3', name: 'Adapter', sku: 'AD-001', price: 5, currentStock: 0),
];

final _movements = [
  StockMovement(
    id: 'm1',
    productId: 'p2',
    quantity: 2,
    type: MovementType.sale,
    date: DateTime(2026, 5, 31),
    reference: 'SO-001',
  ),
];

final _orders = [
  PurchaseOrder(
    id: 'PO-PENDING',
    vendorName: 'Jakarta Supply',
    orderDate: DateTime(2026, 5, 29),
    totalAmount: 50,
    status: OrderStatus.pending,
    expectedDeliveryDate: DateTime(2026, 5, 30),
    items: [
      PurchaseOrderItem(id: 'i1', name: 'Adapter', quantity: 5, unitPrice: 10),
    ],
  ),
];
