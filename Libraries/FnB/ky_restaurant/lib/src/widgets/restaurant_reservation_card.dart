import 'package:flutter/material.dart';

import '../models/reservation_status_action_confirmation.dart';
import '../models/reservation_status_timeline.dart';
import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_communication.dart';
import '../models/restaurant_reservation_status_action.dart';
import '../services/restaurant_reservation_seating_advisor.dart';
import 'reservation_action_bar.dart';
import 'reservation_action_confirmation_dialog.dart';
import 'reservation_signal_strip.dart';
import 'restaurant_card_header.dart';
import 'restaurant_reservation_communication_bar.dart';
import 'restaurant_reservation_seating_strip.dart';
import 'reservation_status_timeline.dart';
import 'restaurant_status_card_surface.dart';
import 'restaurant_status_styles.dart';

/// Displays one reservation row with guest context, signals, and status actions.
class RestaurantReservationCard extends StatelessWidget {
  const RestaurantReservationCard({
    super.key,
    required this.reservation,
    required this.onStatusChanged,
    this.focused = false,
    this.onCommunicationSelected,
    this.actionConfirmationPolicy =
        const RestaurantReservationStatusActionConfirmationPolicy(),
    this.showStatusTimeline = true,
    this.seatingAdvisor = const RestaurantReservationSeatingAdvisor(),
  });

  final RestaurantReservation reservation;
  final void Function(String reservationId, RestaurantReservationStatus status)?
  onStatusChanged;
  final bool focused;
  final ValueChanged<RestaurantReservationCommunicationDraft>?
  onCommunicationSelected;
  final RestaurantReservationStatusActionConfirmationPolicy
  actionConfirmationPolicy;
  final bool showStatusTimeline;
  final RestaurantReservationSeatingAdvisor seatingAdvisor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final serviceStatus = reservation.status.serviceStatus;
    final statusStyle = restaurantStatusStyle(colors, serviceStatus);

    return Semantics(
      container: true,
      selected: focused,
      label:
          '${reservation.guestName}, ${reservation.partyLabel}, '
          '${reservation.timeLabel}, ${reservation.status.label}',
      child: RestaurantStatusCardSurface(
        statusStyle: statusStyle,
        isFocused: focused,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantCardHeader(
              icon: statusStyle.icon,
              foregroundColor: statusStyle.foreground,
              backgroundColor: statusStyle.background,
              title: reservation.guestName,
              subtitle:
                  '${reservation.timeLabel} - ${reservation.seatingLabel}',
              trailing: RestaurantStatusPill(
                status: serviceStatus,
                label: reservation.status.label,
                compact: true,
              ),
            ),
            const SizedBox(height: 12),
            RestaurantReservationSignalStrip(
              reservation: reservation,
              statusStyle: statusStyle,
            ),
            if (showStatusTimeline) ...[
              const SizedBox(height: 10),
              RestaurantReservationStatusTimeline(
                timeline:
                    RestaurantReservationStatusTimelineData.fromReservation(
                      reservation,
                    ),
              ),
            ],
            const SizedBox(height: 10),
            RestaurantReservationSeatingStrip(
              reservation: reservation,
              advisor: seatingAdvisor,
            ),
            if (reservation.notes case final notes?) ...[
              const SizedBox(height: 10),
              Text(
                notes,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            if (onCommunicationSelected != null) ...[
              const SizedBox(height: 12),
              RestaurantReservationCommunicationBar(
                reservation: reservation,
                onDraftSelected: onCommunicationSelected!,
              ),
            ],
            if (onStatusChanged != null &&
                reservation.status.nextActions.isNotEmpty) ...[
              const SizedBox(height: 12),
              RestaurantReservationActionBar(
                actions: reservation.status.nextActions,
                onActionSelected: (action) =>
                    _handleStatusAction(context, action),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleStatusAction(
    BuildContext context,
    RestaurantReservationStatusAction action,
  ) async {
    final confirmation = actionConfirmationPolicy.confirmationFor(
      reservation: reservation,
      action: action,
    );

    if (confirmation != null) {
      final confirmed = await showRestaurantReservationActionConfirmationDialog(
        context: context,
        confirmation: confirmation,
      );
      if (!context.mounted || !confirmed) return;
    }

    onStatusChanged?.call(reservation.id, action.targetStatus);
  }
}
