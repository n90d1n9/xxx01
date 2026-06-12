import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/reservation_qr_scan_action_plan.dart';
import 'reservation_qr_scan_action_bar.dart';

/// Preview entry for QR scan action hierarchy.
@Preview(name: 'Reservation QR Scan Action Bar', group: 'Restaurant')
Widget restaurantReservationQrScanActionBarPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationQrScanActionBar(
          plan: const RestaurantReservationQrScanActionPlan(
            primaryAction: RestaurantReservationQrScanAction.confirmCheckIn,
            secondaryActions: [RestaurantReservationQrScanAction.dismiss],
          ),
          onActionSelected: (_) {},
        ),
      ),
    ),
  );
}
