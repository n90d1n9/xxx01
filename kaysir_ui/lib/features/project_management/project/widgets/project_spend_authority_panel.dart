import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_budget_overview_service.dart';
import '../services/project_budget_pulse_service.dart';
import '../services/project_expense_intake_service.dart';
import '../services/project_finance_control_service.dart';
import '../services/project_spend_authority_service.dart';

/// Spend authority panel for project spend approval and escalation bands.
class ProjectSpendAuthorityPanel extends StatelessWidget {
  const ProjectSpendAuthorityPanel({
    required this.summary,
    this.maxRules = 4,
    super.key,
  });

  final ProjectSpendAuthoritySummary summary;
  final int maxRules;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleRules = summary.rules.take(maxRules).toList();

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
            maxWidth: 118,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Bands',
              value: summary.ruleCount.toString(),
              icon: Icons.account_tree_outlined,
              accentColor: colorScheme.primary,
              helper: 'Authority rules',
            ),
            AppMetricGridItem(
              title: 'Delegated',
              value: summary.delegatedCount.toString(),
              icon: Icons.verified_user_outlined,
              accentColor: Colors.green.shade700,
              helper: 'Can approve',
            ),
            AppMetricGridItem(
              title: 'Guarded',
              value: summary.guardedCount.toString(),
              icon: Icons.admin_panel_settings_outlined,
              accentColor:
                  summary.guardedCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Needs setup',
            ),
            AppMetricGridItem(
              title: 'Escalate',
              value: summary.escalationCount.toString(),
              icon: Icons.priority_high_rounded,
              accentColor:
                  summary.escalationCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Sponsor route',
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleRules.length; index++) ...[
          _SpendAuthorityRuleTile(rule: visibleRules[index]),
          if (index != visibleRules.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Rule tile with threshold, approver, and evidence requirements.
class _SpendAuthorityRuleTile extends StatelessWidget {
  const _SpendAuthorityRuleTile({required this.rule});

  final ProjectSpendAuthorityRule rule;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ruleColor = rule.level.color(colorScheme);

    return AppInfoRow(
      title: rule.title,
      subtitle:
          '${rule.detail} Threshold: ${rule.thresholdLabel}. Approver: ${rule.approverLabel}. Evidence: ${rule.evidenceLabel}.',
      icon: rule.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: ruleColor.withValues(alpha: 0.12),
      iconForegroundColor: ruleColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: rule.level.label,
        icon: rule.level.icon,
        color: ruleColor,
        maxWidth: 118,
      ),
    );
  }
}

@Preview(name: 'Project spend authority panel')
Widget projectSpendAuthorityPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 620,
          child: ProjectSpendAuthorityPanel(
            summary: ProjectSpendAuthoritySummary(
              projectId: 'venue-fit-out',
              projectName: 'Venue Fit Out',
              financeSummary: ProjectFinanceControlSummary(
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
                attributes: const [],
                signals: const [],
              ),
              expenseIntake: ProjectExpenseIntakeSummary(
                projectId: 'venue-fit-out',
                projectName: 'Venue Fit Out',
                financeSummary: ProjectFinanceControlSummary(
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
                  attributes: const [],
                  signals: const [],
                ),
                routes: const [],
              ),
              rules: const [
                ProjectSpendAuthorityRule(
                  id: 'venue-fit-out-budget-exception',
                  title: 'Budget exception authority',
                  detail:
                      '74% budget used against 58% progress (+16 pts). Sponsor sign-off is required.',
                  band: ProjectSpendAuthorityBand.budgetException,
                  level: ProjectSpendAuthorityLevel.escalation,
                  icon: Icons.account_balance_wallet_outlined,
                  thresholdLabel: 'Above approved baseline',
                  approverLabel: 'Sponsor and on-site approval threshold',
                  evidenceLabel:
                      'Variance reason, tradeoff, funding source, sponsor note',
                ),
                ProjectSpendAuthorityRule(
                  id: 'venue-fit-out-petty-cash',
                  title: 'Project float authority',
                  detail:
                      'Define float, expense owner, and approval policy before delegated petty cash opens.',
                  band: ProjectSpendAuthorityBand.pettyCash,
                  level: ProjectSpendAuthorityLevel.guarded,
                  icon: Icons.payments_outlined,
                  thresholdLabel: 'Float not configured',
                  approverLabel: 'Owner needed',
                  evidenceLabel:
                      'Receipt, purpose, custodian, reconciliation date',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
