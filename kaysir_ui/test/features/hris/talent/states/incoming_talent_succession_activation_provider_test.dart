import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_calibration_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_calibration_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_activation_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_nomination_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_panel_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

import 'incoming_talent_calibration_test_support.dart';

void main() {
  test('incoming talent succession activation submits from panel decision', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = calibrationTestContainer(asOfDate);
    addTearDown(container.dispose);

    final decision = _seedApprovedPanelDecision(container, asOfDate);

    container
        .read(incomingTalentSuccessionActivationDraftProvider.notifier)
        .initializeFromDecision(decision);
    final draft = container.read(
      incomingTalentSuccessionActivationDraftProvider,
    );
    final plan = container
        .read(incomingTalentSuccessionActivationPlansProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentSuccessionActivationSummaryProvider,
    );

    expect(plan.id, 'talent-succession-activation-001');
    expect(plan.decisionId, decision.id);
    expect(plan.status, IncomingTalentSuccessionActivationStatus.planned);
    expect(plan.needsAttention, isFalse);
    expect(
      container.read(activationReadySuccessionPanelDecisionsProvider),
      isEmpty,
    );
    expect(summary.totalPlans, 1);
    expect(summary.plannedCount, 1);
    expect(summary.nextAction, 'Launch 1 planned succession moves.');

    expect(
      () => container
          .read(incomingTalentSuccessionActivationPlansProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('incoming talent succession activation draft validates fields', () {
    final asOfDate = DateTime(2026, 5, 30);
    final draft = IncomingTalentSuccessionActivationPlanDraft.empty(
      asOfDate,
    ).copyWith(
      startDate: asOfDate.subtract(const Duration(days: 1)),
      milestoneDate: asOfDate.subtract(const Duration(days: 2)),
      firstReviewDate: asOfDate.subtract(const Duration(days: 2)),
      transitionGoal: 'short',
      milestone: 'tiny',
      successMetric: 'mini',
      supportPlan: 'small',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter an approved panel decision',
      'Please enter an activation owner',
      'Please enter a transition mentor',
      'Select activation status',
      'Select panel outcome',
      'Select readiness',
      'Select risk',
      'Start date cannot be in the past',
      'Milestone date must be after start date',
      'First review must be after start date',
      'Transition goal must be at least 12 characters',
      'Milestone must be at least 12 characters',
      'Success metric must be at least 12 characters',
      'Support plan must be at least 12 characters',
    ]);
  });

  test('incoming talent succession activation follows talent filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = calibrationTestContainer(asOfDate);
    addTearDown(container.dispose);

    final engineeringDecision = _seedApprovedPanelDecision(
      container,
      asOfDate,
      id: 'outcome-engineering',
      activationPlanId: 'activation-engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
    );
    _submitActivationPlan(container, engineeringDecision);

    final financeDecision = _seedApprovedPanelDecision(
      container,
      asOfDate,
      id: 'outcome-finance',
      activationPlanId: 'activation-finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
      outcome: IncomingTalentSuccessionPanelOutcome.conditionalApproval,
    );
    _submitActivationPlan(container, financeDecision);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentSuccessionActivationPlansProvider,
    );
    final summary = container.read(
      incomingTalentSuccessionActivationSummaryProvider,
    );

    expect(filtered.map((plan) => plan.candidateName), ['Mira Lestari']);
    expect(
      filtered.single.status,
      IncomingTalentSuccessionActivationStatus.atRisk,
    );
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.totalPlans, 1);
    expect(summary.atRiskCount, 1);
    expect(summary.nextAction, 'Stabilize 1 at-risk activations.');
  });
}

IncomingTalentSuccessionPanelDecision _seedApprovedPanelDecision(
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
  return container
      .read(incomingTalentSuccessionPanelDecisionsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentSuccessionPanelDecisionDraftProvider),
      );
}

IncomingTalentSuccessionActivationPlan _submitActivationPlan(
  ProviderContainer container,
  IncomingTalentSuccessionPanelDecision decision,
) {
  container
      .read(incomingTalentSuccessionActivationDraftProvider.notifier)
      .initializeFromDecision(decision);
  return container
      .read(incomingTalentSuccessionActivationPlansProvider.notifier)
      .submitDraft(
        container.read(incomingTalentSuccessionActivationDraftProvider),
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
