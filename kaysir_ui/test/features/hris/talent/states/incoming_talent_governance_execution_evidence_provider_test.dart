import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_execution_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_closure_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_evidence_provider.dart';

void main() {
  test('governance execution evidence register joins actions and closures', () {
    final container = ProviderContainer(
      overrides: [
        incomingTalentGovernanceExecutionActionsProvider.overrideWithValue(
          _actions,
        ),
        incomingTalentGovernanceExecutionClosuresProvider.overrideWith(
          (_) => _PreviewClosuresNotifier(_closures),
        ),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(
      incomingTalentGovernanceExecutionEvidenceItemsProvider,
    );
    final summary = container.read(
      incomingTalentGovernanceExecutionEvidenceSummaryProvider,
    );

    expect(items, hasLength(2));
    expect(items.first.ownerName, 'Talent Operations');
    expect(
      items.first.status,
      IncomingTalentGovernanceExecutionEvidenceStatus.missing,
    );
    expect(items.first.hasEvidence, isFalse);
    expect(items.first.normalizedReadinessRatio, 0.2);
    expect(items[1].ownerName, 'People Risk and Assurance');
    expect(
      items[1].status,
      IncomingTalentGovernanceExecutionEvidenceStatus.monitor,
    );
    expect(items[1].evidenceSummary, contains('assurance approval'));
    expect(items[1].residualRiskCount, 1);
    expect(summary.totalCount, 2);
    expect(summary.missingCount, 1);
    expect(summary.monitorCount, 1);
    expect(summary.acceptedCount, 0);
    expect(summary.attentionCount, 2);
    expect(summary.residualRiskCount, 1);
    expect(summary.signalCount, 8);
    expect(summary.decisionCount, 6);
    expect(summary.averageReadinessRatio, closeTo(0.45, 0.001));
    expect(
      summary.nextAction,
      'Attach evidence for 1 governance execution action.',
    );
  });
}

class _PreviewClosuresNotifier
    extends IncomingTalentGovernanceExecutionClosuresNotifier {
  _PreviewClosuresNotifier(
    List<IncomingTalentGovernanceExecutionClosure> items,
  ) {
    state = items;
  }
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
        'Ask People Risk and Assurance to recover overdue follow-through.',
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
    playbook: 'Attach evidence and refresh notes.',
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

final _closures = [
  IncomingTalentGovernanceExecutionClosure(
    id: 'talent-governance-execution-closure-001',
    actionId:
        'talent-governance-execution-action:talent-governance-execution:assurance-overdue',
    trackId: 'talent-governance-execution:assurance-overdue',
    ownerName: 'People Risk and Assurance',
    reviewerName: 'People Risk and Assurance',
    actionType: IncomingTalentGovernanceExecutionActionType.recoverOverdue,
    actionPriority: IncomingTalentGovernanceExecutionActionPriority.critical,
    actionDueDate: DateTime(2026, 6, 11),
    closureDate: DateTime(2026, 6, 12),
    outcome: IncomingTalentGovernanceExecutionClosureOutcome.monitor,
    residualRiskCount: 1,
    evidenceSummary:
        'Closure evidence confirms assurance approval follow-through is attached.',
    ownerConfirmationNote:
        'Owner confirms recovery evidence and governance cadence.',
    nextAction: 'Monitor closure evidence in the next governance check-in.',
    nextReviewDate: DateTime(2026, 6, 26),
    signalCount: 5,
    decisionCount: 3,
    createdAt: DateTime(2026, 6, 12),
  ),
];
