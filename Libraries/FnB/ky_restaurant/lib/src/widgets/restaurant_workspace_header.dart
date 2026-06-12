import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import 'restaurant_status_styles.dart';

class RestaurantWorkspaceHeader extends StatelessWidget {
  const RestaurantWorkspaceHeader({super.key, required this.snapshot});

  final RestaurantOperatingSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.primary.withValues(alpha: .045),
          colors.surface,
        ),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .7)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Wrap(
          spacing: 22,
          runSpacing: 18,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RestaurantStatusPill(
                    status: snapshot.blockedOrCriticalZones > 0
                        ? RestaurantServiceStatus.critical
                        : RestaurantServiceStatus.busy,
                    label: snapshot.serviceDateLabel,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    snapshot.locationName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manager ${snapshot.managerName} is tracking floor load, kitchen pace, and menu availability from one workspace.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            _HeaderStat(
              icon: Icons.groups_2_outlined,
              label: 'Covers',
              value: snapshot.activeCovers.toString(),
            ),
            _HeaderStat(
              icon: Icons.receipt_long_outlined,
              label: 'Open orders',
              value: snapshot.pendingOrders.toString(),
            ),
            _HeaderStat(
              icon: Icons.event_seat_outlined,
              label: 'Seats used',
              value: '${snapshot.seatUtilizationPercent}%',
            ),
            _HeaderStat(
              icon: Icons.schedule_outlined,
              label: 'Avg ticket',
              value: '${snapshot.averageTicketMinutes}m',
            ),
            _HeaderStat(
              icon: Icons.payments_outlined,
              label: 'Net sales',
              value: snapshot.revenueTodayLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: 132,
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Icon(icon, color: colors.primary, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
