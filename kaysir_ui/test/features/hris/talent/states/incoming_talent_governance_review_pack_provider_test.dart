import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_command_center_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_review_pack_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_command_center_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_review_pack_provider.dart';

void main() {
  test('talent governance review pack builds decision agenda from lanes', () {
    final container = ProviderContainer(
      overrides: [
        incomingTalentGovernanceCommandCenterProvider.overrideWithValue(
          _commandCenter,
        ),
      ],
    );
    addTearDown(container.dispose);

    final pack = container.read(incomingTalentGovernanceReviewPackProvider);

    expect(pack.status, IncomingTalentGovernanceReviewPackStatus.urgent);
    expect(pack.agendaItemCount, 2);
    expect(pack.urgentItemCount, 1);
    expect(pack.scheduledItemCount, 1);
    expect(pack.decisionQuestionCount, 6);
    expect(pack.totalTimeboxMinutes, 25);
    expect(pack.totalSignalCount, 8);
    expect(pack.reviewReadinessScore, 61);
    expect(pack.items.first.title, 'Assurance');
    expect(
      pack.items.first.decisionQuestion,
      'What leadership decision removes the assurance blocker today?',
    );
    expect(
      pack.facilitationFocus,
      'Start with Assurance and land the approve decision before other agenda items.',
    );
  });
}

const _lanes = [
  IncomingTalentGovernanceCommandLane(
    id: 'governance-lane-assurance',
    type: IncomingTalentGovernanceCommandLaneType.assurance,
    status: IncomingTalentGovernanceCommandStatus.critical,
    title: 'Assurance',
    detail: '4 evidence gaps, 3 remediation actions, 2 execution tracks.',
    metricLabel: 'Gaps',
    metricValue: '4',
    nextAction: 'Unblock 1 assurance remediation execution track.',
    pressureRatio: 0.74,
    signalCount: 5,
    decisionCount: 3,
  ),
  IncomingTalentGovernanceCommandLane(
    id: 'governance-lane-action-sla',
    type: IncomingTalentGovernanceCommandLaneType.actionSla,
    status: IncomingTalentGovernanceCommandStatus.watch,
    title: 'Action SLA',
    detail: '0 overdue, 1 today, 2 at risk across 5 sources.',
    metricLabel: 'SLAs',
    metricValue: '8',
    nextAction: 'Close 1 talent operating SLA item due today.',
    pressureRatio: 0.42,
    signalCount: 3,
    decisionCount: 3,
  ),
  IncomingTalentGovernanceCommandLane(
    id: 'governance-lane-training',
    type: IncomingTalentGovernanceCommandLaneType.training,
    status: IncomingTalentGovernanceCommandStatus.stable,
    title: 'Training',
    detail: '2 scheduled, 0 live, 75% seat utilization.',
    metricLabel: 'Sessions',
    metricValue: '2',
    nextAction: 'Track 2 scheduled training sessions.',
    pressureRatio: 0.12,
    signalCount: 0,
    decisionCount: 0,
  ),
];

const _commandCenter = IncomingTalentGovernanceCommandCenter(
  status: IncomingTalentGovernanceCommandStatus.critical,
  governanceScore: 64,
  laneCount: 7,
  criticalLaneCount: 1,
  watchLaneCount: 1,
  stableLaneCount: 5,
  totalSignalCount: 8,
  decisionCount: 6,
  nextAction:
      'Run governance review for 1 critical talent lane: Unblock 1 assurance remediation execution track.',
  lanes: _lanes,
);
