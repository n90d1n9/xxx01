import 'package:flutter/material.dart';

import '../models/reservation_qr_scan_action_plan.dart';

/// Identifies where a reservation QR scan action icon is being rendered.
enum RestaurantReservationQrScanActionIconVariant { command, selectedNotice }

/// Resolves Material icons for reservation QR scan actions.
class RestaurantReservationQrScanActionIconResolver {
  const RestaurantReservationQrScanActionIconResolver();

  IconData iconFor(
    RestaurantReservationQrScanAction action, {
    RestaurantReservationQrScanActionIconVariant variant =
        RestaurantReservationQrScanActionIconVariant.command,
  }) {
    return switch (action) {
      RestaurantReservationQrScanAction.createBooking =>
        Icons.event_available_outlined,
      RestaurantReservationQrScanAction.joinWaitlist => Icons.playlist_add,
      RestaurantReservationQrScanAction.confirmCheckIn =>
        _confirmCheckInIconFor(variant),
      RestaurantReservationQrScanAction.refreshLink => Icons.refresh_rounded,
      RestaurantReservationQrScanAction.dismiss => Icons.close_rounded,
    };
  }

  IconData _confirmCheckInIconFor(
    RestaurantReservationQrScanActionIconVariant variant,
  ) {
    return switch (variant) {
      RestaurantReservationQrScanActionIconVariant.command =>
        Icons.login_rounded,
      RestaurantReservationQrScanActionIconVariant.selectedNotice =>
        Icons.assignment_turned_in_outlined,
    };
  }
}
