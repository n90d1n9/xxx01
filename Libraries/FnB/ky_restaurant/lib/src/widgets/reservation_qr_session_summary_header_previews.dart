import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/reservation_qr_session_summary.dart';
import 'reservation_qr_session_summary_header.dart';

/// Preview entry for the compact reservation QR session summary header.
@Preview(name: 'Reservation QR Session Summary Header', group: 'Restaurant')
Widget restaurantReservationQrSessionSummaryHeaderPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: RestaurantReservationQrSessionSummaryHeader(
          summary: RestaurantReservationQrSessionSummaryPresentation(
            title: 'QR scan ready',
            message: 'Check in is ready to continue.',
            tone: RestaurantReservationQrSessionSummaryTone.success,
            metrics: [
              RestaurantReservationQrSessionSummaryMetric(
                label: 'Link',
                value: 'Check in',
              ),
              RestaurantReservationQrSessionSummaryMetric(
                label: 'Scan',
                value: 'QR link ready',
              ),
              RestaurantReservationQrSessionSummaryMetric(
                label: 'Events',
                value: '3 events',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
