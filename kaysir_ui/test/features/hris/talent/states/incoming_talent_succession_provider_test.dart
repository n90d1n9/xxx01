import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_calibration_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_profile_timeline_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_calibration_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_profile_timeline_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

import 'incoming_talent_calibration_test_support.dart';

void main() {
  test('incoming talent succession board nominates ready-now talent', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = calibrationTestContainer(asOfDate);
    addTearDown(container.dispose);

    final outcome = submitCalibrationOutcome(
      container,
      calibrationOutcome(
        asOfDate,
        decision: IncomingTalentActivationOutcomeDecision.stabilized,
        risk: IncomingTalentActivationRetentionRisk.low,
        readinessScore: 92,
      ),
    );
    submitCalibrationRoadmap(
      container,
      calibrationRoadmap(
        asOfDate,
        outcome,
        status: IncomingTalentDevelopmentRoadmapStatus.active,
      ),
    );
    _submitCalibrationReviewForOutcome(container, outcome.id);

    final candidates = container.read(
      incomingTalentSuccessionCandidatesProvider,
    );
    final summary = container.read(incomingTalentSuccessionSummaryProvider);
    final candidate = candidates.single;

    expect(candidate.readiness, IncomingTalentSuccessionReadiness.readyNow);
    expect(candidate.risk, IncomingTalentSuccessionRisk.low);
    expect(candidate.nextAction, 'Nominate for succession panel.');
    expect(candidate.targetRole, 'Expanded Senior Flutter Engineer scope');
    expect(summary.readyNowCount, 1);
    expect(summary.nextAction, 'Nominate 1 ready-now successor.');
  });

  test(
    'incoming talent succession board blocks risky open-action profiles',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = calibrationTestContainer(asOfDate);
      addTearDown(container.dispose);

      final packet = seedRiskCalibrationPacket(container, asOfDate);
      _submitCalibrationReview(container, packet);

      final candidate =
          container.read(incomingTalentSuccessionCandidatesProvider).single;
      final summary = container.read(incomingTalentSuccessionSummaryProvider);

      expect(candidate.readiness, IncomingTalentSuccessionReadiness.blocked);
      expect(candidate.risk, IncomingTalentSuccessionRisk.high);
      expect(candidate.openInterventionCount, 1);
      expect(candidate.nextAction, 'Close 1 open intervention.');
      expect(candidate.needsAttention, isTrue);
      expect(summary.blockedCount, 1);
      expect(summary.openInterventions, 1);
      expect(summary.nextAction, 'Unblock 1 succession actions.');
    },
  );

  test(
    'incoming talent succession board gates ready-now promotion resolution watch',
    () {
      final container = ProviderContainer(
        overrides: [
          incomingTalentProfileTimelinesProvider.overrideWithValue([
            _promotionResolutionWatchTimeline(),
          ]),
        ],
      );
      addTearDown(container.dispose);

      final candidate =
          container.read(incomingTalentSuccessionCandidatesProvider).single;
      final summary = container.read(incomingTalentSuccessionSummaryProvider);

      expect(candidate.readiness, IncomingTalentSuccessionReadiness.developing);
      expect(candidate.risk, IncomingTalentSuccessionRisk.medium);
      expect(candidate.needsAttention, isTrue);
      expect(candidate.nextAction, 'Resolve 1 promotion resolution review.');
      expect(candidate.evidenceSummary, contains('Promotion resolution'));
      expect(summary.readyNowCount, 0);
      expect(summary.developingCount, 1);
      expect(summary.nextAction, 'Review 1 developing succession successor.');
    },
  );

  test('incoming talent succession board follows talent filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = calibrationTestContainer(asOfDate);
    addTearDown(container.dispose);

    final engineeringOutcome = submitCalibrationOutcome(
      container,
      calibrationOutcome(
        asOfDate,
        id: 'outcome-engineering',
        activationPlanId: 'activation-engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
        decision: IncomingTalentActivationOutcomeDecision.stabilized,
        risk: IncomingTalentActivationRetentionRisk.low,
        readinessScore: 92,
      ),
    );
    submitCalibrationRoadmap(
      container,
      calibrationRoadmap(
        asOfDate,
        engineeringOutcome,
        status: IncomingTalentDevelopmentRoadmapStatus.active,
      ),
    );
    _submitCalibrationReviewForOutcome(container, engineeringOutcome.id);

    final financePacket = seedRiskCalibrationPacket(
      container,
      asOfDate,
      outcome: calibrationOutcome(
        asOfDate,
        id: 'outcome-finance',
        activationPlanId: 'activation-finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
        decision: IncomingTalentActivationOutcomeDecision.escalateRisk,
        risk: IncomingTalentActivationRetentionRisk.high,
        readinessScore: 48,
      ),
    );
    _submitCalibrationReview(container, financePacket);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentSuccessionCandidatesProvider,
    );
    final summary = container.read(incomingTalentSuccessionSummaryProvider);

    expect(filtered.map((candidate) => candidate.candidateName), [
      'Mira Lestari',
    ]);
    expect(
      filtered.single.readiness,
      IncomingTalentSuccessionReadiness.blocked,
    );
    expect(summary.totalCandidates, 1);
    expect(summary.blockedCount, 1);
  });
}

