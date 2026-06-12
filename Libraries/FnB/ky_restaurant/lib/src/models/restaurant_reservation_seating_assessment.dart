import 'restaurant_models.dart';

/// Identifies the next seating-readiness state for a reservation.
enum RestaurantReservationSeatingReadiness {
  recoverArrival,
  confirmRequest,
  prepareTable,
  readyToSeat,
  assignTable,
  inService,
  closed,
}

/// Summarizes the host-facing seating guidance for one reservation.
class RestaurantReservationSeatingAssessment {
  const RestaurantReservationSeatingAssessment({
    required this.readiness,
    required this.label,
    required this.detail,
    required this.serviceStatus,
    this.isLargeParty = false,
  });

  final RestaurantReservationSeatingReadiness readiness;
  final String label;
  final String detail;
  final RestaurantServiceStatus serviceStatus;
  final bool isLargeParty;

  bool get needsAttention {
    return serviceStatus == RestaurantServiceStatus.busy ||
        serviceStatus == RestaurantServiceStatus.critical ||
        serviceStatus == RestaurantServiceStatus.blocked;
  }
}
