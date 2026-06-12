import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_calibration_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_calibration_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_nomination_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_panel_decision_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

import 'incoming_talent_calibration_test_support.dart';

void main() {
  test('incoming talent succession panel decisions submit from nomination', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = calibrationTestContainer(asOfDate);
    addTearDown(container.dispose);

    final nomination = _seedPanelReadyNomination(container, asOfDate);

    container
        .read(incomingTalentSuccessionPanelDecisionDraftProvider.notifier)
        .initializeFromNomination(nomination);
    final draft = container.read(
      incomingTalentSuccessionPanelDecisionDraftProvider,
    );
    final decision = container
        .read(incomingTalentSuccessionPanelDecisionsProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentSuccessionPanelDecisionSummaryProvider,
    );

    expect(decision.id, 'talent-succession-panel-001');
    expect(decision.nominationId, nomination.id);
    expect(
      decision.outcome,
      IncomingTalentSuccessionPanelOutcome.approvePromotion,
    );
    expect(decision.isApproved, isTrue);
    expect(container.read(panelReadySuccessionNominationsProvider), isEmpty);
    expect(summary.totalDecisions, 1);
    expect(summary.approvedCount, 1);
    expect(summary.nextAction, 'Activate 1 approved talent moves.');

    expect(
      () => container
          .read(incomingTalentSuccessionPanelDecisionsProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('incoming talent succession panel decision draft validates fields', () {
    final asOfDate = DateTime(2026, 5, 30);
    final draft = IncomingTalentSuccessionPanelDecisionDraft.empty(
      asOfDate,
    ).copyWith(
      decisionDate: asOfDate.subtract(const Duration(days: 1)),
      activationDate: asOfDate.subtract(const Duration(days: 2)),
      nextReviewDate: asOfDate,
      decisionSummary: 'short',
      sponsorCommitment: 'tiny',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a succession nomination',
      'Please enter a panel lead',
      'Please enter a follow-up owner',
      'Select nomination type',
      'Select readiness',
      'Select risk',
      'Select panel outcome',
      'Decision date cannot be in the past',
      'Activation date cannot be before decision date',
      'Decision summary must be at least 12 characters',
      'Sponsor commitment must be at least 12 characters',
    ]);
  });

  test('incoming talent succession panel decisions follow talent filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = calibrationTestContainer(asOfDate);
    addTearDown(container.dispose);

    final engineeringNomination = _seedPanelReadyNomination(
      container,
      asOfDate,
      id: 'outcome-engineering',
      activationPlanId: 'activation-engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
    );
    _submitPanelDecision(
      container,
      engineeringNomination,
      IncomingTalentSuccessionPanelOutcome.approvePromotion,
    );

    final financeNomination = _seedPanelReadyNomination(
      container,
      asOfDate,
      id: 'outcome-finance',
      activationPlanId: 'activation-finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
    );
    _submitPanelDecision(
      container,
      financeNomination,
      IncomingTalentSuccessionPanelOutcome.conditionalApproval,
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentSuccessionPanelDecisionsProvider,
    );
    final summary = container.read(
      incomingTalentSuccessionPanelDecisionSummaryProvider,
    );

    expect(filtered.map((decision) => decision.candidateName), [
      'Mira Lestari',
    ]);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.totalDecisions, 1);
    expect(summary.conditionalCount, 1);
    expect(summary.nextAction, 'Track 1 conditional approvals.');
  });
}

IncomingTalentSuccessionNomination _seedPanelReadyNomination(
  ProviderContainer container,
  DateTime asOfDate, {
  String id = 'outcome-001',
  String activationPlanId = 'activation-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
}) {
  final outcome = submitCalibrationOutcome(
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
      outcome,
      status: IncomingTalentDevelopmentRoadmapStatus.active,
    ),
  );
  _submitCalibrationReviewForOutcome(container, outcome.id);

  final candidate = container
      .read(incomingTalentSuccessionCandidatesProvider)
      .firstWhere((candidate) => candidate.candidateId == outcome.candidateId);
  container
      .read(incomingTalentSuccessionNominationDraftProvider.notifier)
      .initializeFromCandidate(candidate);
  return container
      .read(incomingTalentSuccessionNominationsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentSuccessionNominationDraftProvider),
      );
}

IncomingTalentSuccessionPanelDecision _submitPanelDecision(
  ProviderContainer container,
  IncomingTalentSuccessionNomination nomination,
  IncomingTalentSuccessionPanelOutcome outcome,
) {
  final draftNotifier = container.read(
    incomingTalentSuccessionPanelDecisionDraftProvider.notifier,
  );
  draftNotifier.initializeFromNomination(nomination);
  draftNotifier.setOutcome(outcome);
  return container
      .read(incomingTalentSuccessionPanelDecisionsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentSuccessionPanelDecisionDraftProvider),
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
