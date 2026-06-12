import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR presentation builder formats payload labels', () {
    const builder = RestaurantReservationQrPresentationBuilder();

    final presentation = builder.buildPayload(
      RestaurantReservationQrPayload(
        token: 'qr-token',
        intent: RestaurantReservationQrIntent.waitlist,
        expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
        zoneLabel: 'Terrace',
        tableLabel: 'Table 21',
      ),
    );

    expect(presentation.title, 'Join waitlist');
    expect(presentation.expiryLabel, 'Expires 13:30 UTC');
    expect(presentation.subtitle, 'Terrace - Table 21 - Expires 13:30 UTC');
    expect(presentation.metadata.map((item) => item.kind), [
      RestaurantReservationQrMetadataKind.intent,
      RestaurantReservationQrMetadataKind.expiry,
      RestaurantReservationQrMetadataKind.zone,
      RestaurantReservationQrMetadataKind.table,
    ]);
    expect(presentation.metadata.map((item) => item.label), [
      'Join waitlist',
      'Expires 13:30 UTC',
      'Terrace',
      'Table 21',
    ]);
  });

  test('reservation QR presentation builder omits empty location metadata', () {
    const builder = RestaurantReservationQrPresentationBuilder();

    final presentation = builder.buildPayload(
      RestaurantReservationQrPayload(
        token: 'qr-token',
        intent: RestaurantReservationQrIntent.booking,
        expiresAt: DateTime(2026, 6, 10, 13, 30),
      ),
    );

    expect(presentation.title, 'Create booking');
    expect(presentation.expiryLabel, 'Expires 13:30');
    expect(presentation.subtitle, 'Expires 13:30');
    expect(presentation.metadata.map((item) => item.kind), [
      RestaurantReservationQrMetadataKind.intent,
      RestaurantReservationQrMetadataKind.expiry,
    ]);
  });

  test('reservation QR presentation builder formats scan outcomes', () {
    const builder = RestaurantReservationQrPresentationBuilder();
    final valid = RestaurantReservationQrScanResult.valid(
      uri: Uri.parse('https://tables.kaysir.test/restaurant/reservations/qr'),
      payload: RestaurantReservationQrPayload(
        token: 'scan-token',
        intent: RestaurantReservationQrIntent.checkIn,
        expiresAt: DateTime.utc(2026, 6, 10, 12, 30),
      ),
      scannedAt: DateTime.utc(2026, 6, 10, 12),
    );
    final invalid = RestaurantReservationQrScanResult.invalid(
      scannedAt: DateTime.utc(2026, 6, 10, 12),
      detail: 'Reservation QR link is required.',
    );

    final validPresentation = builder.buildScan(valid);
    final invalidPresentation = builder.buildScan(invalid);

    expect(validPresentation.statusLabel, 'QR link ready');
    expect(validPresentation.detailLabel, 'Check in is ready to continue.');
    expect(validPresentation.payload?.title, 'Check in');
    expect(invalidPresentation.statusLabel, 'QR link unavailable');
    expect(invalidPresentation.detailLabel, 'Reservation QR link is required.');
    expect(invalidPresentation.payload, isNull);
  });
}
