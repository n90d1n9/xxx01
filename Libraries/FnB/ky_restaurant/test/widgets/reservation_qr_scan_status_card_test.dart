import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/reservation_qr_test_finders.dart';
import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation QR scan status card renders valid scan actions', (
    tester,
  ) async {
    var continueCount = 0;
    var dismissCount = 0;
    final selectedActions = <RestaurantReservationQrScanAction>[];
    final result = RestaurantReservationQrScanResult.valid(
      uri: Uri.parse('https://tables.kaysir.test/restaurant/reservations/qr'),
      payload: RestaurantReservationQrPayload(
        token: 'scan-token',
        intent: RestaurantReservationQrIntent.checkIn,
        expiresAt: DateTime.utc(2026, 6, 10, 12, 30),
        reservationId: 'RSV-42',
        zoneLabel: 'Main Floor',
        tableLabel: 'Table 8',
      ),
      scannedAt: DateTime.utc(2026, 6, 10, 12),
    );

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrScanStatusCard(
        result: result,
        onActionSelected: selectedActions.add,
        onContinue: () => continueCount += 1,
        onDismiss: () => dismissCount += 1,
      ),
    );

    expect(find.text('QR link ready'), findsWidgets);
    expect(find.text('Ready to continue'), findsOneWidget);
    expect(
      find.text('Confirm check-in keeps the check in flow moving.'),
      findsOneWidget,
    );
    expect(find.text('Check in'), findsOneWidget);
    expect(find.text('Main Floor'), findsOneWidget);
    expect(find.text('Table 8'), findsOneWidget);
    expect(find.text('Scanned 12:00 UTC'), findsOneWidget);
    expect(find.text('Reservation RSV-42'), findsOneWidget);
    expect(find.text('Expires 12:30 UTC'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Confirm check-in'),
      findsOneWidget,
    );
    expect(find.widgetWithText(OutlinedButton, 'Dismiss'), findsOneWidget);
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

    await tester.tap(
      findReservationQrScanAction(
        RestaurantReservationQrScanAction.confirmCheckIn,
      ),
    );
    await tester.tap(
      findReservationQrScanAction(RestaurantReservationQrScanAction.dismiss),
    );
    await tester.pumpAndSettle();

    expect(selectedActions, [
      RestaurantReservationQrScanAction.confirmCheckIn,
      RestaurantReservationQrScanAction.dismiss,
    ]);
    expect(continueCount, 1);
    expect(dismissCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'reservation QR scan status card renders expired recovery action',
    (tester) async {
      var refreshCount = 0;
      final selectedActions = <RestaurantReservationQrScanAction>[];
      final result = RestaurantReservationQrScanResult.expired(
        uri: Uri.parse('https://tables.kaysir.test/restaurant/reservations/qr'),
        payload: RestaurantReservationQrPayload(
          token: 'expired-token',
          intent: RestaurantReservationQrIntent.waitlist,
          expiresAt: DateTime.utc(2026, 6, 10, 12, 30),
          zoneLabel: 'Terrace',
        ),
        scannedAt: DateTime.utc(2026, 6, 10, 12, 45),
      );

      await pumpRestaurantPanel(
        tester,
        RestaurantReservationQrScanStatusCard(
          result: result,
          onActionSelected: selectedActions.add,
          onRefresh: () => refreshCount += 1,
        ),
      );

      expect(find.text('QR link expired'), findsWidgets);
      expect(find.text('Generate a fresh QR'), findsOneWidget);
      expect(
        find.text('Ask the guest to refresh the QR code.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'This link expired at 12:30 UTC. Refresh it before continuing.',
        ),
        findsOneWidget,
      );
      expect(find.text('Join waitlist'), findsOneWidget);
      expect(find.text('Terrace'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Refresh QR link'),
        findsOneWidget,
      );
      expect(
        findReservationQrScanAction(
          RestaurantReservationQrScanAction.refreshLink,
        ),
        findsOneWidget,
      );

      await tester.tap(
        findReservationQrScanAction(
          RestaurantReservationQrScanAction.refreshLink,
        ),
      );
      await tester.pumpAndSettle();

      expect(selectedActions, [RestaurantReservationQrScanAction.refreshLink]);
      expect(refreshCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reservation QR scan status card hides actions without handlers',
    (tester) async {
      final result = RestaurantReservationQrScanResult.valid(
        uri: Uri.parse('https://tables.kaysir.test/restaurant/reservations/qr'),
        payload: RestaurantReservationQrPayload(
          token: 'scan-token',
          intent: RestaurantReservationQrIntent.booking,
          expiresAt: DateTime.utc(2026, 6, 10, 12, 30),
        ),
        scannedAt: DateTime.utc(2026, 6, 10, 12),
      );

      await pumpRestaurantPanel(
        tester,
        RestaurantReservationQrScanStatusCard(result: result),
      );

      expect(
        findReservationQrScanAction(
          RestaurantReservationQrScanAction.createBooking,
        ),
        findsNothing,
      );
      expect(
        findReservationQrScanAction(RestaurantReservationQrScanAction.dismiss),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
