import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_path.dart';
import 'package:kaysir/features/finance/accounting/screens/financial_report_management_measure_screen.dart';

void main() {
  test('parses UKTM release checklist focus from route query', () {
    expect(
      financialReportManagementMeasureFocusFromQuery(
        AccountingPath.managementMeasuresReleaseChecklistFocus,
      ),
      FinancialReportManagementMeasureFocus.releaseChecklist,
    );
    expect(
      financialReportManagementMeasureFocusFromQuery('checklist'),
      FinancialReportManagementMeasureFocus.releaseChecklist,
    );
  });

  test('parses UKTM release checklist tile focus from route query', () {
    expect(
      financialReportManagementMeasureFocusFromQuery(
        AccountingPath.managementMeasuresApprovalFocus,
      ),
      FinancialReportManagementMeasureFocus.approvalCheck,
    );
    expect(
      financialReportManagementMeasureFocusFromQuery(
        AccountingPath.managementMeasuresReconciliationFocus,
      ),
      FinancialReportManagementMeasureFocus.reconciliationCheck,
    );
    expect(
      financialReportManagementMeasureFocusFromQuery(
        AccountingPath.managementMeasuresExportEvidenceFocus,
      ),
      FinancialReportManagementMeasureFocus.exportEvidenceCheck,
    );
  });

  test('parses UKTM audit trail focus from route query', () {
    expect(
      financialReportManagementMeasureFocusFromQuery(
        AccountingPath.managementMeasuresAuditFocus,
      ),
      FinancialReportManagementMeasureFocus.auditTrail,
    );
    expect(
      financialReportManagementMeasureFocusFromQuery('auditTrail'),
      FinancialReportManagementMeasureFocus.auditTrail,
    );
    expect(
      financialReportManagementMeasureFocusFromQuery(null),
      FinancialReportManagementMeasureFocus.register,
    );
  });

  test('builds management measures release checklist focus path', () {
    expect(
      AccountingPath.managementMeasuresWithFocus(
        AccountingPath.managementMeasuresReleaseChecklistFocus,
      ),
      '/management-measures?focus=release-checklist',
    );
    expect(
      AccountingPath.managementMeasuresWithFocus(
        AccountingPath.managementMeasuresApprovalFocus,
      ),
      '/management-measures?focus=approval',
    );
    expect(
      AccountingPath.managementMeasuresWithFocus(
        AccountingPath.managementMeasuresExportEvidenceFocus,
      ),
      '/management-measures?focus=export-evidence',
    );
  });

  test('builds management measures audit focus path', () {
    expect(
      AccountingPath.managementMeasuresWithFocus(
        AccountingPath.managementMeasuresAuditFocus,
      ),
      '/management-measures?focus=audit',
    );
  });
}
