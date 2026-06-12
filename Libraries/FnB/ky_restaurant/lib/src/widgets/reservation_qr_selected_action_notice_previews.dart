import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/reservation_qr_scan_action_plan.dart';
import 'reservation_qr_selected_action_notice.dart';

/// Preview entry for the reservation QR selected action notice.
@Preview(name: 'Reservation QR Selected Action', group: 'Restaurant')
Widget restaurantReservationQrSelectedActionNoticePreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: RestaurantReservationQrSelectedActionNotice(
          action: RestaurantReservationQrScanAction.confirmCheckIn,
        ),
      ),
    ),
  );
}
