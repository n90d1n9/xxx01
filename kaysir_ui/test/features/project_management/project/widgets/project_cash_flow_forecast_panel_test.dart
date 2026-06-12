import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_overview_service.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_pulse_service.dart';
import 'package:kaysir/features/project_management/project/services/project_cash_flow_forecast_service.dart';
import 'package:kaysir/features/project_management/project/services/project_cost_structure_service.dart';
import 'package:kaysir/features/project_management/project/services/project_expense_intake_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_control_service.dart';
import 'package:kaysir/features/project_management/project/services/project_spend_authority_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_cash_flow_forecast_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('cash-flow forecast panel renders funding windows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 780,
            child: ProjectCashFlowForecastPanel(
              summary: ProjectCashFlowForecastSummary(
                projectId: 'venue-fit-out',
                projectName: 'Venue Fit Out',
                asOfDate: DateTime(2026, 6, 9),
                budgetUsed: 0.74,
                projectedAtCompletion: 1.28,
                costStructure: _costStructure(),
                spendAuthority: _spendAuthority(),
                windows: [
                  ProjectCashFlowWindow(
                    id: 'venue-fit-out-active-cash-flow',
                    title: 'Active funding window',
                    detail:
                        'Release near-term budget only after current spend evidence and authority checks are complete.',
                    kind: ProjectCashFlowWindowKind.active,
                    level: ProjectCashFlowForecastLevel.constrained,
                    icon: Icons.payments_outlined,
                    startDate: DateTime(2026, 6, 9),
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
                    startDate: DateTime(2026, 6, 9),
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

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Cash flow constrained'), findsOneWidget);
    expect(find.text('Runway'), findsOneWidget);
    expect(find.text('Projected'), findsOneWidget);
    expect(find.text('Windows'), findsOneWidget);
    expect(find.text('Attention'), findsOneWidget);
    expect(find.text('Active funding window (9%)'), findsOneWidget);
    expect(find.text('Reserve guardrail (15%)'), findsOneWidget);
    expect(find.textContaining('Window: Jun 9 - Jun 21'), findsOneWidget);
    expect(find.textContaining('Gate: Pilot'), findsOneWidget);
  });
}

ProjectCostStructureSummary _costStructure() {
  return const ProjectCostStructureSummary(
    projectId: 'venue-fit-out',
    projectName: 'Venue Fit Out',
    profileLabel: 'Event production',
    budgetPaceLabel: 'Spend ahead of progress',
    lines: [],
  );
}

ProjectSpendAuthoritySummary _spendAuthority() {
  final financeSummary = ProjectFinanceControlSummary(
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
  );

  return ProjectSpendAuthoritySummary(
    projectId: 'venue-fit-out',
    projectName: 'Venue Fit Out',
    financeSummary: financeSummary,
    expenseIntake: ProjectExpenseIntakeSummary(
      projectId: 'venue-fit-out',
      projectName: 'Venue Fit Out',
      financeSummary: financeSummary,
      routes: const [],
    ),
    rules: const [],
  );
}
