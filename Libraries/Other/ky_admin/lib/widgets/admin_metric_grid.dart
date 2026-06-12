import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_card.dart';

@immutable
class AdminMetricGridItem {
  const AdminMetricGridItem({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color accentColor;
}

class AdminMetricGrid extends StatelessWidget {
  const AdminMetricGrid({
    super.key,
    required this.metrics,
    this.spacing = 16,
    this.tileHeight = 156,
    this.minTileWidth = 260,
    this.maxColumns = 4,
  });

  final List<AdminMetricGridItem> metrics;
  final double spacing;
  final double tileHeight;
  final double minTileWidth;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final widthBasedColumns = (constraints.maxWidth / minTileWidth).floor();
        final crossAxisCount = widthBasedColumns.clamp(
          1,
          maxColumns.clamp(1, metrics.length),
        );

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: tileHeight,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final metric = metrics[index];

            return AppMetricCard(
              title: metric.title,
              value: metric.value,
              change: metric.change,
              icon: metric.icon,
              accentColor: metric.accentColor,
            );
          },
        );
      },
    );
  }
}
