import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR refresh feedback presenter builds context copy', () {
    const presenter = RestaurantReservationQrRefreshFeedbackPresenter();

    final presentation = presenter.build(
      RestaurantReservationQrLink(
        action: RestaurantReservationIntakeAction.qrWaitlist,
        payload: RestaurantReservationQrPayload(
          token: 'qr-token',
          intent: RestaurantReservationQrIntent.waitlist,
          expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
          zoneLabel: 'Terrace',
          tableLabel: 'Table 21',
        ),
        uri: Uri.parse(
          'https://tables.kaysir.test/restaurant/reservations/qr?payload=encoded',
        ),
        createdAt: DateTime.utc(2026, 6, 10, 13),
      ),
    );

    expect(presentation.title, 'Join waitlist QR refreshed');
    expect(
      presentation.message,
      'New handoff link is live for Terrace - Table 21.',
    );
    expect(
      presentation.semanticsLabel,
      'Join waitlist QR refreshed. '
      'New handoff link is live for Terrace - Table 21.',
    );
  });

  test('reservation QR refresh feedback presenter handles bare links', () {
    const presenter = RestaurantReservationQrRefreshFeedbackPresenter();

    final presentation = presenter.build(
      RestaurantReservationQrLink(
        action: RestaurantReservationIntakeAction.qrBooking,
        payload: RestaurantReservationQrPayload(
          token: 'qr-token',
          intent: RestaurantReservationQrIntent.booking,
          expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
        ),
        uri: Uri.parse(
          'https://tables.kaysir.test/restaurant/reservations/qr?payload=encoded',
        ),
        createdAt: DateTime.utc(2026, 6, 10, 13),
      ),
    );

    expect(presentation.title, 'Create booking QR refreshed');
    expect(presentation.message, 'New handoff link is live for the guest.');
  });
}
