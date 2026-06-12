import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR expiry status presenter describes fresh links', () {
    const presenter = RestaurantReservationQrExpiryStatusPresenter();
    final now = DateTime.utc(2026, 6, 10, 13);

    final status = presenter.build(
      expiresAt: now.add(const Duration(minutes: 12)),
      now: now,
    );

    expect(status.urgency, RestaurantReservationQrExpiryUrgency.fresh);
    expect(status.label, 'Expires in 12 min');
    expect(status.isFresh, isTrue);
  });

  test('reservation QR expiry status presenter warns inside threshold', () {
    const presenter = RestaurantReservationQrExpiryStatusPresenter();
    final now = DateTime.utc(2026, 6, 10, 13);

    final status = presenter.build(
      expiresAt: now.add(const Duration(minutes: 4, seconds: 30)),
      now: now,
    );

    expect(status.urgency, RestaurantReservationQrExpiryUrgency.expiringSoon);
    expect(status.label, 'Expires in 5 min');
    expect(status.isExpiringSoon, isTrue);
  });

  test('reservation QR expiry status presenter describes expired links', () {
    const presenter = RestaurantReservationQrExpiryStatusPresenter();
    final now = DateTime.utc(2026, 6, 10, 13);

    final status = presenter.build(
      expiresAt: now.subtract(const Duration(minutes: 2)),
      now: now,
    );

    expect(status.urgency, RestaurantReservationQrExpiryUrgency.expired);
    expect(status.label, 'Expired 2 min ago');
    expect(status.isExpired, isTrue);
  });
}
