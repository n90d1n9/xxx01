import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_command_center_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_decision_ledger_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_review_pack_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_review_readiness_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_decision_ledger_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_review_pack_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_review_readiness_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('talent governance decision ledger publishes review outcomes', () {
    final container = ProviderContainer(
      overrides: [
        incomingTalentGovernanceReviewPackProvider.overrideWithValue(
          _reviewPack,
        ),
        incomingTalentGovernanceReviewReadinessItemsProvider.overrideWithValue(
          _readinessItems,
        ),
        talentAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 11)),
      ],
    );
    addTearDown(container.dispose);

    final items = container.read(
      incomingTalentGovernanceDecisionLedgerItemsProvider,
    );
    final summary = container.read(
      incomingTalentGovernanceDecisionLedgerSummaryProvider,
    );

    expect(items.length, 2);
    expect(items.first.title, 'Publish assurance approval decision');
    expect(
      items.first.status,
      IncomingTalentGovernanceDecisionLedgerStatus.blocked,
    );
    expect(
      items.first.type,
      IncomingTalentGovernanceDecisionLedgerType.approvalDecision,
    );
    expect(items.first.dueDate, DateTime(2026, 6, 11));
    expect(items.first.readinessTaskIds, [_readinessItems.first.id]);
    expect(summary.blockedCount, 1);
    expect(summary.needsEvidenceCount, 1);
    expect(summary.needsDecisionCount, 0);
    expect(summary.readyToPublishCount, 0);
    expect(summary.decisionCount, 6);
    expect(summary.signalCount, 8);
    expect(summary.totalTimeboxMinutes, 25);
    expect(summary.publishableRatio, 0);
    expect(
      summary.nextAction,
      'Resolve 1 blocked governance decision before publishing.',
    );
  });
}

const _reviewItems = [
  IncomingTalentGovernanceReviewItem(
    id: 'review-pack-governance-lane-assurance',
    laneType: IncomingTalentGovernanceCommandLaneType.assurance,
    status: IncomingTalentGovernanceCommandStatus.critical,
    decisionKind: IncomingTalentGovernanceReviewDecisionKind.approve,
    title: 'Assurance',
    decisionQuestion:
        'What leadership decision removes the assurance blocker today?',
    recommendedDecision:
        'Approve immediate intervention for assurance: Unblock 1 assurance remediation execution track.',
    ownerLabel: 'People Risk and Assurance',
    evidencePrompt: 'Gaps 4 with 5 active signals.',
    dueLabel: 'Decision today',
    signalCount: 5,
    decisionCount: 3,
    timeboxMinutes: 15,
    pressureRatio: 0.74,
  ),
  IncomingTalentGovernanceReviewItem(
    id: 'review-pack-governance-lane-action-sla',
    laneType: IncomingTalentGovernanceCommandLaneType.actionSla,
    status: IncomingTalentGovernanceCommandStatus.watch,
    decisionKind: IncomingTalentGovernanceReviewDecisionKind.unblock,
    title: 'Action SLA',
    decisionQuestion:
        'Which owner and evidence keep action SLA on track this week?',
    recommendedDecision:
        'Keep action SLA on weekly governance watch and confirm the accountable owner.',
    ownerLabel: 'Talent Operations',
    evidencePrompt: 'SLAs 8 with 3 active signals.',
    dueLabel: 'Decision this week',
    signalCount: 3,
    decisionCount: 3,
    timeboxMinutes: 10,
    pressureRatio: 0.42,
  ),
];

const _reviewPack = IncomingTalentGovernanceReviewPack(
  status: IncomingTalentGovernanceReviewPackStatus.urgent,
  reviewReadinessScore: 64,
  agendaItemCount: 2,
  urgentItemCount: 1,
  scheduledItemCount: 1,
  decisionQuestionCount: 6,
  totalSignalCount: 8,
  totalTimeboxMinutes: 25,
  chairNote: 'Prepare 2 governance decisions from 8 active signals.',
  facilitationFocus:
      'Start with Assurance and land the approve decision before other agenda items.',
  items: _reviewItems,
);

final _readinessItems = [
  IncomingTalentGovernanceReviewReadinessItem(
    id:
        'talent-governance-review-readiness:review-pack-governance-lane-assurance',
    sourceReviewItemId: 'review-pack-governance-lane-assurance',
    category: IncomingTalentGovernanceReviewReadinessCategory.decisionBrief,
    status: IncomingTalentGovernanceReviewReadinessStatus.blocked,
    title: 'Prepare assurance decision brief',
    detail:
        'What leadership decision removes the assurance blocker today? Evidence required: Gaps 4 with 5 active signals.',
    ownerName: 'People Risk and Assurance',
    evidencePrompt: 'Gaps 4 with 5 active signals.',
    dueDate: DateTime(2026, 6, 11),
    signalCount: 5,
    decisionCount: 3,
    timeboxMinutes: 15,
  ),
  IncomingTalentGovernanceReviewReadinessItem(
    id:
        'talent-governance-review-readiness:review-pack-governance-lane-action-sla',
    sourceReviewItemId: 'review-pack-governance-lane-action-sla',
    category: IncomingTalentGovernanceReviewReadinessCategory.escalationPrep,
    status: IncomingTalentGovernanceReviewReadinessStatus.needsPrep,
    title: 'Prepare action SLA unblock path',
    detail:
        'Which owner and evidence keep action SLA on track this week? Evidence required: SLAs 8 with 3 active signals.',
    ownerName: 'Talent Operations',
    evidencePrompt: 'SLAs 8 with 3 active signals.',
    dueDate: DateTime(2026, 6, 14),
    signalCount: 3,
    decisionCount: 3,
    timeboxMinutes: 10,
  ),
];
