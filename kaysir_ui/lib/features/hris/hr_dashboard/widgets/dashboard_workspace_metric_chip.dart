import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_entry.dart';

class DashboardWorkspaceMetricChip extends StatelessWidget {
  final DashboardWorkspaceMetric metric;
  final Color color;
  final bool compact;

  const DashboardWorkspaceMetricChip({
    super.key,
    required this.metric,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(metric.icon, color: color, size: compact ? 15 : 16),
          const SizedBox(width: 6),
          Text(
            metric.label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(width: 8),
          Text(
            metric.value,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
