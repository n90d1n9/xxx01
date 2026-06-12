import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide FontWeight;

import 'simple_charts_showcase_data.dart';
import 'simple_charts_showcase_widgets.dart';

class SimpleChartsMetricsStrip extends StatelessWidget {
  final SimpleTrendChartStyle trendStyle;
  final bool showTooltips;

  const SimpleChartsMetricsStrip({
    super.key,
    required this.trendStyle,
    required this.showTooltips,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final tileWidth = compact
            ? constraints.maxWidth
            : (constraints.maxWidth - 36) / 4;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SimpleChartsMetricTile(
              width: tileWidth,
              title: 'Revenue',
              value: '\$74k',
              delta: '+18%',
              color: colorScheme.primary,
              points: SimpleChartsShowcaseData.salesPulse,
              type: SimpleSparklineType.area,
              style: trendStyle,
              showTooltip: showTooltips,
              valueFormatter: (value) => '\$${value.toStringAsFixed(0)}k',
            ),
            SimpleChartsMetricTile(
              width: tileWidth,
              title: 'Retention',
              value: '91%',
              delta: '+6 pts',
              color: colorScheme.secondary,
              points: SimpleChartsShowcaseData.retentionPulse,
              type: SimpleSparklineType.line,
              style: trendStyle,
              showTooltip: showTooltips,
              referenceValue: 88,
              valueFormatter: (value) => '${value.toStringAsFixed(0)}%',
            ),
            SimpleChartsMetricTile(
              width: tileWidth,
              title: 'Completion',
              value: '84%',
              delta: '+9 pts',
              color: colorScheme.tertiary,
              points: SimpleChartsShowcaseData.completionPulse,
              type: SimpleSparklineType.bar,
              style: trendStyle,
              showTooltip: showTooltips,
              valueFormatter: (value) => '${value.toStringAsFixed(0)}%',
            ),
            SimpleChartsMetricTile(
              width: tileWidth,
              title: 'Risk',
              value: '12',
              delta: '-5',
              color: colorScheme.error,
              points: SimpleChartsShowcaseData.riskPulse,
              type: SimpleSparklineType.line,
              style: trendStyle,
              showTooltip: showTooltips,
              referenceValue: 18,
            ),
          ],
        );
      },
    );
  }
}
