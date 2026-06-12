/// Describes how urgent a reservation QR link expiry is for hosts.
enum RestaurantReservationQrExpiryUrgency { fresh, expiringSoon, expired }

/// Carries relative expiry copy for reservation QR handoff surfaces.
class RestaurantReservationQrExpiryStatus {
  const RestaurantReservationQrExpiryStatus({
    required this.urgency,
    required this.label,
  });

  final RestaurantReservationQrExpiryUrgency urgency;
  final String label;

  bool get isFresh => urgency == RestaurantReservationQrExpiryUrgency.fresh;

  bool get isExpiringSoon {
    return urgency == RestaurantReservationQrExpiryUrgency.expiringSoon;
  }

  bool get isExpired => urgency == RestaurantReservationQrExpiryUrgency.expired;
}
