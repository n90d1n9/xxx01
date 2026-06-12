import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/finance/accounting/accounting_path.dart';
import 'package:kaysir/features/finance/accounting/repositories/accounting_workspace_recent_view_repository.dart';
import 'package:kaysir/features/finance/accounting/screens/acc_payable/acc_payable_large.dart';
import 'package:kaysir/features/finance/accounting/screens/acc_payable/vendor_manage_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/acc_receivable/acc_receivable_large.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_catalog.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_detail_section.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/screens/accounting_navigation_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/accounting_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/accounting_policy_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/chart_of_accounts_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/customer_list_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/entry_history_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/fin_statement_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/financial_report_notes_center_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/financial_report_release_center_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/financial_report_management_measure_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/gl_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/journal_approval_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/period_close_workflow_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/reconciliation_center_screen.dart';
import 'package:kaysir/features/finance/accounting/screens/trial_balance_screen.dart';
import 'package:ky_core/core/features/feature_routes.dart';
import 'package:ky_core/core/features/features_base.dart';

class AccountingFeatures extends FeaturesBase {
  @override
  List<FeatureRoutes> registerScreens() => [
    FeatureRoutes(
      name: 'Accounting',
      icon: 'account_balance',
      items: [
        _featureForDestination(accountingWorkspaceDestination),
        ...accountingWorkspaceRoleDestinations.map(_featureForDestination),
        ...accountingMenuSections.map(_featureForSection),
      ],
    ),
  ];

  static FeatureRoutes _featureForSection(AccountingMenuSection section) {
    return FeatureRoutes(
      name: section.name,
      subtitle: section.subtitle,
      icon: section.icon,
      position: const [MenuPosition.sidebar, MenuPosition.node],
      items: section.destinations.map(_featureForDestination).toList(),
    );
  }

  static FeatureRoutes _featureForDestination(
    AccountingMenuDestination destination,
  ) {
    return FeatureRoutes(
      name: destination.name,
      subtitle: destination.subtitle,
      path: destination.path,
      basePath:
          destination.routePath == destination.path
              ? null
              : destination.routePath,
      icon: destination.icon,
      pageBuilder:
          destination.registerRoute
              ? _pageBuilderFor(destination.routePath)
              : null,
    );
  }

  static Page<dynamic> Function(BuildContext, GoRouterState) _pageBuilderFor(
    String path,
  ) {
    switch (path) {
      case AccountingPath.workspace:
        return (BuildContext context, GoRouterState state) {
          final rolePreset = accountingWorkspaceRolePresetFromStorage(
            state.uri.queryParameters[AccountingPath.workspaceRoleParam],
          );

          return MaterialPage(
            child: AccountingNavigationScreen(
              initialQuery:
                  state.uri.queryParameters[AccountingPath
                      .workspaceSearchParam] ??
                  '',
              initialScope: accountingMenuSearchScopeFromQuery(
                state.uri.queryParameters[AccountingPath.workspaceScopeParam],
              ),
              initialRolePreset:
                  rolePreset ?? AccountingWorkspaceRolePreset.accountant,
              initialWorkQueueFocus: accountingWorkspaceWorkQueueFocusFromQuery(
                state.uri.queryParameters[AccountingPath.workspaceQueueParam],
              ),
              initialWorkQueueSort: accountingWorkspaceWorkQueueSortFromQuery(
                state.uri.queryParameters[AccountingPath.workspaceSortParam],
              ),
              initialWorkQueueOwnerFilter:
                  state.uri.queryParameters[AccountingPath.workspaceOwnerParam],
              initialSelectedWorkQueueId:
                  state.uri.queryParameters[AccountingPath.workspaceWorkParam],
              initialSelectedWorkQueueDetailSection:
                  accountingWorkspaceWorkQueueDetailSectionFromQuery(
                    state.uri.queryParameters[AccountingPath
                        .workspaceWorkDetailParam],
                  ),
              preferInitialRolePreset: rolePreset != null,
              preferInitialWorkQueueFocus: state.uri.queryParameters
                  .containsKey(AccountingPath.workspaceQueueParam),
              preferInitialWorkQueueSort: state.uri.queryParameters.containsKey(
                AccountingPath.workspaceSortParam,
              ),
              recentViewRepository:
                  AccountingWorkspaceRecentViewRepository.local(),
            ),
          );
        };
      case AccountingPath.policy:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: AccountingPolicyScreen());
      case AccountingPath.chartOfAccounts:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: ChartOfAccountsScreen());
      case AccountingPath.journalApproval:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: JournalApprovalScreen());
      case AccountingPath.periodClose:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: PeriodCloseWorkflowScreen());
      case AccountingPath.gl:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: GLScreen());
      case AccountingPath.trialBalance:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: TrialBalanceScreen());
      case AccountingPath.adjustment:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: ResponsiveAccountingScreen());
      case AccountingPath.entryHistory:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: EntryHistoryScreen());
      case AccountingPath.finStatement:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: FinancialStatementsScreen());
      case AccountingPath.reportPack:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(
              child: FinancialStatementTypeScreen(statementType: 'reportPack'),
            );
      case AccountingPath.managementMeasures:
        return (BuildContext context, GoRouterState state) => MaterialPage(
          child: FinancialReportManagementMeasureScreen(
            initialFocus: financialReportManagementMeasureFocusFromQuery(
              state.uri.queryParameters[AccountingPath
                  .managementMeasuresFocusParam],
            ),
          ),
        );
      case AccountingPath.financialNotes:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: FinancialReportNotesCenterScreen());
      case AccountingPath.reportRelease:
        return (BuildContext context, GoRouterState state) => MaterialPage(
          child: FinancialReportReleaseCenterScreen(
            initialFocus: financialReportReleaseCenterFocusFromQuery(
              state.uri.queryParameters[AccountingPath.reportReleaseFocusParam],
            ),
          ),
        );
      case AccountingPath.profitLoss:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(
              child: FinancialStatementTypeScreen(
                statementType: 'profitAndLoss',
              ),
            );
      case AccountingPath.balanceSheet:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(
              child: FinancialStatementTypeScreen(
                statementType: 'balanceSheet',
              ),
            );
      case AccountingPath.cashFlow:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(
              child: FinancialStatementTypeScreen(statementType: 'cashFlow'),
            );
      case AccountingPath.bankReconciliation:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(
              child: ReconciliationCenterScreen(
                focus: AccountingReconciliationFocus.bank,
              ),
            );
      case AccountingPath.payableReconciliation:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(
              child: ReconciliationCenterScreen(
                focus: AccountingReconciliationFocus.payable,
              ),
            );
      case AccountingPath.receivableReconciliation:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(
              child: ReconciliationCenterScreen(
                focus: AccountingReconciliationFocus.receivable,
              ),
            );
      case AccountingPath.accPayable:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: AccountsPayableDashboard());
      case AccountingPath.vendors:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: VendorManagementScreen());
      case AccountingPath.accReceivable:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: ARDashboardScreen());
      case AccountingPath.customers:
        return (BuildContext context, GoRouterState state) =>
            const MaterialPage(child: CustomerListScreen());
    }

    throw UnsupportedError('Missing accounting route builder for $path');
  }
}
