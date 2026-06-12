import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

/// Builds the accessible tooltip copy for a reservation QR scan action.
String reservationQrScanActionTooltip(
  RestaurantReservationQrScanAction action,
) {
  return const RestaurantReservationQrScanActionPresenter()
      .build(action)
      .tooltipLabel;
}

/// Finds the accessible action button for a reservation QR scan action.
Finder findReservationQrScanAction(RestaurantReservationQrScanAction action) {
  return find.byTooltip(reservationQrScanActionTooltip(action));
}
