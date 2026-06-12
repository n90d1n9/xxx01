import 'package:flutter/material.dart';

import '../models/restaurant_reservation_action_queue.dart';
import 'action_bucket_tile.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';

/// Shows reservation action buckets that can drive focused booking filters.
class RestaurantReservationActionQueue extends StatelessWidget {
  const RestaurantReservationActionQueue({
    super.key,
    required this.summary,
    this.title = 'Action queue',
    this.selectedBucketKind,
    this.onBucketSelected,
  });

  final RestaurantReservationActionQueueSummary summary;
  final String title;
  final RestaurantReservationActionBucketKind? selectedBucketKind;
  final ValueChanged<RestaurantReservationActionBucketKind>? onBucketSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: _semanticLabel(title, summary),
      child: RestaurantSectionSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantSectionHeader(
              icon: Icons.rule_folder_outlined,
              title: title,
              trailingLabel: summary.actionLabel,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final bucket in summary.buckets)
                  RestaurantReservationActionBucketTile(
                    bucket: bucket,
                    isSelected: bucket.kind == selectedBucketKind,
                    onSelected:
                        onBucketSelected == null || !bucket.hasReservations
                        ? null
                        : () => onBucketSelected!(bucket.kind),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _semanticLabel(
  String title,
  RestaurantReservationActionQueueSummary summary,
) {
  final bucketLabels = summary.buckets.map(
    (bucket) =>
        '${bucket.kind.label}: ${bucket.bookingLabel}, ${bucket.coverLabel}, '
        '${bucket.kind.actionLabel}',
  );
  return '$title. ${summary.actionLabel}. ${bucketLabels.join('. ')}.';
}
