import 'package:flutter/material.dart';

import '../models/restaurant_reservation_action_queue.dart';
import 'restaurant_interactive_surface.dart';
import 'restaurant_status_styles.dart';

/// Displays one reservation action bucket with count, status, and selection state.
class RestaurantReservationActionBucketTile extends StatelessWidget {
  const RestaurantReservationActionBucketTile({
    super.key,
    required this.bucket,
    required this.isSelected,
    this.onSelected,
    this.width = 190,
  });

  final RestaurantReservationActionBucket bucket;
  final bool isSelected;
  final VoidCallback? onSelected;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = restaurantStatusStyle(colors, bucket.kind.serviceStatus);
    final foregroundColor = bucket.hasReservations
        ? style.foreground
        : colors.onSurfaceVariant;
    final backgroundColor = bucket.hasReservations
        ? style.background
        : colors.surface.withValues(alpha: .72);
    final borderColor = bucket.hasReservations
        ? style.foreground.withValues(alpha: .22)
        : colors.outlineVariant.withValues(alpha: .5);

    return SizedBox(
      width: width,
      child: RestaurantInteractiveSurface(
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        isSelected: isSelected,
        tooltip: onSelected == null
            ? bucket.kind.label
            : 'Show ${bucket.kind.label.toLowerCase()} reservations',
        onPressed: onSelected,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _iconForKind(bucket.kind),
                    color: foregroundColor,
                    size: 18,
                  ),
                  const Spacer(),
                  Text(
                    bucket.count.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                bucket.kind.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                bucket.kind.detailLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bucket.kind.actionLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                bucket.coverLabel,
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

IconData _iconForKind(RestaurantReservationActionBucketKind kind) {
  return switch (kind) {
    RestaurantReservationActionBucketKind.confirmRequests =>
      Icons.fact_check_outlined,
    RestaurantReservationActionBucketKind.recoverLate =>
      Icons.warning_amber_rounded,
    RestaurantReservationActionBucketKind.greetDue => Icons.login_rounded,
    RestaurantReservationActionBucketKind.seatArrivals =>
      Icons.event_seat_outlined,
    RestaurantReservationActionBucketKind.closeSeated => Icons.done_all_rounded,
  };
}
