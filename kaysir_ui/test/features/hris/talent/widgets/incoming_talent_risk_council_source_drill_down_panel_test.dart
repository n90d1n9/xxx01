import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_decision_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_follow_up_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_queue_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_sla_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_source_drill_down.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_source_pressure.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_source_drill_down_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_risk_council_source_drill_down_panel.dart';

void main() {
  testWidgets('source drill-down panel exposes operational buckets', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentRiskCouncilSourceDrillDownProvider.overrideWithValue(
            _drillDown,
          ),
          talentAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 11)),
        ],
        child: _shell(const IncomingTalentRiskCouncilSourceDrillDownPanel()),
      ),
    );

    expect(find.text('Council source drill-down'), findsOneWidget);
    expect(find.text('Promotion resolution review'), findsWidgets);
    expect(find.text('Auto-focused source'), findsOneWidget);
    expect(find.text('SLA pressure'), findsOneWidget);
    expect(find.text('Pending council decisions'), findsOneWidget);
    expect(find.text('Decisions needing follow-up'), findsOneWidget);
    expect(find.text('Open follow-ups'), findsOneWidget);
    expect(
      find.text('Track 1 escalated promotion resolution review SLA item.'),
      findsOneWidget,
    );
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

final _slaItem = IncomingTalentRiskCouncilSlaItem(
  id: 'sla:promotion',
  source: IncomingTalentRiskCouncilSlaSource.councilFollowUp,
  councilSource: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  status: IncomingTalentRiskCouncilSlaStatus.escalated,
  candidateName: 'Mira Lestari',
  role: 'Senior Analyst',
  department: 'Finance',
  ownerName: 'Finance Talent Partner',
  title: 'Create risk follow-up',
  nextAction: 'Prepare talent risk council work.',
  dueDate: DateTime(2026, 6, 17),
  requiresAttention: true,
);

final _pressure = IncomingTalentRiskCouncilSourcePressure.fromItems(
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  items: [_slaItem],
);

final _drillDown = IncomingTalentRiskCouncilSourceDrillDown(
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  isAutoFocused: true,
  pressure: _pressure,
  queueItems: [_queueItem],
  decisions: [_decision],
  followUps: [_followUp],
  slaItems: [_slaItem],
);

final _queueItem = IncomingTalentRiskCouncilQueueItem(
  id: 'risk-council:promotion',
  candidateId: 'candidate-promotion',
  candidateName: 'Mira Lestari',
  role: 'Senior Analyst',
  department: 'Finance',
  category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
  severity: IncomingTalentRiskCouncilQueueSeverity.watch,
  title: 'Mira needs council decision',
  detail: 'Council has enough evidence to decide the follow-up path.',
  recommendedAction: 'Confirm owner, decision outcome, and follow-up date.',
  dueDate: DateTime(2026, 6, 12),
  signalCount: 1,
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
);

final _decision = IncomingTalentRiskCouncilDecision(
  id: 'decision:promotion',
  queueItemId: 'risk-council:promotion',
  candidateId: 'candidate-promotion',
  candidateName: 'Mira Lestari',
  role: 'Senior Analyst',
  department: 'Finance',
  category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
  sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.watch,
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  decisionMakerName: 'Talent Council',
  ownerName: 'Finance Talent Partner',
  decisionDate: DateTime(2026, 6, 10),
  outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
  commitmentSummary: 'Council will monitor this risk.',
  minutesNote: 'Residual evidence needs follow-up.',
  followUpDate: DateTime(2026, 6, 17),
  createdAt: DateTime(2026, 6, 10),
  signalCount: 1,
);

final _followUp = IncomingTalentRiskCouncilFollowUp(
  id: 'follow-up:promotion',
  decisionId: 'decision:promotion',
  queueItemId: 'risk-council:promotion',
  candidateId: 'candidate-promotion',
  candidateName: 'Mira Lestari',
  role: 'Senior Analyst',
  department: 'Finance',
  decisionMakerName: 'Talent Council',
  followUpOwnerName: 'Finance Talent Partner',
  outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
  category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
  sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.watch,
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  followUpType: IncomingTalentRiskCouncilFollowUpType.monitoringReview,
  status: IncomingTalentRiskCouncilFollowUpStatus.inProgress,
  dueDate: DateTime(2026, 6, 17),
  actionPlan: 'Review stabilization evidence.',
  successCriteria: 'Evidence is recorded and accepted.',
  blockerNote: '',
  escalationReason: '',
  createdAt: DateTime(2026, 6, 10),
  signalCount: 1,
);
