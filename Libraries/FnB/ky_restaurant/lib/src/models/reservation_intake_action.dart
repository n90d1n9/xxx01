import 'reservation_qr_payload.dart';
import 'restaurant_reservation.dart';

/// Describes reservation intake alternatives that hosts can offer during service.
enum RestaurantReservationIntakeAction {
  manual,
  phone,
  online,
  qrBooking,
  qrWaitlist,
  qrCheckIn;

  String get label => switch (this) {
    RestaurantReservationIntakeAction.manual => 'Manual',
    RestaurantReservationIntakeAction.phone => 'Phone',
    RestaurantReservationIntakeAction.online => 'Online',
    RestaurantReservationIntakeAction.qrBooking => 'QR booking',
    RestaurantReservationIntakeAction.qrWaitlist => 'QR waitlist',
    RestaurantReservationIntakeAction.qrCheckIn => 'QR check-in',
  };

  String get detailLabel => switch (this) {
    RestaurantReservationIntakeAction.manual => 'Host creates a booking',
    RestaurantReservationIntakeAction.phone => 'Log a call-in party',
    RestaurantReservationIntakeAction.online => 'Open external booking flow',
    RestaurantReservationIntakeAction.qrBooking => 'Guest scans to reserve',
    RestaurantReservationIntakeAction.qrWaitlist => 'Guest joins the waitlist',
    RestaurantReservationIntakeAction.qrCheckIn => 'Scan guest arrival code',
  };

  RestaurantReservationSource? get source => switch (this) {
    RestaurantReservationIntakeAction.phone =>
      RestaurantReservationSource.phone,
    RestaurantReservationIntakeAction.online =>
      RestaurantReservationSource.online,
    RestaurantReservationIntakeAction.qrBooking ||
    RestaurantReservationIntakeAction.qrWaitlist ||
    RestaurantReservationIntakeAction.qrCheckIn =>
      RestaurantReservationSource.qrCode,
    RestaurantReservationIntakeAction.manual => null,
  };

  RestaurantReservationQrIntent? get qrIntent => switch (this) {
    RestaurantReservationIntakeAction.qrBooking =>
      RestaurantReservationQrIntent.booking,
    RestaurantReservationIntakeAction.qrWaitlist =>
      RestaurantReservationQrIntent.waitlist,
    RestaurantReservationIntakeAction.qrCheckIn =>
      RestaurantReservationQrIntent.checkIn,
    RestaurantReservationIntakeAction.manual ||
    RestaurantReservationIntakeAction.phone ||
    RestaurantReservationIntakeAction.online => null,
  };

  bool get usesQrCode => qrIntent != null;
}
