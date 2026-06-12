import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/features/finance/accounting/accounting_features.dart';
import 'package:kaysir/features/finance/accounting/accounting_path.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_catalog.dart';

void main() {
  test(
    'accounting feature exposes every operational screen in the sidebar',
    () {
      final accounting = AccountingFeatures().registerScreens().single;
      final leafRoutes = _leafRoutes(accounting.items);
      final routes = {for (final route in leafRoutes) route.name: route};
      final routePaths = leafRoutes.map((route) => route.path).toSet();
      final expectedPaths =
          accountingMenuDestinations
              .map((destination) => destination.path)
              .toSet();
      final destinationsByName = {
        for (final destination in accountingMenuDestinations)
          destination.name: destination,
      };

      expect(accounting.name, 'Accounting');
      expect(accounting.position, contains(MenuPosition.sidebar));
      expect(
        accounting.items.map((route) => route.name),
        containsAll([
          'Accounting Workspace',
          'Accountant Workspace',
          'Controller Workspace',
          'Tax Workspace',
          'Auditor Workspace',
          'Close & Ledger',
          'Reconciliation',
          'Financial Reporting',
          'Payables',
          'Receivables',
        ]),
      );
      expect(routePaths, expectedPaths);

      expect(routes['Accounting Workspace']?.path, AccountingPath.workspace);
      expect(
        routes['Accountant Workspace']?.path,
        AccountingPath.workspaceAccountant,
      );
      expect(
        routes['Controller Workspace']?.path,
        AccountingPath.workspaceController,
      );
      expect(routes['Tax Workspace']?.path, AccountingPath.workspaceTax);
      expect(
        routes['Auditor Workspace']?.path,
        AccountingPath.workspaceAuditor,
      );
      expect(routes['Accounting Policy']?.path, AccountingPath.policy);
      expect(routes['Chart of Accounts']?.path, AccountingPath.chartOfAccounts);
      expect(routes['Journal Approval']?.path, AccountingPath.journalApproval);
      expect(routes['Period Close']?.path, AccountingPath.periodClose);
      expect(routes['General Ledger']?.path, AccountingPath.gl);
      expect(routes['Trial Balance']?.path, AccountingPath.trialBalance);
      expect(routes['Journal Adjustment']?.path, AccountingPath.adjustment);
      expect(routes['Entry History']?.path, AccountingPath.entryHistory);
      expect(
        routes['Bank Reconciliation']?.path,
        AccountingPath.bankReconciliation,
      );
      expect(
        routes['Payable Reconciliation']?.path,
        AccountingPath.payableReconciliation,
      );
      expect(
        routes['Receivable Reconciliation']?.path,
        AccountingPath.receivableReconciliation,
      );
      expect(routes['Financial Statements']?.path, AccountingPath.finStatement);
      expect(routes['Report Pack']?.path, AccountingPath.reportPack);
      expect(
        routes['Management Measures']?.path,
        AccountingPath.managementMeasures,
      );
      expect(
        routes['Management Checklist']?.path,
        AccountingPath.managementMeasuresReleaseChecklist,
      );
      expect(
        routes['Management Approval']?.path,
        AccountingPath.managementMeasuresApproval,
      );
      expect(
        routes['Management Reconciliation']?.path,
        AccountingPath.managementMeasuresReconciliation,
      );
      expect(
        routes['Management Export Evidence']?.path,
        AccountingPath.managementMeasuresExportEvidence,
      );
      expect(
        routes['Management Audit']?.path,
        AccountingPath.managementMeasuresAudit,
      );
      expect(routes['Financial Notes']?.path, AccountingPath.financialNotes);
      expect(routes['Report Release']?.path, AccountingPath.reportRelease);
      expect(
        routes['Release Sign-off']?.path,
        AccountingPath.reportReleaseSignOff,
      );
      expect(
        routes['Release Evidence']?.path,
        AccountingPath.reportReleaseEvidence,
      );
      expect(
        routes['Release Distribution']?.path,
        AccountingPath.reportReleaseDistribution,
      );
      expect(
        routes['Release Archive']?.path,
        AccountingPath.reportReleaseArchive,
      );
      expect(
        routes['Release Retention']?.path,
        AccountingPath.reportReleaseRetention,
      );
      expect(
        routes['Release Filing']?.path,
        AccountingPath.reportReleaseStatutoryFiling,
      );
      expect(routes['Profit & Loss']?.path, AccountingPath.profitLoss);
      expect(routes['Balance Sheet']?.path, AccountingPath.balanceSheet);
      expect(routes['Cash Flow']?.path, AccountingPath.cashFlow);
      expect(routes['Account Payable']?.path, AccountingPath.accPayable);
      expect(routes['Vendors']?.path, AccountingPath.vendors);
      expect(routes['Account Receivable']?.path, AccountingPath.accReceivable);
      expect(routes['Customers']?.path, AccountingPath.customers);

      for (final route in leafRoutes) {
        final destination = destinationsByName[route.name];

        expect(route.position, contains(MenuPosition.sidebar));
        expect(route.path, isNotNull, reason: '${route.name} path');
        if (destination?.registerRoute ?? true) {
          expect(route.pageBuilder, isNotNull, reason: '${route.name} route');
        } else {
          expect(route.pageBuilder, isNull, reason: '${route.name} shortcut');
          expect(route.basePath, destination?.routePath);
        }
      }
    },
  );
}

List<FeatureRoutes> _leafRoutes(List<FeatureRoutes> routes) {
  return [
    for (final route in routes)
      if (route.items.isEmpty) route else ..._leafRoutes(route.items),
  ];
}
