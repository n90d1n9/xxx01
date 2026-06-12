import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_budget_overview_service.dart';
import '../services/project_budget_pulse_service.dart';
import '../services/project_expense_intake_service.dart';
import '../services/project_finance_control_service.dart';

/// Expense intake panel for petty cash, reimbursements, vendor spend, and exceptions.
class ProjectExpenseIntakePanel extends StatelessWidget {
  const ProjectExpenseIntakePanel({
    required this.summary,
    this.maxRoutes = 4,
    super.key,
  });

  final ProjectExpenseIntakeSummary summary;
  final int maxRoutes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleRoutes = summary.routes.take(maxRoutes).toList();

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
              title: 'Routes',
              value: summary.routeCount.toString(),
              icon: Icons.call_split_outlined,
              accentColor: colorScheme.primary,
              helper: 'Intake paths',
            ),
            AppMetricGridItem(
              title: 'Ready',
              value: summary.readyCount.toString(),
              icon: Icons.verified_outlined,
              accentColor: Colors.green.shade700,
              helper: 'Can proceed',
            ),
            AppMetricGridItem(
              title: 'Setup',
              value: summary.setupNeededCount.toString(),
              icon: Icons.tune_outlined,
              accentColor:
                  summary.setupNeededCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Needs controls',
            ),
            AppMetricGridItem(
              title: 'Approval',
              value: summary.approvalRequiredCount.toString(),
              icon: Icons.approval_outlined,
              accentColor:
                  summary.approvalRequiredCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Needs sign-off',
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleRoutes.length; index++) ...[
          _ExpenseIntakeRouteTile(route: visibleRoutes[index]),
          if (index != visibleRoutes.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Route tile with evidence and approval guidance for one expense path.
class _ExpenseIntakeRouteTile extends StatelessWidget {
  const _ExpenseIntakeRouteTile({required this.route});

  final ProjectExpenseIntakeRoute route;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final routeColor = route.level.color(colorScheme);

    return AppInfoRow(
      title: route.title,
      subtitle:
          '${route.detail} Evidence: ${route.evidenceLabel}. Approval: ${route.approvalLabel}.',
      icon: route.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: routeColor.withValues(alpha: 0.12),
      iconForegroundColor: routeColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: route.level.label,
        icon: route.level.icon,
        color: routeColor,
        maxWidth: 112,
      ),
    );
  }
}

@Preview(name: 'Project expense intake panel')
Widget projectExpenseIntakePanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 620,
          child: ProjectExpenseIntakePanel(
            summary: ProjectExpenseIntakeSummary(
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
              routes: const [
                ProjectExpenseIntakeRoute(
                  id: 'venue-fit-out-budget-exception',
                  title: 'Prepare spend exception',
                  detail:
                      '74% budget used against 58% progress (+16 pts). Capture tradeoff and sponsor decision.',
                  kind: ProjectExpenseIntakeKind.budgetException,
                  level: ProjectExpenseIntakeLevel.approvalRequired,
                  icon: Icons.account_balance_wallet_outlined,
                  evidenceLabel:
                      'Variance reason, tradeoff, funding source, sponsor note',
                  approvalLabel: 'On-site approval threshold',
                ),
                ProjectExpenseIntakeRoute(
                  id: 'venue-fit-out-petty-cash',
                  title: 'Configure project float',
                  detail:
                      'Define limit, custodian, and reconciliation cadence before petty-cash requests open.',
                  kind: ProjectExpenseIntakeKind.pettyCash,
                  level: ProjectExpenseIntakeLevel.setupNeeded,
                  icon: Icons.payments_outlined,
                  evidenceLabel:
                      'Receipt, purpose, custodian, reconciliation date',
                  approvalLabel: 'On-site approval threshold',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
