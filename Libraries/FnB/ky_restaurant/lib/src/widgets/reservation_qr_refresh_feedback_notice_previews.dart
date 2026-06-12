import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/reservation_intake_action.dart';
import '../models/reservation_qr_link.dart';
import '../models/reservation_qr_payload.dart';
import 'reservation_qr_refresh_feedback_notice.dart';

/// Preview entry for QR handoff refresh feedback.
@Preview(name: 'Reservation QR Refresh Feedback', group: 'Restaurant')
Widget restaurantReservationQrRefreshFeedbackNoticePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationQrRefreshFeedbackNotice(
          link: RestaurantReservationQrLink(
            action: RestaurantReservationIntakeAction.qrWaitlist,
            payload: RestaurantReservationQrPayload(
              token: 'preview-token',
              intent: RestaurantReservationQrIntent.waitlist,
              expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
              zoneLabel: 'Terrace',
              tableLabel: 'Table 21',
            ),
            uri: Uri.parse(
              'https://tables.kaysir.test/restaurant/reservations/qr?payload=preview',
            ),
            createdAt: DateTime.utc(2026, 6, 10, 13),
          ),
          onDismiss: () {},
        ),
      ),
    ),
  );
}
