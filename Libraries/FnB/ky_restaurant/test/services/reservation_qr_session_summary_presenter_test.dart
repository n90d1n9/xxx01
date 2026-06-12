import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test(
    'reservation QR session summary presenter describes selected action',
    () {
      const presenter = RestaurantReservationQrSessionSummaryPresenter();
      final uri = Uri.parse(
        'https://tables.kaysir.test/restaurant/reservations/qr?payload=encoded',
      );
      final payload = RestaurantReservationQrPayload(
        token: 'qr-token',
        intent: RestaurantReservationQrIntent.checkIn,
        expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
      );

      final presentation = presenter.build(
        RestaurantReservationQrSessionState(
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
        now: DateTime.utc(2026, 6, 10, 13, 10),
      );

      expect(presentation.title, 'QR action selected');
      expect(
        presentation.message,
        'Confirm check-in: Confirm the arriving party.',
      );
      expect(
        presentation.tone,
        RestaurantReservationQrSessionSummaryTone.active,
      );
      expect(presentation.metrics.map((metric) => metric.text), [
        'Link: Check in',
        'Expiry: Expires in 20 min',
        'Scan: QR link ready',
        'Action: Confirm check-in',
        'Events: 1 event',
      ]);
      expect(
        presentation.semanticsLabel,
        'QR action selected. Confirm check-in: Confirm the arriving party. '
        'Link: Check in. Expiry: Expires in 20 min. Scan: QR link ready. '
        'Action: Confirm check-in. Events: 1 event.',
      );
    },
  );

  test('reservation QR session summary presenter describes fresh links', () {
    const presenter = RestaurantReservationQrSessionSummaryPresenter();
    final now = DateTime.utc(2026, 6, 10, 13);

    final presentation = presenter.build(
      _linkState(
        intent: RestaurantReservationQrIntent.waitlist,
        action: RestaurantReservationIntakeAction.qrWaitlist,
        expiresAt: now.add(const Duration(minutes: 12)),
      ),
      now: now,
    );

    expect(presentation.title, 'QR handoff active');
    expect(
      presentation.message,
      'Join waitlist link is ready for scan. Expires in 12 min.',
    );
    expect(presentation.tone, RestaurantReservationQrSessionSummaryTone.active);
    expect(presentation.metrics.map((metric) => metric.text), [
      'Link: Join waitlist',
      'Expiry: Expires in 12 min',
    ]);
  });

  test('reservation QR session summary presenter warns on expiring links', () {
    const presenter = RestaurantReservationQrSessionSummaryPresenter();
    final now = DateTime.utc(2026, 6, 10, 13);

    final presentation = presenter.build(
      _linkState(
        intent: RestaurantReservationQrIntent.booking,
        action: RestaurantReservationIntakeAction.qrBooking,
        expiresAt: now.add(const Duration(minutes: 4, seconds: 30)),
      ),
      now: now,
    );

    expect(presentation.title, 'QR handoff expiring soon');
    expect(
      presentation.message,
      'Create booking link expires in 5 min. '
      'Refresh if the guest has not scanned yet.',
    );
    expect(
      presentation.tone,
      RestaurantReservationQrSessionSummaryTone.warning,
    );
    expect(presentation.metrics.map((metric) => metric.text), [
      'Link: Create booking',
      'Expiry: Expires in 5 min',
    ]);
  });

  test('reservation QR session summary presenter flags expired links', () {
    const presenter = RestaurantReservationQrSessionSummaryPresenter();
    final now = DateTime.utc(2026, 6, 10, 13);

    final presentation = presenter.build(
      _linkState(
        intent: RestaurantReservationQrIntent.checkIn,
        action: RestaurantReservationIntakeAction.qrCheckIn,
        expiresAt: now.subtract(const Duration(minutes: 2)),
      ),
      now: now,
    );

    expect(presentation.title, 'QR handoff expired');
    expect(
      presentation.message,
      'Check in link expired. Generate a fresh QR link before the guest scans.',
    );
    expect(
      presentation.tone,
      RestaurantReservationQrSessionSummaryTone.critical,
    );
    expect(presentation.metrics.map((metric) => metric.text), [
      'Link: Check in',
      'Expiry: Expired 2 min ago',
    ]);
  });

  test('reservation QR session summary presenter flags expired scans', () {
    const presenter = RestaurantReservationQrSessionSummaryPresenter();
    final uri = Uri.parse(
      'https://tables.kaysir.test/restaurant/reservations/qr?payload=encoded',
    );
    final payload = RestaurantReservationQrPayload(
      token: 'qr-token',
      intent: RestaurantReservationQrIntent.waitlist,
      expiresAt: DateTime.utc(2026, 6, 10, 13),
    );

    final presentation = presenter.build(
      RestaurantReservationQrSessionState(
        scanWorkflow: RestaurantReservationQrScanWorkflow(
          result: RestaurantReservationQrScanResult.expired(
            uri: uri,
            payload: payload,
            scannedAt: DateTime.utc(2026, 6, 10, 13, 8),
          ),
          actionPlan: const RestaurantReservationQrScanActionPlan(
            primaryAction: RestaurantReservationQrScanAction.refreshLink,
          ),
        ),
      ),
    );

    expect(presentation.title, 'QR scan needs refresh');
    expect(presentation.message, 'Ask the guest to refresh the QR code.');
    expect(
      presentation.tone,
      RestaurantReservationQrSessionSummaryTone.warning,
    );
    expect(presentation.metrics.single.text, 'Scan: QR link expired');
  });

  test('reservation QR session summary presenter flags invalid scans', () {
    const presenter = RestaurantReservationQrSessionSummaryPresenter();

    final presentation = presenter.build(
      RestaurantReservationQrSessionState(
        scanWorkflow: RestaurantReservationQrScanWorkflow(
          result: RestaurantReservationQrScanResult.invalid(
            uri: Uri.parse('not-a-qr://reservation'),
            detail: 'The QR payload was tampered with.',
            scannedAt: DateTime.utc(2026, 6, 10, 13, 8),
          ),
          actionPlan: const RestaurantReservationQrScanActionPlan(
            primaryAction: RestaurantReservationQrScanAction.dismiss,
          ),
        ),
      ),
    );

    expect(presentation.title, 'QR scan blocked');
    expect(presentation.message, 'The QR payload was tampered with.');
    expect(
      presentation.tone,
      RestaurantReservationQrSessionSummaryTone.critical,
    );
    expect(presentation.metrics.single.text, 'Scan: QR link unavailable');
  });

  test('reservation QR session summary presenter describes idle sessions', () {
    const presenter = RestaurantReservationQrSessionSummaryPresenter();

    final presentation = presenter.build(
      const RestaurantReservationQrSessionState(),
    );

    expect(presentation.title, 'QR session idle');
    expect(presentation.message, 'No active QR handoff.');
    expect(
      presentation.tone,
      RestaurantReservationQrSessionSummaryTone.neutral,
    );
    expect(presentation.metrics, isEmpty);
    expect(
      presentation.semanticsLabel,
      'QR session idle. No active QR handoff.',
    );
  });
}

RestaurantReservationQrSessionState _linkState({
  required RestaurantReservationQrIntent intent,
  required RestaurantReservationIntakeAction action,
  required DateTime expiresAt,
}) {
  return RestaurantReservationQrSessionState(
    activeLink: RestaurantReservationQrLink(
      action: action,
      payload: RestaurantReservationQrPayload(
        token: 'qr-token',
        intent: intent,
        expiresAt: expiresAt,
      ),
      uri: Uri.parse(
        'https://tables.kaysir.test/restaurant/reservations/qr?payload=encoded',
      ),
      createdAt: DateTime.utc(2026, 6, 10, 12, 45),
    ),
  );
}
