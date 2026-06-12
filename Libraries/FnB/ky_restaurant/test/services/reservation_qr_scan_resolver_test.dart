import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR scan resolver returns valid payloads', () {
    final now = DateTime.utc(2026, 6, 10, 12);
    final uri = const RestaurantReservationQrLinkBuilder().buildUri(
      baseUri: Uri.parse('https://tables.kaysir.test'),
      payload: RestaurantReservationQrPayload(
        token: 'scan-token',
        intent: RestaurantReservationQrIntent.checkIn,
        expiresAt: DateTime.utc(2026, 6, 10, 12, 10),
        reservationId: 'reservation-42',
      ),
    );
    final resolver = RestaurantReservationQrScanResolver(clock: () => now);

    final result = resolver.resolveUri(uri);

    expect(result.status, RestaurantReservationQrScanStatus.valid);
    expect(result.isValid, isTrue);
    expect(result.scannedAt, now);
    expect(result.uri, uri);
    expect(result.payload?.token, 'scan-token');
    expect(result.payload?.intent, RestaurantReservationQrIntent.checkIn);
    expect(result.detailLabel, 'Check in is ready to continue.');
  });

  test('reservation QR scan resolver preserves expired payload context', () {
    final now = DateTime.utc(2026, 6, 10, 12, 11);
    final uri = const RestaurantReservationQrLinkBuilder().buildUri(
      baseUri: Uri.parse('https://tables.kaysir.test'),
      payload: RestaurantReservationQrPayload(
        token: 'expired-token',
        intent: RestaurantReservationQrIntent.waitlist,
        expiresAt: DateTime.utc(2026, 6, 10, 12, 10),
        zoneLabel: 'Terrace',
      ),
    );
    final resolver = RestaurantReservationQrScanResolver(clock: () => now);

    final result = resolver.resolveValue(uri.toString());

    expect(result.status, RestaurantReservationQrScanStatus.expired);
    expect(result.isExpired, isTrue);
    expect(result.payload?.token, 'expired-token');
    expect(result.payload?.zoneLabel, 'Terrace');
    expect(result.detailLabel, 'Ask the guest to refresh the QR code.');
  });

  test(
    'reservation QR scan resolver returns invalid results for bad input',
    () {
      final now = DateTime.utc(2026, 6, 10, 12);
      final resolver = RestaurantReservationQrScanResolver(clock: () => now);

      final empty = resolver.resolveValue('   ');
      final missingPayload = resolver.resolveValue(
        'https://tables.kaysir.test',
      );

      expect(empty.status, RestaurantReservationQrScanStatus.invalid);
      expect(empty.isInvalid, isTrue);
      expect(empty.detailLabel, 'Reservation QR link is required.');
      expect(missingPayload.status, RestaurantReservationQrScanStatus.invalid);
      expect(
        missingPayload.detailLabel,
        'Reservation QR link payload is required.',
      );
    },
  );
}
