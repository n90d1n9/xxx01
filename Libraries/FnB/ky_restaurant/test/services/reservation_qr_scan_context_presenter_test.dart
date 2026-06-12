import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR scan context presenter builds scan context', () {
    const presenter = RestaurantReservationQrScanContextPresenter();

    final presentation = presenter.build(
      RestaurantReservationQrScanResult.valid(
        uri: Uri.parse('https://tables.kaysir.test/restaurant/reservations/qr'),
        payload: RestaurantReservationQrPayload(
          token: 'scan-token',
          intent: RestaurantReservationQrIntent.checkIn,
          expiresAt: DateTime.utc(2026, 6, 10, 12, 30),
          reservationId: ' RSV-42 ',
          zoneLabel: 'Main Floor',
          tableLabel: 'Table 8',
        ),
        scannedAt: DateTime.utc(2026, 6, 10, 12),
      ),
    );

    expect(presentation.items.map((item) => item.kind), [
      RestaurantReservationQrScanContextKind.status,
      RestaurantReservationQrScanContextKind.scannedAt,
      RestaurantReservationQrScanContextKind.intent,
      RestaurantReservationQrScanContextKind.reservation,
      RestaurantReservationQrScanContextKind.expiry,
      RestaurantReservationQrScanContextKind.zone,
      RestaurantReservationQrScanContextKind.table,
    ]);
    expect(presentation.items.map((item) => item.label), [
      'QR link ready',
      'Scanned 12:00 UTC',
      'Check in',
      'Reservation RSV-42',
      'Expires 12:30 UTC',
      'Main Floor',
      'Table 8',
    ]);
    expect(
      presentation.semanticsLabel,
      'QR link ready. Scanned 12:00 UTC. Check in. Reservation RSV-42. '
      'Expires 12:30 UTC. Main Floor. Table 8',
    );
  });

  test('reservation QR scan context presenter handles invalid scans', () {
    const presenter = RestaurantReservationQrScanContextPresenter();

    final presentation = presenter.build(
      RestaurantReservationQrScanResult.invalid(
        scannedAt: DateTime.utc(2026, 6, 10, 12),
      ),
    );

    expect(presentation.items.map((item) => item.label), [
      'QR link unavailable',
      'Scanned 12:00 UTC',
    ]);
  });
}
