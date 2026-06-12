import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR session section presenter omits idle sections', () {
    const presenter = RestaurantReservationQrSessionSectionPresenter();

    final plan = presenter.build(
      RestaurantReservationQrSessionState(
        activityTrail: [
          RestaurantReservationQrSessionActivity.sessionReset(
            occurredAt: DateTime.utc(2026, 6, 10, 12),
          ),
        ],
      ),
    );

    expect(plan.isEmpty, isTrue);
  });

  test('reservation QR session section presenter orders active sections', () {
    const presenter = RestaurantReservationQrSessionSectionPresenter();
    final link = _link();
    final payload = link.payload;
    final uri = link.uri;

    final plan = presenter.build(
      RestaurantReservationQrSessionState(
        activeLink: link,
        scanWorkflow: RestaurantReservationQrScanWorkflow(
          result: RestaurantReservationQrScanResult.valid(
            uri: uri,
            payload: payload,
            scannedAt: DateTime.utc(2026, 6, 10, 13, 8),
          ),
          actionPlan: const RestaurantReservationQrScanActionPlan(
            primaryAction: RestaurantReservationQrScanAction.confirmCheckIn,
          ),
        ),
        selectedAction: RestaurantReservationQrScanAction.confirmCheckIn,
        activityTrail: [
          RestaurantReservationQrSessionActivity.actionSelected(
            action: RestaurantReservationQrScanAction.confirmCheckIn,
            occurredAt: DateTime.utc(2026, 6, 10, 13, 9),
          ),
        ],
      ),
    );

    expect(plan.sections, [
      RestaurantReservationQrSessionSection.summary,
      RestaurantReservationQrSessionSection.activeLink,
      RestaurantReservationQrSessionSection.scanStatus,
      RestaurantReservationQrSessionSection.selectedAction,
      RestaurantReservationQrSessionSection.activityTrail,
    ]);
  });

  test('reservation QR session section presenter can hide activity trail', () {
    const presenter = RestaurantReservationQrSessionSectionPresenter();
    final link = _link();

    final plan = presenter.build(
      RestaurantReservationQrSessionState(
        activeLink: link,
        activityTrail: [
          RestaurantReservationQrSessionActivity.linkGenerated(
            link: link,
            occurredAt: DateTime.utc(2026, 6, 10, 13),
          ),
        ],
      ),
      showActivityTrail: false,
    );

    expect(
      plan.contains(RestaurantReservationQrSessionSection.activityTrail),
      isFalse,
    );
    expect(plan.sections, [
      RestaurantReservationQrSessionSection.summary,
      RestaurantReservationQrSessionSection.activeLink,
    ]);
  });
}

RestaurantReservationQrLink _link() {
  return RestaurantReservationQrLink(
    action: RestaurantReservationIntakeAction.qrCheckIn,
    payload: RestaurantReservationQrPayload(
      token: 'qr-token',
      intent: RestaurantReservationQrIntent.checkIn,
      expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
    ),
    uri: Uri.parse('https://tables.kaysir.test/restaurant/reservations/qr'),
    createdAt: DateTime.utc(2026, 6, 10, 13),
  );
}
