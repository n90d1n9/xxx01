import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_state.dart';

void main() {
  test('tracks queue resolution state and serializes cleared queues', () {
    const open = AccountingWorkspaceWorkQueueResolutionState(
      queueId: 'auditor-evidence-gaps',
    );

    expect(open.cleared, isFalse);
    expect(open.hasResolution, isFalse);
    expect(open.statusLabel, 'Open');
    expect(open.resolutionBrief, contains('Queue resolution: Open'));

    final cleared = open.copyWith(cleared: true);

    expect(cleared.cleared, isTrue);
    expect(cleared.hasResolution, isTrue);
    expect(cleared.statusLabel, 'Cleared');

    final restored = AccountingWorkspaceWorkQueueResolutionState.fromJson(
      cleared.toJson(),
    );

    expect(restored.queueId, 'auditor-evidence-gaps');
    expect(restored.cleared, isTrue);
  });
}
