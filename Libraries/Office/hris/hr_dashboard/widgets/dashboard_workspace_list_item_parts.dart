import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_entry.dart';
import '../models/hris_workspace.dart';
import 'dashboard_workspace_metric_chip.dart';
import 'dashboard_workspace_risk_badge.dart';

class DashboardWorkspaceListIcon extends StatelessWidget {
  final DashboardWorkspaceEntry entry;

  const DashboardWorkspaceListIcon({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: entry.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(entry.icon, color: entry.color, size: 21),
    );
  }
}

class DashboardWorkspaceListCopy extends StatelessWidget {
  final DashboardWorkspaceEntry entry;

  const DashboardWorkspaceListCopy({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          entry.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            HrisStatusPill(
              label: dashboardWorkspaceCategoryLabel(entry.category),
              color: entry.color,
            ),
            if (entry.riskSignal?.shouldHighlight ?? false)
              DashboardWorkspaceRiskBadge(
                signal: entry.riskSignal!,
                compact: true,
              ),
          ],
        ),
      ],
    );
  }
}

class DashboardWorkspaceListMetrics extends StatelessWidget {
  final DashboardWorkspaceEntry entry;

  const DashboardWorkspaceListMetrics({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children:
          entry.metrics
              .map(
                (metric) => DashboardWorkspaceMetricChip(
                  metric: metric,
                  color: entry.color,
                  compact: true,
                ),
              )
              .toList(),
    );
  }
}

String dashboardWorkspaceCategoryLabel(DashboardWorkspaceCategory category) {
  switch (category) {
    case DashboardWorkspaceCategory.strategic:
      return 'Strategic';
    case DashboardWorkspaceCategory.operational:
      return 'Operational';
  }
}
