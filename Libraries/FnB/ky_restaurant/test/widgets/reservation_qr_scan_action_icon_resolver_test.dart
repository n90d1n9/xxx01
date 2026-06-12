import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('reservation QR scan action icon resolver maps command icons', () {
    const resolver = RestaurantReservationQrScanActionIconResolver();

    expect(
      resolver.iconFor(RestaurantReservationQrScanAction.createBooking),
      Icons.event_available_outlined,
    );
    expect(
      resolver.iconFor(RestaurantReservationQrScanAction.joinWaitlist),
      Icons.playlist_add,
    );
    expect(
      resolver.iconFor(RestaurantReservationQrScanAction.confirmCheckIn),
      Icons.login_rounded,
    );
    expect(
      resolver.iconFor(RestaurantReservationQrScanAction.refreshLink),
      Icons.refresh_rounded,
    );
    expect(
      resolver.iconFor(RestaurantReservationQrScanAction.dismiss),
      Icons.close_rounded,
    );
  });

  test(
    'reservation QR scan action icon resolver maps selected notice icons',
    () {
      const resolver = RestaurantReservationQrScanActionIconResolver();

      expect(
        resolver.iconFor(
          RestaurantReservationQrScanAction.confirmCheckIn,
          variant: RestaurantReservationQrScanActionIconVariant.selectedNotice,
        ),
        Icons.assignment_turned_in_outlined,
      );
    },
  );
}
