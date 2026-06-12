import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_governance_review_readiness_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_governance_review_readiness_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_governance_review_readiness_panel.dart';

void main() {
  testWidgets('talent governance review readiness exposes prep tasks', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentGovernanceReviewReadinessItemsProvider
              .overrideWithValue(_items),
          incomingTalentGovernanceReviewReadinessSummaryProvider
              .overrideWithValue(_summary),
        ],
        child: _shell(const IncomingTalentGovernanceReviewReadinessPanel()),
      ),
    );

    expect(find.text('Talent governance review readiness'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Blocked'), findsWidgets);
    expect(find.text('0% governance review ready'), findsOneWidget);
    expect(find.text('Prepare assurance decision brief'), findsOneWidget);
    expect(find.text('People Risk and Assurance'), findsOneWidget);
    expect(find.text('Jun 11'), findsOneWidget);
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

final _items = [
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

const _summary = IncomingTalentGovernanceReviewReadinessSummary(
  totalCount: 2,
  readyCount: 0,
  needsPrepCount: 1,
  blockedCount: 1,
  attentionCount: 2,
  decisionQuestionCount: 6,
  totalSignalCount: 8,
  totalTimeboxMinutes: 25,
  readinessRatio: 0,
  nextAction: 'Unblock 1 governance review prep task.',
);
