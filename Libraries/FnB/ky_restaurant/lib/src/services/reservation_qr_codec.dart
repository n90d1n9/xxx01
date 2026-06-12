import 'dart:convert';

import '../models/reservation_qr_payload.dart';

/// Encodes and decodes reservation QR payloads without choosing a QR package.
class RestaurantReservationQrCodec {
  const RestaurantReservationQrCodec();

  String encode(RestaurantReservationQrPayload payload) {
    return jsonEncode(payload.toJson());
  }

  RestaurantReservationQrPayload decode(String value, {DateTime? now}) {
    final decoded = jsonDecode(value);
    if (decoded is! Map) {
      throw const FormatException('Reservation QR payload must be an object.');
    }

    final payload = RestaurantReservationQrPayload.fromJson(
      Map<String, Object?>.from(decoded),
    );
    if (now != null && payload.isExpiredAt(now)) {
      throw const FormatException('Reservation QR code has expired.');
    }

    return payload;
  }
}
