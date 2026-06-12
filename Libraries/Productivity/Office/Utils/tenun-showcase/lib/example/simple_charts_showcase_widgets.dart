import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide FontWeight;

import 'showcase_source_panel.dart';
import 'simple_charts_showcase_source.dart';

class SimpleChartsMetricTile extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final String delta;
  final Color color;
  final List<SimpleTrendPoint> points;
  final SimpleSparklineType type;
  final SimpleTrendChartStyle style;
  final bool showTooltip;
  final double? referenceValue;
  final SimpleTrendValueFormatter? valueFormatter;

  const SimpleChartsMetricTile({
    super.key,
    required this.width,
    required this.title,
    required this.value,
    required this.delta,
    required this.color,
    required this.points,
    required this.type,
    required this.style,
    required this.showTooltip,
    this.referenceValue,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    delta,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: SimpleSparklineChart(
                  points: points,
                  type: type,
                  style: style,
                  color: color,
                  showTooltip: showTooltip,
                  referenceLines: referenceValue == null
                      ? const []
                      : [
                          SimpleChartReferenceLine(
                            value: referenceValue!,
                            lineStyle: SimpleChartReferenceLineStyle.dashed,
                          ),
                        ],
                  valueFormatter: valueFormatter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SimpleChartsShowcasePanel extends StatelessWidget {
  final double width;
  final String title;
  final String subtitle;
  final Widget child;
  final SimpleChartSampleSource? source;
  final bool showSampleJson;
  final bool showSampleCode;

  const SimpleChartsShowcasePanel({
    super.key,
    required this.width,
    required this.title,
    required this.subtitle,
    required this.child,
    this.source,
    this.showSampleJson = true,
    this.showSampleCode = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(height: 250, child: child),
              if (source != null && (showSampleJson || showSampleCode)) ...[
                const SizedBox(height: 12),
                _SimpleChartsSourcePanels(
                  title: title,
                  source: source!,
                  showSampleJson: showSampleJson,
                  showSampleCode: showSampleCode,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleChartsSourcePanels extends StatelessWidget {
  const _SimpleChartsSourcePanels({
    required this.title,
    required this.source,
    required this.showSampleJson,
    required this.showSampleCode,
  });

  final String title;
  final SimpleChartSampleSource source;
  final bool showSampleJson;
  final bool showSampleCode;

  @override
  Widget build(BuildContext context) {
    return ShowcaseSourceTextPanelGroup(
      items: [
        if (showSampleJson)
          ShowcaseSourceTextItem(
            title: 'Sample JSON',
            text: source.jsonText,
            copyLabel: '$title JSON',
          ),
        if (showSampleCode)
          ShowcaseSourceTextItem(
            title: 'Dart Code',
            text: source.dartCode,
            copyLabel: '$title code',
          ),
      ],
    );
  }
}
