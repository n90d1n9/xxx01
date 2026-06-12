import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_finance_closeout_service.dart';
import '../services/project_finance_workspace_service.dart';

/// Finance closeout checklist panel for project handoff readiness.
class ProjectFinanceCloseoutPanel extends StatelessWidget {
  const ProjectFinanceCloseoutPanel({
    required this.summary,
    this.maxChecks = 6,
    super.key,
  });

  final ProjectFinanceWorkspaceSummary summary;
  final int maxChecks;

  @override
  Widget build(BuildContext context) {
    final closeout = buildProjectFinanceCloseoutSummary(summary);
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = closeout.level.color(colorScheme);
    final visibleChecks = closeout.checks.take(maxChecks).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: closeout.title,
          subtitle: closeout.detail,
          icon: closeout.level.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: levelColor.withValues(alpha: 0.12),
          iconForegroundColor: levelColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: closeout.level.label,
            icon: closeout.level.icon,
            color: levelColor,
            maxWidth: 128,
          ),
        ),
        const SizedBox(height: 12),
        _CloseoutProgressBar(
          completionPercent: closeout.completionPercent,
          color: levelColor,
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Ready',
              value: closeout.readyCount.toString(),
              icon: Icons.verified_outlined,
              accentColor: Colors.green.shade700,
              helper: 'Checks passed',
            ),
            AppMetricGridItem(
              title: 'Attention',
              value: closeout.attentionCount.toString(),
              icon: Icons.pending_actions_outlined,
              accentColor:
                  closeout.attentionCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Needs follow-up',
            ),
            AppMetricGridItem(
              title: 'Blocked',
              value: closeout.blockedCount.toString(),
              icon: Icons.priority_high_rounded,
              accentColor:
                  closeout.blockedCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Cannot close',
            ),
            AppMetricGridItem(
              title: 'Complete',
              value: '${closeout.completionPercent}%',
              icon: Icons.task_alt_outlined,
              accentColor: levelColor,
              helper: 'Closeout progress',
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleChecks.length; index++) ...[
          _CloseoutCheckTile(check: visibleChecks[index]),
          if (index != visibleChecks.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Linear closeout progress bar with a fixed label row.
class _CloseoutProgressBar extends StatelessWidget {
  const _CloseoutProgressBar({
    required this.completionPercent,
    required this.color,
  });

  final int completionPercent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Closeout readiness',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '$completionPercent%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: completionPercent / 100,
              color: color,
              backgroundColor: color.withValues(alpha: 0.14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Finance closeout checklist row with owner and readiness state.
class _CloseoutCheckTile extends StatelessWidget {
  const _CloseoutCheckTile({required this.check});

  final ProjectFinanceCloseoutCheck check;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final checkColor = check.level.color(colorScheme);

    return AppInfoRow(
      title: check.title,
      subtitle: '${check.detail} Owner: ${check.ownerLabel}.',
      icon: check.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: checkColor.withValues(alpha: 0.12),
      iconForegroundColor: checkColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: check.level.label,
        icon: check.level.icon,
        color: checkColor,
        maxWidth: 128,
      ),
    );
  }
}

@Preview(name: 'Project finance closeout panel')
Widget projectFinanceCloseoutPanelPreview() {
  final project = const ProjectPortfolioRepository().fetchProjects().first;

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectFinanceCloseoutPanel(
          summary: buildProjectFinanceWorkspaceSummary(project),
        ),
      ),
    ),
  );
}
