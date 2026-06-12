import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/reservation_qr_scan_guidance.dart';
import 'reservation_qr_scan_guidance_notice.dart';

/// Preview entry for QR scan host guidance.
@Preview(name: 'Reservation QR Scan Guidance', group: 'Restaurant')
Widget restaurantReservationQrScanGuidancePreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: RestaurantReservationQrScanGuidanceNotice(
          guidance: RestaurantReservationQrScanGuidance(
            title: 'Generate a fresh QR',
            message:
                'This link expired at 19:15. Refresh it before continuing.',
            tone: RestaurantReservationQrScanGuidanceTone.warning,
          ),
        ),
      ),
    ),
  );
}
