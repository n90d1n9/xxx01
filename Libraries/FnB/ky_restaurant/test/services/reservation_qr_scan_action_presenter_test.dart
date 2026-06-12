import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR scan action presenter builds button copy', () {
    const presenter = RestaurantReservationQrScanActionPresenter();

    final presentation = presenter.build(
      RestaurantReservationQrScanAction.confirmCheckIn,
    );

    expect(presentation.label, 'Confirm check-in');
    expect(presentation.detail, 'Confirm the arriving party.');
    expect(
      presentation.tooltipLabel,
      'Confirm check-in. Confirm the arriving party.',
    );
  });

  test('reservation QR scan action presenter describes recovery actions', () {
    const presenter = RestaurantReservationQrScanActionPresenter();

    final refresh = presenter.build(
      RestaurantReservationQrScanAction.refreshLink,
    );
    final dismiss = presenter.build(RestaurantReservationQrScanAction.dismiss);

    expect(refresh.label, 'Refresh QR link');
    expect(refresh.detail, 'Generate a fresh QR link for the guest.');
    expect(
      refresh.tooltipLabel,
      'Refresh QR link. Generate a fresh QR link for the guest.',
    );
    expect(dismiss.label, 'Dismiss');
    expect(dismiss.detail, 'Close the scan result.');
  });
}
