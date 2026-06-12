import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/screens/project_finance_screen.dart';
import 'package:kaysir/features/project_management/project/widgets/project_budget_overview_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_cash_flow_forecast_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_cost_structure_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_expense_intake_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_action_queue_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_closeout_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_control_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_handoff_pack_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_ledger_records_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_ledger_snapshot_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_portfolio_triage_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_reconciliation_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_scenario_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_workspace_panels.dart';
import 'package:kaysir/features/project_management/project/widgets/project_spend_authority_panel.dart';

void main() {
  testWidgets('project finance screen renders reusable finance panels', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectFinanceScreen(initialProjectId: 'retail-modernization'),
      ),
    );

    expect(find.text('Project Finance'), findsWidgets);
    expect(
      find.textContaining('Retail Modernization finance workspace'),
      findsOneWidget,
    );
    expect(find.byType(ProjectFinanceWorkspacePanels), findsOneWidget);
    expect(find.byType(ProjectFinancePortfolioTriagePanel), findsOneWidget);
    expect(find.byType(ProjectFinanceActionQueuePanel), findsOneWidget);
    expect(find.byType(ProjectFinanceScenarioPanel), findsOneWidget);
    expect(find.byType(ProjectFinanceLedgerRecordsPanel), findsOneWidget);
    expect(find.byType(ProjectFinanceLedgerSnapshotPanel), findsOneWidget);
    expect(find.byType(ProjectBudgetOverviewPanel), findsOneWidget);
    expect(find.byType(ProjectCostStructurePanel), findsOneWidget);
    expect(find.byType(ProjectFinanceControlPanel), findsOneWidget);
    expect(find.byType(ProjectSpendAuthorityPanel), findsOneWidget);
    expect(find.byType(ProjectCashFlowForecastPanel), findsOneWidget);
    expect(find.byType(ProjectExpenseIntakePanel), findsOneWidget);
    expect(find.byType(ProjectFinanceReconciliationPanel), findsOneWidget);
    expect(find.byType(ProjectFinanceCloseoutPanel), findsOneWidget);
    expect(find.byType(ProjectFinanceHandoffPackPanel), findsOneWidget);
    expect(find.text('Portfolio Finance Triage'), findsOneWidget);
    expect(find.text('Finance Action Queue'), findsOneWidget);
    expect(find.text('Budget Scenarios'), findsOneWidget);
    expect(find.text('Ledger Records'), findsOneWidget);
    expect(find.text('Finance Ledger'), findsOneWidget);
    expect(find.text('Budget Overview'), findsOneWidget);
    expect(find.text('Cost Structure'), findsOneWidget);
    expect(find.text('Finance Controls'), findsOneWidget);
    expect(find.text('Spend Authority'), findsOneWidget);
    expect(find.text('Cash Flow Forecast'), findsOneWidget);
    expect(find.text('Expense Intake'), findsOneWidget);
    expect(find.text('Finance Reconciliation'), findsOneWidget);
    expect(find.text('Closeout Readiness'), findsOneWidget);
    expect(find.text('Finance Handoff Pack'), findsOneWidget);
  });

  testWidgets('project finance screen can switch project from triage tiles', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectFinanceScreen(initialProjectId: 'retail-modernization'),
      ),
    );

    await tester.ensureVisible(find.text('Warehouse Automation'));
    await tester.tap(find.text('Warehouse Automation').first);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Warehouse Automation finance workspace'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Retail Modernization finance workspace'),
      findsNothing,
    );
  });

  testWidgets('project finance screen can switch selected project', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectFinanceScreen(initialProjectId: 'retail-modernization'),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Warehouse Automation').last);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Warehouse Automation finance workspace'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Retail Modernization finance workspace'),
      findsNothing,
    );
  });

  testWidgets('project finance screen handles empty project portfolios', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectFinanceScreen(repository: _EmptyProjectRepository()),
      ),
    );

    expect(find.text('No projects available'), findsOneWidget);
    expect(
      find.textContaining('Add a project before reviewing budgets'),
      findsOneWidget,
    );
  });
}

/// Test repository that allows the finance screen empty state to be verified.
class _EmptyProjectRepository extends ProjectPortfolioRepository {
  const _EmptyProjectRepository();

  @override
  List<ProjectPortfolioItem> fetchProjects() => const [];
}
