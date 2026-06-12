import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_close_command_center.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_close_command_center_service.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_work_queue_service.dart';

void main() {
  test('summarizes close command center from work queue signals', () {
    const workQueueService = AccountingWorkspaceWorkQueueService();
    const commandCenterService = AccountingWorkspaceCloseCommandCenterService();
    final queues = workQueueService.queuesFor(
      rolePreset: AccountingWorkspaceRolePreset.controller,
    );
    final health = workQueueService.summarize(queues);
    final slaSummary = workQueueService.summarizeSla(queues);
    final ownerSummary = workQueueService.summarizeOwners(queues);
    final closeReadiness = workQueueService.summarizeCloseReadiness(queues);

    final commandCenter = commandCenterService.summarize(
      health: health,
      slaSummary: slaSummary,
      ownerSummary: ownerSummary,
      closeReadiness: closeReadiness,
    );

    expect(
      commandCenter.state,
      AccountingWorkspaceCloseCommandCenterState.blocked,
    );
    expect(commandCenter.hasQueues, isTrue);
    expect(commandCenter.decisionLabel, 'Lock blocked');
    expect(commandCenter.readinessLabel, '37% ready');
    expect(commandCenter.decisionDetailLabel, '6 blockers before lock');
    expect(
      commandCenter.primaryActionLabel,
      'Clear release blockers before close or reporting lock',
    );
    expect(commandCenter.openValueLabel, '16');
    expect(commandCenter.openDetailLabel, '6 blocked');
    expect(commandCenter.evidenceValueLabel, '13');
    expect(commandCenter.evidenceDetailLabel, '2 days max overdue');
    expect(commandCenter.postingValueLabel, '14');
    expect(commandCenter.postingDetailLabel, 'Review before lock');
    expect(commandCenter.ownerValueLabel, 'Controller');
    expect(commandCenter.ownerDetailLabel, '4 overdue');
    expect(commandCenter.hasNextAction, isTrue);
    expect(commandCenter.nextActionQueueId, 'controller-close-blockers');
    expect(commandCenter.hasGateChecks, isTrue);
    expect(commandCenter.gateChecks.map((gate) => gate.id), [
      'blockers',
      'evidence',
      'posting',
    ]);
    expect(commandCenter.gateChecks.map((gate) => gate.status), [
      AccountingWorkspaceCloseCommandCenterGateStatus.blocked,
      AccountingWorkspaceCloseCommandCenterGateStatus.blocked,
      AccountingWorkspaceCloseCommandCenterGateStatus.watch,
    ]);
    expect(commandCenter.gateChecks.map((gate) => gate.detailLabel), [
      '6 blockers before lock',
      '2 days max overdue',
      '14 posting gates before lock',
    ]);
    expect(
      commandCenter.nextActionLabel,
      '#1 Critical overdue · Release blocker · Controller · 1 day overdue',
    );
    expect(
      commandCenter.decisionBrief,
      contains('Close decision: Lock blocked (37% ready)'),
    );
    expect(
      commandCenter.decisionBrief,
      contains('Primary action: Clear release blockers before close'),
    );
    expect(commandCenter.decisionBrief, contains('Gate checks:'));
    expect(
      commandCenter.decisionBrief,
      contains('- Blockers: Blocked - 6 blockers before lock'),
    );
    expect(
      commandCenter.decisionBrief,
      contains('- Posting: Review - 14 posting gates before lock'),
    );
    expect(
      commandCenter.decisionBrief,
      contains('Evidence: 13 - 2 days max overdue'),
    );
    expect(
      commandCenter.decisionBrief,
      contains(
        'Next action: #1 Critical overdue · Release blocker · Controller',
      ),
    );
  });
}
