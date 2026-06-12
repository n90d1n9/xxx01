import '../models/reservation_intake_action.dart';
import '../models/reservation_qr_payload.dart';

/// Builds QR payloads from reservation intake actions without coupling widgets to encoding.
class RestaurantReservationQrPayloadBuilder {
  const RestaurantReservationQrPayloadBuilder();

  RestaurantReservationQrPayload buildForAction({
    required RestaurantReservationIntakeAction action,
    required String token,
    required DateTime expiresAt,
    String? reservationId,
    String? zoneLabel,
    String? tableLabel,
  }) {
    final intent = action.qrIntent;
    if (intent == null) {
      throw ArgumentError.value(
        action,
        'action',
        'Action does not create a reservation QR payload.',
      );
    }

    return RestaurantReservationQrPayload(
      token: token,
      intent: intent,
      expiresAt: expiresAt,
      reservationId: reservationId,
      zoneLabel: zoneLabel,
      tableLabel: tableLabel,
    );
  }
}
