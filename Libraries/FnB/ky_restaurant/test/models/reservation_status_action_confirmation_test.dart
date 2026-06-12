import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';

void main() {
  test('reservation status action confirmation describes no-show risk', () {
    const policy = RestaurantReservationStatusActionConfirmationPolicy();

    final confirmation = policy.confirmationFor(
      reservation: restaurantTestReservations.first,
      action: RestaurantReservationStatusAction.markNoShow,
    );

    expect(confirmation?.action, RestaurantReservationStatusAction.markNoShow);
    expect(confirmation?.title, 'Mark no-show?');
    expect(confirmation?.message, contains('Wijaya Family'));
    expect(confirmation?.message, contains('8 guests'));
    expect(confirmation?.confirmLabel, 'Mark no-show');
    expect(confirmation?.cancelLabel, 'Keep reservation');
  });

  test('reservation status action confirmation skips safe actions', () {
    const policy = RestaurantReservationStatusActionConfirmationPolicy();

    expect(
      policy.confirmationFor(
        reservation: restaurantTestReservations.first,
        action: RestaurantReservationStatusAction.markArrived,
      ),
      isNull,
    );
  });
}
