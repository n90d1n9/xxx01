import 'package:flutter/material.dart';

import '../models/reservation_seating_queue.dart';
import '../models/restaurant_reservation_seating_assessment.dart';
import 'restaurant_interactive_surface.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';
import 'restaurant_signal_chip.dart';
import 'restaurant_status_styles.dart';

/// Displays seating-readiness buckets that can focus reservation work.
class RestaurantReservationSeatingQueueStrip extends StatelessWidget {
  const RestaurantReservationSeatingQueueStrip({
    super.key,
    required this.summary,
    this.title = 'Seating readiness',
    this.selectedReadiness,
    this.onBucketSelected,
  });

  final RestaurantReservationSeatingQueueSummary summary;
  final String title;
  final RestaurantReservationSeatingReadiness? selectedReadiness;
  final ValueChanged<RestaurantReservationSeatingReadiness>? onBucketSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      label: _semanticLabel(title, summary),
      child: RestaurantSectionSurface(
        backgroundColor: colors.surfaceContainerHighest.withValues(alpha: .24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantSectionHeader(
              icon: Icons.table_restaurant_outlined,
              title: title,
              trailingLabel: summary.hasActiveReadiness
                  ? summary.activeStateLabel
                  : 'All clear',
            ),
            const SizedBox(height: 12),
            if (summary.hasActiveReadiness)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final bucket in summary.activeBuckets)
                    _ReservationSeatingQueueBucketTile(
                      bucket: bucket,
                      isSelected: bucket.readiness == selectedReadiness,
                      onSelected: onBucketSelected == null
                          ? null
                          : () => onBucketSelected!(bucket.readiness),
                    ),
                ],
              )
            else
              RestaurantSignalChip(
                icon: Icons.task_alt_rounded,
                label: 'No active seating work',
                backgroundColor: colors.surface.withValues(alpha: .72),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReservationSeatingQueueBucketTile extends StatelessWidget {
  const _ReservationSeatingQueueBucketTile({
    required this.bucket,
    required this.isSelected,
    this.onSelected,
  });

  final RestaurantReservationSeatingQueueBucket bucket;
  final bool isSelected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = restaurantStatusStyle(colors, bucket.serviceStatus);

    return SizedBox(
      width: 168,
      child: RestaurantInteractiveSurface(
        backgroundColor: style.background,
        borderColor: style.foreground.withValues(alpha: .2),
        isSelected: isSelected,
        tooltip: onSelected == null
            ? bucket.label
            : 'Show ${bucket.label.toLowerCase()} reservations',
        onPressed: onSelected,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _iconForReadiness(bucket.readiness),
                    color: style.foreground,
                    size: 18,
                  ),
                  const Spacer(),
                  Text(
                    bucket.count.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: style.foreground,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                bucket.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: style.foreground,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                bucket.detailLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
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

IconData _iconForReadiness(RestaurantReservationSeatingReadiness readiness) {
  return switch (readiness) {
    RestaurantReservationSeatingReadiness.recoverArrival =>
      Icons.priority_high_rounded,
    RestaurantReservationSeatingReadiness.confirmRequest =>
      Icons.fact_check_outlined,
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

String _semanticLabel(
  String title,
  RestaurantReservationSeatingQueueSummary summary,
) {
  if (!summary.hasActiveReadiness) {
    return '$title. No active seating work.';
  }

  final bucketLabels = summary.activeBuckets.map(
    (bucket) =>
        '${bucket.label}: ${bucket.bookingLabel}, ${bucket.coverLabel}, '
        '${bucket.detailLabel}',
  );
  return '$title. ${summary.activeStateLabel}. ${bucketLabels.join('. ')}.';
}
