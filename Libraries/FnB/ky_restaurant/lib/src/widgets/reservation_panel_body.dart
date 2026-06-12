import 'package:flutter/material.dart';

import '../models/reservation_intake_action.dart';
import '../models/reservation_status_action_confirmation.dart';
import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_action_queue.dart';
import '../models/restaurant_reservation_arrival_window.dart';
import '../models/restaurant_reservation_communication.dart';
import '../models/restaurant_reservation_filter.dart';
import '../models/restaurant_reservation_panel_data.dart';
import '../models/restaurant_reservation_seating_assessment.dart';
import '../models/restaurant_reservation_zone_load.dart';
import '../services/restaurant_reservation_seating_advisor.dart';
import 'filtered_panel_body.dart';
import 'reservation_controls_section.dart';
import 'reservation_qr_panel_binding.dart';
import 'reservation_results_section.dart';
import 'restaurant_empty_state.dart';

/// Builds the reservation panel body from reservation presentation data.
class RestaurantReservationPanelBody extends StatelessWidget {
  const RestaurantReservationPanelBody({
    super.key,
    required this.data,
    required this.onActionBucketSelected,
    required this.onArrivalWindowSelected,
    required this.onSeatingBucketSelected,
    required this.onZoneSelected,
    required this.onFilterChanged,
    required this.onSearchQueryChanged,
    required this.onClearSearch,
    required this.onShowAll,
    this.onIntakeActionSelected,
    this.qrPanelBinding,
    this.qrScanEntry,
    this.qrSessionPanel,
    this.onStatusChanged,
    this.onCommunicationSelected,
    this.focusedReservationId,
    this.actionConfirmationPolicy =
        const RestaurantReservationStatusActionConfirmationPolicy(),
    this.seatingAdvisor = const RestaurantReservationSeatingAdvisor(),
  });

  final RestaurantReservationPanelData data;
  final ValueChanged<RestaurantReservationActionBucketKind>
  onActionBucketSelected;
  final ValueChanged<RestaurantReservationArrivalWindowKind>
  onArrivalWindowSelected;
  final ValueChanged<RestaurantReservationSeatingReadiness>
  onSeatingBucketSelected;
  final ValueChanged<RestaurantReservationZoneLoad> onZoneSelected;
  final ValueChanged<RestaurantReservationFilter> onFilterChanged;
  final ValueChanged<String> onSearchQueryChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onShowAll;
  final ValueChanged<RestaurantReservationIntakeAction>? onIntakeActionSelected;
  final RestaurantReservationQrPanelBinding? qrPanelBinding;
  final Widget? qrScanEntry;
  final Widget? qrSessionPanel;
  final void Function(String reservationId, RestaurantReservationStatus status)?
  onStatusChanged;
  final ValueChanged<RestaurantReservationCommunicationDraft>?
  onCommunicationSelected;
  final String? focusedReservationId;
  final RestaurantReservationStatusActionConfirmationPolicy
  actionConfirmationPolicy;
  final RestaurantReservationSeatingAdvisor seatingAdvisor;

  @override
  Widget build(BuildContext context) {
    return RestaurantFilteredPanelBody(
      hasItems: data.hasReservations,
      hasVisibleItems: data.hasVisibleReservations,
      emptyState: const RestaurantEmptyState(
        icon: Icons.event_available_outlined,
        message: 'Reservations will appear here for today\'s service.',
      ),
      controls: RestaurantReservationControlsSection(
        data: data,
        onActionBucketSelected: onActionBucketSelected,
        onArrivalWindowSelected: onArrivalWindowSelected,
        onSeatingBucketSelected: onSeatingBucketSelected,
        onZoneSelected: onZoneSelected,
        onFilterChanged: onFilterChanged,
        onSearchQueryChanged: onSearchQueryChanged,
        onIntakeActionSelected: onIntakeActionSelected,
        qrPanelBinding: qrPanelBinding,
        qrScanEntry: qrScanEntry,
        qrSessionPanel: qrSessionPanel,
      ),
      emptyResultsState: RestaurantEmptyState(
        icon: data.hasSearch
            ? Icons.search_off_rounded
            : Icons.event_busy_outlined,
        message: data.hasSearch
            ? 'No reservations match "${data.searchQuery}".'
            : 'No ${data.selectedFilter.label.toLowerCase()} reservations right now.',
        actionLabel: data.hasSearch ? 'Clear search' : 'Show all',
        onAction: data.hasSearch ? onClearSearch : onShowAll,
      ),
      results: RestaurantReservationResultsSection(
        priorityQueue: data.priorityQueue,
        reservations: data.visibleReservations,
        onStatusChanged: onStatusChanged,
        onCommunicationSelected: onCommunicationSelected,
        focusedReservationId: focusedReservationId,
        actionConfirmationPolicy: actionConfirmationPolicy,
        seatingAdvisor: seatingAdvisor,
      ),
    );
  }
}
