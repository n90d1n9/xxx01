import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_budget_overview_service.dart';
import '../services/project_budget_pulse_service.dart';
import '../services/project_cash_flow_forecast_service.dart';
import '../services/project_cost_structure_service.dart';
import '../services/project_expense_intake_service.dart';
import '../services/project_finance_control_service.dart';
import '../services/project_spend_authority_service.dart';

/// Cash-flow forecast panel for funding windows, release gates, and reserve runway.
class ProjectCashFlowForecastPanel extends StatelessWidget {
  const ProjectCashFlowForecastPanel({
    required this.summary,
    this.maxWindows = 4,
    super.key,
  });

  final ProjectCashFlowForecastSummary summary;
  final int maxWindows;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleWindows = summary.windows.take(maxWindows).toList();

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
            maxWidth: 126,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Runway',
              value: '${summary.remainingBudgetPercent}%',
              icon: Icons.savings_outlined,
              accentColor:
                  summary.remainingBudgetPercent >= 20
                      ? Colors.green.shade700
                      : levelColor,
              helper: 'Budget remaining',
            ),
            AppMetricGridItem(
              title: 'Projected',
              value: '${summary.projectedAtCompletionPercent}%',
              icon: Icons.query_stats_outlined,
              accentColor:
                  summary.projectedAtCompletionPercent <= 105
                      ? Colors.green.shade700
                      : levelColor,
              helper: 'At completion',
            ),
            AppMetricGridItem(
              title: 'Windows',
              value: summary.windowCount.toString(),
              icon: Icons.view_timeline_outlined,
              accentColor: colorScheme.primary,
              helper: 'Funding gates',
            ),
            AppMetricGridItem(
              title: 'Attention',
              value: summary.constrainedWindowCount.toString(),
              icon: Icons.priority_high_rounded,
              accentColor:
                  summary.constrainedWindowCount == 0
                      ? Colors.green.shade700
                      : levelColor,
              helper: 'Watch windows',
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleWindows.length; index++) ...[
          _CashFlowWindowTile(window: visibleWindows[index]),
          if (index != visibleWindows.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Forecast window tile with dates, release share, and gate status.
class _CashFlowWindowTile extends StatelessWidget {
  const _CashFlowWindowTile({required this.window});

  final ProjectCashFlowWindow window;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final windowColor = window.level.color(colorScheme);
    final dateRange = _dateRange(window.startDate, window.endDate);

    return AppInfoRow(
      title: '${window.title} (${window.releaseSharePercent}%)',
      subtitle:
          '${window.detail} Window: $dateRange. Gate: ${window.gateLabel}.',
      icon: window.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: windowColor.withValues(alpha: 0.12),
      iconForegroundColor: windowColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: window.level.label,
        icon: window.level.icon,
        color: windowColor,
        maxWidth: 126,
      ),
    );
  }

  String _dateRange(DateTime startDate, DateTime endDate) {
    final formatter = DateFormat.MMMd();
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }
}

@Preview(name: 'Project cash-flow forecast panel')
Widget projectCashFlowForecastPanelPreview() {
  final asOfDate = DateTime(2026, 6, 9);

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 620,
          child: ProjectCashFlowForecastPanel(
            summary: ProjectCashFlowForecastSummary(
              projectId: 'venue-fit-out',
              projectName: 'Venue Fit Out',
              asOfDate: asOfDate,
              budgetUsed: 0.74,
              projectedAtCompletion: 1.28,
              costStructure: _previewCostStructure(),
              spendAuthority: _previewSpendAuthority(),
              windows: [
                ProjectCashFlowWindow(
                  id: 'venue-fit-out-active-cash-flow',
                  title: 'Active funding window',
                  detail:
                      'Release near-term budget only after spend evidence and authority checks are complete.',
                  kind: ProjectCashFlowWindowKind.active,
                  level: ProjectCashFlowForecastLevel.constrained,
                  icon: Icons.payments_outlined,
                  startDate: asOfDate,
                  endDate: DateTime(2026, 6, 21),
                  releaseShare: 0.09,
                  gateLabel: 'Pilot',
                ),
                ProjectCashFlowWindow(
                  id: 'venue-fit-out-reserve-cash-flow',
                  title: 'Reserve guardrail',
                  detail:
                      'Keep contingency visible for supplier changes or sponsor-approved exceptions.',
                  kind: ProjectCashFlowWindowKind.reserve,
                  level: ProjectCashFlowForecastLevel.watch,
                  icon: Icons.savings_outlined,
                  startDate: asOfDate,
                  endDate: DateTime(2026, 8, 7),
                  releaseShare: 0.15,
                  gateLabel: 'Reserve',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

ProjectCostStructureSummary _previewCostStructure() {
  return const ProjectCostStructureSummary(
    projectId: 'venue-fit-out',
    projectName: 'Venue Fit Out',
    profileLabel: 'Event production',
    budgetPaceLabel: 'Spend ahead of progress',
    lines: [],
  );
}

ProjectSpendAuthoritySummary _previewSpendAuthority() {
  return const ProjectSpendAuthoritySummary(
    projectId: 'venue-fit-out',
    projectName: 'Venue Fit Out',
    financeSummary: ProjectFinanceControlSummary(
      projectId: 'venue-fit-out',
      projectName: 'Venue Fit Out',
      profile: ProjectFinanceControlProfile(
        floatLabel: 'Project float',
        expenseOwnerLabel: 'Field expense owner',
        approvalLabel: 'On-site approval threshold',
      ),
      budgetOverview: ProjectBudgetOverview(
        projectId: 'venue-fit-out',
        projectName: 'Venue Fit Out',
        progress: 0.58,
        budgetUsed: 0.74,
        state: ProjectBudgetPulseState.pressure,
      ),
      attributes: [],
      signals: [],
    ),
    expenseIntake: ProjectExpenseIntakeSummary(
      projectId: 'venue-fit-out',
      projectName: 'Venue Fit Out',
      financeSummary: ProjectFinanceControlSummary(
        projectId: 'venue-fit-out',
        projectName: 'Venue Fit Out',
        profile: ProjectFinanceControlProfile(
          floatLabel: 'Project float',
          expenseOwnerLabel: 'Field expense owner',
          approvalLabel: 'On-site approval threshold',
        ),
        budgetOverview: ProjectBudgetOverview(
          projectId: 'venue-fit-out',
          projectName: 'Venue Fit Out',
          progress: 0.58,
          budgetUsed: 0.74,
          state: ProjectBudgetPulseState.pressure,
        ),
        attributes: [],
        signals: [],
      ),
      routes: [],
    ),
    rules: [],
  );
}
