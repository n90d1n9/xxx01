import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'builder_metric_chip.dart';

/// Immutable description for one metric shown inside [KyBuilderMetricStrip].
class KyBuilderMetricItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const KyBuilderMetricItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });
}

/// Arranges related builder metrics as a responsive, wrapping chip strip.
class KyBuilderMetricStrip extends StatelessWidget {
  final List<KyBuilderMetricItem> metrics;
  final double spacing;
  final double runSpacing;

  const KyBuilderMetricStrip({
    super.key,
    required this.metrics,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @Preview(name: 'Builder metric strip')
  const KyBuilderMetricStrip.preview({super.key})
    : metrics = const [
        KyBuilderMetricItem(
          icon: Icons.widgets_outlined,
          value: '12',
          label: 'blocks',
        ),
        KyBuilderMetricItem(
          icon: Icons.crop_free,
          value: '1440 x 960',
          label: 'canvas',
        ),
        KyBuilderMetricItem(
          icon: Icons.warning_amber_outlined,
          value: '2',
          label: 'warnings',
        ),
      ],
      spacing = 8,
      runSpacing = 8;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        for (final metric in metrics)
          KyBuilderMetricChip(
            icon: metric.icon,
            value: metric.value,
            label: metric.label,
            color: metric.color,
          ),
      ],
    );
  }
}
