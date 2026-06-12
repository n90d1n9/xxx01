import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_execution_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_provider.dart';

void main() {
  test('talent governance execution action board derives owner playbooks', () {
    final container = ProviderContainer(
      overrides: [
        incomingTalentGovernanceExecutionTracksProvider.overrideWithValue(
          _tracks,
        ),
      ],
    );
    addTearDown(container.dispose);

    final actions = container.read(
      incomingTalentGovernanceExecutionActionsProvider,
    );
    final summary = container.read(
      incomingTalentGovernanceExecutionActionSummaryProvider,
    );

    expect(actions, hasLength(2));
    expect(actions.first.trackId, _tracks.first.id);
    expect(
      actions.first.type,
      IncomingTalentGovernanceExecutionActionType.recoverOverdue,
    );
    expect(
      actions.first.priority,
      IncomingTalentGovernanceExecutionActionPriority.critical,
    );
    expect(
      actions.first.nextAction,
      'Ask People Risk and Assurance to recover overdue follow-through for execute assurance approval decision.',
    );
    expect(
      actions[1].type,
      IncomingTalentGovernanceExecutionActionType.attachEvidence,
    );
    expect(
      actions[1].priority,
      IncomingTalentGovernanceExecutionActionPriority.high,
    );
    expect(summary.actionCount, 2);
    expect(summary.criticalActionCount, 1);
    expect(summary.highActionCount, 1);
    expect(summary.standardActionCount, 0);
    expect(summary.overdueActionCount, 1);
    expect(summary.ownerCount, 2);
    expect(summary.signalCount, 8);
    expect(summary.decisionCount, 6);
    expect(summary.averageProgressRatio, closeTo(0.275, 0.001));
    expect(summary.nextAction, 'Close 1 critical governance execution action.');
  });
}

final _tracks = [
  IncomingTalentGovernanceExecutionTrack(
    id:
        'talent-governance-execution:talent-governance-decision-ledger:review-pack-governance-lane-assurance',
    ledgerItemId:
        'talent-governance-decision-ledger:review-pack-governance-lane-assurance',
    status: IncomingTalentGovernanceExecutionStatus.blocked,
    title: 'Execute assurance approval decision',
    actionPlan:
        'Unblock publish assurance approval decision before assigning follow-through.',
    evidenceExpectation:
        'Approve immediate intervention for assurance: Unblock 1 assurance remediation execution track. Evidence: Gaps 4 with 5 active signals.',
    blockerNote:
        'Readiness blockers must be resolved before execution can move.',
    ownerName: 'People Risk and Assurance',
    dueDate: DateTime(2026, 6, 11),
    progressRatio: 0.1,
    signalCount: 5,
    decisionCount: 3,
    readinessTaskCount: 1,
    overdue: true,
  ),
  IncomingTalentGovernanceExecutionTrack(
    id:
        'talent-governance-execution:talent-governance-decision-ledger:review-pack-governance-lane-action-sla',
    ledgerItemId:
        'talent-governance-decision-ledger:review-pack-governance-lane-action-sla',
    status: IncomingTalentGovernanceExecutionStatus.evidenceRecovery,
    title: 'Execute action SLA unblock decision',
    actionPlan:
        'Attach execution evidence for publish action SLA unblock decision and refresh recovery notes.',
    evidenceExpectation:
        'Keep action SLA on weekly governance watch and confirm the accountable owner. Evidence: SLAs 8 with 3 active signals.',
    blockerNote: 'Execution evidence is missing or not current.',
    ownerName: 'Talent Operations',
    dueDate: DateTime(2026, 6, 14),
    progressRatio: 0.45,
    signalCount: 3,
    decisionCount: 3,
    readinessTaskCount: 1,
    overdue: false,
  ),
  IncomingTalentGovernanceExecutionTrack(
    id:
        'talent-governance-execution:talent-governance-decision-ledger:review-pack-governance-lane-complete',
    ledgerItemId:
        'talent-governance-decision-ledger:review-pack-governance-lane-complete',
    status: IncomingTalentGovernanceExecutionStatus.completed,
    title: 'Execute completed governance decision',
    actionPlan: 'Archive completed governance decision.',
    evidenceExpectation: 'Completed evidence is already attached.',
    blockerNote: '',
    ownerName: 'People Leadership',
    dueDate: DateTime(2026, 6, 9),
    progressRatio: 1,
    signalCount: 1,
    decisionCount: 1,
    readinessTaskCount: 0,
    overdue: false,
  ),
];
