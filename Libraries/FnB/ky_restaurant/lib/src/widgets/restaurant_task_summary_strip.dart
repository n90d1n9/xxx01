import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import '../models/restaurant_task_summary.dart';
import 'restaurant_summary_strip.dart';

class RestaurantTaskSummaryStrip extends StatelessWidget {
  const RestaurantTaskSummaryStrip({super.key, required this.summary});

  final RestaurantTaskSummary summary;

  @override
  Widget build(BuildContext context) {
    final status = summary.attentionCount > 0
        ? RestaurantServiceStatus.busy
        : RestaurantServiceStatus.calm;

    return RestaurantSummaryStrip(
      title: 'Task progress',
      valueLabel: summary.completionLabel,
      progressValue: summary.completionRate,
      status: status,
      metrics: [
        RestaurantSummaryStripMetric(
          icon: Icons.playlist_add_check_rounded,
          label: '${summary.openCount} open',
        ),
        RestaurantSummaryStripMetric(
          icon: Icons.priority_high_rounded,
          label: '${summary.attentionCount} attention',
        ),
        RestaurantSummaryStripMetric(
          icon: Icons.check_circle_outline_rounded,
          label: '${summary.completedCount}/${summary.totalCount} done',
        ),
      ],
    );
  }
}
