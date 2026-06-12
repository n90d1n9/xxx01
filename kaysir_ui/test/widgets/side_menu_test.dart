import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/widgets/side_menu/side_menu.dart';

void main() {
  testWidgets('does not crash when optional menu data is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SideMenu(
            menuItems: null,
            onMenuClick: null,
            title: Text('Kaysir'),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.apps), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses fallback icons and invokes menu callback', (tester) async {
    FeatureRoutes? clickedRoute;
    final route = FeatureRoutes(name: 'Inventory', icon: 'missing-icon');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SideMenu(
            menuItems: [route],
            onMenuClick: (menu) => clickedRoute = menu,
            title: const Text('Kaysir'),
            currentIndex: 0,
          ),
        ),
      ),
    );

    expect(find.text('Inventory'), findsOneWidget);
    expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
    expect(
      tester
          .widget<ListTile>(find.widgetWithText(ListTile, 'Inventory'))
          .selected,
      isTrue,
    );

    await tester.tap(find.text('Inventory'));
    await tester.pump();

    expect(clickedRoute, route);
  });

  testWidgets('expands nested menu groups so child screens remain reachable', (
    tester,
  ) async {
    FeatureRoutes? clickedRoute;
    final bankReconciliation = FeatureRoutes(
      name: 'Bank Reconciliation',
      icon: 'account_balance',
      path: '/bank-reconciliation',
    );
    final accounting = FeatureRoutes(
      name: 'Accounting',
      icon: 'account_balance',
      items: [
        FeatureRoutes(
          name: 'Reconciliation',
          icon: 'sync_alt',
          items: [bankReconciliation],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SideMenu(
            menuItems: [accounting],
            onMenuClick: (menu) => clickedRoute = menu,
            title: const Text('Kaysir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Accounting'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reconciliation'));
    await tester.pumpAndSettle();

    expect(find.text('Bank Reconciliation'), findsOneWidget);

    await tester.tap(find.text('Bank Reconciliation'));
    await tester.pump();

    expect(clickedRoute, bankReconciliation);
  });

  testWidgets('expands and selects the active nested route by current path', (
    tester,
  ) async {
    final restaurant = FeatureRoutes(
      name: 'Restaurant',
      icon: 'restaurant',
      path: '/restaurant',
      items: [
        FeatureRoutes(
          name: 'Floor Plan',
          icon: 'restaurant-floor',
          path: '/restaurant/floor',
        ),
        FeatureRoutes(
          name: 'Menu Mix',
          icon: 'restaurant-menu',
          path: '/restaurant/menu',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SideMenu(
            menuItems: [restaurant],
            onMenuClick: (_) {},
            title: const Text('Kaysir'),
            currentPath: '/restaurant/menu?tab=live',
          ),
        ),
      ),
    );

    expect(find.text('Menu Mix'), findsOneWidget);
    expect(
      tester
          .widget<ListTile>(find.widgetWithText(ListTile, 'Menu Mix'))
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<ListTile>(find.widgetWithText(ListTile, 'Floor Plan'))
          .selected,
      isFalse,
    );
  });
}
