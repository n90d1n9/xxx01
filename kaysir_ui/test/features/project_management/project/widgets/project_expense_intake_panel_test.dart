import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_overview_service.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_pulse_service.dart';
import 'package:kaysir/features/project_management/project/services/project_expense_intake_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_control_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_expense_intake_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('expense intake panel renders routes and readiness metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 780,
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

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Expense approvals required'), findsOneWidget);
    expect(find.text('Routes'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Setup'), findsWidgets);
    expect(find.text('Approval'), findsWidgets);
    expect(find.text('Prepare spend exception'), findsOneWidget);
    expect(find.text('Configure project float'), findsOneWidget);
    expect(find.textContaining('Evidence: Variance reason'), findsOneWidget);
    expect(
      find.textContaining('Approval: On-site approval threshold'),
      findsWidgets,
    );
  });
}
