import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('briefing panel body renders recommendations and actions', (
    tester,
  ) async {
    final selectedActions = <RestaurantBriefingActionKind>[];
    final items = const RestaurantBriefingBuilder().build(
      restaurantDemoSnapshot,
    );

    await pumpRestaurantPanel(
      tester,
      RestaurantBriefingPanelBody(
        items: items,
        onActionSelected: (action) => selectedActions.add(action.kind),
      ),
    );

    expect(find.byType(RestaurantBriefingCard), findsNWidgets(items.length));
    expect(find.text('Priority 1'), findsOneWidget);
    expect(find.textContaining('Private Room'), findsWidgets);

    await tester.tap(find.widgetWithText(TextButton, 'Send floor lead'));
    await tester.pumpAndSettle();

    expect(selectedActions, [RestaurantBriefingActionKind.stabilizeZone]);
  });
}
