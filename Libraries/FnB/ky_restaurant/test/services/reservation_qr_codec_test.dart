import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR codec round-trips non-PII payloads', () {
    const codec = RestaurantReservationQrCodec();
    final expiresAt = DateTime.utc(2026, 6, 10, 12, 30);
    final payload = RestaurantReservationQrPayload(
      token: ' qr-token ',
      intent: RestaurantReservationQrIntent.checkIn,
      expiresAt: expiresAt,
      reservationId: 'reservation-42',
      zoneLabel: 'Terrace',
      tableLabel: 'Table 21',
    );

    final decoded = codec.decode(
      codec.encode(payload),
      now: DateTime.utc(2026, 6, 10, 12),
    );

    expect(decoded.token, 'qr-token');
    expect(decoded.intent, RestaurantReservationQrIntent.checkIn);
    expect(decoded.expiresAt, expiresAt);
    expect(decoded.reservationId, 'reservation-42');
    expect(decoded.zoneLabel, 'Terrace');
    expect(decoded.tableLabel, 'Table 21');
    expect(decoded.isExpiredAt(DateTime.utc(2026, 6, 10, 12, 31)), isTrue);
  });

  test('reservation QR codec rejects invalid and expired payloads', () {
    const codec = RestaurantReservationQrCodec();
    final encoded = codec.encode(
      RestaurantReservationQrPayload(
        token: 'qr-token',
        intent: RestaurantReservationQrIntent.booking,
        expiresAt: DateTime.utc(2026, 6, 10, 12),
      ),
    );

    expect(() => codec.decode('{}'), throwsFormatException);
    expect(() => codec.decode('[]'), throwsFormatException);
    expect(
      () => codec.decode(encoded, now: DateTime.utc(2026, 6, 10, 12, 1)),
      throwsFormatException,
    );
  });

  test('reservation QR payload builder maps QR intake actions to intents', () {
    const builder = RestaurantReservationQrPayloadBuilder();

    final payload = builder.buildForAction(
      action: RestaurantReservationIntakeAction.qrWaitlist,
      token: 'waitlist-token',
      expiresAt: DateTime.utc(2026, 6, 10, 13),
      zoneLabel: 'Terrace',
    );

    expect(payload.intent, RestaurantReservationQrIntent.waitlist);
    expect(payload.token, 'waitlist-token');
    expect(payload.zoneLabel, 'Terrace');
    expect(
      () => builder.buildForAction(
        action: RestaurantReservationIntakeAction.online,
        token: 'online-token',
        expiresAt: DateTime.utc(2026, 6, 10, 13),
      ),
      throwsArgumentError,
    );
  });
}
