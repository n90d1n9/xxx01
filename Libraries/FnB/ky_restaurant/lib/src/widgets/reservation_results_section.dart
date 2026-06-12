import 'package:flutter/material.dart';

import '../models/reservation_status_action_confirmation.dart';
import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_communication.dart';
import '../models/restaurant_reservation_priority_queue.dart';
import '../services/restaurant_reservation_seating_advisor.dart';
import 'restaurant_reservation_list.dart';
import 'restaurant_reservation_next_up_list.dart';

/// Displays prioritized reservation actions with the matching reservation cards.
class RestaurantReservationResultsSection extends StatelessWidget {
  const RestaurantReservationResultsSection({
    super.key,
    required this.priorityQueue,
    required this.reservations,
    required this.onStatusChanged,
    this.focusedReservationId,
    this.onCommunicationSelected,
    this.actionConfirmationPolicy =
        const RestaurantReservationStatusActionConfirmationPolicy(),
    this.seatingAdvisor = const RestaurantReservationSeatingAdvisor(),
  });

  final RestaurantReservationPriorityQueue priorityQueue;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RestaurantReservationNextUpList(queue: priorityQueue),
        const SizedBox(height: 16),
        RestaurantReservationList(
          reservations: reservations,
          onStatusChanged: onStatusChanged,
          focusedReservationId: focusedReservationId,
          onCommunicationSelected: onCommunicationSelected,
          actionConfirmationPolicy: actionConfirmationPolicy,
          seatingAdvisor: seatingAdvisor,
        ),
      ],
    );
  }
}
