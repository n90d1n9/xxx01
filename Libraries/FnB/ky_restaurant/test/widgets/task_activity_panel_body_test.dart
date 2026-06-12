import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';
import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('task and activity panel bodies render controls and results', (
    tester,
  ) async {
    final activities = [
      RestaurantOperationActivity(
        id: 'task-1',
        kind: RestaurantOperationActivityKind.taskCompleted,
        title: 'Task completed',
        description: 'Dessert restock finished.',
        createdAt: DateTime(2026, 1, 1, 18),
      ),
      RestaurantOperationActivity(
        id: 'menu-1',
        kind: RestaurantOperationActivityKind.menuRiskResolved,
        title: 'Menu risk resolved',
        description: 'Short rib restocked.',
        createdAt: DateTime(2026, 1, 1, 18, 5),
      ),
    ];

    await pumpRestaurantPanel(
      tester,
      Column(
        children: [
          RestaurantTaskPanelBody(
            data: RestaurantTaskPanelData.fromTasks(
              tasks: restaurantTestShiftTasks,
              selectedFilter: RestaurantTaskFilter.all,
            ),
            onFilterChanged: (_) {},
            onShowAll: () {},
          ),
          RestaurantActivityPanelBody(
            data: RestaurantActivityPanelData.fromActivities(
              activities: activities,
              selectedFilter: RestaurantActivityFilter.all,
              visibleCount: activities.length,
            ),
            onFilterChanged: (_) {},
            onShowAll: () {},
          ),
        ],
      ),
    );

    expect(find.text('Task progress'), findsOneWidget);
    expect(find.text('All 3'), findsOneWidget);
    expect(find.byType(RestaurantShiftTaskCard), findsWidgets);
    expect(find.byType(RestaurantActivityCard), findsWidgets);
  });
}
