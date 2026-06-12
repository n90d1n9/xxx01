import 'package:flutter/material.dart';

import 'registry_health_chart_example_matrix_model.dart';

class RegistryHealthChartExampleMatrixStatusBreakdown extends StatelessWidget {
  const RegistryHealthChartExampleMatrixStatusBreakdown({
    super.key,
    required this.summaries,
    this.title = 'Readiness Breakdown',
  });

  final Iterable<RegistryHealthChartExampleMatrixStatusSummary> summaries;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final segments = [
      for (final summary in summaries)
        _ChartExampleMatrixStatusSegment(
          summary: summary,
          color: registryHealthChartExampleMatrixStatusBreakdownColor(
            summary.status,
          ),
        ),
    ];
    final visibleSegments = segments
        .where((segment) => segment.trackFlex > 0)
        .toList(growable: false);
    final emptyTrackColor = theme.colorScheme.onSurface.withValues(alpha: 0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 12,
            width: double.infinity,
            child: visibleSegments.isEmpty
                ? ColoredBox(color: emptyTrackColor)
                : Row(
                    children: [
                      for (final segment in visibleSegments)
                        Expanded(
                          flex: segment.trackFlex,
                          child: ColoredBox(color: segment.color),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final segment in segments)
              _ChartExampleMatrixStatusLegendChip(segment: segment),
          ],
        ),
      ],
    );
  }
}

Color registryHealthChartExampleMatrixStatusBreakdownColor(
  RegistryHealthChartExampleMatrixStatus status,
) {
  return switch (status) {
    RegistryHealthChartExampleMatrixStatus.ready => Colors.green.shade700,
    RegistryHealthChartExampleMatrixStatus.missingSample =>
      Colors.orange.shade800,
    RegistryHealthChartExampleMatrixStatus.issue => Colors.red.shade700,
    RegistryHealthChartExampleMatrixStatus.unknown => Colors.blueGrey.shade600,
  };
}

class _ChartExampleMatrixStatusLegendChip extends StatelessWidget {
  const _ChartExampleMatrixStatusLegendChip({required this.segment});

  final _ChartExampleMatrixStatusSegment segment;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: segment.color.withValues(alpha: 0.28)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: segment.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${segment.summary.bucketLabel} ${segment.summary.count}',
                style: labelStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartExampleMatrixStatusSegment {
  const _ChartExampleMatrixStatusSegment({
    required this.summary,
    required this.color,
  });

  final RegistryHealthChartExampleMatrixStatusSummary summary;
  final Color color;

  int get trackFlex => summary.count < 0 ? 0 : summary.count;
}
