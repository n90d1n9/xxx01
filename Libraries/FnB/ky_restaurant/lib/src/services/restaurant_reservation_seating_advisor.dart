import '../models/restaurant_models.dart';
import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_seating_assessment.dart';

/// Derives seating-readiness guidance from reservation timing and status.
class RestaurantReservationSeatingAdvisor {
  const RestaurantReservationSeatingAdvisor({
    this.dueSoonMinutes = 15,
    this.largePartySize = 8,
  }) : assert(dueSoonMinutes >= 0),
       assert(largePartySize > 0);

  final int dueSoonMinutes;
  final int largePartySize;

  RestaurantReservationSeatingAssessment assess(
    RestaurantReservation reservation,
  ) {
    final isLargeParty = reservation.partySize >= largePartySize;

    if (reservation.status.isClosed) {
      return RestaurantReservationSeatingAssessment(
        readiness: RestaurantReservationSeatingReadiness.closed,
        label: 'Closed',
        detail: '${reservation.status.label} reservation.',
        serviceStatus: RestaurantServiceStatus.calm,
        isLargeParty: isLargeParty,
      );
    }

    if (reservation.needsLateRecovery) {
      return RestaurantReservationSeatingAssessment(
        readiness: RestaurantReservationSeatingReadiness.recoverArrival,
        label: 'Recover arrival',
        detail: '${reservation.arrivalMinutesFromNow.abs()}m late.',
        serviceStatus: RestaurantServiceStatus.critical,
        isLargeParty: isLargeParty,
      );
    }

    return switch (reservation.status) {
      RestaurantReservationStatus.requested =>
        RestaurantReservationSeatingAssessment(
          readiness: RestaurantReservationSeatingReadiness.confirmRequest,
          label: 'Confirm request',
          detail: 'Guest request needs confirmation.',
          serviceStatus: RestaurantServiceStatus.busy,
          isLargeParty: isLargeParty,
        ),
      RestaurantReservationStatus.confirmed => _confirmedAssessment(
        reservation,
        isLargeParty,
      ),
      RestaurantReservationStatus.arrived => _arrivedAssessment(
        reservation,
        isLargeParty,
      ),
      RestaurantReservationStatus.seated =>
        RestaurantReservationSeatingAssessment(
          readiness: RestaurantReservationSeatingReadiness.inService,
          label: 'In service',
          detail: 'Guest is already seated.',
          serviceStatus: RestaurantServiceStatus.calm,
          isLargeParty: isLargeParty,
        ),
      RestaurantReservationStatus.completed ||
      RestaurantReservationStatus.cancelled ||
      RestaurantReservationStatus.noShow ||
      RestaurantReservationStatus.late =>
        RestaurantReservationSeatingAssessment(
          readiness: RestaurantReservationSeatingReadiness.closed,
          label: 'Closed',
          detail: '${reservation.status.label} reservation.',
          serviceStatus: RestaurantServiceStatus.calm,
          isLargeParty: isLargeParty,
        ),
    };
  }

  RestaurantReservationSeatingAssessment _confirmedAssessment(
    RestaurantReservation reservation,
    bool isLargeParty,
  ) {
    if (reservation.arrivalMinutesFromNow <= dueSoonMinutes) {
      return RestaurantReservationSeatingAssessment(
        readiness: RestaurantReservationSeatingReadiness.prepareTable,
        label: 'Prepare table',
        detail: reservation.arrivalMinutesFromNow <= 0
            ? 'Guest is due now.'
            : 'Due in ${reservation.arrivalMinutesFromNow}m.',
        serviceStatus: RestaurantServiceStatus.busy,
        isLargeParty: isLargeParty,
      );
    }

    return RestaurantReservationSeatingAssessment(
      readiness: RestaurantReservationSeatingReadiness.prepareTable,
      label: 'Scheduled',
      detail: 'Due in ${reservation.arrivalMinutesFromNow}m.',
      serviceStatus: RestaurantServiceStatus.calm,
      isLargeParty: isLargeParty,
    );
  }

  RestaurantReservationSeatingAssessment _arrivedAssessment(
    RestaurantReservation reservation,
    bool isLargeParty,
  ) {
    final hasTable =
        reservation.tableLabel != null &&
        reservation.tableLabel!.trim().isNotEmpty;
    if (!hasTable) {
      return RestaurantReservationSeatingAssessment(
        readiness: RestaurantReservationSeatingReadiness.assignTable,
        label: 'Assign table',
        detail: '${reservation.zoneLabel} needs a table.',
        serviceStatus: RestaurantServiceStatus.blocked,
        isLargeParty: isLargeParty,
      );
    }

    return RestaurantReservationSeatingAssessment(
      readiness: RestaurantReservationSeatingReadiness.readyToSeat,
      label: 'Ready to seat',
      detail: reservation.seatingLabel,
      serviceStatus: RestaurantServiceStatus.calm,
      isLargeParty: isLargeParty,
    );
  }
}
