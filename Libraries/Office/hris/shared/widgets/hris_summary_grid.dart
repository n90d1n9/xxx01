import 'package:flutter/material.dart';

import '../theme/hris_theme.dart';

class HrisSummaryMetric {
  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;

  const HrisSummaryMetric({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });
}

class HrisSummaryGrid extends StatelessWidget {
  final List<HrisSummaryMetric> metrics;

  const HrisSummaryGrid({super.key, required this.metrics});

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
                ? 2.9
                : columns == 2
                ? 2.55
                : 2.2;

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
          itemBuilder:
              (context, index) => _HrisSummaryCard(metric: metrics[index]),
        );
      },
    );
  }
}

class _HrisSummaryCard extends StatelessWidget {
  final HrisSummaryMetric metric;

  const _HrisSummaryCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: hrisPanelDecoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: metric.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(metric.icon, color: metric.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.value,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metric.detail,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
