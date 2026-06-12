import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_ledger_summary_service.dart';

void main() {
  test('finance ledger summary aggregates project records', () {
    final summary = buildProjectFinanceLedgerSummary(
      projectId: 'retail-modernization',
    );

    expect(summary.level, ProjectFinanceLedgerLevel.active);
    expect(summary.title, 'Ledger active');
    expect(summary.budgetLineCount, 3);
    expect(summary.plannedAmount, 255000000);
    expect(summary.committedAmount, 150000000);
    expect(summary.spentAmount, 128000000);
    expect(summary.openExpenseCount, 1);
    expect(summary.openPettyCashCount, 1);
    expect(summary.openEvidenceCount, 1);
    expect(summary.openItemCount, 3);
    expect(
      summary.highestUtilizationLine?.title,
      'Checkout and inventory systems',
    );
  });

  test('finance ledger summary flags blocked records for attention', () {
    final summary = buildProjectFinanceLedgerSummary(
      projectId: 'warehouse-automation',
    );

    expect(summary.level, ProjectFinanceLedgerLevel.attention);
    expect(summary.title, 'Ledger needs attention');
    expect(summary.openExpenseCount, 1);
    expect(summary.openPettyCashCount, 1);
    expect(summary.openApprovalCount, 1);
    expect(summary.openEvidenceCount, 1);
    expect(summary.openItemCount, 4);
  });
}
