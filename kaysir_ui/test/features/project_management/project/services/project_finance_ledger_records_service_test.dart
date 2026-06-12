import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_ledger_records_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_ledger_summary_service.dart';

void main() {
  test('builds filterable ledger records from finance summary', () {
    final summary = buildProjectFinanceLedgerSummary(
      projectId: 'retail-modernization',
    );

    final view = buildProjectFinanceLedgerRecordsView(summary);

    expect(view.projectId, 'retail-modernization');
    expect(view.rowCount, 7);
    expect(view.openCount, 3);
    expect(view.blockedCount, 0);
    expect(view.countFor(ProjectFinanceLedgerRecordLens.budget), 3);
    expect(view.countFor(ProjectFinanceLedgerRecordLens.expense), 1);
    expect(view.countFor(ProjectFinanceLedgerRecordLens.pettyCash), 1);
    expect(view.countFor(ProjectFinanceLedgerRecordLens.approval), 1);
    expect(view.countFor(ProjectFinanceLedgerRecordLens.evidence), 1);
    expect(view.countFor(ProjectFinanceLedgerRecordLens.openItems), 3);
    expect(
      view.rows.map((row) => row.title),
      containsAll([
        'Store operations rollout',
        'Pilot branch training materials',
        'Pilot store project float',
        'Training delivery proof',
      ]),
    );
  });
}
