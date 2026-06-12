import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';
import 'package:kaysir/features/inventory/models/purchase_order.dart';
import 'package:kaysir/features/inventory/screens/purchase_order/create_purchase_order_screen.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/purchase_order_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_purchase_order_create_components.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('create purchase order screen composes reusable panels', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_createPurchaseOrderPage(products: _products));

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(
      find.byType(InventoryPurchaseOrderCreateSummaryGrid),
      findsOneWidget,
    );
    expect(
      find.byType(InventoryPurchaseOrderCreateDetailsPanel),
      findsOneWidget,
    );
    expect(find.byType(InventoryPurchaseOrderCreateItemsPanel), findsOneWidget);
    expect(find.text('Create Purchase Order'), findsWidgets);
    expect(
      find.text('Build a supplier order from 2 available products'),
      findsOneWidget,
    );
    expect(find.text('Supplier & Delivery'), findsOneWidget);
    expect(find.text('Order Items'), findsOneWidget);
  });

  testWidgets('create purchase order screen saves a supplier order', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    late _SeededPurchaseOrders ordersNotifier;

    await tester.pumpWidget(
      _createPurchaseOrderHost(
        products: _products,
        onPurchaseOrdersReady: (notifier) => ordersNotifier = notifier,
      ),
    );

    await tester.tap(find.text('Open creator'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Supplier name'),
      'Jakarta Supply',
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Add item'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppSelectField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laptop').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Quantity'), '2');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Add item').last);
    await tester.pumpAndSettle();

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text(r'$200.00'), findsWidgets);

    final createButton = find.widgetWithText(
      FilledButton,
      r'Create $200.00 order',
    );
    await tester.ensureVisible(createButton);
    await tester.pumpAndSettle();
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(find.text('Open creator'), findsOneWidget);
    expect(ordersNotifier.state, hasLength(1));

    final order = ordersNotifier.state.single;
    expect(order.id, startsWith('PO-'));
    expect(order.supplierName, 'Jakarta Supply');
    expect(order.vendorName, 'Jakarta Supply');
    expect(order.status, OrderStatus.confirmed);
    expect(order.totalAmount, 200);
    expect(order.items.single.name, 'Laptop');
    expect(order.items.single.quantity, 2);
  });
}

Widget _createPurchaseOrderPage({required List<Product> products}) {
  return ProviderScope(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(products)),
    ],
    child: const MaterialApp(home: CreatePurchaseOrderScreen()),
  );
}

Widget _createPurchaseOrderHost({
  required List<Product> products,
  required ValueChanged<_SeededPurchaseOrders> onPurchaseOrdersReady,
}) {
  return ProviderScope(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(products)),
      purchaseOrdersProvider.overrideWith((ref) {
        final notifier = _SeededPurchaseOrders(const []);
        onPurchaseOrdersReady(notifier);
        return notifier;
      }),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CreatePurchaseOrderScreen(),
                    ),
                  );
                },
                child: const Text('Open creator'),
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _SeededProducts extends ProductsNotifier {
  _SeededProducts(List<Product> products) {
    state = products;
  }
}

class _SeededPurchaseOrders extends PurchaseOrdersNotifier {
  _SeededPurchaseOrders(List<PurchaseOrder> orders) : super() {
    state = orders;
  }
}

final _products = [
  Product(id: 'p1', name: 'Laptop', sku: 'LT-001', price: 100),
  Product(id: 'p2', name: 'Cable', sku: 'CB-001', price: 20),
];
