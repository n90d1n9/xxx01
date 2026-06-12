import 'package:flutter/material.dart';

import '../models/restaurant_reservation_priority_queue.dart';
import 'restaurant_icon_badge.dart';
import 'restaurant_section_surface.dart';
import 'restaurant_signal_chip.dart';
import 'restaurant_status_styles.dart';

/// Displays one priority reservation action with urgency and booking context.
class RestaurantPriorityReservationCard extends StatelessWidget {
  const RestaurantPriorityReservationCard({super.key, required this.item});

  final RestaurantReservationPriorityItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusStyle = restaurantStatusStyle(colors, item.serviceStatus);

    return Semantics(
      container: true,
      label:
          '${item.guestLabel}, ${item.urgencyLabel}, ${item.actionLabel}, '
          '${item.detailLabel}, ${item.reservation.partyLabel}',
      child: RestaurantSectionSurface(
        backgroundColor: colors.surface.withValues(alpha: .76),
        borderColor: statusStyle.foreground.withValues(alpha: .18),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantIconBadge(
              icon: statusStyle.icon,
              foregroundColor: statusStyle.foreground,
              backgroundColor: statusStyle.background,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.guestLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      RestaurantStatusPill(
                        status: item.serviceStatus,
                        label: item.urgencyLabel,
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.detailLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      RestaurantSignalChip(label: item.reservation.partyLabel),
                      RestaurantSignalChip(label: item.actionLabel),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
