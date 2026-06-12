import 'package:flutter/material.dart';

import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_seating_assessment.dart';
import '../services/restaurant_reservation_seating_advisor.dart';
import 'restaurant_signal_chip.dart';
import 'restaurant_status_styles.dart';

/// Displays compact seating-readiness guidance for a reservation card.
class RestaurantReservationSeatingStrip extends StatelessWidget {
  const RestaurantReservationSeatingStrip({
    super.key,
    required this.reservation,
    this.assessment,
    this.advisor = const RestaurantReservationSeatingAdvisor(),
  });

  final RestaurantReservation reservation;
  final RestaurantReservationSeatingAssessment? assessment;
  final RestaurantReservationSeatingAdvisor advisor;

  @override
  Widget build(BuildContext context) {
    final effectiveAssessment = assessment ?? advisor.assess(reservation);
    final colors = Theme.of(context).colorScheme;
    final style = restaurantStatusStyle(
      colors,
      effectiveAssessment.serviceStatus,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        RestaurantSignalChip(
          icon: _iconFor(effectiveAssessment.readiness),
          label: effectiveAssessment.label,
          foregroundColor: style.foreground,
          backgroundColor: style.background,
          borderColor: style.foreground.withValues(alpha: .18),
        ),
        if (effectiveAssessment.isLargeParty)
          RestaurantSignalChip(
            icon: Icons.groups_3_outlined,
            label: 'Large party',
            foregroundColor: colors.tertiary,
            backgroundColor: colors.tertiaryContainer.withValues(alpha: .2),
            borderColor: colors.tertiary.withValues(alpha: .18),
          ),
      ],
    );
  }
}

IconData _iconFor(RestaurantReservationSeatingReadiness readiness) {
  return switch (readiness) {
    RestaurantReservationSeatingReadiness.recoverArrival =>
      Icons.priority_high_rounded,
    RestaurantReservationSeatingReadiness.confirmRequest =>
      Icons.rule_folder_outlined,
    RestaurantReservationSeatingReadiness.prepareTable =>
      Icons.table_restaurant_outlined,
    RestaurantReservationSeatingReadiness.readyToSeat =>
      Icons.event_seat_outlined,
    RestaurantReservationSeatingReadiness.assignTable =>
      Icons.add_location_alt_outlined,
    RestaurantReservationSeatingReadiness.inService =>
      Icons.room_service_outlined,
    RestaurantReservationSeatingReadiness.closed => Icons.done_all_rounded,
  };
}
