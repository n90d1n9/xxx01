import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_overview_service.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_pulse_service.dart';
import 'package:kaysir/features/project_management/project/services/project_expense_intake_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_control_service.dart';
import 'package:kaysir/features/project_management/project/services/project_spend_authority_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_spend_authority_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('spend authority panel renders approval bands', (tester) async {
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 780,
            child: ProjectSpendAuthorityPanel(
              summary: ProjectSpendAuthoritySummary(
                projectId: 'venue-fit-out',
                projectName: 'Venue Fit Out',
                financeSummary: financeSummary,
                expenseIntake: ProjectExpenseIntakeSummary(
                  projectId: 'venue-fit-out',
                  projectName: 'Venue Fit Out',
                  financeSummary: financeSummary,
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

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Spend escalation required'), findsOneWidget);
    expect(find.text('Bands'), findsOneWidget);
    expect(find.text('Delegated'), findsWidgets);
    expect(find.text('Guarded'), findsWidgets);
    expect(find.text('Escalate'), findsWidgets);
    expect(find.text('Budget exception authority'), findsOneWidget);
    expect(find.text('Project float authority'), findsOneWidget);
    expect(
      find.textContaining('Threshold: Above approved baseline'),
      findsOneWidget,
    );
    expect(find.textContaining('Approver: Sponsor'), findsOneWidget);
  });
}
