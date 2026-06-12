import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import 'restaurant_icon_badge.dart';
import 'restaurant_status_card_surface.dart';
import 'restaurant_status_styles.dart';

/// Displays one service pulse metric with status, detail text, and category icon.
class RestaurantPulseMetricCard extends StatelessWidget {
  const RestaurantPulseMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.detail,
    required this.status,
    required this.icon,
  });

  final String label;
  final String value;
  final String detail;
  final RestaurantServiceStatus status;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusStyle = restaurantStatusStyle(colors, status);

    return Semantics(
      container: true,
      label: '$label, $value, ${status.label}. $detail',
      child: RestaurantStatusCardSurface(
        statusStyle: statusStyle,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantIconBadge(
              icon: icon,
              foregroundColor: statusStyle.foreground,
              backgroundColor: statusStyle.background,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    detail,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            RestaurantStatusPill(status: status, compact: true),
          ],
        ),
      ),
    );
  }
}
