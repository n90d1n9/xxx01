import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('restaurant workspace switcher reports view changes', (
    tester,
  ) async {
    RestaurantWorkspaceView? selectedView;

    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantWorkspaceScreen(
          onViewChanged: (view) => selectedView = view,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final menuView = find.text('Menu Mix');
    await tester.ensureVisible(menuView);
    await tester.pumpAndSettle();
    await tester.tap(menuView);
    await tester.pumpAndSettle();

    expect(selectedView, RestaurantWorkspaceView.menu);
    expect(find.text('Menu mix'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(RestaurantMenuSignalList),
        matching: find.text('Short Rib Rendang'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'restaurant view switcher deduplicates views and falls back safely',
    (tester) async {
      RestaurantWorkspaceView? selectedView;

      await pumpRestaurantViewSwitcher(
        tester,
        RestaurantViewSwitcher(
          selectedView: RestaurantWorkspaceView.kitchen,
          views: const [
            RestaurantWorkspaceView.menu,
            RestaurantWorkspaceView.menu,
            RestaurantWorkspaceView.floor,
          ],
          onChanged: (view) => selectedView = view,
        ),
      );

      final switcher = tester.widget<SegmentedButton<RestaurantWorkspaceView>>(
        find.byType(SegmentedButton<RestaurantWorkspaceView>),
      );

      expect(find.text('Menu Mix'), findsOneWidget);
      expect(find.text('Floor Plan'), findsOneWidget);
      expect(find.text('Kitchen Flow'), findsNothing);
      expect(switcher.selected, {RestaurantWorkspaceView.menu});

      await tester.tap(find.text('Floor Plan'));
      await tester.pump();

      expect(selectedView, RestaurantWorkspaceView.floor);
    },
  );

  testWidgets('restaurant view switcher handles empty views', (tester) async {
    RestaurantWorkspaceView? selectedView;

    await pumpRestaurantViewSwitcher(
      tester,
      RestaurantViewSwitcher(
        selectedView: RestaurantWorkspaceView.menu,
        views: const [],
        onChanged: (view) => selectedView = view,
      ),
    );

    expect(find.byType(SegmentedButton<RestaurantWorkspaceView>), findsNothing);
    expect(find.text('Menu Mix'), findsNothing);
    expect(selectedView, isNull);
  });
}
