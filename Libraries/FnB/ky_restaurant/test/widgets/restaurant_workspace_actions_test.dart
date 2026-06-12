import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('restaurant briefing actions update controller state', (
    tester,
  ) async {
    final controller = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
    );

    await pumpRestaurantActionWorkspace(
      tester,
      controller,
      initialView: RestaurantWorkspaceView.kitchen,
      views: const [RestaurantWorkspaceView.kitchen],
    );

    final actionButton = find.widgetWithText(
      TextButton,
      'Send support to Grill',
    );
    await tester.ensureVisible(actionButton);
    await tester.pumpAndSettle();
    await tester.tap(actionButton);
    await tester.pumpAndSettle();

    final grill = controller.state.snapshot!.stations.singleWhere(
      (station) => station.id == 'grill',
    );
    expect(grill.status, RestaurantServiceStatus.calm);
    expect(
      controller.state.activities.first.kind,
      RestaurantOperationActivityKind.stationStatusChanged,
    );
    expect(find.text('Station rebalanced'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    final restoredGrill = controller.state.snapshot!.stations.singleWhere(
      (station) => station.id == 'grill',
    );
    expect(restoredGrill.status, RestaurantServiceStatus.critical);
    expect(controller.state.activities, isEmpty);
    expect(find.text('Action undone'), findsOneWidget);

    await disposeRestaurantActionWorkspace(tester, controller);
  });

  testWidgets('restaurant workspace actions update controller state', (
    tester,
  ) async {
    final controller = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
    );

    await pumpRestaurantActionWorkspace(
      tester,
      controller,
      initialView: RestaurantWorkspaceView.kitchen,
      views: const [RestaurantWorkspaceView.kitchen],
    );

    await tester.ensureVisible(find.byTooltip('Change Grill status'));
    await tester.tap(find.byTooltip('Change Grill status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calm').last);
    await tester.pumpAndSettle();

    final grill = controller.state.snapshot!.stations.singleWhere(
      (station) => station.id == 'grill',
    );
    expect(grill.status, RestaurantServiceStatus.calm);

    await tester.ensureVisible(find.widgetWithText(TextButton, 'Done').first);
    await tester.tap(find.widgetWithText(TextButton, 'Done').first);
    await tester.pumpAndSettle();

    final firstTask = controller.state.snapshot!.tasks.first;
    expect(firstTask.progress, 1);
    expect(firstTask.status, RestaurantServiceStatus.calm);
    expect(
      controller.state.activities.first.kind,
      RestaurantOperationActivityKind.taskCompleted,
    );
    expect(find.text('Recent actions'), findsOneWidget);
    expect(find.text('Task completed'), findsWidgets);
    expect(find.byType(RestaurantActivityCard), findsWidgets);
    expect(find.text('All 2'), findsOneWidget);
    expect(find.text('Kitchen 1'), findsOneWidget);
    expect(find.text('Tasks 1'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Kitchen 1'));
    await tester.tap(find.text('Kitchen 1'));
    await tester.pumpAndSettle();

    expect(find.text('Lead Ari station pressure updated.'), findsOneWidget);
    expect(find.text('Floor team completed follow-up work.'), findsNothing);

    await tester.tap(find.text('Tasks 1'));
    await tester.pumpAndSettle();

    expect(find.text('Lead Ari station pressure updated.'), findsNothing);
    expect(find.text('Floor team completed follow-up work.'), findsOneWidget);

    await disposeRestaurantActionWorkspace(tester, controller);
  });

  testWidgets('restaurant reservation actions update controller state', (
    tester,
  ) async {
    final controller = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
    );

    await pumpRestaurantActionWorkspace(
      tester,
      controller,
      initialView: RestaurantWorkspaceView.reservations,
      views: const [RestaurantWorkspaceView.reservations],
    );

    final arrivedAction = find.widgetWithText(FilledButton, 'Arrived').first;
    await tester.ensureVisible(arrivedAction);
    await tester.tap(arrivedAction);
    await tester.pumpAndSettle();

    final reservation = controller.state.snapshot!.reservations.singleWhere(
      (reservation) => reservation.id == 'wijaya-family',
    );
    expect(reservation.status, RestaurantReservationStatus.arrived);
    expect(
      controller.state.activities.first.kind,
      RestaurantOperationActivityKind.reservationStatusChanged,
    );
    expect(find.text('Reservation marked Arrived'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await disposeRestaurantActionWorkspace(tester, controller);
  });

  testWidgets('restaurant menu risk action updates controller state', (
    tester,
  ) async {
    final controller = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
    );

    await pumpRestaurantActionWorkspace(
      tester,
      controller,
      initialView: RestaurantWorkspaceView.menu,
      views: const [RestaurantWorkspaceView.menu],
    );

    await tester.ensureVisible(
      find.widgetWithText(TextButton, 'Restocked').first,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Restocked').first);
    await tester.pumpAndSettle();

    final shortRib = controller.state.snapshot!.menuSignals.singleWhere(
      (signal) => signal.id == 'short-rib-rendang',
    );
    expect(shortRib.soldOutRiskPercent, 12);
    expect(shortRib.tags, contains('Restocked'));

    await disposeRestaurantActionWorkspace(tester, controller);
  });

  testWidgets('restaurant catalog review action updates controller state', (
    tester,
  ) async {
    final controller = RestaurantWorkspaceController(
      repository: const DemoRestaurantSnapshotRepository(),
    );

    await pumpRestaurantActionWorkspace(
      tester,
      controller,
      initialView: RestaurantWorkspaceView.menu,
      views: const [RestaurantWorkspaceView.menu],
    );

    await tester.ensureVisible(
      find.byTooltip('Review Nasi Ulam catalog readiness'),
    );
    await tester.tap(find.byTooltip('Review Nasi Ulam catalog readiness'));
    await tester.pumpAndSettle();

    final nasiUlam = controller.state.snapshot!.menu!.itemById('nasi-ulam');
    expect(nasiUlam?.tags, contains(restaurantCatalogReviewedTag));
    expect(
      controller.state.activities.first.kind,
      RestaurantOperationActivityKind.menuCatalogReviewed,
    );
    expect(find.text('Catalog review saved'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await disposeRestaurantActionWorkspace(tester, controller);
  });
}
