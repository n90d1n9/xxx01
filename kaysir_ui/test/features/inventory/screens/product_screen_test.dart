import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/product_screen.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_dialog.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('product page composes modern catalog workspace', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productPage());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryProductCatalogSummaryGrid), findsOneWidget);
    expect(find.byType(InventoryProductCatalogToolbar), findsOneWidget);
    expect(find.byType(InventoryProductCatalogPanel), findsOneWidget);
    expect(find.text('Product Directory'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Notebook'), findsOneWidget);
    expect(find.text('Untracked'), findsWidgets);

    await tester.enterText(find.byType(TextField).first, 'cable');
    await tester.pump();

    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Laptop'), findsNothing);
  });

  testWidgets('product page uses shared inventory navigation shell', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productPage());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryNavigationDrawer), findsOneWidget);

    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );
    expect(
      drawer.selectedIndex,
      InventoryNavigationDrawer.destinations.indexOf(
        InventoryNavigationDestination.products,
      ),
    );
  });

  testWidgets('product page adds edits and deletes products', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_productPage());

    await tester.tap(find.byTooltip('Add product'));
    await tester.pumpAndSettle();

    var fields = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(fields.at(0), 'Scanner');
    await tester.enterText(fields.at(1), 'SC-001');
    await tester.enterText(fields.at(2), 'Hardware');
    await tester.enterText(fields.at(3), '80');
    await tester.enterText(fields.at(4), 'Barcode scanner');
    await tester.tap(find.widgetWithText(FilledButton, 'Add product'));
    await tester.pumpAndSettle();

    expect(find.text('Scanner'), findsOneWidget);
    expect(find.textContaining('SC-001'), findsOneWidget);
    expect(find.text('Scanner added to catalog'), findsOneWidget);

    final catalogScrollable =
        find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .first;
    await tester.scrollUntilVisible(
      find.byTooltip('Edit Laptop'),
      500,
      scrollable: catalogScrollable,
    );
    await tester.drag(catalogScrollable, const Offset(0, -180));
    await tester.pump();

    await tester.tap(find.byTooltip('Edit Laptop'));
    await tester.pumpAndSettle();

    fields = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(fields.at(0), 'Wireless Laptop');
    await tester.enterText(fields.at(1), 'LT-W1');
    await tester.tap(find.widgetWithText(FilledButton, 'Update product'));
    await tester.pumpAndSettle();

    expect(find.text('Wireless Laptop'), findsOneWidget);
    expect(find.textContaining('LT-W1'), findsOneWidget);
    expect(find.text('Wireless Laptop updated'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byTooltip('Delete Wireless Laptop'),
      500,
      scrollable: catalogScrollable,
    );
    await tester.drag(catalogScrollable, const Offset(0, -180));
    await tester.pump();

    await tester.tap(find.byTooltip('Delete Wireless Laptop'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryProductDeleteDialog), findsOneWidget);
    expect(find.text('Delete Wireless Laptop?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Wireless Laptop'), findsNothing);
    expect(find.text('Wireless Laptop deleted'), findsOneWidget);
  });
}

Widget _productPage() {
  return ProviderScope(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(_products)),
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(_warehouses)),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems(_inventoryItems),
      ),
    ],
    child: const MaterialApp(home: ProductPage()),
  );
}

final _products = [
  Product(
    id: 'p1',
    name: 'Laptop',
    sku: 'LT-001',
    category: 'Electronics',
    description: 'Workstation',
    price: 100,
  ),
  Product(
    id: 'p2',
    name: 'Cable',
    sku: 'CB-001',
    category: 'Accessories',
    price: 25,
  ),
  Product(
    id: 'p3',
    name: 'Notebook',
    sku: 'NB-001',
    category: 'Stationery',
    price: 5,
  ),
];

final _warehouses = [
  Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
  Warehouse(id: 'w2', name: 'North Warehouse', location: 'Surabaya'),
];

final _inventoryItems = [
  InventoryItem(
    id: 'i1',
    productId: 'p1',
    warehouseId: 'w1',
    currentQuantity: 10,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
  InventoryItem(
    id: 'i2',
    productId: 'p2',
    warehouseId: 'w1',
    currentQuantity: 2,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
];

class _SeededProducts extends ProductsNotifier {
  _SeededProducts(List<Product> products) {
    state = products;
  }
}

class _SeededWarehouses extends WarehousesNotifier {
  _SeededWarehouses(List<Warehouse> warehouses) {
    state = warehouses;
  }
}

class _SeededInventoryItems extends InventoryItemsNotifier {
  _SeededInventoryItems(List<InventoryItem> items) {
    state = items;
  }
}
