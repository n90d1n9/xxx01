import '../controllers/reservation_qr_session_controller.dart';
import '../models/reservation_intake_action.dart';
import '../models/reservation_qr_intake_launch_config.dart';
import '../models/reservation_qr_link.dart';

/// Launches QR-capable reservation intake actions into a QR session controller.
class RestaurantReservationQrIntakeLauncher {
  const RestaurantReservationQrIntakeLauncher({
    required this.controller,
    required this.config,
  });

  final RestaurantReservationQrSessionController controller;
  final RestaurantReservationQrIntakeLaunchConfig config;

  bool canLaunch(RestaurantReservationIntakeAction action) {
    return action.usesQrCode;
  }

  RestaurantReservationQrLink launch(
    RestaurantReservationIntakeAction action, {
    RestaurantReservationQrIntakeLaunchConfig? config,
  }) {
    if (!canLaunch(action)) {
      throw ArgumentError.value(
        action,
        'action',
        'Reservation intake action must use a QR code.',
      );
    }

    final effectiveConfig = config ?? this.config;
    return controller.generateLink(
      action: action,
      baseUri: effectiveConfig.baseUri,
      lifetime: effectiveConfig.lifetime,
      reservationId: effectiveConfig.reservationId,
      zoneLabel: effectiveConfig.zoneLabel,
      tableLabel: effectiveConfig.tableLabel,
      queryParameters: effectiveConfig.queryParameters,
    );
  }

  RestaurantReservationQrLink? tryLaunch(
    RestaurantReservationIntakeAction action, {
    RestaurantReservationQrIntakeLaunchConfig? config,
  }) {
    if (!canLaunch(action)) return null;
    return launch(action, config: config);
  }
}
