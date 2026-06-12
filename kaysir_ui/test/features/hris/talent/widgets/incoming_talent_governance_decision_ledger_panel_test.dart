import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_decision_ledger_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_decision_ledger_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_governance_decision_ledger_panel.dart';

void main() {
  testWidgets('talent governance decision ledger exposes publish readiness', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentGovernanceDecisionLedgerItemsProvider.overrideWithValue(
            _items,
          ),
          incomingTalentGovernanceDecisionLedgerSummaryProvider
              .overrideWithValue(_summary),
        ],
        child: _shell(const IncomingTalentGovernanceDecisionLedgerPanel()),
      ),
    );

    expect(find.text('Talent governance decision ledger'), findsOneWidget);
    expect(find.text('Ledger'), findsOneWidget);
    expect(find.text('Evidence'), findsOneWidget);
    expect(find.text('0% publish-ready'), findsOneWidget);
    expect(find.text('Publish assurance approval decision'), findsOneWidget);
    expect(find.text('People Risk and Assurance'), findsOneWidget);
    expect(find.text('Jun 11'), findsOneWidget);
    expect(find.text('6 governance decisions'), findsOneWidget);
  });
}

Widget _shell(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}

final _items = [
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

const _summary = IncomingTalentGovernanceDecisionLedgerSummary(
  totalCount: 2,
  clearCount: 0,
  readyToPublishCount: 0,
  blockedCount: 1,
  needsDecisionCount: 0,
  needsEvidenceCount: 1,
  needsOwnerCount: 0,
  attentionCount: 2,
  decisionCount: 6,
  signalCount: 8,
  totalTimeboxMinutes: 25,
  publishableRatio: 0,
  nextAction: 'Resolve 1 blocked governance decision before publishing.',
);
