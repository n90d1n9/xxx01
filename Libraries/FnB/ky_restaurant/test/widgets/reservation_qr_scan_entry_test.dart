import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation QR scan entry trims submitted values', (
    tester,
  ) async {
    final submittedValues = <String>[];
    final changedValues = <String>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrScanEntry(
        onChanged: changedValues.add,
        onSubmitted: submittedValues.add,
      ),
    );

    await tester.enterText(
      find.byType(TextField),
      '  https://tables.kaysir.test/qr?payload=encoded  ',
    );
    await tester.pump();
    await tester.tap(find.text('Resolve scan'));
    await tester.pumpAndSettle();

    expect(submittedValues, ['https://tables.kaysir.test/qr?payload=encoded']);
    expect(changedValues.last, contains('payload=encoded'));
    expect(find.text('Scan QR handoff'), findsOneWidget);
    expect(find.text('Ready to resolve this QR handoff.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation QR scan entry clears typed scan values', (
    tester,
  ) async {
    var clearCount = 0;

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrScanEntry(
        initialValue: 'https://tables.kaysir.test/qr?payload=encoded',
        onSubmitted: (_) {},
        onClear: () => clearCount += 1,
      ),
    );

    expect(find.byTooltip('Clear scan value'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear scan value'));
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, isEmpty);
    expect(clearCount, 1);
    expect(find.byTooltip('Clear scan value'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation QR scan controller entry resolves scanned links', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 6, 10, 12);
    final controller = RestaurantReservationQrSessionController(
      workflow: RestaurantReservationQrWorkflow(
        linkComposer: RestaurantReservationQrLinkComposer(
          clock: () => now,
          tokenFactory: () => 'scan-entry-token',
        ),
        scanResolver: RestaurantReservationQrScanResolver(clock: () => now),
      ),
    );
    final resolvedScans = <RestaurantReservationQrScanWorkflow>[];
    final link = controller.generateLink(
      action: RestaurantReservationIntakeAction.qrCheckIn,
      baseUri: Uri.parse('https://tables.kaysir.test'),
      lifetime: const Duration(minutes: 15),
      reservationId: 'reservation-42',
      zoneLabel: 'Main Floor',
      tableLabel: 'Table 8',
    );

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrScanControllerEntry(
        controller: controller,
        onScanResolved: resolvedScans.add,
      ),
    );

    await tester.enterText(find.byType(TextField), link.url);
    await tester.pump();
    await tester.tap(find.text('Resolve scan'));
    await tester.pumpAndSettle();

    expect(resolvedScans, hasLength(1));
    expect(
      resolvedScans.single.result.status,
      RestaurantReservationQrScanStatus.valid,
    );
    expect(
      resolvedScans.single.primaryAction,
      RestaurantReservationQrScanAction.confirmCheckIn,
    );
    expect(controller.scanWorkflow, resolvedScans.single);
    expect(
      controller.scanWorkflow?.result.payload?.reservationId,
      'reservation-42',
    );
    expect(tester.takeException(), isNull);

    controller.dispose();
  });
}
