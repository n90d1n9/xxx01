import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/hr_metric.dart';

class DashboardMetricGrid extends StatelessWidget {
  final List<HRMetric> metrics;

  const DashboardMetricGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 1100
                ? 4
                : constraints.maxWidth >= 640
                ? 2
                : 1;
        final aspectRatio =
            columns == 1
                ? 2.85
                : columns == 2
                ? 2.35
                : 1.75;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: aspectRatio,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) => _MetricCard(metric: metrics[index]),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final HRMetric metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final trendColor =
        metric.isPositive ? Colors.green[700]! : Colors.red[700]!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: hrisPanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ),
              Icon(
                metric.isPositive ? Icons.trending_up : Icons.trending_down,
                color: trendColor,
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '${metric.value}${metric.unit}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${metric.percentChange >= 0 ? '+' : ''}${metric.percentChange.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: trendColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: _metricProgress(metric),
              color: metric.color,
              backgroundColor: metric.color.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

double _metricProgress(HRMetric metric) {
  if (metric.unit == '%') return (metric.value / 100).clamp(0, 1);
  if (metric.unit == '/5') return (metric.value / 5).clamp(0, 1);
  if (metric.unit.trim() == 'days') {
    return (1 - (metric.value / 40)).clamp(0, 1);
  }
  return (metric.value / 100).clamp(0, 1);
}
