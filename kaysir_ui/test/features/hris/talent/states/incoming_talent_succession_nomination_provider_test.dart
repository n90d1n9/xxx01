import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_calibration_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_calibration_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_nomination_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

import 'incoming_talent_calibration_test_support.dart';

void main() {
  test(
    'incoming talent succession nominations submit from ready candidate',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = calibrationTestContainer(asOfDate);
      addTearDown(container.dispose);

      final candidate = _seedReadyCandidate(container, asOfDate);

      container
          .read(incomingTalentSuccessionNominationDraftProvider.notifier)
          .initializeFromCandidate(candidate);
      final draft = container.read(
        incomingTalentSuccessionNominationDraftProvider,
      );
      final nomination = container
          .read(incomingTalentSuccessionNominationsProvider.notifier)
          .submitDraft(draft);
      final summary = container.read(
        incomingTalentSuccessionNominationSummaryProvider,
      );

      expect(nomination.id, 'talent-succession-nomination-001');
      expect(nomination.candidateName, candidate.candidateName);
      expect(
        nomination.nominationType,
        IncomingTalentSuccessionNominationType.promotion,
      );
      expect(
        nomination.status,
        IncomingTalentSuccessionNominationStatus.panelReview,
      );
      expect(
        container.read(nominationReadySuccessionCandidatesProvider),
        isEmpty,
      );
      expect(summary.totalNominations, 1);
      expect(summary.panelReviewCount, 1);
      expect(summary.nextAction, 'Prepare 1 nominations for panel review.');

      expect(
        () => container
            .read(incomingTalentSuccessionNominationsProvider.notifier)
            .submitDraft(draft),
        throwsStateError,
      );
    },
  );

  test('incoming talent succession nomination draft validates fields', () {
    final asOfDate = DateTime(2026, 5, 30);
    final draft = IncomingTalentSuccessionNominationDraft.empty(
      asOfDate,
    ).copyWith(
      nominationDate: asOfDate.subtract(const Duration(days: 1)),
      panelDate: asOfDate.subtract(const Duration(days: 2)),
      businessCase: 'short',
      evidenceSummary: 'tiny',
      successPlan: 'small',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a succession candidate',
      'Please enter a sponsor',
      'Please enter a panel',
      'Select nomination type',
      'Select nomination status',
      'Select readiness',
      'Select risk',
      'Nomination date cannot be in the past',
      'Panel date cannot be before nomination date',
      'Business case must be at least 12 characters',
      'Evidence summary must be at least 12 characters',
      'Success plan must be at least 12 characters',
    ]);
  });

  test('incoming talent succession nominations follow talent filters', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = calibrationTestContainer(asOfDate);
    addTearDown(container.dispose);

    final engineeringCandidate = _seedReadyCandidate(
      container,
      asOfDate,
      id: 'outcome-engineering',
      activationPlanId: 'activation-engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
    );
    _submitNomination(
      container,
      engineeringCandidate,
      IncomingTalentSuccessionNominationStatus.approved,
    );

    final financeCandidate = _seedReadyCandidate(
      container,
      asOfDate,
      id: 'outcome-finance',
      activationPlanId: 'activation-finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
    );
    _submitNomination(
      container,
      financeCandidate,
      IncomingTalentSuccessionNominationStatus.sponsorFollowUp,
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentSuccessionNominationsProvider,
    );
    final summary = container.read(
      incomingTalentSuccessionNominationSummaryProvider,
    );

    expect(filtered.map((nomination) => nomination.candidateName), [
      'Mira Lestari',
    ]);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.totalNominations, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Follow up 1 nomination risks.');
  });
}

IncomingTalentSuccessionCandidate _seedReadyCandidate(
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

  return container
      .read(incomingTalentSuccessionCandidatesProvider)
      .firstWhere((candidate) => candidate.candidateId == outcome.candidateId);
}

IncomingTalentSuccessionNomination _submitNomination(
  ProviderContainer container,
  IncomingTalentSuccessionCandidate candidate,
  IncomingTalentSuccessionNominationStatus status,
) {
  final draftNotifier = container.read(
    incomingTalentSuccessionNominationDraftProvider.notifier,
  );
  draftNotifier.initializeFromCandidate(candidate);
  draftNotifier.setStatus(status);
  return container
      .read(incomingTalentSuccessionNominationsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentSuccessionNominationDraftProvider),
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
