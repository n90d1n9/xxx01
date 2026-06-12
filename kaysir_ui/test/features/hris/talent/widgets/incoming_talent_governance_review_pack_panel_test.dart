import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_command_center_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_review_pack_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_review_pack_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_governance_review_pack_panel.dart';

void main() {
  testWidgets('talent governance review pack exposes agenda decisions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentGovernanceReviewPackProvider.overrideWithValue(
            _reviewPack,
          ),
        ],
        child: _shell(const IncomingTalentGovernanceReviewPackPanel()),
      ),
    );

    expect(find.text('Talent governance review pack'), findsOneWidget);
    expect(find.text('Agenda'), findsOneWidget);
    expect(find.text('Urgent'), findsWidgets);
    expect(find.text('64% review readiness'), findsOneWidget);
    expect(find.text('Assurance'), findsOneWidget);
    expect(find.text('Decision today'), findsOneWidget);
    expect(
      find.text(
        'What leadership decision removes the assurance blocker today?',
      ),
      findsOneWidget,
    );
    expect(find.text('People Risk and Assurance'), findsOneWidget);
    expect(find.text('6 decision questions'), findsOneWidget);
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

const _items = [
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
  items: _items,
);
