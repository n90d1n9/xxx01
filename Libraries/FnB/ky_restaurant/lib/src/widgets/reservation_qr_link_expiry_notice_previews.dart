import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/reservation_qr_expiry_status.dart';
import 'reservation_qr_link_expiry_notice.dart';

/// Preview entry for reservation QR link expiry recovery guidance.
@Preview(name: 'Reservation QR Link Expiry Notice', group: 'Restaurant')
Widget restaurantReservationQrLinkExpiryNoticePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationQrLinkExpiryNotice(
          status: const RestaurantReservationQrExpiryStatus(
            urgency: RestaurantReservationQrExpiryUrgency.expiringSoon,
            label: 'Expires in 4 min',
          ),
          onRefresh: () {},
        ),
      ),
    ),
  );
}
