import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_clearance_checklist.dart';

void main() {
  test('summarizes readiness and next open clearance step', () {
    final checklist = AccountingWorkspaceWorkQueueClearanceChecklist(
      steps: [
        _step(
          title: 'Owner acknowledgement',
          status: AccountingWorkspaceWorkQueueClearanceStatus.ready,
        ),
        _step(
          title: 'Evidence pack',
          status: AccountingWorkspaceWorkQueueClearanceStatus.waiting,
        ),
        _step(
          title: 'Release or close gate',
          status: AccountingWorkspaceWorkQueueClearanceStatus.blocked,
        ),
      ],
    );

    expect(checklist.stepCount, 3);
    expect(checklist.readinessPercent, 33);
    expect(checklist.readinessLabel, 'Blocked clearance');
    expect(checklist.nextOpenStep?.title, 'Release or close gate');
    expect(checklist.nextActionLabel, 'Next: Release or close gate');
    expect(
      checklist.clearanceBrief,
      contains('Clearance readiness: Blocked clearance (33%)'),
    );
    expect(
      checklist.clearanceBrief,
      contains('Summary: 1 ready / 1 waiting / 1 blocked'),
    );
    expect(
      checklist.clearanceBrief,
      contains('3. Release or close gate - Blocked - Controller'),
    );
  });

  test('reports ready state when all clearance steps are ready', () {
    final checklist = AccountingWorkspaceWorkQueueClearanceChecklist(
      steps: [
        _step(
          title: 'Owner acknowledgement',
          status: AccountingWorkspaceWorkQueueClearanceStatus.ready,
        ),
        _step(
          title: 'Evidence pack',
          status: AccountingWorkspaceWorkQueueClearanceStatus.ready,
        ),
      ],
    );

    expect(checklist.readinessPercent, 100);
    expect(checklist.readinessLabel, 'Clearance ready');
    expect(checklist.nextOpenStep, isNull);
    expect(checklist.nextActionLabel, 'All clearance steps ready');
    expect(
      checklist.clearanceBrief,
      contains('Next action: All clearance steps ready'),
    );
  });
}

AccountingWorkspaceWorkQueueClearanceStep _step({
  required String title,
  required AccountingWorkspaceWorkQueueClearanceStatus status,
}) {
  return AccountingWorkspaceWorkQueueClearanceStep(
    id: title.toLowerCase().replaceAll(' ', '-'),
    title: title,
    ownerLabel: 'Controller',
    evidenceLabel: 'Evidence support',
    status: status,
  );
}
