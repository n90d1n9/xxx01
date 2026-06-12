import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_decision_action_plan_service.dart';
import '../services/project_decisions_workspace_service.dart';

/// Owner-focused action plan for clearing project decision records.
class ProjectDecisionActionPlanPanel extends StatelessWidget {
  const ProjectDecisionActionPlanPanel({
    required this.summary,
    this.maxOwners = 5,
    super.key,
  });

  final ProjectDecisionActionPlanSummary summary;
  final int maxOwners;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.signal.color(colorScheme);
    final visibleActions = summary.ownerActions.take(maxOwners).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: summary.title,
          subtitle: summary.detail,
          icon: summary.signal.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: signalColor.withValues(alpha: 0.12),
          iconForegroundColor: signalColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.signal.label,
            icon: summary.signal.icon,
            color: signalColor,
            maxWidth: 124,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Owners',
              value: summary.ownerCount.toString(),
              icon: Icons.groups_outlined,
              accentColor: colorScheme.primary,
              helper: 'Accountable',
            ),
            AppMetricGridItem(
              title: 'Open',
              value: summary.openCount.toString(),
              icon: Icons.rule_folder_outlined,
              accentColor:
                  summary.openCount == 0
                      ? Colors.green.shade700
                      : colorScheme.primary,
              helper: 'Decision actions',
            ),
            AppMetricGridItem(
              title: 'Awaiting',
              value: summary.awaitingCount.toString(),
              icon: Icons.pending_actions_outlined,
              accentColor:
                  summary.awaitingCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Review needed',
            ),
            AppMetricGridItem(
              title: 'Overdue',
              value: summary.overdueCount.toString(),
              icon: Icons.event_busy_outlined,
              accentColor:
                  summary.overdueCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Past due',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (visibleActions.isEmpty)
          const AppInfoRow(
            title: 'No owner actions waiting',
            subtitle:
                'All decision records are closed, approved, delegated, or completed.',
            icon: Icons.verified_outlined,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
          )
        else
          for (var index = 0; index < visibleActions.length; index++) ...[
            _DecisionOwnerActionTile(action: visibleActions[index]),
            if (index != visibleActions.length - 1) const SizedBox(height: 10),
          ],
        if (summary.ownerCount > maxOwners) ...[
          const SizedBox(height: 10),
          Text(
            'Showing $maxOwners of ${summary.ownerCount} decision owners',
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

/// Compact owner row showing decision load, source mix, and next action.
class _DecisionOwnerActionTile extends StatelessWidget {
  const _DecisionOwnerActionTile({required this.action});

  final ProjectDecisionOwnerAction action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = action.signal.color(colorScheme);

    return AppInfoRow(
      title: action.owner,
      subtitle:
          '${action.ownerLabel} - ${action.openCount} open - '
          '${action.awaitingCount} awaiting - ${action.sourceMixLabel} - '
          'Next: ${action.nextStepLabel}',
      icon: action.signal.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: signalColor.withValues(alpha: 0.12),
      iconForegroundColor: signalColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: _DecisionOwnerActionTrailing(
        action: action,
        color: signalColor,
      ),
    );
  }
}

/// Fixed-width owner action trailing block for stable row alignment.
class _DecisionOwnerActionTrailing extends StatelessWidget {
  const _DecisionOwnerActionTrailing({
    required this.action,
    required this.color,
  });

  final ProjectDecisionOwnerAction action;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${action.openCount} open',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: AppStatusPill(
              label: action.signal.label,
              icon: action.signal.icon,
              color: color,
              maxWidth: 120,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Project decision action plan panel')
Widget projectDecisionActionPlanPanelPreview() {
  final workspace = buildProjectDecisionsWorkspaceSummary(
    project: demoProjectPortfolio.first,
    dependencyTasks: const [],
    today: DateTime(2026, 6, 11),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectDecisionActionPlanPanel(
          summary: workspace.decisionActionPlanSummary,
        ),
      ),
    ),
  );
}