IncomingTalentProfileTimeline _promotionResolutionWatchTimeline() {
  return IncomingTalentProfileTimeline(
    candidateId: 'candidate-promotion-resolution',
    candidateName: 'Alya Maheswari',
    role: 'Senior People Partner',
    department: 'People Operations',
    readinessScore: 92,
    confidenceScore: 4,
    openInterventionCount: 0,
    watchDevelopmentOutcomeCount: 0,
    openDevelopmentFollowUpCount: 0,
    watchDevelopmentFollowUpCount: 0,
    watchDevelopmentResolutionCount: 0,
    openCareerSupportCount: 0,
    watchCareerSupportOutcomeCount: 0,
    programMilestoneRevisionCount: 0,
    programCompletionExtensionCount: 0,
    watchPromotionStabilizationCount: 0,
    openPromotionFollowUpCount: 0,
    watchPromotionFollowUpCount: 0,
    watchPromotionResolutionCount: 1,
    latestCalibrationDecisionLabel:
        IncomingTalentCalibrationDecision.accelerateGrowth.label,
    nextAction: 'Resolve 1 promotion resolution review.',
    events: [
      IncomingTalentProfileTimelineEvent(
        id: 'promotion-resolution-watch',
        candidateId: 'candidate-promotion-resolution',
        candidateName: 'Alya Maheswari',
        role: 'People Operations Lead',
        department: 'People Operations',
        type:
            IncomingTalentProfileTimelineEventType.promotionFollowUpResolution,
        tone: IncomingTalentProfileTimelineEventTone.watch,
        title: 'Monitor',
        description:
            'One stabilization risk remains after promotion follow-up.',
        eventDate: DateTime(2026, 6, 10),
        statusLabel: '3/5 confidence',
      ),
    ],
  );
}

IncomingTalentCalibrationReview _submitCalibrationReviewForOutcome(
  ProviderContainer container,
  String outcomeReviewId,
) {
  final packet = container
      .read(incomingTalentCalibrationPacketsProvider)
      .singleWhere((packet) => packet.outcomeReviewId == outcomeReviewId);
  return _submitCalibrationReview(container, packet);
}

IncomingTalentCalibrationReview _submitCalibrationReview(
  ProviderContainer container,
  IncomingTalentCalibrationPacket packet,
) {
  container
      .read(incomingTalentCalibrationReviewDraftProvider.notifier)
      .initializeFromPacket(packet);
  return container
      .read(incomingTalentCalibrationReviewsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentCalibrationReviewDraftProvider),
      );
}
