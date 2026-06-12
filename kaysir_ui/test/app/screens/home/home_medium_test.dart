import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/app/screens/home/home_medium.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/widgets/side_menu/side_menu_fold.dart';

void main() {
  testWidgets('renders safely without body or menu items', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeMediumScreen(actions: [], currentIndex: 0, menuItems: []),
      ),
    );

    expect(find.byType(SideMenuFold), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses folded menu and delegates selection callback', (
    tester,
  ) async {
    FeatureRoutes? clickedRoute;
    final route = FeatureRoutes(name: 'Orders', icon: 'missing-icon');

    await tester.pumpWidget(
      MaterialApp(
        home: HomeMediumScreen(
          actions: const [],
          body: const Text('Orders content'),
          currentIndex: 0,
          menuItems: [route],
          onMenuClick: (menu) => clickedRoute = menu,
        ),
      ),
    );

    expect(find.text('Orders content'), findsOneWidget);
    expect(find.byTooltip('Orders'), findsOneWidget);

    await tester.tap(find.byTooltip('Orders'));
    await tester.pump();

    expect(clickedRoute, route);
  });
}
