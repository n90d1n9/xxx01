import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR link composer creates tokenized scan links', () {
    final now = DateTime.utc(2026, 6, 10, 12);
    final composer = RestaurantReservationQrLinkComposer(
      clock: () => now,
      tokenFactory: () => 'stable-token',
    );

    final link = composer.composeForAction(
      action: RestaurantReservationIntakeAction.qrBooking,
      baseUri: Uri.parse('https://tables.kaysir.test/tenant/demo?lang=en'),
      lifetime: const Duration(minutes: 10),
      zoneLabel: 'Terrace',
      tableLabel: 'Table 21',
      queryParameters: const {'source': 'host-console'},
    );

    expect(link.action, RestaurantReservationIntakeAction.qrBooking);
    expect(link.createdAt, now);
    expect(link.payload.token, 'stable-token');
    expect(link.payload.intent, RestaurantReservationQrIntent.booking);
    expect(link.payload.expiresAt, DateTime.utc(2026, 6, 10, 12, 10));
    expect(link.payload.zoneLabel, 'Terrace');
    expect(link.payload.tableLabel, 'Table 21');
    expect(link.uri.path, '/tenant/demo/restaurant/reservations/qr');
    expect(link.uri.queryParameters['lang'], 'en');
    expect(link.uri.queryParameters['source'], 'host-console');
    expect(link.url, link.uri.toString());
    expect(link.isExpiredAt(DateTime.utc(2026, 6, 10, 12, 11)), isTrue);

    final decoded = const RestaurantReservationQrLinkBuilder().decodeUri(
      link.uri,
      now: now,
    );
    expect(decoded.token, 'stable-token');
    expect(decoded.intent, RestaurantReservationQrIntent.booking);
  });

  test(
    'reservation QR link composer validates unsupported actions and lifetime',
    () {
      final composer = RestaurantReservationQrLinkComposer(
        clock: () => DateTime.utc(2026, 6, 10, 12),
        tokenFactory: () => 'stable-token',
      );

      expect(
        () => composer.composeForAction(
          action: RestaurantReservationIntakeAction.phone,
          baseUri: Uri.parse('https://tables.kaysir.test'),
        ),
        throwsArgumentError,
      );
      expect(
        () => composer.composeForAction(
          action: RestaurantReservationIntakeAction.qrWaitlist,
          baseUri: Uri.parse('https://tables.kaysir.test'),
          lifetime: Duration.zero,
        ),
        throwsArgumentError,
      );
    },
  );

  test('reservation QR token generator creates URL-safe opaque tokens', () {
    const generator = RestaurantReservationQrTokenGenerator();

    final token = generator.generate(byteLength: 18);

    expect(token, isNotEmpty);
    expect(token, isNot(contains('=')));
    expect(Uri.encodeComponent(token), token);
    expect(() => generator.generate(byteLength: 0), throwsRangeError);
  });
}
