import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/inventory_routes.dart';
import 'package:kaysir/features/inventory/models/inventory_branch.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/screens/warehouse_dashboard_screen.dart';
import 'package:kaysir/features/inventory/states/inventory_branch_provider.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/inventory/widgets/inventory_warehouse_dashboard_components.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('warehouse dashboard composes module command center', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_warehouseDashboardPage());

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.byType(InventoryWarehouseDashboardSummaryGrid), findsOneWidget);
    expect(find.byType(InventoryWarehouseDashboardActionPanel), findsOneWidget);
    expect(find.byType(InventoryWarehouseBranchHealthPanel), findsOneWidget);
    expect(find.text('Warehouse Dashboard'), findsWidgets);
    expect(find.text('Warehouse Module'), findsOneWidget);
    expect(find.text('Jakarta Central'), findsOneWidget);
    expect(find.text('Attention'), findsOneWidget);
  });

  testWidgets('warehouse dashboard uses selected sidebar destination', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_warehouseDashboardPage());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    final drawer = tester.widget<NavigationDrawer>(
      find.byType(NavigationDrawer),
    );
    expect(
      drawer.selectedIndex,
      InventoryNavigationDrawer.destinations.indexOf(
        InventoryNavigationDestination.warehouseDashboard,
      ),
    );
  });

  testWidgets('warehouse dashboard opens branch detail route', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1180, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_warehouseDashboardPageWithRouteCapture());

    await tester.ensureVisible(find.text('Open branch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open branch'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        '${InventoryRoutes.warehouseBranchDetail}?branch=branch-jakarta',
      ),
      findsOneWidget,
    );
  });
}

Widget _warehouseDashboardPage() {
  return _providerScope(
    child: const MaterialApp(home: WarehouseDashboardPage()),
  );
}

Widget _warehouseDashboardPageWithRouteCapture() {
  return _providerScope(
    child: MaterialApp(
      home: const WarehouseDashboardPage(),
      onGenerateRoute:
          (settings) => MaterialPageRoute<void>(
            builder:
                (context) =>
                    Scaffold(body: Center(child: Text(settings.name ?? ''))),
          ),
    ),
  );
}

Widget _providerScope({required Widget child}) {
  return ProviderScope(
    overrides: [
      inventoryBranchesProvider.overrideWith(
        (ref) => _SeededBranches(_branches),
      ),
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(_warehouses)),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems(_items),
      ),
    ],
    child: child,
  );
}

const _branches = [
  InventoryBranch(
    id: 'branch-jakarta',
    name: 'Jakarta Central',
    city: 'Jakarta',
    managerName: 'Rina',
    contact: 'jakarta@example.test',
  ),
];

final _warehouses = [
  Warehouse(
    id: 'w1',
    name: 'Main Warehouse',
    branchId: 'branch-jakarta',
    branchName: 'Jakarta Central',
    location: 'Jakarta',
    capacity: 100,
  ),
];

final _items = [
  InventoryItem(
    id: 'i1',
    productId: 'p1',
    warehouseId: 'w1',
    currentQuantity: 95,
    reorderPoint: 100,
    reorderQuantity: 10,
  ),
];

class _SeededBranches extends InventoryBranchesNotifier {
  _SeededBranches(List<InventoryBranch> branches) {
    state = branches;
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
