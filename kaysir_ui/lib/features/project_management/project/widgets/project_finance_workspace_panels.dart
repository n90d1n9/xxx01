import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_finance_workspace_service.dart';
import 'project_finance_action_queue_panel.dart';
import 'project_budget_overview_panel.dart';
import 'project_cash_flow_forecast_panel.dart';
import 'project_cost_structure_panel.dart';
import 'project_expense_intake_panel.dart';
import 'project_finance_control_panel.dart';
import 'project_finance_closeout_panel.dart';
import 'project_finance_handoff_pack_panel.dart';
import 'project_finance_ledger_records_panel.dart';
import 'project_finance_ledger_snapshot_panel.dart';
import 'project_finance_reconciliation_panel.dart';
import 'project_finance_scenario_panel.dart';
import 'project_spend_authority_panel.dart';

/// Responsive finance workspace layout composed from reusable finance panels.
class ProjectFinanceWorkspacePanels extends StatelessWidget {
  const ProjectFinanceWorkspacePanels({required this.summary, super.key});

  final ProjectFinanceWorkspaceSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 980) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _financeActionQueuePanel(),
              const SizedBox(height: 16),
              _financeScenarioPanel(),
              const SizedBox(height: 16),
              _ledgerRecordsPanel(),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _PanelColumn(
                      children: [
                        _ledgerPanel(),
                        _costStructurePanel(),
                        _spendAuthorityPanel(),
                        _financeReconciliationPanel(),
                        _financeCloseoutPanel(),
                        _financeHandoffPackPanel(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _PanelColumn(
                      children: [
                        _budgetOverviewPanel(),
                        _financeControlsPanel(),
                        _cashFlowForecastPanel(),
                        _expenseIntakePanel(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return _PanelColumn(
          children: [
            _financeActionQueuePanel(),
            _financeScenarioPanel(),
            _ledgerRecordsPanel(),
            _ledgerPanel(),
            _budgetOverviewPanel(),
            _costStructurePanel(),
            _financeControlsPanel(),
            _spendAuthorityPanel(),
            _cashFlowForecastPanel(),
            _expenseIntakePanel(),
            _financeReconciliationPanel(),
            _financeCloseoutPanel(),
            _financeHandoffPackPanel(),
          ],
        );
      },
    );
  }

  Widget _financeActionQueuePanel() {
    return AppContentPanel(
      title: 'Finance Action Queue',
      subtitle:
          'Prioritized next steps for blocks, approvals, petty cash, and evidence',
      leadingIcon: Icons.pending_actions_outlined,
      child: ProjectFinanceActionQueuePanel(summary: summary.financeLedger),
    );
  }

  Widget _ledgerRecordsPanel() {
    return AppContentPanel(
      title: 'Ledger Records',
      subtitle:
          'Filterable finance queue across budget, expense, cash, approvals, and evidence',
      leadingIcon: Icons.format_list_bulleted_rounded,
      child: ProjectFinanceLedgerRecordsPanel(summary: summary.financeLedger),
    );
  }

  Widget _financeScenarioPanel() {
    return AppContentPanel(
      title: 'Budget Scenarios',
      subtitle: 'Compare current pace, guarded spend, and recovery runway',
      leadingIcon: Icons.insights_outlined,
      child: ProjectFinanceScenarioPanel(summary: summary),
    );
  }

  Widget _ledgerPanel() {
    return AppContentPanel(
      title: 'Finance Ledger',
      subtitle: 'Budget lines, expenses, petty cash, approvals, and evidence',
      leadingIcon: Icons.receipt_long_outlined,
      child: ProjectFinanceLedgerSnapshotPanel(summary: summary.financeLedger),
    );
  }

  Widget _budgetOverviewPanel() {
    return AppContentPanel(
      title: 'Budget Overview',
      subtitle: 'Spend pace, progress gap, and remaining runway',
      leadingIcon: Icons.account_balance_wallet_outlined,
      child: ProjectBudgetOverviewPanel(overview: summary.budgetOverview),
    );
  }

  Widget _costStructurePanel() {
    return AppContentPanel(
      title: 'Cost Structure',
      subtitle: 'Domain-adaptive baseline categories and controls',
      leadingIcon: Icons.pie_chart_outline_rounded,
      child: ProjectCostStructurePanel(summary: summary.costStructure),
    );
  }

  Widget _financeControlsPanel() {
    return AppContentPanel(
      title: 'Finance Controls',
      subtitle: 'Petty cash, expense ownership, and approvals',
      leadingIcon: Icons.rule_folder_outlined,
      child: ProjectFinanceControlPanel(summary: summary.financeControls),
    );
  }

  Widget _spendAuthorityPanel() {
    return AppContentPanel(
      title: 'Spend Authority',
      subtitle: 'Delegation, thresholds, and escalation routes',
      leadingIcon: Icons.verified_user_outlined,
      child: ProjectSpendAuthorityPanel(summary: summary.spendAuthority),
    );
  }

  Widget _cashFlowForecastPanel() {
    return AppContentPanel(
      title: 'Cash Flow Forecast',
      subtitle: 'Funding windows, release gates, and reserve runway',
      leadingIcon: Icons.query_stats_outlined,
      child: ProjectCashFlowForecastPanel(summary: summary.cashFlowForecast),
    );
  }

  Widget _expenseIntakePanel() {
    return AppContentPanel(
      title: 'Expense Intake',
      subtitle: 'Petty cash, reimbursements, vendors, and exceptions',
      leadingIcon: Icons.request_quote_outlined,
      child: ProjectExpenseIntakePanel(summary: summary.expenseIntake),
    );
  }

  Widget _financeReconciliationPanel() {
    return AppContentPanel(
      title: 'Finance Reconciliation',
      subtitle: 'Receipts, approvals, vendor proof, and closeout',
      leadingIcon: Icons.fact_check_outlined,
      child: ProjectFinanceReconciliationPanel(
        summary: summary.financeReconciliation,
      ),
    );
  }

  Widget _financeCloseoutPanel() {
    return AppContentPanel(
      title: 'Closeout Readiness',
      subtitle:
          'Checklist for ledger, evidence, budget, authority, and funding gates',
      leadingIcon: Icons.task_alt_outlined,
      child: ProjectFinanceCloseoutPanel(summary: summary),
    );
  }

  Widget _financeHandoffPackPanel() {
    return AppContentPanel(
      title: 'Finance Handoff Pack',
      subtitle: 'Audit and client-ready package sections with a copyable brief',
      leadingIcon: Icons.inventory_2_outlined,
      child: ProjectFinanceHandoffPackPanel(summary: summary),
    );
  }
}

/// Vertical panel stack with consistent spacing for finance workspace sections.
class _PanelColumn extends StatelessWidget {
  const _PanelColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

@Preview(name: 'Project finance workspace panels')
Widget projectFinanceWorkspacePanelsPreview() {
  final project = const ProjectPortfolioRepository().fetchProjects().first;

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectFinanceWorkspacePanels(
          summary: buildProjectFinanceWorkspaceSummary(project),
        ),
      ),
    ),
  );
}
