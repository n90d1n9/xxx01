import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_finance_ledger_records_service.dart';
import '../services/project_finance_workspace_service.dart';
import '../services/project_petty_cash_workspace_service.dart';

/// Reusable petty-cash workspace panel for float, custodians, and evidence.
class ProjectPettyCashWorkspacePanel extends StatelessWidget {
  const ProjectPettyCashWorkspacePanel({
    required this.summary,
    this.maxEntries = 6,
    this.maxControls = 3,
    super.key,
  });

  final ProjectPettyCashWorkspaceSummary summary;
  final int maxEntries;
  final int maxControls;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleEntries = summary.entries.take(maxEntries).toList();
    final visibleControls = summary.controls.take(maxControls).toList();

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
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Open Float',
              value: summary.openFloatAmountLabel,
              icon: Icons.payments_outlined,
              accentColor:
                  summary.openCount == 0 ? Colors.green.shade700 : levelColor,
              helper: '${summary.openCount} open',
            ),
            AppMetricGridItem(
              title: 'Custodians',
              value: summary.custodianCount.toString(),
              icon: Icons.groups_outlined,
              accentColor: colorScheme.primary,
              helper: 'Accountable owners',
            ),
            AppMetricGridItem(
              title: 'Due Soon',
              value: summary.dueSoonCount.toString(),
              icon: Icons.event_available_outlined,
              accentColor:
                  summary.dueSoonCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: '14-day window',
            ),
            AppMetricGridItem(
              title: 'Blocked',
              value: summary.blockedCount.toString(),
              icon: Icons.block_outlined,
              accentColor:
                  summary.blockedCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Cannot release',
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppInfoRow(
          title: 'Petty cash controls',
          subtitle:
              '${summary.readyControlCount} of ${summary.controls.length} controls ready for ${summary.businessDomain}.',
          icon: Icons.rule_folder_outlined,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: colorScheme.primary.withValues(alpha: 0.12),
          iconForegroundColor: colorScheme.primary,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < visibleControls.length; index++) ...[
          _PettyCashControlTile(control: visibleControls[index]),
          if (index != visibleControls.length - 1) const SizedBox(height: 10),
        ],
        const SizedBox(height: 12),
        if (visibleEntries.isEmpty)
          _PettyCashEmptyEntries(summary: summary)
        else
          for (var index = 0; index < visibleEntries.length; index++) ...[
            _PettyCashEntryTile(entry: visibleEntries[index]),
            if (index != visibleEntries.length - 1) const SizedBox(height: 10),
          ],
        if (summary.entryCount > maxEntries) ...[
          const SizedBox(height: 10),
          Text(
            'Showing $maxEntries of ${summary.entryCount} petty-cash entries',
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

/// Empty petty-cash state that still exposes the required setup path.
class _PettyCashEmptyEntries extends StatelessWidget {
  const _PettyCashEmptyEntries({required this.summary});

  final ProjectPettyCashWorkspaceSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final control = summary.primaryControl;
    final color = control?.level.color(colorScheme) ?? colorScheme.primary;

    return AppInfoRow(
      title: 'No petty-cash float entries yet',
      subtitle:
          control == null
              ? 'Create a float entry once this project needs field cash or small operational spend.'
              : 'Start with ${control.title.toLowerCase()} before opening a float request.',
      icon: Icons.payments_outlined,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: color.withValues(alpha: 0.12),
      iconForegroundColor: color,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
    );
  }
}

/// Petty-cash entry row with custodian, amount, due date, and next action.
class _PettyCashEntryTile extends StatelessWidget {
  const _PettyCashEntryTile({required this.entry});

  final ProjectPettyCashEntryView entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = entry.level.color(colorScheme);

    return AppInfoRow(
      title: entry.title,
      subtitle:
          'Custodian: ${entry.custodian} - Due ${entry.dueDateLabel} - ${entry.detail} Evidence: ${entry.evidenceLabel}. Approval: ${entry.approvalLabel}.',
      icon: Icons.payments_outlined,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: levelColor.withValues(alpha: 0.12),
      iconForegroundColor: levelColor,
      titleMaxLines: 2,
      subtitleMaxLines: 4,
      trailing: _PettyCashEntryTrailing(entry: entry),
    );
  }
}

/// Fixed-width petty-cash entry trailing content for stable row alignment.
class _PettyCashEntryTrailing extends StatelessWidget {
  const _PettyCashEntryTrailing({required this.entry});

  final ProjectPettyCashEntryView entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = entry.status.color(colorScheme);

    return SizedBox(
      width: 136,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            entry.amountLabel,
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
              label: entry.actionLabel,
              icon: entry.status.icon,
              color: statusColor,
              maxWidth: 128,
            ),
          ),
        ],
      ),
    );
  }
}

/// Petty-cash control row for intake, authority, and evidence readiness.
class _PettyCashControlTile extends StatelessWidget {
  const _PettyCashControlTile({required this.control});

  final ProjectPettyCashControlCheck control;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = control.level.color(colorScheme);

    return AppInfoRow(
      title: control.title,
      subtitle: '${control.detail} Owner: ${control.ownerLabel}.',
      icon: control.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: levelColor.withValues(alpha: 0.12),
      iconForegroundColor: levelColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: control.level.label,
        icon: control.level.icon,
        color: levelColor,
        maxWidth: 128,
      ),
    );
  }
}

@Preview(name: 'Project petty cash workspace panel')
Widget projectPettyCashWorkspacePanelPreview() {
  final project = const ProjectPortfolioRepository().fetchProjects().first;
  final workspace = buildProjectFinanceWorkspaceSummary(project);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectPettyCashWorkspacePanel(
          summary: buildProjectPettyCashWorkspaceSummary(workspace),
        ),
      ),
    ),
  );
}
