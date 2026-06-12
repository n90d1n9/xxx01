import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_calibration_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_check_in_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_calibration_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

import 'incoming_talent_calibration_test_support.dart';

void main() {
  test('incoming talent calibration packets escalate risky signals', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = calibrationTestContainer(asOfDate);
    addTearDown(container.dispose);

    final outcome = submitCalibrationOutcome(
      container,
      calibrationOutcome(
        asOfDate,
        decision: IncomingTalentActivationOutcomeDecision.escalateRisk,
        risk: IncomingTalentActivationRetentionRisk.high,
        readinessScore: 48,
      ),
    );
    final roadmap = submitCalibrationRoadmap(
      container,
      calibrationRoadmap(
        asOfDate,
        outcome,
        status: IncomingTalentDevelopmentRoadmapStatus.atRisk,
      ),
    );
    final checkIn = submitCalibrationCheckIn(
      container,
      calibrationCheckIn(
        asOfDate,
        roadmap,
        trend: IncomingTalentDevelopmentCheckInTrend.blocked,
        confidenceScore: 2,
      ),
    );
    submitCalibrationIntervention(container, checkIn);

    final packets = container.read(incomingTalentCalibrationPacketsProvider);
    final summary = container.read(
      incomingTalentCalibrationPacketSummaryProvider,
    );

    expect(packets, hasLength(1));
    expect(
      packets.single.recommendation,
      IncomingTalentCalibrationRecommendation.escalate,
    );
    expect(packets.single.potential, IncomingTalentCalibrationPotential.watch);
    expect(packets.single.criticalInterventionCount, 1);
    expect(packets.single.evidenceSummary, contains('Blocked check-in'));
    expect(summary.escalateCount, 1);
    expect(summary.nextAction, 'Calibrate 1 retention risks.');
  });

  test('incoming talent calibration reviews submit from packet', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = calibrationTestContainer(asOfDate);
    addTearDown(container.dispose);

    final packet = seedRiskCalibrationPacket(container, asOfDate);

    container
        .read(incomingTalentCalibrationReviewDraftProvider.notifier)
        .initializeFromPacket(packet);
    final draft = container.read(incomingTalentCalibrationReviewDraftProvider);
    final review = container
        .read(incomingTalentCalibrationReviewsProvider.notifier)
        .submitDraft(draft);

    expect(review.id, 'talent-calibration-001');
    expect(
      review.decision,
      IncomingTalentCalibrationDecision.retentionEscalation,
    );
    expect(review.potential, IncomingTalentCalibrationPotential.watch);
    expect(review.needsAttention, isTrue);
    expect(container.read(calibrationReadyPacketsProvider), isEmpty);

    expect(
      () => container
          .read(incomingTalentCalibrationReviewsProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test(
    'incoming talent calibration review draft validates required fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft = IncomingTalentCalibrationReviewDraft.empty(
        asOfDate,
      ).copyWith(
        reviewDate: asOfDate.subtract(const Duration(days: 1)),
        talentTrack: 'short',
        evidenceSummary: 'tiny',
        decisionNote: 'mini',
        nextReviewDate: asOfDate.subtract(const Duration(days: 1)),
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter a calibration packet',
        'Please enter a reviewer',
        'Review date cannot be in the past',
        'Select a calibration decision',
        'Select talent potential',
        'Talent track must be at least 12 characters',
        'Evidence summary must be at least 12 characters',
        'Decision note must be at least 12 characters',
        'Next review must be after the review date',
      ]);
    },
  );

  test('incoming talent calibration follows talent filters', () {
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

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentCalibrationPacketsProvider,
    );
    final summary = container.read(
      incomingTalentCalibrationPacketSummaryProvider,
    );

    expect(filtered.map((packet) => packet.candidateName), ['Mira Lestari']);
    expect(financePacket.candidateName, 'Mira Lestari');
    expect(
      filtered.single.recommendation,
      IncomingTalentCalibrationRecommendation.escalate,
    );
    expect(summary.totalCount, 1);
    expect(summary.escalateCount, 1);
  });
}
