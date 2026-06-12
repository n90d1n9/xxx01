import 'package:flutter/material.dart';

import '../models/reservation_status_action_confirmation.dart';
import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_communication.dart';
import '../services/restaurant_reservation_seating_advisor.dart';
import 'restaurant_reservation_card.dart';
import 'restaurant_spaced_list.dart';

/// Displays reservation cards with consistent spacing and status actions.
class RestaurantReservationList extends StatelessWidget {
  const RestaurantReservationList({
    super.key,
    required this.reservations,
    required this.onStatusChanged,
    this.focusedReservationId,
    this.onCommunicationSelected,
    this.actionConfirmationPolicy =
        const RestaurantReservationStatusActionConfirmationPolicy(),
    this.seatingAdvisor = const RestaurantReservationSeatingAdvisor(),
  });

  final List<RestaurantReservation> reservations;
  final void Function(String reservationId, RestaurantReservationStatus status)?
  onStatusChanged;
  final String? focusedReservationId;
  final ValueChanged<RestaurantReservationCommunicationDraft>?
  onCommunicationSelected;
  final RestaurantReservationStatusActionConfirmationPolicy
  actionConfirmationPolicy;
  final RestaurantReservationSeatingAdvisor seatingAdvisor;

  @override
  Widget build(BuildContext context) {
    return RestaurantSpacedList<RestaurantReservation>(
      items: reservations,
      itemBuilder: (context, reservation, index) {
        return RestaurantReservationCard(
          reservation: reservation,
          onStatusChanged: onStatusChanged,
          focused: reservation.id == focusedReservationId,
          onCommunicationSelected: onCommunicationSelected,
          actionConfirmationPolicy: actionConfirmationPolicy,
          seatingAdvisor: seatingAdvisor,
        );
      },
    );
  }
}
