import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_decision_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_follow_up_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_risk_council_queue_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_risk_council_source_filter_provider.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_risk_council_decision_queue_picker.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_risk_council_follow_up_decision_picker.dart';
import 'package:kaysir/features/hris/talent/widgets/incoming_talent_risk_council_source_filter_bar.dart';

void main() {
  testWidgets('decision queue picker shows selected source context', (
    tester,
  ) async {
    final item = _queueItem();

    await tester.pumpWidget(
      _shell(
        IncomingTalentRiskCouncilDecisionQueuePicker(
          draft: IncomingTalentRiskCouncilDecisionDraft.fromQueueItem(
            item: item,
            asOfDate: DateTime(2026, 6, 11),
          ),
          items: [item],
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.textContaining('Promotion resolution review'), findsWidgets);
    expect(find.text('Promotion resolution review risk'), findsOneWidget);
    expect(find.text('Watch'), findsOneWidget);
    expect(find.text('1 signals'), findsOneWidget);
  });

  testWidgets('follow-up decision picker shows selected source context', (
    tester,
  ) async {
    final decision = _decision();

    await tester.pumpWidget(
      _shell(
        IncomingTalentRiskCouncilFollowUpDecisionPicker(
          draft: IncomingTalentRiskCouncilFollowUpDraft.fromDecision(
            decision: decision,
            asOfDate: DateTime(2026, 6, 11),
          ),
          decisions: [decision],
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.textContaining('Promotion resolution review'), findsWidgets);
    expect(
      find.text(
        'Council will monitor promotion stabilization risk at the next talent risk council.',
      ),
      findsOneWidget,
    );
    expect(find.text('Monitor next council'), findsOneWidget);
    expect(
      find.text('People Operations Promotion Stabilization Partner'),
      findsOneWidget,
    );
  });

  testWidgets('source filter bar exposes selected council source', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingTalentRiskCouncilSourceFilterProvider.overrideWith(
            (ref) =>
                IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
          ),
        ],
        child: _shell(const IncomingTalentRiskCouncilSourceFilterBar()),
      ),
    );

    expect(find.text('Risk council source focus'), findsOneWidget);
    expect(find.text('Queue, decisions, and follow-ups'), findsOneWidget);
    expect(find.text('Promotion resolution review'), findsOneWidget);
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

IncomingTalentRiskCouncilQueueItem _queueItem() {
  return IncomingTalentRiskCouncilQueueItem(
    id: 'risk-council:candidate-preview:promotion-resolution-review',
    candidateId: 'candidate-preview',
    candidateName: 'Alya Maheswari',
    role: 'Senior People Partner',
    department: 'People Operations',
    category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
    severity: IncomingTalentRiskCouncilQueueSeverity.watch,
    title: 'Promotion resolution review risk',
    detail: '1 promotion resolution review still carries residual role risk.',
    recommendedAction:
        'Decide whether to reopen follow-up, escalate to people panel, or approve monitoring.',
    dueDate: DateTime(2026, 6, 17),
    signalCount: 1,
    source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  );
}

IncomingTalentRiskCouncilDecision _decision() {
  return IncomingTalentRiskCouncilDecision(
    id: 'talent-risk-council-decision-preview',
    queueItemId: 'risk-council:candidate-preview:promotion-resolution-review',
    candidateId: 'candidate-preview',
    candidateName: 'Alya Maheswari',
    role: 'Senior People Partner',
    department: 'People Operations',
    category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
    sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.watch,
    source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
    decisionMakerName: 'Talent Council',
    ownerName: 'People Operations Promotion Stabilization Partner',
    decisionDate: DateTime(2026, 6, 11),
    outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
    commitmentSummary:
        'Council will monitor promotion stabilization risk at the next talent risk council.',
    minutesNote:
        'Residual role-risk evidence needs manager checkpoint and closure disposition.',
    followUpDate: DateTime(2026, 7, 11),
    createdAt: DateTime(2026, 6, 11),
    signalCount: 1,
  );
}
