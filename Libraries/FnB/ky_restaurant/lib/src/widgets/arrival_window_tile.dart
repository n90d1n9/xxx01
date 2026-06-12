import 'package:flutter/material.dart';

import '../models/restaurant_reservation_arrival_window.dart';
import 'restaurant_interactive_surface.dart';
import 'restaurant_status_styles.dart';

/// Displays one reservation arrival window with booking count and selection state.
class RestaurantReservationArrivalWindowTile extends StatelessWidget {
  const RestaurantReservationArrivalWindowTile({
    super.key,
    required this.window,
    required this.isSelected,
    this.onSelected,
    this.width,
  });

  final RestaurantReservationArrivalWindow window;
  final bool isSelected;
  final VoidCallback? onSelected;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = restaurantStatusStyle(colors, window.kind.serviceStatus);
    final backgroundColor = window.hasReservations
        ? style.background
        : colors.surface.withValues(alpha: .72);
    final foregroundColor = window.hasReservations
        ? style.foreground
        : colors.onSurfaceVariant;
    final borderColor = window.hasReservations
        ? style.foreground.withValues(alpha: .22)
        : colors.outlineVariant.withValues(alpha: .5);

    return SizedBox(
      width: width,
      child: RestaurantInteractiveSurface(
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        isSelected: isSelected,
        tooltip: onSelected == null
            ? window.kind.label
            : 'Show ${window.kind.targetFilter.label.toLowerCase()} reservations',
        onPressed: onSelected,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _iconForKind(window.kind),
                    color: foregroundColor,
                    size: 18,
                  ),
                  const Spacer(),
                  Text(
                    window.count.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                window.kind.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                window.kind.detailLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                window.coverLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconForKind(RestaurantReservationArrivalWindowKind kind) {
  return switch (kind) {
    RestaurantReservationArrivalWindowKind.late => Icons.warning_amber_rounded,
    RestaurantReservationArrivalWindowKind.dueNow => Icons.timer_outlined,
    RestaurantReservationArrivalWindowKind.upcoming =>
      Icons.event_available_outlined,
    RestaurantReservationArrivalWindowKind.inHouse => Icons.event_seat_outlined,
    RestaurantReservationArrivalWindowKind.closed => Icons.task_alt_rounded,
  };
}
