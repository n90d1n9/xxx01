import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR selected action presenter builds action copy', () {
    const presenter = RestaurantReservationQrSelectedActionPresenter();

    final presentation = presenter.build(
      RestaurantReservationQrScanAction.confirmCheckIn,
    );

    expect(presentation.title, 'Selected action: Confirm check-in');
    expect(
      presentation.message,
      'Confirm the arriving party and mark the reservation as present.',
    );
    expect(
      presentation.semanticsLabel,
      'Selected action: Confirm check-in. '
      'Confirm the arriving party and mark the reservation as present.',
    );
  });

  test('reservation QR selected action presenter supports custom prefixes', () {
    const presenter = RestaurantReservationQrSelectedActionPresenter();

    final presentation = presenter.build(
      RestaurantReservationQrScanAction.refreshLink,
      titlePrefix: 'Queued action',
    );

    expect(presentation.title, 'Queued action: Refresh QR link');
    expect(
      presentation.message,
      'Generate a fresh QR link before the guest scans again.',
    );
  });
}
