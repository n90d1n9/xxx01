import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import 'restaurant_section_header.dart';
import 'restaurant_section_surface.dart';
import 'restaurant_signal_chip.dart';
import 'restaurant_status_styles.dart';

class RestaurantSummaryStripMetric {
  const RestaurantSummaryStripMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class RestaurantSummaryStrip extends StatelessWidget {
  const RestaurantSummaryStrip({
    super.key,
    required this.title,
    required this.valueLabel,
    required this.progressValue,
    required this.status,
    required this.metrics,
  });

  final String title;
  final String valueLabel;
  final double progressValue;
  final RestaurantServiceStatus status;
  final List<RestaurantSummaryStripMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return RestaurantSectionSurface(
      backgroundColor: colors.surfaceContainerHighest.withValues(alpha: .38),
      borderColor: colors.outlineVariant.withValues(alpha: .5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RestaurantSectionHeader(
            title: title,
            trailingLabel: valueLabel,
            titleStyle: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
            trailingStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          RestaurantProgressBar(
            value: progressValue,
            status: status,
            height: 8,
            semanticLabel: '$title progress, $valueLabel',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final metric in metrics)
                _RestaurantSummaryMetricChip(metric: metric),
            ],
          ),
        ],
      ),
    );
  }
}

class _RestaurantSummaryMetricChip extends StatelessWidget {
  const _RestaurantSummaryMetricChip({required this.metric});

  final RestaurantSummaryStripMetric metric;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return RestaurantSignalChip(
      label: metric.label,
      icon: metric.icon,
      backgroundColor: colors.surface.withValues(alpha: .72),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      iconSize: 14,
      iconSpacing: 6,
    );
  }
}
