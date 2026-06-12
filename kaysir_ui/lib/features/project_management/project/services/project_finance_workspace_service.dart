import '../models/project_portfolio_item.dart';
import 'project_budget_overview_service.dart';
import 'project_cash_flow_forecast_service.dart';
import 'project_cost_structure_service.dart';
import 'project_expense_intake_service.dart';
import 'project_finance_control_service.dart';
import 'project_finance_ledger_summary_service.dart';
import 'project_finance_reconciliation_service.dart';
import 'project_spend_authority_service.dart';

/// Aggregates reusable finance summaries for a selected project workspace.
class ProjectFinanceWorkspaceSummary {
  const ProjectFinanceWorkspaceSummary({
    required this.project,
    required this.budgetOverview,
    required this.financeLedger,
    required this.financeControls,
    required this.costStructure,
    required this.expenseIntake,
    required this.spendAuthority,
    required this.cashFlowForecast,
    required this.financeReconciliation,
  });

  final ProjectPortfolioItem project;
  final ProjectBudgetOverview budgetOverview;
  final ProjectFinanceLedgerSummary financeLedger;
  final ProjectFinanceControlSummary financeControls;
  final ProjectCostStructureSummary costStructure;
  final ProjectExpenseIntakeSummary expenseIntake;
  final ProjectSpendAuthoritySummary spendAuthority;
  final ProjectCashFlowForecastSummary cashFlowForecast;
  final ProjectFinanceReconciliationSummary financeReconciliation;
}

/// Builds the finance workspace dependency graph from a portfolio project.
ProjectFinanceWorkspaceSummary buildProjectFinanceWorkspaceSummary(
  ProjectPortfolioItem project,
) {
  final budgetOverview = buildProjectBudgetOverview(project);
  final financeLedger = buildProjectFinanceLedgerSummary(projectId: project.id);
  final financeControls = buildProjectFinanceControlSummary(project);
  final costStructure = buildProjectCostStructureSummary(
    project,
    financeSummary: financeControls,
  );
  final expenseIntake = buildProjectExpenseIntakeSummary(project);
  final spendAuthority = buildProjectSpendAuthoritySummary(
    project,
    expenseIntake: expenseIntake,
  );
  final cashFlowForecast = buildProjectCashFlowForecastSummary(
    project,
    costStructure: costStructure,
    spendAuthority: spendAuthority,
  );
  final financeReconciliation = buildProjectFinanceReconciliationSummary(
    project,
    expenseIntake: expenseIntake,
    spendAuthority: spendAuthority,
    cashFlowForecast: cashFlowForecast,
  );

  return ProjectFinanceWorkspaceSummary(
    project: project,
    budgetOverview: budgetOverview,
    financeLedger: financeLedger,
    financeControls: financeControls,
    costStructure: costStructure,
    expenseIntake: expenseIntake,
    spendAuthority: spendAuthority,
    cashFlowForecast: cashFlowForecast,
    financeReconciliation: financeReconciliation,
  );
}
