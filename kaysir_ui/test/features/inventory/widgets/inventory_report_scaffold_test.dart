import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_navigation_drawer.dart';
import 'package:kaysir/features/inventory/widgets/inventory_report_scaffold.dart';

void main() {
  testWidgets('inventory report scaffold wires reports drawer state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InventoryReportScaffold(
          title: 'Inventory Report',
          body: Text('Report body'),
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
        InventoryNavigationDestination.reports,
      ),
    );
  });

  testWidgets(
    'inventory report scaffold keeps back button and drawer access when pushed',
    (tester) async {
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
                              (context) => const InventoryReportScaffold(
                                title: 'Inventory Report',
                                body: Text('Report body'),
                              ),
                        ),
                      );
                    },
                    child: const Text('Open report'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open report'));
      await tester.pumpAndSettle();

      expect(find.byType(BackButton), findsOneWidget);
      expect(find.byTooltip('Open inventory navigation'), findsOneWidget);

      await tester.tap(find.byTooltip('Open inventory navigation'));
      await tester.pumpAndSettle();

      expect(find.byType(InventoryNavigationDrawer), findsOneWidget);
    },
  );

  testWidgets('inventory report scaffold opens destination routes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          InventoryNavigationDestination.dashboard.routePath:
              (context) => const Scaffold(body: Text('Dashboard route')),
        },
        home: const InventoryReportScaffold(
          title: 'Inventory Report',
          body: Text('Report body'),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard route'), findsOneWidget);
    expect(find.text('Report body'), findsNothing);
  });

  testWidgets(
    'inventory report scaffold routes selected reports item from detail pages',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            InventoryNavigationDestination.reports.routePath:
                (context) => const Scaffold(body: Text('Report hub route')),
          },
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder:
                              (context) => const InventoryReportScaffold(
                                title: 'Inventory Report',
                                body: Text('Report detail body'),
                              ),
                        ),
                      );
                    },
                    child: const Text('Open report'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open report'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Open inventory navigation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();

      expect(find.text('Report hub route'), findsOneWidget);
      expect(find.text('Report detail body'), findsNothing);
    },
  );
}
