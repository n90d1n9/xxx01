import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_execution_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_closure_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('governance execution closures submit from ready action', () {
    final container = ProviderContainer(
      overrides: [
        incomingTalentGovernanceExecutionActionsProvider.overrideWithValue(
          _actions,
        ),
        talentAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 12)),
      ],
    );
    addTearDown(container.dispose);

    final readyBefore = container.read(
      closureReadyTalentGovernanceExecutionActionsProvider,
    );
    expect(readyBefore, hasLength(2));

    container
        .read(incomingTalentGovernanceExecutionClosureDraftProvider.notifier)
        .initializeFromAction(_actions.first);

    final draft = container.read(
      incomingTalentGovernanceExecutionClosureDraftProvider,
    );
    expect(draft.isReadyToSubmit, isTrue);
    expect(
      draft.outcome,
      IncomingTalentGovernanceExecutionClosureOutcome.monitor,
    );
    expect(draft.residualRiskCount, 1);
    expect(draft.nextReviewDate, DateTime(2026, 6, 26));

    final closure = container
        .read(incomingTalentGovernanceExecutionClosuresProvider.notifier)
        .submitDraft(draft);

    expect(closure.id, 'talent-governance-execution-closure-001');
    expect(closure.actionId, _actions.first.id);
    expect(closure.ownerName, 'People Risk and Assurance');
    expect(closure.needsAttention, isTrue);
    expect(closure.signalCount, 5);
    expect(closure.decisionCount, 3);

    final readyAfter = container.read(
      closureReadyTalentGovernanceExecutionActionsProvider,
    );
    final summary = container.read(
      incomingTalentGovernanceExecutionClosureSummaryProvider,
    );

    expect(readyAfter, hasLength(1));
    expect(summary.totalCount, 1);
    expect(summary.monitorCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.residualRiskCount, 1);
    expect(summary.signalCount, 5);
    expect(
      summary.nextAction,
      'Monitor 1 governance execution closure with residual risk.',
    );
    expect(
      () => container
          .read(incomingTalentGovernanceExecutionClosuresProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('governance execution closure draft validates required fields', () {
    final draft = IncomingTalentGovernanceExecutionClosureDraft.empty(
      DateTime(2026, 6, 12),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(
      draft.validationErrors,
      contains('Please enter a governance execution action'),
    );
    expect(draft.completionRatio, lessThan(1));
  });
}

final _actions = [
  IncomingTalentGovernanceExecutionAction(
    id:
        'talent-governance-execution-action:talent-governance-execution:assurance-overdue',
    trackId: 'talent-governance-execution:assurance-overdue',
    type: IncomingTalentGovernanceExecutionActionType.recoverOverdue,
    priority: IncomingTalentGovernanceExecutionActionPriority.critical,
    title: 'People Risk and Assurance - recover overdue',
    detail: 'Execute assurance approval decision',
    nextAction:
        'Ask People Risk and Assurance to recover overdue follow-through for execute assurance approval decision.',
    playbook:
        'Reconfirm due date, capture recovery evidence, and mark owner acceptance.',
    evidenceExpectation:
        'Attach assurance approval evidence, owner confirmation, and recovery note.',
    ownerName: 'People Risk and Assurance',
    dueDate: DateTime(2026, 6, 11),
    progressRatio: 0.1,
    signalCount: 5,
    decisionCount: 3,
    readinessTaskCount: 1,
    overdue: true,
  ),
  IncomingTalentGovernanceExecutionAction(
    id:
        'talent-governance-execution-action:talent-governance-execution:action-sla',
    trackId: 'talent-governance-execution:action-sla',
    type: IncomingTalentGovernanceExecutionActionType.attachEvidence,
    priority: IncomingTalentGovernanceExecutionActionPriority.high,
    title: 'Talent Operations - attach evidence',
    detail: 'Execute action SLA unblock decision',
    nextAction: 'Ask Talent Operations to attach execution evidence.',
    playbook:
        'Attach evidence, refresh notes, and make the audit trail reviewable.',
    evidenceExpectation: 'Attach action SLA recovery notes.',
    ownerName: 'Talent Operations',
    dueDate: DateTime(2026, 6, 15),
    progressRatio: 0.45,
    signalCount: 3,
    decisionCount: 3,
    readinessTaskCount: 1,
    overdue: false,
  ),
];
