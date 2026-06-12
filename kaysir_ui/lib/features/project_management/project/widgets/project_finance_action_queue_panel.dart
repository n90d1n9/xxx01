import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_finance_action_queue_service.dart';
import '../services/project_finance_ledger_records_service.dart';
import '../services/project_finance_ledger_summary_service.dart';

/// Action queue panel for finance blocks, reviews, cash, and proof follow-up.
class ProjectFinanceActionQueuePanel extends StatelessWidget {
  const ProjectFinanceActionQueuePanel({
    required this.summary,
    this.maxActions = 5,
    super.key,
  });

  final ProjectFinanceLedgerSummary summary;
  final int maxActions;

  @override
  Widget build(BuildContext context) {
    final queue = buildProjectFinanceActionQueue(summary);
    final colorScheme = Theme.of(context).colorScheme;
    final primaryAction = queue.primaryAction;
    final headerSeverity =
        queue.criticalCount > 0
            ? ProjectFinanceActionSeverity.critical
            : queue.watchCount > 0
            ? ProjectFinanceActionSeverity.watch
            : ProjectFinanceActionSeverity.routine;
    final headerColor = headerSeverity.color(colorScheme);
    final visibleActions = queue.actions.take(maxActions).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: queue.title,
          subtitle: queue.detail,
          icon: primaryAction?.severity.icon ?? Icons.task_alt_outlined,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: headerColor.withValues(alpha: 0.12),
          iconForegroundColor: headerColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: queue.hasActions ? '${queue.actionCount} Actions' : 'Clear',
            icon:
                queue.hasActions
                    ? Icons.pending_actions_outlined
                    : Icons.verified_outlined,
            color: headerColor,
            maxWidth: 124,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Critical',
              value: queue.criticalCount.toString(),
              icon: ProjectFinanceActionSeverity.critical.icon,
              accentColor:
                  queue.criticalCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Blocked items',
            ),
            AppMetricGridItem(
              title: 'Watch',
              value: queue.watchCount.toString(),
              icon: ProjectFinanceActionSeverity.watch.icon,
              accentColor:
                  queue.watchCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Review needed',
            ),
            AppMetricGridItem(
              title: 'Routine',
              value: queue.routineCount.toString(),
              icon: ProjectFinanceActionSeverity.routine.icon,
              accentColor: Colors.green.shade700,
              helper: 'Proof and closeout',
            ),
            AppMetricGridItem(
              title: 'Owners',
              value: queue.ownerCount.toString(),
              icon: Icons.groups_outlined,
              accentColor: colorScheme.primary,
              helper: 'Accountable people',
            ),
          ],
        ),
        if (visibleActions.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (var index = 0; index < visibleActions.length; index++) ...[
            _FinanceActionTile(action: visibleActions[index]),
            if (index != visibleActions.length - 1) const SizedBox(height: 10),
          ],
        ],
        if (queue.actionCount > maxActions) ...[
          const SizedBox(height: 10),
          Text(
            'Showing $maxActions of ${queue.actionCount} finance actions',
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

/// Compact finance action row with owner, amount, source, and severity.
class _FinanceActionTile extends StatelessWidget {
  const _FinanceActionTile({required this.action});

  final ProjectFinanceActionItem action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final severityColor = action.severity.color(colorScheme);
    final dueDateLabel = action.dueDateLabel;

    return AppInfoRow(
      title: action.title,
      subtitle: [
        action.sourceKind.label,
        'Owner: ${action.owner}',
        if (dueDateLabel.isNotEmpty) dueDateLabel,
        action.detail,
      ].join(' - '),
      icon: action.severity.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: severityColor.withValues(alpha: 0.12),
      iconForegroundColor: severityColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: _FinanceActionTrailing(action: action, color: severityColor),
    );
  }
}

/// Fixed-width finance action trailing content for stable row alignment.
class _FinanceActionTrailing extends StatelessWidget {
  const _FinanceActionTrailing({required this.action, required this.color});

  final ProjectFinanceActionItem action;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            action.amountLabel,
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
              label: action.ctaLabel,
              icon: action.severity.icon,
              color: color,
              maxWidth: 124,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Project finance action queue panel')
Widget projectFinanceActionQueuePanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectFinanceActionQueuePanel(
          summary: buildProjectFinanceLedgerSummary(
            projectId: 'warehouse-automation',
          ),
        ),
      ),
    ),
  );
}
