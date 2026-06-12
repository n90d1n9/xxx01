import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_calibration_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_calibration_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_activation_check_in_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_activation_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_nomination_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_panel_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

import 'incoming_talent_calibration_test_support.dart';

void main() {
  test('incoming talent succession activation check-ins submit from plan', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = calibrationTestContainer(asOfDate);
    addTearDown(container.dispose);

    final plan = _seedActivationPlan(container, asOfDate);

    container
        .read(incomingTalentSuccessionActivationCheckInDraftProvider.notifier)
        .initializeFromPlan(plan);
    final draft = container.read(
      incomingTalentSuccessionActivationCheckInDraftProvider,
    );
    final checkIn = container
        .read(incomingTalentSuccessionActivationCheckInsProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentSuccessionActivationCheckInSummaryProvider,
    );

    expect(checkIn.id, 'talent-succession-activation-check-in-001');
    expect(checkIn.activationPlanId, plan.id);
    expect(
      checkIn.trend,
      IncomingTalentSuccessionActivationCheckInTrend.onTrack,
    );
    expect(checkIn.confidenceScore, 4);
    expect(checkIn.needsAttention, isFalse);
    expect(summary.totalCheckIns, 1);
    expect(summary.onTrackCount, 1);
    expect(summary.averageConfidence, 4);
    expect(summary.nextAction, 'Keep 1 activation check-ins on cadence.');

    expect(
      () => container
          .read(incomingTalentSuccessionActivationCheckInsProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test(
    'incoming talent succession activation check-in draft validates fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft = IncomingTalentSuccessionActivationCheckInDraft.empty(
        asOfDate,
      ).copyWith(
        checkInDate: asOfDate.subtract(const Duration(days: 1)),
        confidenceScore: 6,
        milestoneHealth: 'short',
        sponsorAction: 'tiny',
        nextStep: 'mini',
        nextCheckInDate: asOfDate.subtract(const Duration(days: 2)),
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter an activation plan',
        'Please enter a reviewer',
        'Check-in date cannot be in the past',
        'Select check-in trend',
        'Confidence must be between 1 and 5',
        'Milestone health must be at least 12 characters',
        'Sponsor action must be at least 12 characters',
        'Next step must be at least 12 characters',
        'Next check-in must be after check-in date',
        'Select activation status',
      ]);
    },
  );

  test(
    'incoming talent succession activation check-ins follow talent filters',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = calibrationTestContainer(asOfDate);
      addTearDown(container.dispose);

      final engineeringPlan = _seedActivationPlan(
        container,
        asOfDate,
        id: 'outcome-engineering',
        activationPlanId: 'activation-engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
      );
      _submitCheckIn(container, engineeringPlan);

      final financePlan = _seedActivationPlan(
        container,
        asOfDate,
        id: 'outcome-finance',
        activationPlanId: 'activation-finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
        outcome: IncomingTalentSuccessionPanelOutcome.conditionalApproval,
      );
      _submitCheckIn(container, financePlan);

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      final filtered = container.read(
        filteredIncomingTalentSuccessionActivationCheckInsProvider,
      );
      final summary = container.read(
        incomingTalentSuccessionActivationCheckInSummaryProvider,
      );

      expect(filtered.map((checkIn) => checkIn.candidateName), [
        'Mira Lestari',
      ]);
      expect(
        filtered.single.trend,
        IncomingTalentSuccessionActivationCheckInTrend.watch,
      );
      expect(filtered.single.needsAttention, isTrue);
      expect(summary.totalCheckIns, 1);
      expect(summary.watchCount, 1);
      expect(summary.nextAction, 'Review 1 watched activation check-ins.');
    },
  );
}

IncomingTalentSuccessionActivationPlan _seedActivationPlan(
  ProviderContainer container,
  DateTime asOfDate, {
  String id = 'outcome-001',
  String activationPlanId = 'activation-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  IncomingTalentSuccessionPanelOutcome outcome =
      IncomingTalentSuccessionPanelOutcome.approvePromotion,
}) {
  final outcomeReview = submitCalibrationOutcome(
    container,
    calibrationOutcome(
      asOfDate,
      id: id,
      activationPlanId: activationPlanId,
      candidateName: candidateName,
      department: department,
      role: role,
      decision: IncomingTalentActivationOutcomeDecision.stabilized,
      risk: IncomingTalentActivationRetentionRisk.low,
      readinessScore: 92,
    ),
  );
  submitCalibrationRoadmap(
    container,
    calibrationRoadmap(
      asOfDate,
      outcomeReview,
      status: IncomingTalentDevelopmentRoadmapStatus.active,
    ),
  );
  _submitCalibrationReviewForOutcome(container, outcomeReview.id);

  final candidate = container
      .read(incomingTalentSuccessionCandidatesProvider)
      .firstWhere(
        (candidate) => candidate.candidateId == outcomeReview.candidateId,
      );
  container
      .read(incomingTalentSuccessionNominationDraftProvider.notifier)
      .initializeFromCandidate(candidate);
  final nomination = container
      .read(incomingTalentSuccessionNominationsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentSuccessionNominationDraftProvider),
      );

  final decisionDraft = container.read(
    incomingTalentSuccessionPanelDecisionDraftProvider.notifier,
  );
  decisionDraft.initializeFromNomination(nomination);
  decisionDraft.setOutcome(outcome);
  final decision = container
      .read(incomingTalentSuccessionPanelDecisionsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentSuccessionPanelDecisionDraftProvider),
      );

  container
      .read(incomingTalentSuccessionActivationDraftProvider.notifier)
      .initializeFromDecision(decision);
  return container
      .read(incomingTalentSuccessionActivationPlansProvider.notifier)
      .submitDraft(
        container.read(incomingTalentSuccessionActivationDraftProvider),
      );
}

IncomingTalentSuccessionActivationCheckIn _submitCheckIn(
  ProviderContainer container,
  IncomingTalentSuccessionActivationPlan plan,
) {
  container
      .read(incomingTalentSuccessionActivationCheckInDraftProvider.notifier)
      .initializeFromPlan(plan);
  return container
      .read(incomingTalentSuccessionActivationCheckInsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentSuccessionActivationCheckInDraftProvider),
      );
}

IncomingTalentCalibrationReview _submitCalibrationReviewForOutcome(
  ProviderContainer container,
  String outcomeReviewId,
) {
  final packet = container
      .read(incomingTalentCalibrationPacketsProvider)
      .singleWhere((packet) => packet.outcomeReviewId == outcomeReviewId);
  container
      .read(incomingTalentCalibrationReviewDraftProvider.notifier)
      .initializeFromPacket(packet);
  return container
      .read(incomingTalentCalibrationReviewsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentCalibrationReviewDraftProvider),
      );
}
