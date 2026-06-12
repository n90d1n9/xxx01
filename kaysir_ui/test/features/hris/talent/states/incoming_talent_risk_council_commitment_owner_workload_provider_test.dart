import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_commitment_action_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_commitment_log_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_commitment_owner_workload_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_commitment_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_commitment_owner_workload_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('commitment owner workload groups actions and ranks risk', () {
    final asOfDate = DateTime(2026, 6, 9);
    final container = _container(
      asOfDate,
      actions: [
        _action(
          asOfDate,
          id: 'blocked',
          ownerName: 'Ari Talent Partner',
          status: IncomingTalentRiskCouncilCommitmentActionStatus.blocked,
          dueOffset: 2,
          sourceCount: 2,
        ),
        _action(
          asOfDate,
          id: 'evidence',
          ownerName: 'Ari Talent Partner',
          status:
              IncomingTalentRiskCouncilCommitmentActionStatus.waitingEvidence,
          dueOffset: -1,
          sourceCount: 1,
        ),
        _action(
          asOfDate,
          id: 'planned',
          ownerName: 'Bela People Ops',
          status: IncomingTalentRiskCouncilCommitmentActionStatus.planned,
          dueOffset: 1,
          sourceCount: 1,
        ),
        _action(
          asOfDate,
          id: 'completed',
          ownerName: 'Citra HRBP',
          status: IncomingTalentRiskCouncilCommitmentActionStatus.completed,
          dueOffset: -3,
          sourceCount: 1,
        ),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(
      incomingTalentRiskCouncilCommitmentOwnerWorkloadItemsProvider,
    );
    final summary = container.read(
      incomingTalentRiskCouncilCommitmentOwnerWorkloadSummaryProvider,
    );
    final rebalancePlan = container.read(
      incomingTalentRiskCouncilCommitmentOwnerRebalancePlanProvider,
    );

    expect(items, hasLength(3));
    expect(items.first.ownerName, 'Ari Talent Partner');
    expect(
      items.first.load,
      IncomingTalentRiskCouncilCommitmentOwnerLoad.critical,
    );
    expect(items.first.totalCount, 2);
    expect(items.first.openCount, 2);
    expect(items.first.blockedCount, 1);
    expect(items.first.waitingEvidenceCount, 1);
    expect(items.first.overdueCount, 1);
    expect(items.first.sourceCount, 3);
    expect(items.first.nextAction, 'Unblock 1 owner commitment action.');
    expect(
      items.map((item) => item.load),
      contains(IncomingTalentRiskCouncilCommitmentOwnerLoad.clear),
    );

    expect(summary.ownerCount, 3);
    expect(summary.criticalOwnerCount, 1);
    expect(summary.balancedOwnerCount, 1);
    expect(summary.clearOwnerCount, 1);
    expect(summary.totalActionCount, 4);
    expect(summary.openActionCount, 3);
    expect(summary.blockedActionCount, 1);
    expect(summary.overdueActionCount, 1);
    expect(summary.attentionOwnerCount, 1);
    expect(summary.nextAction, 'Rebalance 1 critical owner workload.');

    expect(rebalancePlan.ownerCount, 3);
    expect(rebalancePlan.ownersNeedingReliefCount, 1);
    expect(rebalancePlan.availableReliefOwnerCount, 2);
    expect(rebalancePlan.reliefCapacity, 5);
    expect(rebalancePlan.suggestedReassignmentCount, 2);
    expect(rebalancePlan.criticalRecommendationCount, 1);
    expect(
      rebalancePlan.nextAction,
      'Reassign 2 urgent commitment actions from critical owners.',
    );
    expect(
      rebalancePlan.recommendations.single.sourceOwnerName,
      'Ari Talent Partner',
    );
    expect(rebalancePlan.recommendations.single.targetOwnerName, 'Citra HRBP');
    expect(
      rebalancePlan.recommendations.single.nextAction,
      'Move 2 urgent actions from Ari Talent Partner to Citra HRBP.',
    );
  });

  test('commitment owner workload summarizes empty state', () {
    final container = _container(DateTime(2026, 6, 9), actions: const []);
    addTearDown(container.dispose);

    final items = container.read(
      incomingTalentRiskCouncilCommitmentOwnerWorkloadItemsProvider,
    );
    final summary = container.read(
      incomingTalentRiskCouncilCommitmentOwnerWorkloadSummaryProvider,
    );

    expect(items, isEmpty);
    expect(summary.ownerCount, 0);
    expect(summary.totalActionCount, 0);
    expect(
      summary.nextAction,
      'Create council commitment actions before reviewing owner workload.',
    );
  });

  test(
    'commitment owner rebalance asks for capacity when no relief exists',
    () {
      final asOfDate = DateTime(2026, 6, 9);
      final container = _container(
        asOfDate,
        actions: [
          _action(
            asOfDate,
            id: 'blocked',
            ownerName: 'Ari Talent Partner',
            status: IncomingTalentRiskCouncilCommitmentActionStatus.blocked,
            dueOffset: 2,
            sourceCount: 2,
          ),
          _action(
            asOfDate,
            id: 'overdue',
            ownerName: 'Bela People Ops',
            status:
                IncomingTalentRiskCouncilCommitmentActionStatus.waitingEvidence,
            dueOffset: -1,
            sourceCount: 1,
          ),
        ],
      );
      addTearDown(container.dispose);

      final rebalancePlan = container.read(
        incomingTalentRiskCouncilCommitmentOwnerRebalancePlanProvider,
      );

      expect(rebalancePlan.ownersNeedingReliefCount, 2);
      expect(rebalancePlan.availableReliefOwnerCount, 0);
      expect(rebalancePlan.suggestedReassignmentCount, 0);
      expect(
        rebalancePlan.nextAction,
        'Add relief capacity for 2 overloaded owners.',
      );
      expect(rebalancePlan.recommendations, hasLength(2));
      expect(
        rebalancePlan.recommendations.map((recommendation) {
          return recommendation.targetOwnerName;
        }),
        everyElement(isNull),
      );
      expect(
        rebalancePlan.recommendations.first.nextAction,
        'Assign relief capacity for Ari Talent Partner before next council.',
      );
    },
  );
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentRiskCouncilCommitmentAction> actions,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentRiskCouncilCommitmentActionsProvider
          .overrideWithValue(actions),
    ],
  );
}

IncomingTalentRiskCouncilCommitmentAction _action(
  DateTime asOfDate, {
  required String id,
  required String ownerName,
  required IncomingTalentRiskCouncilCommitmentActionStatus status,
  required int dueOffset,
  required int sourceCount,
}) {
  return IncomingTalentRiskCouncilCommitmentAction(
    id: 'action:$id',
    commitmentId: 'commitment:$id',
    agendaItemId: 'agenda:$id',
    type: IncomingTalentRiskCouncilCommitmentLogType.ownerUpdate,
    sourceStatus: IncomingTalentRiskCouncilCommitmentLogStatus.needsOwner,
    status: status,
    ownerName: ownerName,
    dueDate: asOfDate.add(Duration(days: dueOffset)),
    actionPlan: 'Confirm council commitment owner action.',
    evidenceExpectation: 'Evidence note and owner update are required.',
    evidenceNote: '',
    followUpCadence: 'Weekly until complete',
    blockerNote: '',
    createdAt: asOfDate,
    sourceCount: sourceCount,
  );
}
