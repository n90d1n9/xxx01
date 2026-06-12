import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_execution_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_owner_workload_provider.dart';

void main() {
  test('talent governance execution owner workload groups owner pressure', () {
    final container = ProviderContainer(
      overrides: [
        incomingTalentGovernanceExecutionActionsProvider.overrideWithValue(
          _actions,
        ),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(
      incomingTalentGovernanceExecutionOwnerWorkloadItemsProvider,
    );
    final summary = container.read(
      incomingTalentGovernanceExecutionOwnerWorkloadSummaryProvider,
    );

    expect(items, hasLength(2));
    expect(items.first.ownerName, 'People Risk and Assurance');
    expect(
      items.first.load,
      IncomingTalentGovernanceExecutionOwnerLoad.critical,
    );
    expect(items.first.actionCount, 2);
    expect(items.first.criticalActionCount, 1);
    expect(items.first.highActionCount, 1);
    expect(items.first.overdueActionCount, 1);
    expect(items.first.signalCount, 9);
    expect(items.first.decisionCount, 6);
    expect(items.first.averageProgressRatio, closeTo(0.25, 0.001));
    expect(
      items.first.nextAction,
      'Rebalance 1 overdue governance execution action from People Risk and Assurance.',
    );
    expect(items[1].load, IncomingTalentGovernanceExecutionOwnerLoad.stretched);
    expect(summary.ownerCount, 2);
    expect(summary.criticalOwnerCount, 1);
    expect(summary.stretchedOwnerCount, 1);
    expect(summary.balancedOwnerCount, 0);
    expect(summary.actionCount, 3);
    expect(summary.criticalActionCount, 1);
    expect(summary.highActionCount, 2);
    expect(summary.overdueActionCount, 1);
    expect(summary.attentionOwnerCount, 2);
    expect(summary.signalCount, 12);
    expect(summary.decisionCount, 9);
    expect(summary.averageProgressRatio, closeTo(0.35, 0.001));
    expect(
      summary.nextAction,
      'Rebalance 1 overdue governance execution action.',
    );
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
        'Ask People Risk and Assurance to recover overdue follow-through.',
    playbook: 'Recover overdue evidence.',
    evidenceExpectation: 'Attach assurance evidence.',
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
        'talent-governance-execution-action:talent-governance-execution:assurance-evidence',
    trackId: 'talent-governance-execution:assurance-evidence',
    type: IncomingTalentGovernanceExecutionActionType.attachEvidence,
    priority: IncomingTalentGovernanceExecutionActionPriority.high,
    title: 'People Risk and Assurance - attach evidence',
    detail: 'Execute assurance evidence decision',
    nextAction: 'Ask People Risk and Assurance to attach execution evidence.',
    playbook: 'Attach evidence.',
    evidenceExpectation: 'Attach assurance recovery notes.',
    ownerName: 'People Risk and Assurance',
    dueDate: DateTime(2026, 6, 14),
    progressRatio: 0.4,
    signalCount: 4,
    decisionCount: 3,
    readinessTaskCount: 1,
    overdue: false,
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
    playbook: 'Attach evidence.',
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
