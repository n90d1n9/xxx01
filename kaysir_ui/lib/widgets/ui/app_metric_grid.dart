import 'package:flutter/material.dart';

import 'app_metric_card.dart';

@immutable
class AppMetricGridItem {
  const AppMetricGridItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.change,
    this.helper,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? change;
  final String? helper;
}

class AppMetricGrid extends StatelessWidget {
  const AppMetricGrid({
    super.key,
    required this.metrics,
    this.spacing = 12,
    this.minTileWidth = 240,
    this.maxColumns = 4,
  });

  final List<AppMetricGridItem> metrics;
  final double spacing;
  final double minTileWidth;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final widthBasedColumns =
            ((constraints.maxWidth + spacing) / (minTileWidth + spacing))
                .floor();
        final columnLimit = maxColumns.clamp(1, metrics.length);
        final columns = widthBasedColumns.clamp(1, columnLimit);
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: tileWidth,
                child: AppMetricCard(
                  title: metric.title,
                  value: metric.value,
                  change: metric.change,
                  helper: metric.helper,
                  icon: metric.icon,
                  accentColor: metric.accentColor,
                ),
              ),
          ],
        );
      },
    );
  }
}
