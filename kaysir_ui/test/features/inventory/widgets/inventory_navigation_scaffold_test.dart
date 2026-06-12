import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_scaffold.dart';

void main() {
  testWidgets('inventory navigation scaffold wires selected drawer state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InventoryNavigationScaffold(
          currentDestination: InventoryNavigationDestination.products,
          appBar: AppBar(title: const Text('Products')),
          body: const Text('Product workspace'),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

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

  testWidgets('inventory navigation scaffold opens destination routes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          InventoryNavigationDestination.dashboard.routePath:
              (context) => const Scaffold(body: Text('Dashboard route')),
        },
        home: InventoryNavigationScaffold(
          currentDestination: InventoryNavigationDestination.products,
          appBar: AppBar(title: const Text('Products')),
          body: const Text('Product route'),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard route'), findsOneWidget);
    expect(find.text('Product route'), findsNothing);
  });

  testWidgets('inventory navigation scaffold can route its selected section', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          InventoryNavigationDestination.purchaseOrders.routePath:
              (context) => const Scaffold(body: Text('Purchase orders route')),
        },
        home: InventoryNavigationScaffold(
          currentDestination: InventoryNavigationDestination.purchaseOrders,
          isCanonicalDestination: false,
          appBar: AppBar(title: const Text('Purchase detail')),
          body: const Text('Nested purchase order route'),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Purchase Orders'));
    await tester.pumpAndSettle();

    expect(find.text('Purchase orders route'), findsOneWidget);
    expect(find.text('Nested purchase order route'), findsNothing);
  });

  testWidgets('inventory navigation drawer action opens drawer when pushed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder:
                            (context) => InventoryNavigationScaffold(
                              currentDestination:
                                  InventoryNavigationDestination.purchaseOrders,
                              appBar: AppBar(
                                leading: const BackButton(),
                                title: const Text('Purchase detail'),
                                actions: const [
                                  InventoryNavigationDrawerAction(
                                    onlyWhenRouteCanPop: true,
                                  ),
                                ],
                              ),
                              body: const Text('Nested purchase order route'),
                            ),
                      ),
                    );
                  },
                  child: const Text('Open nested page'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open nested page'));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    expect(find.byTooltip('Open inventory navigation'), findsOneWidget);

    await tester.tap(find.byTooltip('Open inventory navigation'));
    await tester.pumpAndSettle();

    expect(find.byType(InventoryNavigationDrawer), findsOneWidget);
  });
}
