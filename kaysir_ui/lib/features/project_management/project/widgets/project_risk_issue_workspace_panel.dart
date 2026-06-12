import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_finance_workspace_service.dart';
import '../services/project_risk_issue_workspace_service.dart';

/// Reusable risk and issue workspace panel for project recovery triage.
class ProjectRiskIssueWorkspacePanel extends StatelessWidget {
  const ProjectRiskIssueWorkspacePanel({
    required this.summary,
    this.maxItems = 8,
    super.key,
  });

  final ProjectRiskIssueWorkspaceSummary summary;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (summary.itemCount == 0) {
      return const AppEmptyState(
        icon: Icons.health_and_safety_outlined,
        title: 'No active risks or issues',
        message:
            'Project blockers, milestones, budget pressure, authority gaps, and evidence issues will appear here when they need attention.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleItems = summary.items.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: summary.title,
          subtitle: summary.detail,
          icon: summary.level.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: levelColor.withValues(alpha: 0.12),
          iconForegroundColor: levelColor,
          titleMaxLines: 2,
          subtitleMaxLines: 3,
          trailing: AppStatusPill(
            label: summary.level.label,
            icon: summary.level.icon,
            color: levelColor,
            maxWidth: 128,
          ),
        ),
        const SizedBox(height: 12),
        _RiskIssueReadinessStrip(summary: summary, color: levelColor),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Active',
              value: summary.activeCount.toString(),
              icon: Icons.health_and_safety_outlined,
              accentColor:
                  summary.activeCount == 0 ? Colors.green.shade700 : levelColor,
              helper: 'Open items',
            ),
            AppMetricGridItem(
              title: 'Critical',
              value: summary.criticalCount.toString(),
              icon: Icons.priority_high_rounded,
              accentColor:
                  summary.criticalCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Needs escalation',
            ),
            AppMetricGridItem(
              title: 'Watch',
              value: summary.watchCount.toString(),
              icon: Icons.visibility_outlined,
              accentColor:
                  summary.watchCount == 0
                      ? colorScheme.primary
                      : Colors.orange.shade700,
              helper: 'Needs review',
            ),
            AppMetricGridItem(
              title: 'Exposure',
              value: summary.exposureScore.toString(),
              icon: Icons.radar_outlined,
              accentColor: levelColor,
              helper: '${summary.ownerCount} owners',
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _RiskIssueItemTile(item: visibleItems[index]),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
        if (summary.itemCount > maxItems) ...[
          const SizedBox(height: 10),
          Text(
            'Showing $maxItems of ${summary.itemCount} risk and issue items',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact readiness strip for risk and issue status distribution.
class _RiskIssueReadinessStrip extends StatelessWidget {
  const _RiskIssueReadinessStrip({required this.summary, required this.color});

  final ProjectRiskIssueWorkspaceSummary summary;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stablePercent =
        summary.itemCount == 0 ? 0 : summary.stableCount / summary.itemCount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Risk readiness',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  AppStatusPill(
                    label: '${summary.stableCount} Stable',
                    icon: Icons.verified_outlined,
                    color: Colors.green.shade700,
                    maxWidth: 108,
                  ),
                  AppStatusPill(
                    label: '${summary.watchCount} Watch',
                    icon: Icons.visibility_outlined,
                    color:
                        summary.watchCount == 0
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                    maxWidth: 108,
                  ),
                  AppStatusPill(
                    label: '${summary.criticalCount} Critical',
                    icon: Icons.priority_high_rounded,
                    color:
                        summary.criticalCount == 0
                            ? Colors.green.shade700
                            : colorScheme.error,
                    maxWidth: 120,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: stablePercent.toDouble(),
              color: color,
              backgroundColor: color.withValues(alpha: 0.14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Risk and issue row with source, owner, action, and evidence context.
class _RiskIssueItemTile extends StatelessWidget {
  const _RiskIssueItemTile({required this.item});

  final ProjectRiskIssueItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = item.level.color(colorScheme);

    return AppInfoRow(
      title: item.title,
      subtitle:
          '${item.detail} Owner: ${item.ownerLabel}. Evidence: ${item.evidenceLabel}.',
      icon: item.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: levelColor.withValues(alpha: 0.12),
      iconForegroundColor: levelColor,
      titleMaxLines: 2,
      subtitleMaxLines: 4,
      trailing: _RiskIssueItemTrailing(item: item),
    );
  }
}

/// Fixed-width risk row trailing content for stable alignment.
class _RiskIssueItemTrailing extends StatelessWidget {
  const _RiskIssueItemTrailing({required this.item});

  final ProjectRiskIssueItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = item.level.color(colorScheme);

    return SizedBox(
      width: 154,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStatusPill(
            label: item.kind.label,
            icon: item.icon,
            color: colorScheme.primary,
            tooltip: item.sourceLabel,
            maxWidth: 144,
          ),
          const SizedBox(height: 6),
          AppStatusPill(
            label: item.actionLabel,
            icon: item.level.icon,
            color: levelColor,
            tooltip: item.ownerLabel,
            maxWidth: 144,
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Project risk issue workspace panel')
Widget projectRiskIssueWorkspacePanelPreview() {
  final project =
      const ProjectPortfolioRepository().findById('warehouse-automation')!;
  final workspace = buildProjectFinanceWorkspaceSummary(project);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectRiskIssueWorkspacePanel(
          summary: buildProjectRiskIssueWorkspaceSummary(workspace),
        ),
      ),
    ),
  );
}
