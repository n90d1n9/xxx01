import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_analytics.dart';
import '../models/dashboard_workspace_entry.dart';
import '../models/dashboard_workspace_risk_group.dart';
import 'dashboard_risk_severity_summary.dart' show dashboardRiskSeverityColor;
import 'dashboard_workspace_list_item.dart';

class DashboardWorkspaceGroupedList extends StatelessWidget {
  final List<DashboardWorkspaceEntry> entries;

  const DashboardWorkspaceGroupedList({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final groups = buildDashboardWorkspaceRiskGroups(entries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          groups
              .map(
                (group) => Padding(
                  padding: EdgeInsets.only(
                    bottom: group == groups.last ? 0 : 14,
                  ),
                  child: _WorkspaceRiskGroupSection(group: group),
                ),
              )
              .toList(),
    );
  }
}

class _WorkspaceRiskGroupSection extends StatelessWidget {
  final DashboardWorkspaceRiskGroup group;

  const _WorkspaceRiskGroupSection({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WorkspaceRiskGroupHeader(
          severity: group.severity,
          count: group.entries.length,
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder:
              (context, index) =>
                  DashboardWorkspaceListItem(entry: group.entries[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: group.entries.length,
        ),
      ],
    );
  }
}

class _WorkspaceRiskGroupHeader extends StatelessWidget {
  final DashboardRiskSeverity severity;
  final int count;

  const _WorkspaceRiskGroupHeader({
    required this.severity,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final color = dashboardRiskSeverityColor(severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '${severity.label} workspaces',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
