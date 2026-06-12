import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/inventory_routes.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/warehouse_screen.dart';
import 'package:kaysir/features/inventory/states/inventory_branch_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/inventory/widgets/inventory_warehouse_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_warehouse_dialog.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('warehouse page composes modern warehouse workspace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_warehousePage(_warehouses));

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryWarehouseSummary), findsOneWidget);
    expect(find.byType(InventoryWarehousePanel), findsOneWidget);
    expect(find.text('Warehouse Directory'), findsOneWidget);
    expect(find.text('Main Warehouse'), findsOneWidget);
    expect(find.text('North Warehouse'), findsOneWidget);
    expect(find.textContaining('2 branches'), findsOneWidget);
  });

  testWidgets('warehouse page uses shared inventory navigation shell', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_warehousePage(_warehouses));

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryNavigationDrawer), findsOneWidget);

    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );
    expect(
      drawer.selectedIndex,
      InventoryNavigationDrawer.destinations.indexOf(
        InventoryNavigationDestination.warehouses,
      ),
    );
  });

  testWidgets('warehouse page opens warehouse detail route', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_warehousePageWithRouteCapture());

    await tester.tap(find.byTooltip('Open Main Warehouse'));
    await tester.pumpAndSettle();

    expect(
      find.text('${InventoryRoutes.warehouseDetail}?warehouse=w1'),
      findsOneWidget,
    );
  });

  testWidgets('warehouse page adds edits and deletes a warehouse', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_warehousePage(_warehouses));

    await tester.tap(find.byTooltip('Add warehouse'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryWarehouseDialog), findsOneWidget);

    await tester.tap(find.text('Jakarta Central').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bandung South').last);
    await tester.pumpAndSettle();

    var fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'East Hub');
    await tester.enterText(fields.at(1), 'Bandung');
    await tester.enterText(fields.at(2), '1200');
    await tester.enterText(fields.at(3), 'Cold storage');
    await tester.tap(find.widgetWithText(FilledButton, 'Add warehouse'));
    await tester.pumpAndSettle();

    expect(find.text('East Hub'), findsOneWidget);
    expect(find.text('Bandung South'), findsWidgets);

    await tester.ensureVisible(find.byTooltip('Edit East Hub'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit East Hub'));
    await tester.pumpAndSettle();

    fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'East Fulfillment Hub');
    await tester.tap(find.widgetWithText(FilledButton, 'Update warehouse'));
    await tester.pumpAndSettle();

    expect(find.text('East Fulfillment Hub'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Delete East Fulfillment Hub'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete East Fulfillment Hub'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryWarehouseDeleteDialog), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('East Fulfillment Hub'), findsNothing);
  });
}

Widget _warehousePageWithRouteCapture() {
  return ProviderScope(
    overrides: [
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(_warehouses)),
    ],
    child: MaterialApp(
      home: const WarehousePage(),
      onGenerateRoute:
          (settings) => MaterialPageRoute<void>(
            builder:
                (context) =>
                    Scaffold(body: Center(child: Text(settings.name ?? ''))),
          ),
    ),
  );
}

Widget _warehousePage(List<Warehouse> warehouses) {
  return ProviderScope(
    overrides: [
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(warehouses)),
    ],
    child: const MaterialApp(home: WarehousePage()),
  );
}

final _warehouses = [
  Warehouse(
    id: 'w1',
    name: 'Main Warehouse',
    branchId: inventoryBranchJakartaCentralId,
    branchName: 'Jakarta Central',
    location: 'Jakarta',
    description: 'Primary stock room',
    capacity: 500,
  ),
  Warehouse(
    id: 'w2',
    name: 'North Warehouse',
    branchId: inventoryBranchSurabayaNorthId,
    branchName: 'Surabaya North',
    location: 'Surabaya',
  ),
];

class _SeededWarehouses extends WarehousesNotifier {
  _SeededWarehouses(List<Warehouse> warehouses) {
    state = warehouses;
  }
}
