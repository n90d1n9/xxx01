import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';
import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('floor panel filters zone pressure and updates status', (
    tester,
  ) async {
    final zoneChanges = <String>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantFloorPanel(
        zones: restaurantTestFloorZones,
        onZoneStatusChanged: (zoneId, status) {
          zoneChanges.add('$zoneId:${status.name}');
        },
      ),
    );

    expect(find.text('Floor readiness'), findsOneWidget);
    expect(find.text('2 zones need attention'), findsOneWidget);
    expect(find.text('31/40 tables'), findsOneWidget);
    expect(find.text('134 covers'), findsOneWidget);
    expect(find.text('8 waiting'), findsOneWidget);
    expect(find.text('18m avg ticket'), findsOneWidget);
    expect(find.text('All 3'), findsOneWidget);
    expect(find.text('Attention 2'), findsOneWidget);
    expect(find.text('Waitlist 2'), findsOneWidget);
    expect(find.text('Calm 1'), findsOneWidget);
    expect(find.byType(RestaurantFloorZoneCard), findsWidgets);

    await tester.tap(find.text('Waitlist 2'));
    await tester.pumpAndSettle();

    expect(find.text('Main Floor'), findsOneWidget);
    expect(find.text('Terrace'), findsOneWidget);
    expect(find.text('Private Room'), findsNothing);

    await tester.tap(find.text('Attention 2'));
    await tester.pumpAndSettle();

    expect(find.text('Main Floor'), findsOneWidget);
    expect(find.text('Private Room'), findsOneWidget);
    expect(find.text('Terrace'), findsNothing);

    await tester.tap(find.byTooltip('Change Main Floor status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calm').last);
    await tester.pumpAndSettle();

    expect(zoneChanges, ['main-floor:calm']);
  });

  testWidgets('kitchen panel filters station pressure and updates status', (
    tester,
  ) async {
    final statusChanges = <String>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantKitchenPanel(
        stations: restaurantTestKitchenStations,
        onStationStatusChanged: (stationId, status) {
          statusChanges.add('$stationId:${status.name}');
        },
      ),
    );

    expect(find.text('Kitchen pressure'), findsOneWidget);
    expect(find.text('2 stations warm'), findsOneWidget);
    expect(find.text('25 tickets'), findsOneWidget);
    expect(find.text('All 3'), findsOneWidget);
    expect(find.text('Pressure 2'), findsOneWidget);
    expect(find.text('Delayed 2'), findsOneWidget);
    expect(find.text('Calm 1'), findsOneWidget);
    expect(find.text('Recover Grill'), findsOneWidget);
    expect(find.text('Show pressure'), findsOneWidget);
    expect(find.byType(RestaurantKitchenStationCard), findsWidgets);

    await tester.tap(find.text('Show pressure'));
    await tester.pumpAndSettle();

    expect(find.text('Grill'), findsOneWidget);
    expect(find.text('Wok'), findsOneWidget);
    expect(find.text('Cold Pass'), findsNothing);

    await tester.tap(find.text('Calm 1'));
    await tester.pumpAndSettle();

    expect(find.text('Cold Pass'), findsOneWidget);
    expect(find.text('Grill'), findsNothing);
    expect(find.text('Wok'), findsNothing);

    await tester.tap(find.text('Pressure 2'));
    await tester.pumpAndSettle();

    expect(find.text('Grill'), findsOneWidget);
    expect(find.text('Wok'), findsOneWidget);
    expect(find.text('Cold Pass'), findsNothing);

    await tester.tap(find.byTooltip('Change Grill status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calm').last);
    await tester.pumpAndSettle();

    expect(statusChanges, ['grill:calm']);
  });

  testWidgets('task panel filters follow-up work by state', (tester) async {
    final completedTaskIds = <String>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantTaskPanel(
        tasks: restaurantTestShiftTasks,
        onCompleteTask: completedTaskIds.add,
      ),
    );

    expect(find.text('Task progress'), findsOneWidget);
    expect(find.text('33% complete'), findsOneWidget);
    expect(find.text('Open 2'), findsOneWidget);
    expect(find.text('Attention 1'), findsOneWidget);
    expect(find.text('Done 1'), findsOneWidget);
    expect(find.byType(RestaurantShiftTaskCard), findsWidgets);

    await tester.tap(find.text('Done 1'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm VIP setup'), findsOneWidget);
    expect(find.text('Reset patio section'), findsNothing);
    expect(find.text('Restock dessert station'), findsNothing);

    await tester.tap(find.text('Attention 1'));
    await tester.pumpAndSettle();

    expect(find.text('Restock dessert station'), findsOneWidget);
    expect(find.text('Confirm VIP setup'), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, 'Done'));
    await tester.pumpAndSettle();

    expect(completedTaskIds, ['attention']);
  });

  testWidgets('menu panel filters availability lenses and resolves risk', (
    tester,
  ) async {
    final restockedIds = <String>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantMenuPanel(
        signals: restaurantTestMenuSignals,
        onResolveMenuRisk: restockedIds.add,
      ),
    );

    expect(find.text('Availability watch'), findsOneWidget);
    expect(find.text('1 at risk'), findsOneWidget);
    expect(find.text('67% avg margin'), findsOneWidget);
    expect(find.text('Risk 1'), findsOneWidget);
    expect(find.text('Margin 2'), findsOneWidget);
    expect(find.text('Quick 2'), findsOneWidget);
    expect(find.text('Restocked 1'), findsOneWidget);
    expect(find.byType(RestaurantMenuControlsSection), findsOneWidget);
    expect(find.byType(RestaurantMenuSignalList), findsOneWidget);
    expect(find.byType(RestaurantMenuSignalCard), findsWidgets);

    await tester.tap(find.text('Risk 1'));
    await tester.pumpAndSettle();

    expect(find.text('Short Rib Rendang'), findsOneWidget);
    expect(find.text('Pandan Spritz'), findsNothing);
    expect(find.text('Burnt Cheesecake'), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, 'Restocked'));
    await tester.pumpAndSettle();

    expect(restockedIds, ['risk']);

    await tester.tap(find.text('Quick 2'));
    await tester.pumpAndSettle();

    expect(find.text('Pandan Spritz'), findsOneWidget);
    expect(find.text('Burnt Cheesecake'), findsOneWidget);
    expect(find.text('Short Rib Rendang'), findsNothing);
  });

  testWidgets('menu panel sorts items by selected operating lens', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      const RestaurantMenuPanel(signals: restaurantTestMenuSignals),
    );

    expect(find.text('Demand'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Short Rib Rendang')).dy,
      lessThan(tester.getTopLeft(find.text('Pandan Spritz')).dy),
    );

    await tester.tap(find.byTooltip('Sort menu items'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prep').last);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(RestaurantMenuSortButton),
        matching: find.text('Prep'),
      ),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.text('Pandan Spritz')).dy,
      lessThan(tester.getTopLeft(find.text('Burnt Cheesecake')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Burnt Cheesecake')).dy,
      lessThan(tester.getTopLeft(find.text('Short Rib Rendang')).dy),
    );
  });

  testWidgets('menu panel searches by item text and clears query', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      const RestaurantMenuPanel(signals: restaurantTestMenuSignals),
    );

    await tester.enterText(find.byType(TextField), 'cheese');
    await tester.pumpAndSettle();

    expect(find.text('Burnt Cheesecake'), findsOneWidget);
    expect(find.text('Short Rib Rendang'), findsNothing);
    expect(find.text('Pandan Spritz'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    expect(find.text('Burnt Cheesecake'), findsOneWidget);
    expect(find.text('Short Rib Rendang'), findsOneWidget);
    expect(find.text('Pandan Spritz'), findsOneWidget);
  });

  testWidgets('menu panel empty filter can reset to all items', (tester) async {
    await pumpRestaurantPanel(
      tester,
      const RestaurantMenuPanel(signals: restaurantTestQuickMenuSignals),
    );

    await tester.tap(find.text('Restocked 0'));
    await tester.pumpAndSettle();

    expect(find.text('Pandan Spritz'), findsNothing);
    expect(find.text('No restocked menu items in this lens.'), findsOneWidget);

    await tester.tap(find.text('Show all'));
    await tester.pumpAndSettle();

    expect(find.text('Pandan Spritz'), findsOneWidget);
    expect(find.text('All 1'), findsOneWidget);
  });

  testWidgets('reservation list renders rows and reports status actions', (
    tester,
  ) async {
    final statusChanges = <String>[];
    final drafts = <RestaurantReservationCommunicationDraft>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationList(
        reservations: restaurantTestReservations
            .take(1)
            .toList(growable: false),
        onStatusChanged: (reservationId, status) {
          statusChanges.add('$reservationId:${status.name}');
        },
        onCommunicationSelected: drafts.add,
      ),
    );

    expect(find.text('Wijaya Family'), findsOneWidget);
    expect(find.text('19:05 - Terrace - Table 21'), findsOneWidget);
    expect(find.byType(RestaurantReservationCard), findsOneWidget);
    expect(find.byType(RestaurantReservationSignalStrip), findsOneWidget);
    expect(find.byType(RestaurantReservationStatusTimeline), findsOneWidget);
    expect(find.byType(RestaurantReservationSeatingStrip), findsOneWidget);
    expect(find.byType(RestaurantReservationActionBar), findsOneWidget);
    expect(find.byType(RestaurantReservationActionButton), findsWidgets);
    expect(find.text('8m late'), findsOneWidget);
    expect(find.text('Recover arrival'), findsOneWidget);
    expect(find.text('Large party'), findsOneWidget);
    expect(find.text('Phone'), findsWidgets);
    expect(find.byTooltip('Call'), findsOneWidget);
    expect(find.byTooltip('SMS'), findsOneWidget);
    expect(find.byTooltip('WhatsApp'), findsOneWidget);

    await tester.tap(find.byTooltip('SMS'));
    await tester.pumpAndSettle();

    expect(drafts, hasLength(1));
    expect(drafts.single.reservationId, 'late');
    expect(
      drafts.single.channel,
      RestaurantReservationCommunicationChannel.sms,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Arrived'));
    await tester.pumpAndSettle();

    expect(statusChanges, ['late:arrived']);
  });

  testWidgets('reservation list confirms cautionary status actions', (
    tester,
  ) async {
    final statusChanges = <String>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationList(
        reservations: restaurantTestReservations
            .take(1)
            .toList(growable: false),
        onStatusChanged: (reservationId, status) {
          statusChanges.add('$reservationId:${status.name}');
        },
      ),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'No-show'));
    await tester.pumpAndSettle();

    expect(
      find.byType(RestaurantReservationActionConfirmationDialog),
      findsOneWidget,
    );
    expect(find.text('Mark no-show?'), findsOneWidget);
    expect(statusChanges, isEmpty);

    await tester.tap(find.widgetWithText(TextButton, 'Keep reservation'));
    await tester.pumpAndSettle();

    expect(
      find.byType(RestaurantReservationActionConfirmationDialog),
      findsNothing,
    );
    expect(statusChanges, isEmpty);

    await tester.tap(find.widgetWithText(OutlinedButton, 'No-show'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Mark no-show'));
    await tester.pumpAndSettle();

    expect(statusChanges, ['late:noShow']);
  });

  testWidgets('reservation panel filters arrivals and reports actions', (
    tester,
  ) async {
    final statusChanges = <String>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationPanel(
        reservations: restaurantTestReservations,
        onStatusChanged: (reservationId, status) {
          statusChanges.add('$reservationId:${status.name}');
        },
      ),
    );

    expect(find.text('Reservation flow'), findsOneWidget);
    expect(find.text('Action queue'), findsOneWidget);
    expect(find.text('3 open actions'), findsOneWidget);
    expect(find.text('Recover late'), findsOneWidget);
    expect(find.text('Greet due now'), findsOneWidget);
    expect(find.text('Seat arrivals'), findsOneWidget);
    expect(find.text('Intake options'), findsOneWidget);
    expect(find.text('QR booking'), findsOneWidget);
    expect(find.text('QR waitlist'), findsOneWidget);
    expect(find.text('QR check-in'), findsOneWidget);
    expect(find.byType(RestaurantReservationControlsSection), findsOneWidget);
    expect(
      find.byType(RestaurantReservationContactCoverageStrip),
      findsOneWidget,
    );
    expect(find.text('Guest contact'), findsOneWidget);
    expect(find.text('2 reachable guests'), findsWidgets);
    expect(find.text('1 missing contact'), findsOneWidget);
    expect(find.byType(RestaurantReservationActionBucketTile), findsWidgets);
    expect(find.text('Mark arrived'), findsWidgets);
    expect(find.text('Seating readiness'), findsOneWidget);
    expect(find.text('3 active states'), findsOneWidget);
    expect(find.byType(RestaurantReservationSeatingQueueStrip), findsOneWidget);
    expect(find.text('Arrival queue'), findsOneWidget);
    expect(find.text('16 active covers'), findsOneWidget);
    expect(find.text('Due now'), findsOneWidget);
    expect(find.text('0-15m'), findsOneWidget);
    expect(find.text('In house'), findsOneWidget);
    expect(find.byType(RestaurantReservationArrivalWindowTile), findsWidgets);
    expect(find.text('Zone load'), findsOneWidget);
    expect(find.byType(RestaurantReservationZoneLoadCard), findsWidgets);
    expect(find.text('3 active zones'), findsOneWidget);
    expect(find.text('Late: 1'), findsOneWidget);
    expect(find.text('Due: 1'), findsOneWidget);
    expect(find.text('VIP: 1'), findsOneWidget);
    expect(find.text('Next up'), findsOneWidget);
    expect(find.text('3 priority bookings'), findsOneWidget);
    expect(find.byType(RestaurantReservationResultsSection), findsWidgets);
    expect(find.byType(RestaurantPriorityReservationCard), findsWidgets);
    expect(find.text('Ready to seat'), findsOneWidget);
    expect(find.text('1 late'), findsWidgets);
    expect(find.text('16 covers'), findsWidgets);
    expect(find.text('All 4'), findsOneWidget);
    expect(find.text('Late 1'), findsOneWidget);
    expect(find.text('In house 1'), findsOneWidget);
    expect(find.text('VIP 1'), findsOneWidget);
    expect(find.text('Closed 1'), findsOneWidget);

    await tester.ensureVisible(find.text('Due now'));
    await tester.tap(find.text('Due now'));
    await tester.pumpAndSettle();

    expect(find.text('Sari Putri'), findsWidgets);
    expect(find.text('Wijaya Family'), findsNothing);
    expect(find.text('Andini'), findsNothing);

    await tester.ensureVisible(find.text('In house'));
    await tester.tap(find.text('In house'));
    await tester.pumpAndSettle();

    expect(find.text('Andini'), findsWidgets);
    expect(find.text('Sari Putri'), findsNothing);
    expect(find.text('Wijaya Family'), findsNothing);

    await tester.ensureVisible(find.text('Terrace'));
    await tester.tap(find.text('Terrace'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Terrace'), findsOneWidget);
    expect(find.text('Wijaya Family'), findsWidgets);
    expect(find.text('Sari Putri'), findsNothing);
    expect(find.text('Andini'), findsNothing);

    await tester.ensureVisible(find.text('Recover late'));
    await tester.tap(find.text('Recover late'));
    await tester.pumpAndSettle();

    expect(find.text('Wijaya Family'), findsWidgets);
    expect(find.text('Sari Putri'), findsNothing);

    final arrivedAction = find.widgetWithText(FilledButton, 'Arrived').first;
    await tester.ensureVisible(arrivedAction);
    await tester.pumpAndSettle();
    await tester.tap(arrivedAction);
    await tester.pumpAndSettle();

    expect(statusChanges, ['late:arrived']);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('VIP 1'));
    await tester.tap(find.text('VIP 1'));
    await tester.pumpAndSettle();

    expect(find.text('Sari Putri'), findsWidgets);
    expect(find.text('Wijaya Family'), findsNothing);
  });

  testWidgets('reservation panel can place a QR session after intake options', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      const RestaurantReservationPanel(
        reservations: restaurantTestReservations,
        qrSessionPanel: RestaurantReservationQrSessionPanel(
          state: RestaurantReservationQrSessionState(),
        ),
      ),
    );

    expect(find.byType(RestaurantReservationQrSessionPanel), findsOneWidget);
    expect(find.text('QR session'), findsOneWidget);
    expect(find.text('No active QR handoff.'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Intake options')).dy,
      lessThan(tester.getTopLeft(find.text('QR session')).dy),
    );
    expect(
      tester.getTopLeft(find.text('QR session')).dy,
      lessThan(tester.getTopLeft(find.text('Action queue')).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation panel launches QR intake from panel binding', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 6, 10, 12);
    final controller = RestaurantReservationQrSessionController(
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => now,
          tokenFactory: () => 'panel-token',
        ),
        scanResolver: RestaurantReservationQrScanResolver(clock: () => now),
      ),
    );
    final selectedActions = <RestaurantReservationIntakeAction>[];
    final fallbackActions = <RestaurantReservationIntakeAction>[];
    final launchedLinks = <RestaurantReservationQrLink>[];
    final resolvedScans = <RestaurantReservationQrScanWorkflow>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationPanel(
        reservations: restaurantTestReservations,
        onIntakeActionSelected: selectedActions.add,
        qrPanelBinding: RestaurantReservationQrPanelBinding(
          controller: controller,
          launchConfig: RestaurantReservationQrIntakeLaunchConfig(
            baseUri: Uri.parse('https://tables.kaysir.test/tenant/demo'),
            lifetime: const Duration(minutes: 12),
            zoneLabel: 'Terrace',
            queryParameters: const {'source': 'reservation-panel'},
          ),
          onLinkLaunched: launchedLinks.add,
          onFallbackActionSelected: fallbackActions.add,
          scanEntryBinding: RestaurantReservationQrScanEntryBinding(
            onResolved: resolvedScans.add,
          ),
        ),
      ),
    );

    expect(
      find.byType(RestaurantReservationQrSessionControllerPanel),
      findsOneWidget,
    );
    expect(
      find.byType(RestaurantReservationQrScanControllerEntry),
      findsOneWidget,
    );
    expect(find.text('Scan QR handoff'), findsOneWidget);
    expect(find.text('QR session'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Intake options')).dy,
      lessThan(tester.getTopLeft(find.text('Scan QR handoff')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Scan QR handoff')).dy,
      lessThan(tester.getTopLeft(find.text('QR session')).dy),
    );
    expect(
      tester.getTopLeft(find.text('QR session')).dy,
      lessThan(tester.getTopLeft(find.text('Action queue')).dy),
    );

    await tester.ensureVisible(find.text('QR waitlist'));
    await tester.tap(find.text('QR waitlist'));
    await tester.pumpAndSettle();

    expect(selectedActions, [RestaurantReservationIntakeAction.qrWaitlist]);
    expect(fallbackActions, isEmpty);
    expect(launchedLinks, hasLength(1));
    expect(controller.activeLink, launchedLinks.single);
    expect(launchedLinks.single.payload.token, 'panel-token');
    expect(
      launchedLinks.single.payload.intent,
      RestaurantReservationQrIntent.waitlist,
    );
    expect(launchedLinks.single.payload.zoneLabel, 'Terrace');
    expect(
      launchedLinks.single.uri.queryParameters['source'],
      'reservation-panel',
    );
    expect(find.text('Active QR handoff'), findsOneWidget);
    expect(find.text('Join waitlist'), findsWidgets);

    final scanField = _textFieldWithHint('Reservation QR link');
    await tester.ensureVisible(scanField);
    await tester.enterText(scanField, launchedLinks.single.url);
    await tester.pump();
    final resolveScanButton = find.widgetWithText(FilledButton, 'Resolve scan');
    await tester.ensureVisible(resolveScanButton);
    await tester.tap(resolveScanButton);
    await tester.pumpAndSettle();

    expect(resolvedScans, hasLength(1));
    expect(
      resolvedScans.single.result.status,
      RestaurantReservationQrScanStatus.valid,
    );
    expect(
      resolvedScans.single.primaryAction,
      RestaurantReservationQrScanAction.joinWaitlist,
    );
    expect(controller.scanWorkflow, resolvedScans.single);
    expect(find.text('Latest scan'), findsOneWidget);

    await tester.ensureVisible(find.text('Phone').first);
    await tester.tap(find.text('Phone').first);
    await tester.pumpAndSettle();

    expect(selectedActions, [
      RestaurantReservationIntakeAction.qrWaitlist,
      RestaurantReservationIntakeAction.phone,
    ]);
    expect(fallbackActions, [RestaurantReservationIntakeAction.phone]);
    expect(launchedLinks, hasLength(1));
    expect(controller.activeLink, launchedLinks.single);

    controller.dispose();
  });

  testWidgets('reservation panel accepts custom QR scan entry slots', (
    tester,
  ) async {
    final controller = RestaurantReservationQrSessionController();

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationPanel(
        reservations: restaurantTestReservations,
        qrPanelBinding: RestaurantReservationQrPanelBinding(
          controller: controller,
          launchConfig: RestaurantReservationQrIntakeLaunchConfig(
            baseUri: Uri.parse('https://tables.kaysir.test/tenant/demo'),
          ),
          scanEntryBinding: const RestaurantReservationQrScanEntryBinding(
            entry: Text('Scanner kiosk bridge'),
          ),
        ),
      ),
    );

    expect(find.text('Scanner kiosk bridge'), findsOneWidget);
    expect(find.text('Scan QR handoff'), findsNothing);
    expect(
      find.byType(RestaurantReservationQrScanControllerEntry),
      findsNothing,
    );
    expect(
      find.byType(RestaurantReservationQrSessionControllerPanel),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    controller.dispose();
  });

  testWidgets('reservation panel searches reservations and clears the query', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      const RestaurantReservationPanel(
        reservations: restaurantTestReservations,
      ),
    );

    await tester.enterText(find.byType(TextField), 'stroller');
    await tester.pumpAndSettle();

    expect(find.text('Wijaya Family'), findsWidgets);
    expect(find.text('Sari Putri'), findsNothing);
    expect(find.text('Andini'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    final searchField = tester.widget<TextField>(find.byType(TextField));
    expect(searchField.controller?.text, isEmpty);
    expect(find.text('Wijaya Family'), findsWidgets);
    expect(find.text('Sari Putri'), findsWidgets);
  });
}

Finder _textFieldWithHint(String hintText) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == hintText,
  );
}
