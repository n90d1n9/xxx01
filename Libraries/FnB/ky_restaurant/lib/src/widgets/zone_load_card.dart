import 'package:flutter/material.dart';

import '../models/restaurant_reservation_zone_load.dart';
import 'restaurant_interactive_surface.dart';
import 'restaurant_signal_chip.dart';
import 'restaurant_status_styles.dart';

/// Displays one reservation zone load summary with pressure and selection state.
class RestaurantReservationZoneLoadCard extends StatelessWidget {
  const RestaurantReservationZoneLoadCard({
    super.key,
    required this.load,
    required this.isSelected,
    this.onSelected,
  });

  final RestaurantReservationZoneLoad load;
  final bool isSelected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusStyle = restaurantStatusStyle(colors, load.serviceStatus);

    return Semantics(
      container: true,
      label:
          '${load.zoneLabel}, ${load.bookingLabel}, ${load.coverLabel}, '
          '${load.pressureLabel}',
      child: RestaurantInteractiveSurface(
        backgroundColor: colors.surfaceContainerHighest.withValues(alpha: .3),
        borderColor: statusStyle.foreground.withValues(alpha: .22),
        isSelected: isSelected,
        tooltip: onSelected == null
            ? load.zoneLabel
            : 'Show ${load.zoneLabel} reservations',
        onPressed: onSelected,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      load.zoneLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RestaurantStatusPill(
                    status: load.serviceStatus,
                    label: load.pressureLabel,
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                load.coverLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: statusStyle.foreground,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${load.bookingLabel} active',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _ZoneSignalChip(label: 'Late: ${load.lateCount}'),
                  _ZoneSignalChip(label: 'Due: ${load.dueSoonCount}'),
                  _ZoneSignalChip(label: 'VIP: ${load.vipCount}'),
                  _ZoneSignalChip(label: 'In: ${load.inHouseCount}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneSignalChip extends StatelessWidget {
  const _ZoneSignalChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return RestaurantSignalChip(
      label: label,
      backgroundColor: colors.surface.withValues(alpha: .76),
      borderColor: colors.outlineVariant.withValues(alpha: .42),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    );
  }
}
