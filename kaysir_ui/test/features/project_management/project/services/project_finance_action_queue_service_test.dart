import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_action_queue_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_ledger_summary_service.dart';

void main() {
  test(
    'builds routine and watch actions for active retail finance records',
    () {
      final summary = buildProjectFinanceLedgerSummary(
        projectId: 'retail-modernization',
      );

      final queue = buildProjectFinanceActionQueue(summary);

      expect(queue.projectId, 'retail-modernization');
      expect(queue.actionCount, 3);
      expect(queue.criticalCount, 0);
      expect(queue.watchCount, 2);
      expect(queue.routineCount, 1);
      expect(queue.ownerCount, 3);
      expect(queue.title, 'Finance follow-up ready');
      expect(
        queue.actions.map((action) => action.title),
        containsAll([
          'Reconcile project float: Pilot store project float',
          'Review evidence: Training delivery proof',
          'Prepare payment proof: Pilot branch training materials',
        ]),
      );
    },
  );

  test('prioritizes blocked finance records as critical actions', () {
    final summary = buildProjectFinanceLedgerSummary(
      projectId: 'warehouse-automation',
    );

    final queue = buildProjectFinanceActionQueue(summary);

    expect(queue.actionCount, 4);
    expect(queue.criticalCount, 4);
    expect(queue.watchCount, 0);
    expect(queue.title, 'Finance blocks need action');
    expect(queue.primaryAction?.title, contains('Unblock'));
    expect(
      queue.primaryAction?.severity,
      ProjectFinanceActionSeverity.critical,
    );
  });
}
