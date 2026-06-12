import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_decision_ledger_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_execution_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_decision_ledger_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('talent governance execution tracker derives owner follow-through', () {
    final container = ProviderContainer(
      overrides: [
        incomingTalentGovernanceDecisionLedgerItemsProvider.overrideWithValue(
          _ledgerItems,
        ),
        talentAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 12)),
      ],
    );
    addTearDown(container.dispose);

    final tracks = container.read(
      incomingTalentGovernanceExecutionTracksProvider,
    );
    final summary = container.read(
      incomingTalentGovernanceExecutionSummaryProvider,
    );

    expect(tracks.length, 2);
    expect(tracks.first.title, 'Execute assurance approval decision');
    expect(
      tracks.first.status,
      IncomingTalentGovernanceExecutionStatus.blocked,
    );
    expect(tracks.first.overdue, isTrue);
    expect(tracks.first.progressRatio, 0.1);
    expect(tracks.first.readinessTaskCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.evidenceRecoveryCount, 1);
    expect(summary.overdueCount, 1);
    expect(summary.signalCount, 8);
    expect(summary.decisionCount, 6);
    expect(summary.averageProgressRatio, closeTo(0.275, 0.001));
    expect(summary.nextAction, 'Unblock 1 governance execution track.');
  });
}

final _ledgerItems = [
  IncomingTalentGovernanceDecisionLedgerItem(
    id: 'talent-governance-decision-ledger:review-pack-governance-lane-assurance',
    reviewItemId: 'review-pack-governance-lane-assurance',
    type: IncomingTalentGovernanceDecisionLedgerType.approvalDecision,
    status: IncomingTalentGovernanceDecisionLedgerStatus.blocked,
    title: 'Publish assurance approval decision',
    decisionRecord:
        'What leadership decision removes the assurance blocker today?',
    commitment: 'Capture the approval decision and conditions for closure.',
    evidenceExpectation:
        'Approve immediate intervention for assurance: Unblock 1 assurance remediation execution track. Evidence: Gaps 4 with 5 active signals.',
    ownerName: 'People Risk and Assurance',
    dueDate: DateTime(2026, 6, 11),
    signalCount: 5,
    decisionCount: 3,
    timeboxMinutes: 15,
    readinessTaskIds: const [
      'talent-governance-review-readiness:review-pack-governance-lane-assurance',
    ],
  ),
  IncomingTalentGovernanceDecisionLedgerItem(
    id:
        'talent-governance-decision-ledger:review-pack-governance-lane-action-sla',
    reviewItemId: 'review-pack-governance-lane-action-sla',
    type: IncomingTalentGovernanceDecisionLedgerType.executiveUnblock,
    status: IncomingTalentGovernanceDecisionLedgerStatus.needsEvidence,
    title: 'Publish action SLA unblock decision',
    decisionRecord:
        'Which owner and evidence keep action SLA on track this week?',
    commitment:
        'Capture the unblock decision, accountable owner, and recovery date.',
    evidenceExpectation:
        'Keep action SLA on weekly governance watch and confirm the accountable owner. Evidence: SLAs 8 with 3 active signals.',
    ownerName: 'Talent Operations',
    dueDate: DateTime(2026, 6, 14),
    signalCount: 3,
    decisionCount: 3,
    timeboxMinutes: 10,
    readinessTaskIds: const [
      'talent-governance-review-readiness:review-pack-governance-lane-action-sla',
    ],
  ),
];
