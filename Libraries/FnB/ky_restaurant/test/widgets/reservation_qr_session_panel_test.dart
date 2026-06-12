import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/reservation_qr_test_finders.dart';
import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation QR session panel renders empty state', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      const RestaurantReservationQrSessionPanel(
        state: RestaurantReservationQrSessionState(),
      ),
    );

    expect(find.text('QR session'), findsOneWidget);
    expect(find.text('No active QR handoff.'), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation QR session panel renders link and scan state', (
    tester,
  ) async {
    final copiedLinks = <Uri>[];
    final openedLinks = <Uri>[];
    final selectedActions = <RestaurantReservationQrScanAction>[];
    var refreshLinkCount = 0;
    var continueCount = 0;
    var dismissCount = 0;
    final uri = Uri.parse(
      'https://tables.kaysir.test/restaurant/reservations/qr?payload=encoded',
    );
    final payload = RestaurantReservationQrPayload(
      token: 'qr-token',
      intent: RestaurantReservationQrIntent.checkIn,
      expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
      reservationId: 'reservation-42',
      zoneLabel: 'Main Floor',
      tableLabel: 'Table 8',
    );
    final state = RestaurantReservationQrSessionState(
      activeLink: RestaurantReservationQrLink(
        action: RestaurantReservationIntakeAction.qrCheckIn,
        payload: payload,
        uri: uri,
        createdAt: DateTime.utc(2026, 6, 10, 13),
      ),
      scanWorkflow: RestaurantReservationQrScanWorkflow(
        result: RestaurantReservationQrScanResult.valid(
          uri: uri,
          payload: payload,
          scannedAt: DateTime.utc(2026, 6, 10, 13, 8),
        ),
        actionPlan: const RestaurantReservationQrScanActionPlan(
          primaryAction: RestaurantReservationQrScanAction.confirmCheckIn,
          secondaryActions: [RestaurantReservationQrScanAction.dismiss],
        ),
      ),
      selectedAction: RestaurantReservationQrScanAction.confirmCheckIn,
    );

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrSessionPanel(
        state: state,
        summaryNow: DateTime.utc(2026, 6, 10, 13, 10),
        onCopyLink: copiedLinks.add,
        onOpenLink: openedLinks.add,
        onRefreshLink: () => refreshLinkCount += 1,
        onScanActionSelected: selectedActions.add,
        onContinue: () => continueCount += 1,
        onDismissScan: () => dismissCount += 1,
      ),
    );

    expect(find.text('QR action selected'), findsOneWidget);
    expect(
      find.text('Confirm check-in: Confirm the arriving party.'),
      findsOneWidget,
    );
    expect(find.text('Link: Check in'), findsOneWidget);
    expect(find.text('Expiry: Expires in 20 min'), findsOneWidget);
    expect(find.text('Scan: QR link ready'), findsOneWidget);
    expect(find.text('Action: Confirm check-in'), findsOneWidget);
    expect(find.text('Active QR handoff'), findsOneWidget);
    expect(find.text('Latest scan'), findsOneWidget);
    expect(find.text('Check in'), findsWidgets);
    expect(find.text('Main Floor'), findsWidgets);
    expect(find.text('Table 8'), findsWidgets);
    expect(find.text('Selected action: Confirm check-in'), findsOneWidget);
    expect(
      find.text(
        'Confirm the arriving party and mark the reservation as present.',
      ),
      findsOneWidget,
    );
    expect(find.text('Confirm the arriving party.'), findsWidgets);
    expect(find.byTooltip('Copy link'), findsOneWidget);
    expect(find.byTooltip('Open link'), findsOneWidget);
    expect(find.byTooltip('Refresh link'), findsOneWidget);
    expect(
      findReservationQrScanAction(
        RestaurantReservationQrScanAction.confirmCheckIn,
      ),
      findsOneWidget,
    );
    expect(
      findReservationQrScanAction(RestaurantReservationQrScanAction.dismiss),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Copy link'));
    await tester.tap(find.byTooltip('Open link'));
    await tester.tap(find.byTooltip('Refresh link'));
    await tester.tap(
      findReservationQrScanAction(
        RestaurantReservationQrScanAction.confirmCheckIn,
      ),
    );
    await tester.tap(
      findReservationQrScanAction(RestaurantReservationQrScanAction.dismiss),
    );
    await tester.pumpAndSettle();

    expect(copiedLinks, [uri]);
    expect(openedLinks, [uri]);
    expect(refreshLinkCount, 1);
    expect(selectedActions, [
      RestaurantReservationQrScanAction.confirmCheckIn,
      RestaurantReservationQrScanAction.dismiss,
    ]);
    expect(continueCount, 1);
    expect(dismissCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation QR session panel accepts grouped callbacks', (
    tester,
  ) async {
    final copiedLinks = <Uri>[];
    final selectedActions = <RestaurantReservationQrScanAction>[];
    var continueCount = 0;
    final uri = Uri.parse(
      'https://tables.kaysir.test/restaurant/reservations/qr?payload=encoded',
    );
    final payload = RestaurantReservationQrPayload(
      token: 'qr-token',
      intent: RestaurantReservationQrIntent.waitlist,
      expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
      zoneLabel: 'Terrace',
    );

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrSessionPanel(
        state: RestaurantReservationQrSessionState(
          activeLink: RestaurantReservationQrLink(
            action: RestaurantReservationIntakeAction.qrWaitlist,
            payload: payload,
            uri: uri,
            createdAt: DateTime.utc(2026, 6, 10, 13),
          ),
          scanWorkflow: RestaurantReservationQrScanWorkflow(
            result: RestaurantReservationQrScanResult.valid(
              uri: uri,
              payload: payload,
              scannedAt: DateTime.utc(2026, 6, 10, 13, 8),
            ),
            actionPlan: const RestaurantReservationQrScanActionPlan(
              primaryAction: RestaurantReservationQrScanAction.joinWaitlist,
            ),
          ),
        ),
        callbacks: RestaurantReservationQrSessionCallbacks(
          onCopyLink: copiedLinks.add,
          onScanActionSelected: selectedActions.add,
          onContinue: () => continueCount += 1,
        ),
        summaryNow: DateTime.utc(2026, 6, 10, 13, 10),
      ),
    );

    await tester.tap(find.byTooltip('Copy link'));
    await tester.tap(
      findReservationQrScanAction(
        RestaurantReservationQrScanAction.joinWaitlist,
      ),
    );
    await tester.pumpAndSettle();

    expect(copiedLinks, [uri]);
    expect(selectedActions, [RestaurantReservationQrScanAction.joinWaitlist]);
    expect(continueCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'reservation QR controller panel rebuilds from controller state',
    (tester) async {
      final now = DateTime.utc(2026, 6, 10, 13);
      final controller = RestaurantReservationQrSessionController(
        workflow: RestaurantReservationQrWorkflow(
          linkComposer: RestaurantReservationQrLinkComposer(
            clock: () => now,
            tokenFactory: () => 'controller-token',
          ),
        ),
      );

      await pumpRestaurantPanel(
        tester,
        RestaurantReservationQrSessionControllerPanel(
          controller: controller,
          summaryNow: now.add(const Duration(minutes: 1)),
        ),
      );

      expect(find.text('QR session'), findsOneWidget);
      expect(find.text('Active QR handoff'), findsNothing);

      controller.generateLink(
        action: RestaurantReservationIntakeAction.qrWaitlist,
        baseUri: Uri.parse('https://tables.kaysir.test'),
        lifetime: const Duration(minutes: 10),
        zoneLabel: 'Terrace',
      );
      await tester.pumpAndSettle();

      expect(find.text('Active QR handoff'), findsOneWidget);
      expect(find.text('QR handoff active'), findsOneWidget);
      expect(find.text('Link: Join waitlist'), findsOneWidget);
      expect(find.text('Expiry: Expires in 9 min'), findsOneWidget);
      expect(find.text('Join waitlist'), findsWidgets);
      expect(find.text('Terrace'), findsWidgets);
      expect(find.text('Recent QR activity'), findsOneWidget);
      expect(find.text('Join waitlist QR generated'), findsOneWidget);
      expect(find.text('QR session'), findsNothing);

      controller.dispose();
    },
  );

  testWidgets('reservation QR controller panel records scan actions', (
    tester,
  ) async {
    final selectedActions = <RestaurantReservationQrScanAction>[];
    var continueCount = 0;
    var dismissCount = 0;
    final uri = Uri.parse(
      'https://tables.kaysir.test/restaurant/reservations/qr?payload=encoded',
    );
    final payload = RestaurantReservationQrPayload(
      token: 'qr-token',
      intent: RestaurantReservationQrIntent.checkIn,
      expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
      reservationId: 'reservation-42',
      zoneLabel: 'Main Floor',
      tableLabel: 'Table 8',
    );
    final controller = RestaurantReservationQrSessionController(
      initialState: RestaurantReservationQrSessionState(
        scanWorkflow: RestaurantReservationQrScanWorkflow(
          result: RestaurantReservationQrScanResult.valid(
            uri: uri,
            payload: payload,
            scannedAt: DateTime.utc(2026, 6, 10, 13, 8),
          ),
          actionPlan: const RestaurantReservationQrScanActionPlan(
            primaryAction: RestaurantReservationQrScanAction.confirmCheckIn,
            secondaryActions: [RestaurantReservationQrScanAction.dismiss],
          ),
        ),
      ),
    );

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrSessionControllerPanel(
        controller: controller,
        summaryNow: DateTime.utc(2026, 6, 10, 13, 10),
        callbacks: RestaurantReservationQrSessionCallbacks(
          onScanActionSelected: selectedActions.add,
          onContinue: () => continueCount += 1,
          onDismissScan: () => dismissCount += 1,
        ),
      ),
    );

    await tester.tap(
      findReservationQrScanAction(
        RestaurantReservationQrScanAction.confirmCheckIn,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      controller.selectedAction,
      RestaurantReservationQrScanAction.confirmCheckIn,
    );
    expect(find.text('Selected action: Confirm check-in'), findsOneWidget);
    expect(selectedActions, [RestaurantReservationQrScanAction.confirmCheckIn]);
    expect(continueCount, 1);

    await tester.tap(
      findReservationQrScanAction(RestaurantReservationQrScanAction.dismiss),
    );
    await tester.pumpAndSettle();

    expect(controller.state.hasScanResult, isFalse);
    expect(controller.selectedAction, isNull);
    expect(selectedActions, [
      RestaurantReservationQrScanAction.confirmCheckIn,
      RestaurantReservationQrScanAction.dismiss,
    ]);
    expect(dismissCount, 1);
    expect(find.text('No active QR handoff.'), findsOneWidget);

    controller.dispose();
  });
}
