import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import 'restaurant_section_surface.dart';
import 'restaurant_status_styles.dart';

/// Displays a restaurant operating metric with status, value, detail, and trend.
class RestaurantMetricCard extends StatelessWidget {
  const RestaurantMetricCard({super.key, required this.metric});

  final RestaurantMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = restaurantStatusStyle(colors, metric.status);

    return Semantics(
      container: true,
      label:
          '${metric.label}, ${metric.value}, ${metric.detail}, '
          '${metric.trend}, ${metric.status.label}',
      child: RestaurantSectionSurface(
        backgroundColor: colors.surface,
        borderColor: colors.outlineVariant.withValues(alpha: .7),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(status.icon, color: status.foreground, size: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    metric.label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              metric.value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric.detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              metric.trend,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: status.foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
