import 'reservation_intake_action.dart';
import 'reservation_qr_payload.dart';

/// Represents a generated reservation QR scan link and its encoded payload.
class RestaurantReservationQrLink {
  const RestaurantReservationQrLink({
    required this.action,
    required this.payload,
    required this.uri,
    required this.createdAt,
  });

  final RestaurantReservationIntakeAction action;
  final RestaurantReservationQrPayload payload;
  final Uri uri;
  final DateTime createdAt;

  String get url => uri.toString();

  bool isExpiredAt(DateTime now) {
    return payload.isExpiredAt(now);
  }
}
