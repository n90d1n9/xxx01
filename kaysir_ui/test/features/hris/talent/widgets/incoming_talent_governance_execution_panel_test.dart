import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_execution_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_execution_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_governance_execution_panel.dart';

void main() {
  testWidgets('talent governance execution tracker exposes follow-through', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentGovernanceExecutionTracksProvider.overrideWithValue(
            _tracks,
          ),
          incomingTalentGovernanceExecutionSummaryProvider.overrideWithValue(
            _summary,
          ),
        ],
        child: _shell(const IncomingTalentGovernanceExecutionPanel()),
      ),
    );

    expect(find.text('Talent governance execution tracker'), findsOneWidget);
    expect(find.text('Tracks'), findsOneWidget);
    expect(find.text('Overdue'), findsWidgets);
    expect(find.text('28% execution progress'), findsOneWidget);
    expect(find.text('Execute assurance approval decision'), findsOneWidget);
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
];

const _summary = IncomingTalentGovernanceExecutionSummary(
  totalCount: 2,
  completedCount: 0,
  inProgressCount: 0,
  blockedCount: 1,
  awaitingDecisionCount: 0,
  evidenceRecoveryCount: 1,
  ownerConfirmationCount: 0,
  overdueCount: 1,
  attentionCount: 2,
  signalCount: 8,
  decisionCount: 6,
  averageProgressRatio: 0.275,
  nextAction: 'Unblock 1 governance execution track.',
);
