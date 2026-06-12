import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR scan action planner maps valid intents to actions', () {
    const planner = RestaurantReservationQrScanActionPlanner();

    RestaurantReservationQrScanResult validResult(
      RestaurantReservationQrIntent intent,
    ) {
      return RestaurantReservationQrScanResult.valid(
        uri: Uri.parse('https://tables.kaysir.test/restaurant/reservations/qr'),
        payload: RestaurantReservationQrPayload(
          token: intent.name,
          intent: intent,
          expiresAt: DateTime.utc(2026, 6, 10, 12, 30),
        ),
        scannedAt: DateTime.utc(2026, 6, 10, 12),
      );
    }

    expect(
      planner
          .planFor(validResult(RestaurantReservationQrIntent.booking))
          .actions,
      [
        RestaurantReservationQrScanAction.createBooking,
        RestaurantReservationQrScanAction.dismiss,
      ],
    );
    expect(
      planner
          .planFor(validResult(RestaurantReservationQrIntent.waitlist))
          .actions,
      [
        RestaurantReservationQrScanAction.joinWaitlist,
        RestaurantReservationQrScanAction.dismiss,
      ],
    );
    expect(
      planner
          .planFor(validResult(RestaurantReservationQrIntent.checkIn))
          .actions,
      [
        RestaurantReservationQrScanAction.confirmCheckIn,
        RestaurantReservationQrScanAction.dismiss,
      ],
    );
  });

  test('reservation QR scan action planner maps recovery states', () {
    const planner = RestaurantReservationQrScanActionPlanner();
    final expired = RestaurantReservationQrScanResult.expired(
      uri: Uri.parse('https://tables.kaysir.test/restaurant/reservations/qr'),
      payload: RestaurantReservationQrPayload(
        token: 'expired-token',
        intent: RestaurantReservationQrIntent.waitlist,
        expiresAt: DateTime.utc(2026, 6, 10, 12, 30),
      ),
      scannedAt: DateTime.utc(2026, 6, 10, 12, 45),
    );
    final invalid = RestaurantReservationQrScanResult.invalid(
      scannedAt: DateTime.utc(2026, 6, 10, 12),
    );

    expect(planner.planFor(expired).actions, [
      RestaurantReservationQrScanAction.refreshLink,
      RestaurantReservationQrScanAction.dismiss,
    ]);
    expect(planner.planFor(invalid).actions, [
      RestaurantReservationQrScanAction.dismiss,
    ]);
    expect(planner.planFor(invalid, includeDismiss: false).hasActions, isFalse);
  });

  test('reservation QR scan action labels describe host next steps', () {
    expect(
      RestaurantReservationQrScanAction.createBooking.label,
      'Create booking',
    );
    expect(
      RestaurantReservationQrScanAction.confirmCheckIn.detailLabel,
      'Confirm the arriving party.',
    );
    expect(
      reservationQrScanActionForIntent(RestaurantReservationQrIntent.waitlist),
      RestaurantReservationQrScanAction.joinWaitlist,
    );
  });
}
