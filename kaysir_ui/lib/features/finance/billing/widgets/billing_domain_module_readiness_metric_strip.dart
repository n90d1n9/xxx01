import 'package:flutter/material.dart';

class BillingReadinessMetric {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const BillingReadinessMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class BillingReadinessMetricStrip extends StatelessWidget {
  final List<BillingReadinessMetric> metrics;

  const BillingReadinessMetricStrip({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;
        if (isCompact) {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                metrics
                    .map(
                      (metric) => SizedBox(
                        width: (constraints.maxWidth - 10) / 2,
                        child: _ReadinessMetricTile(metric: metric),
                      ),
                    )
                    .toList(),
          );
        }

        return Row(
          children: List.generate(metrics.length, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == metrics.length - 1 ? 0 : 10,
                ),
                child: _ReadinessMetricTile(metric: metrics[index]),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ReadinessMetricTile extends StatelessWidget {
  final BillingReadinessMetric metric;

  const _ReadinessMetricTile({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: metric.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: metric.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(metric.icon, color: metric.color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: metric.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
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
