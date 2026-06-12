import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/widgets/side_menu/side_menu_fold.dart';

void main() {
  testWidgets('renders nothing when there are no folded menu items', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SideMenuFold(menuItems: null))),
    );

    expect(find.byType(NavigationRail), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports a single folded menu item', (tester) async {
    FeatureRoutes? clickedRoute;
    final route = FeatureRoutes(name: 'Inventory', icon: 'missing-icon');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SideMenuFold(
            menuItems: [route],
            onMenuClick: (menu) => clickedRoute = menu,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Inventory'), findsOneWidget);
    expect(find.byIcon(Icons.circle_outlined), findsOneWidget);

    await tester.tap(find.byTooltip('Inventory'));
    await tester.pump();

    expect(clickedRoute, route);
  });

  testWidgets('flattens nested routes so child screens remain reachable', (
    tester,
  ) async {
    FeatureRoutes? clickedRoute;
    final periodClose = FeatureRoutes(name: 'Period Close', icon: 'lock_clock');
    final bankReconciliation = FeatureRoutes(
      name: 'Bank Reconciliation',
      icon: 'account_balance',
    );
    final accounting = FeatureRoutes(
      name: 'Accounting',
      icon: 'account_balance',
      items: [
        periodClose,
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
          body: SideMenuFold(
            menuItems: [accounting],
            onMenuClick: (menu) => clickedRoute = menu,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Period Close'), findsOneWidget);
    expect(find.byTooltip('Bank Reconciliation'), findsOneWidget);
    expect(find.byIcon(Icons.lock_clock_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Bank Reconciliation'));
    await tester.pump();

    expect(clickedRoute, bankReconciliation);
  });

  testWidgets('selects folded rail destination by current path', (
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
          body: SideMenuFold(
            menuItems: [restaurant],
            currentIndex: 0,
            currentPath: '/restaurant/menu',
          ),
        ),
      ),
    );

    expect(find.byTooltip('Restaurant'), findsOneWidget);
    expect(find.byTooltip('Floor Plan'), findsOneWidget);
    expect(find.byTooltip('Menu Mix'), findsOneWidget);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      2,
    );
  });
}
