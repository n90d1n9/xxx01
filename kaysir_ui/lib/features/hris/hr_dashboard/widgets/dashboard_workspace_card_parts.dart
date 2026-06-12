import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_entry.dart';
import 'dashboard_workspace_metric_chip.dart';
import 'dashboard_workspace_risk_badge.dart';

class DashboardWorkspaceCardHeader extends StatelessWidget {
  final DashboardWorkspaceEntry entry;

  const DashboardWorkspaceCardHeader({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DashboardWorkspaceCardIcon(entry: entry),
        const SizedBox(width: 12),
        Expanded(child: DashboardWorkspaceCardCopy(entry: entry)),
        if (entry.riskSignal?.shouldHighlight ?? false) ...[
          const SizedBox(width: 8),
          DashboardWorkspaceRiskBadge(signal: entry.riskSignal!, compact: true),
        ],
        const Icon(Icons.chevron_right, color: HrisColors.muted),
      ],
    );
  }
}

class DashboardWorkspaceCardIcon extends StatelessWidget {
  final DashboardWorkspaceEntry entry;

  const DashboardWorkspaceCardIcon({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: entry.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(entry.icon, color: entry.color),
    );
  }
}

class DashboardWorkspaceCardCopy extends StatelessWidget {
  final DashboardWorkspaceEntry entry;

  const DashboardWorkspaceCardCopy({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          entry.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
      ],
    );
  }
}

class DashboardWorkspaceCardMetrics extends StatelessWidget {
  final DashboardWorkspaceEntry entry;

  const DashboardWorkspaceCardMetrics({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          entry.metrics
              .map(
                (metric) => DashboardWorkspaceMetricChip(
                  metric: metric,
                  color: entry.color,
                ),
              )
              .toList(),
    );
  }
}
