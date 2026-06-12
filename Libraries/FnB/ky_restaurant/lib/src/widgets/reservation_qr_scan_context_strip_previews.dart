import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/reservation_qr_payload.dart';
import '../models/reservation_qr_scan_result.dart';
import 'reservation_qr_scan_context_strip.dart';

/// Preview entry for resolved reservation QR scan context.
@Preview(name: 'Reservation QR Scan Context', group: 'Restaurant')
Widget restaurantReservationQrScanContextStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationQrScanContextStrip(
          result: RestaurantReservationQrScanResult.valid(
            uri: Uri.parse(
              'https://tables.kaysir.test/restaurant/reservations/qr',
            ),
            payload: RestaurantReservationQrPayload(
              token: 'preview-token',
              intent: RestaurantReservationQrIntent.checkIn,
              expiresAt: DateTime.utc(2026, 6, 10, 12, 30),
              reservationId: 'RSV-42',
              zoneLabel: 'Main Floor',
              tableLabel: 'Table 8',
            ),
            scannedAt: DateTime.utc(2026, 6, 10, 12),
          ),
        ),
      ),
    ),
  );
}
