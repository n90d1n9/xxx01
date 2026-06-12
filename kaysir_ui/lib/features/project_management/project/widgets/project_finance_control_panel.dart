import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_budget_overview_service.dart';
import '../services/project_budget_pulse_service.dart';
import '../services/project_finance_control_service.dart';

/// Finance control panel for budget authority, project float, and expenses.
class ProjectFinanceControlPanel extends StatelessWidget {
  const ProjectFinanceControlPanel({
    required this.summary,
    this.maxSignals = 4,
    super.key,
  });

  final ProjectFinanceControlSummary summary;
  final int maxSignals;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleSignals = summary.signals.take(maxSignals).toList();

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
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.level.label,
            icon: summary.level.icon,
            color: levelColor,
            maxWidth: 112,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Controls',
              value:
                  '${summary.configuredControlCount}/${summary.expectedControlCount}',
              icon: Icons.rule_folder_outlined,
              accentColor: levelColor,
              helper: 'Required setup',
            ),
            AppMetricGridItem(
              title: summary.profile.floatLabel,
              value: _roleStatus(ProjectFinanceControlRole.projectFloat),
              icon: ProjectFinanceControlRole.projectFloat.icon,
              accentColor: _roleColor(
                ProjectFinanceControlRole.projectFloat,
                colorScheme,
              ),
              helper: 'Petty cash / reserve',
            ),
            AppMetricGridItem(
              title: 'Expense Owner',
              value: _roleStatus(ProjectFinanceControlRole.expenseOwner),
              icon: ProjectFinanceControlRole.expenseOwner.icon,
              accentColor: _roleColor(
                ProjectFinanceControlRole.expenseOwner,
                colorScheme,
              ),
              helper: 'Accountability',
            ),
            AppMetricGridItem(
              title: 'Actions',
              value: summary.actionCount.toString(),
              icon: Icons.task_alt_outlined,
              accentColor:
                  summary.actionCount == 0 ? Colors.green.shade700 : levelColor,
              helper: 'Open controls',
            ),
          ],
        ),
        if (summary.attributes.isNotEmpty) ...[
          const SizedBox(height: 12),
          _FinanceAttributeStrip(attributes: summary.attributes),
        ],
        const SizedBox(height: 12),
        for (var index = 0; index < visibleSignals.length; index++) ...[
          _FinanceControlSignalTile(signal: visibleSignals[index]),
          if (index != visibleSignals.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  String _roleStatus(ProjectFinanceControlRole role) {
    return summary.attributes.any((attribute) => attribute.role == role)
        ? 'Set'
        : 'Open';
  }

  Color _roleColor(ProjectFinanceControlRole role, ColorScheme colorScheme) {
    return summary.attributes.any((attribute) => attribute.role == role)
        ? Colors.green.shade700
        : colorScheme.error;
  }
}

/// Compact strip of configured finance extension attributes.
class _FinanceAttributeStrip extends StatelessWidget {
  const _FinanceAttributeStrip({required this.attributes});

  final List<ProjectFinanceControlAttribute> attributes;

  @override
  Widget build(BuildContext context) {
    final visibleAttributes = attributes.take(3).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final attribute in visibleAttributes)
          AppStatusPill(
            label: '${attribute.role.label}: ${attribute.value}',
            icon: attribute.role.icon,
            color: Theme.of(context).colorScheme.primary,
            maxWidth: 220,
          ),
      ],
    );
  }
}

/// Row showing one finance setup or approval action.
class _FinanceControlSignalTile extends StatelessWidget {
  const _FinanceControlSignalTile({required this.signal});

  final ProjectFinanceControlSignal signal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = signal.level.color(colorScheme);

    return AppInfoRow(
      title: signal.title,
      subtitle: signal.detail,
      icon: signal.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: signalColor.withValues(alpha: 0.12),
      iconForegroundColor: signalColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: signal.level.label,
        icon: signal.level.icon,
        color: signalColor,
        maxWidth: 112,
      ),
    );
  }
}

@Preview(name: 'Project finance control panel')
Widget projectFinanceControlPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 560,
          child: ProjectFinanceControlPanel(
            summary: ProjectFinanceControlSummary(
              projectId: 'venue-fit-out',
              projectName: 'Venue Fit Out',
              profile: const ProjectFinanceControlProfile(
                floatLabel: 'Project float',
                expenseOwnerLabel: 'Field expense owner',
                approvalLabel: 'On-site approval threshold',
              ),
              budgetOverview: const ProjectBudgetOverview(
                projectId: 'venue-fit-out',
                projectName: 'Venue Fit Out',
                progress: 0.58,
                budgetUsed: 0.74,
                state: ProjectBudgetPulseState.pressure,
              ),
              attributes: const [
                ProjectFinanceControlAttribute(
                  label: 'Petty Cash Limit',
                  value: '5000000 IDR',
                  role: ProjectFinanceControlRole.projectFloat,
                ),
              ],
              signals: const [
                ProjectFinanceControlSignal(
                  title: 'Assign field expense owner',
                  detail:
                      'Name the person accountable for reimbursements and exception handling.',
                  level: ProjectFinanceControlLevel.watch,
                  icon: Icons.person_search_outlined,
                ),
                ProjectFinanceControlSignal(
                  title: 'Review spend authority',
                  detail:
                      '74% budget used against 58% progress (+16 pts). Confirm approval coverage.',
                  level: ProjectFinanceControlLevel.watch,
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
