import 'package:flutter/material.dart';

import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_status_action.dart';
import 'restaurant_signal_chip.dart';
import 'restaurant_status_styles.dart';

/// Displays compact guest, arrival, source, table, and VIP reservation signals.
class RestaurantReservationSignalStrip extends StatelessWidget {
  const RestaurantReservationSignalStrip({
    super.key,
    required this.reservation,
    this.statusStyle,
  });

  final RestaurantReservation reservation;
  final RestaurantStatusStyle? statusStyle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final effectiveStatusStyle =
        statusStyle ??
        restaurantStatusStyle(colors, reservation.status.serviceStatus);
    final arrivalLabel = _arrivalLabel(reservation.arrivalMinutesFromNow);
    final isLate =
        reservation.arrivalMinutesFromNow < 0 ||
        reservation.status == RestaurantReservationStatus.late;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        RestaurantSignalChip(
          icon: Icons.groups_2_outlined,
          label: reservation.partyLabel,
        ),
        RestaurantSignalChip(
          icon: Icons.schedule_outlined,
          label: arrivalLabel,
          foregroundColor: isLate ? effectiveStatusStyle.foreground : null,
          backgroundColor: isLate
              ? effectiveStatusStyle.background
              : colors.surfaceContainerHighest.withValues(alpha: .46),
        ),
        RestaurantSignalChip(
          icon: Icons.source_outlined,
          label: reservation.source.label,
        ),
        if (reservation.tableLabel case final tableLabel?
            when tableLabel.trim().isNotEmpty)
          RestaurantSignalChip(
            icon: Icons.event_seat_outlined,
            label: tableLabel.trim(),
          ),
        if (reservation.isVip)
          RestaurantSignalChip(
            icon: Icons.stars_outlined,
            label: 'VIP',
            foregroundColor: const Color(0xFF8A5A00),
            backgroundColor: const Color(0xFFFFF3D6),
          ),
      ],
    );
  }
}

String _arrivalLabel(int minutesFromNow) {
  if (minutesFromNow == 0) return 'Now';
  if (minutesFromNow < 0) return '${minutesFromNow.abs()}m late';
  return '${minutesFromNow}m';
}
