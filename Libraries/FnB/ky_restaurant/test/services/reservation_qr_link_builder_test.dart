import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR link builder creates and decodes scan URLs', () {
    const builder = RestaurantReservationQrLinkBuilder();
    final expiresAt = DateTime.utc(2026, 6, 10, 13);
    final payload = RestaurantReservationQrPayload(
      token: 'booking-token',
      intent: RestaurantReservationQrIntent.booking,
      expiresAt: expiresAt,
      zoneLabel: 'Terrace',
    );

    final uri = builder.buildUri(
      baseUri: Uri.parse('https://tables.kaysir.test/tenant/demo?lang=en'),
      payload: payload,
      queryParameters: const {'source': 'table-tent'},
    );

    expect(uri.scheme, 'https');
    expect(uri.host, 'tables.kaysir.test');
    expect(uri.path, '/tenant/demo/restaurant/reservations/qr');
    expect(uri.queryParameters['lang'], 'en');
    expect(uri.queryParameters['source'], 'table-tent');
    expect(uri.queryParameters.containsKey('payload'), isTrue);
    expect(uri.queryParameters['payload'], isNot(contains('{')));

    final decoded = builder.decodeUri(uri, now: DateTime.utc(2026, 6, 10, 12));

    expect(decoded.token, 'booking-token');
    expect(decoded.intent, RestaurantReservationQrIntent.booking);
    expect(decoded.expiresAt, expiresAt);
    expect(decoded.zoneLabel, 'Terrace');
  });

  test(
    'reservation QR link builder rejects missing invalid and expired links',
    () {
      const builder = RestaurantReservationQrLinkBuilder();
      final expiredUri = builder.buildUri(
        baseUri: Uri.parse('https://tables.kaysir.test'),
        payload: RestaurantReservationQrPayload(
          token: 'expired-token',
          intent: RestaurantReservationQrIntent.waitlist,
          expiresAt: DateTime.utc(2026, 6, 10, 12),
        ),
      );

      expect(
        () => builder.decodeUri(Uri.parse('https://tables.kaysir.test')),
        throwsFormatException,
      );
      expect(
        () => builder.decodeUri(
          Uri.parse('https://tables.kaysir.test?payload=not-a-payload'),
        ),
        throwsFormatException,
      );
      expect(
        () => builder.decodeUri(
          expiredUri,
          now: DateTime.utc(2026, 6, 10, 12, 1),
        ),
        throwsFormatException,
      );
    },
  );
}
