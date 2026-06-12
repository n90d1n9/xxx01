import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR workflow composes and resolves action plans', () {
    final now = DateTime.utc(2026, 6, 10, 12);
    final workflow = RestaurantReservationQrWorkflow(
      linkComposer: RestaurantReservationQrLinkComposer(
        clock: () => now,
        tokenFactory: () => 'stable-token',
      ),
      scanResolver: RestaurantReservationQrScanResolver(clock: () => now),
    );

    final link = workflow.composeLink(
      action: RestaurantReservationIntakeAction.qrWaitlist,
      baseUri: Uri.parse('https://tables.kaysir.test/tenant/demo'),
      lifetime: const Duration(minutes: 15),
      zoneLabel: 'Terrace',
    );
    final scanWorkflow = workflow.resolveUri(link.uri);

    expect(link.payload.token, 'stable-token');
    expect(link.payload.intent, RestaurantReservationQrIntent.waitlist);
    expect(scanWorkflow.result.status, RestaurantReservationQrScanStatus.valid);
    expect(scanWorkflow.result.payload?.zoneLabel, 'Terrace');
    expect(scanWorkflow.isActionable, isTrue);
    expect(
      scanWorkflow.primaryAction,
      RestaurantReservationQrScanAction.joinWaitlist,
    );
    expect(scanWorkflow.actionPlan.actions, [
      RestaurantReservationQrScanAction.joinWaitlist,
      RestaurantReservationQrScanAction.dismiss,
    ]);
  });

  test('reservation QR workflow plans expired scan recovery', () {
    final createdAt = DateTime.utc(2026, 6, 10, 12);
    final workflow = RestaurantReservationQrWorkflow(
      linkComposer: RestaurantReservationQrLinkComposer(
        clock: () => createdAt,
        tokenFactory: () => 'expired-token',
      ),
      scanResolver: RestaurantReservationQrScanResolver(
        clock: () => DateTime.utc(2026, 6, 10, 12, 20),
      ),
    );

    final link = workflow.composeLink(
      action: RestaurantReservationIntakeAction.qrBooking,
      baseUri: Uri.parse('https://tables.kaysir.test'),
      lifetime: const Duration(minutes: 5),
    );
    final scanWorkflow = workflow.resolveValue(link.url);

    expect(
      scanWorkflow.result.status,
      RestaurantReservationQrScanStatus.expired,
    );
    expect(scanWorkflow.actionPlan.actions, [
      RestaurantReservationQrScanAction.refreshLink,
      RestaurantReservationQrScanAction.dismiss,
    ]);
  });

  test('reservation QR workflow can suppress dismiss actions', () {
    final now = DateTime.utc(2026, 6, 10, 12);
    final workflow = RestaurantReservationQrWorkflow(
      scanResolver: RestaurantReservationQrScanResolver(clock: () => now),
    );

    final scanWorkflow = workflow.resolveValue(' ', includeDismiss: false);

    expect(
      scanWorkflow.result.status,
      RestaurantReservationQrScanStatus.invalid,
    );
    expect(scanWorkflow.result.detailLabel, 'Reservation QR link is required.');
    expect(scanWorkflow.isActionable, isFalse);
    expect(scanWorkflow.primaryAction, isNull);
    expect(scanWorkflow.actionPlan.actions, isEmpty);
  });
}
