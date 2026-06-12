import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_activity_action_state.dart';

void main() {
  test('tracks work queue activity action progress immutably', () {
    const initial = AccountingWorkspaceWorkQueueActivityActionState(
      queueId: 'auditor-evidence-gaps',
    );

    expect(initial.summaryLabel, '0/3 actions captured');
    expect(initial.progressLabel, 'Activity not started');
    expect(initial.hasCapturedActions, isFalse);
    expect(initial.nextActionLabel, 'Acknowledge owner response');
    expect(initial.isComplete, isFalse);

    final acknowledged = initial.copyWith(ownerAcknowledged: true);

    expect(initial.ownerAcknowledged, isFalse);
    expect(acknowledged.summaryLabel, '1/3 actions captured');
    expect(acknowledged.progressLabel, '1/3 actions captured');
    expect(acknowledged.hasCapturedActions, isTrue);
    expect(acknowledged.nextActionLabel, 'Record evidence receipt');
    expect(acknowledged.ownerActionLabel, 'Owner acknowledged');
    expect(acknowledged.capturedActionLabels, ['Owner acknowledged']);
    expect(
      acknowledged.auditActionBrief,
      contains('Captured actions: 1/3 actions captured'),
    );
    expect(
      acknowledged.auditActionBrief,
      contains('- Owner acknowledged: Yes'),
    );
    expect(acknowledged.auditActionBrief, contains('- Evidence received: No'));
    expect(
      acknowledged.auditActionBrief,
      contains('Next action: Record evidence receipt'),
    );

    final complete = acknowledged.copyWith(
      evidenceReceived: true,
      escalationLogged: true,
    );

    expect(complete.summaryLabel, '3/3 actions captured');
    expect(complete.progressLabel, 'Activity actions complete');
    expect(complete.nextActionLabel, 'Activity actions complete');
    expect(complete.capturedActionLabels, [
      'Owner acknowledged',
      'Evidence received',
      'Escalation logged',
    ]);
    expect(complete.isComplete, isTrue);

    final restored = AccountingWorkspaceWorkQueueActivityActionState.fromJson(
      complete.toJson(),
    );

    expect(restored.queueId, 'auditor-evidence-gaps');
    expect(restored.ownerAcknowledged, isTrue);
    expect(restored.evidenceReceived, isTrue);
    expect(restored.escalationLogged, isTrue);
  });
}
