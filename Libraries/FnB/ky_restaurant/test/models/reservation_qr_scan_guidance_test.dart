import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR scan guidance describes valid next action', () {
    final result = RestaurantReservationQrScanResult.valid(
      uri: Uri.parse('https://tables.kaysir.test/restaurant/reservations/qr'),
      payload: RestaurantReservationQrPayload(
        token: 'scan-token',
        intent: RestaurantReservationQrIntent.checkIn,
        expiresAt: DateTime.utc(2026, 6, 10, 12, 30),
      ),
      scannedAt: DateTime.utc(2026, 6, 10, 12),
    );

    final guidance = RestaurantReservationQrScanGuidance.fromScan(
      result: result,
      actionPlan: const RestaurantReservationQrScanActionPlan(
        primaryAction: RestaurantReservationQrScanAction.confirmCheckIn,
      ),
    );

    expect(guidance.title, 'Ready to continue');
    expect(
      guidance.message,
      'Confirm check-in keeps the check in flow moving.',
    );
    expect(guidance.tone, RestaurantReservationQrScanGuidanceTone.success);
    expect(guidance.needsAttention, isFalse);
  });

  test('reservation QR scan guidance describes expired recovery', () {
    final result = RestaurantReservationQrScanResult.expired(
      uri: Uri.parse('https://tables.kaysir.test/restaurant/reservations/qr'),
      payload: RestaurantReservationQrPayload(
        token: 'expired-token',
        intent: RestaurantReservationQrIntent.waitlist,
        expiresAt: DateTime.utc(2026, 6, 10, 12, 30),
      ),
      scannedAt: DateTime.utc(2026, 6, 10, 12, 45),
    );

    final guidance = RestaurantReservationQrScanGuidance.fromScan(
      result: result,
      actionPlan: const RestaurantReservationQrScanActionPlan(
        primaryAction: RestaurantReservationQrScanAction.refreshLink,
      ),
    );

    expect(guidance.title, 'Generate a fresh QR');
    expect(
      guidance.message,
      'This link expired at 12:30 UTC. Refresh it before continuing.',
    );
    expect(guidance.tone, RestaurantReservationQrScanGuidanceTone.warning);
    expect(guidance.needsAttention, isTrue);
  });

  test('reservation QR scan guidance describes invalid scans', () {
    final result = RestaurantReservationQrScanResult.invalid(
      scannedAt: DateTime.utc(2026, 6, 10, 12),
      detail: 'Reservation QR link is required.',
    );

    final guidance = RestaurantReservationQrScanGuidance.fromScan(
      result: result,
      actionPlan: const RestaurantReservationQrScanActionPlan(
        primaryAction: RestaurantReservationQrScanAction.dismiss,
      ),
    );

    expect(guidance.title, 'Use another intake path');
    expect(guidance.message, 'Reservation QR link is required.');
    expect(guidance.tone, RestaurantReservationQrScanGuidanceTone.critical);
    expect(guidance.needsAttention, isTrue);
  });
}
