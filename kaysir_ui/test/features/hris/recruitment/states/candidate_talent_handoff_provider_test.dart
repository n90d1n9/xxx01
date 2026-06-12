import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_development_calibration_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_development_check_in_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_development_intervention_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_development_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_talent_handoff_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_decision_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_development_calibration_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_development_check_in_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_development_intervention_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_development_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_talent_handoff_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'candidate talent handoff draft initializes from calibration review',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = ProviderContainer(
        overrides: [
          recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
          talentAsOfDateProvider.overrideWithValue(asOfDate),
        ],
      );
      addTearDown(container.dispose);

      final review = _submitReadyCalibrationReview(container, 'Fajar Nugroho');

      container
          .read(candidateTalentHandoffDraftProvider.notifier)
          .initializeFromCalibrationReview(review);

      final draft = container.read(candidateTalentHandoffDraftProvider);

      expect(draft.calibrationReviewId, 'development-calibration-001');
      expect(draft.candidateId, review.candidateId);
      expect(draft.candidateName, 'Fajar Nugroho');
      expect(draft.type, CandidateTalentHandoffType.offerTransition);
      expect(draft.status, CandidateTalentHandoffStatus.ready);
      expect(draft.readinessScore, 86);
      expect(draft.receivingManagerName, 'Engineering Manager');
      expect(draft.targetStartDate, asOfDate.add(const Duration(days: 7)));
      expect(draft.firstCheckpointDate, asOfDate.add(const Duration(days: 21)));
      expect(draft.talentFocus, 'Confirm readiness for Fajar Nugroho.');
      expect(draft.isReadyToSubmit, isTrue);
    },
  );

  test('candidate talent handoff draft validates required fields', () {
    final asOfDate = DateTime(2026, 5, 30);
    final draft = CandidateTalentHandoffDraft.empty(asOfDate).copyWith(
      targetStartDate: asOfDate.subtract(const Duration(days: 1)),
      firstCheckpointDate: asOfDate.subtract(const Duration(days: 2)),
      talentFocus: 'short',
      handoffNote: 'tiny',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a calibration review',
      'Select a handoff type',
      'Select a handoff status',
      'Please enter a handoff owner',
      'Please enter a receiving manager',
      'Target start date cannot be in the past',
      'First checkpoint cannot be before target start',
      'Talent focus must be at least 8 characters',
      'Handoff notes must be at least 12 characters',
    ]);
  });

  test('candidate talent handoffs submit and summarize risk', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    final readyReview = _submitReadyCalibrationReview(
      container,
      'Fajar Nugroho',
    );

    container
        .read(candidateTalentHandoffDraftProvider.notifier)
        .initializeFromCalibrationReview(readyReview);

    final readyHandoff = container
        .read(candidateTalentHandoffsProvider.notifier)
        .submitDraft(container.read(candidateTalentHandoffDraftProvider));

    expect(readyHandoff.id, 'talent-handoff-001');
    expect(readyHandoff.candidateName, 'Fajar Nugroho');
    expect(readyHandoff.status, CandidateTalentHandoffStatus.ready);
    expect(readyHandoff.risk, CandidateTalentHandoffRisk.low);
    expect(readyHandoff.needsAttention, isFalse);

    var summary = container.read(candidateTalentHandoffSummaryProvider);
    expect(summary.totalCount, 1);
    expect(summary.readyCount, 1);
    expect(summary.watchCount, 0);
    expect(summary.blockedCount, 0);
    expect(summary.highRiskCount, 0);
    expect(summary.averageReadinessScore, 86);
    expect(summary.nextAction, 'Release 1 ready handoffs to ramp.');

    final blockedReview = _submitBlockedCalibrationReview(
      container,
      'Mira Lestari',
    );

    container
        .read(candidateTalentHandoffDraftProvider.notifier)
        .initializeFromCalibrationReview(blockedReview);

    final blockedHandoff = container
        .read(candidateTalentHandoffsProvider.notifier)
        .submitDraft(container.read(candidateTalentHandoffDraftProvider));

    expect(blockedHandoff.id, 'talent-handoff-002');
    expect(blockedHandoff.status, CandidateTalentHandoffStatus.blocked);
    expect(blockedHandoff.type, CandidateTalentHandoffType.deferred);
    expect(blockedHandoff.risk, CandidateTalentHandoffRisk.high);
    expect(
      blockedHandoff.targetStartDate,
      asOfDate.add(const Duration(days: 21)),
    );

    summary = container.read(candidateTalentHandoffSummaryProvider);
    expect(summary.totalCount, 2);
    expect(summary.readyCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.highRiskCount, 1);
    expect(summary.averageReadinessScore, 43);
    expect(summary.nextAction, 'Escalate 1 blocked handoffs.');
  });
}

CandidateDevelopmentCalibrationReview _submitReadyCalibrationReview(
  ProviderContainer container,
  String candidateName,
) {
  _submitReadyCheckIn(container, candidateName);
  final profile = container
      .read(candidateDevelopmentCalibrationProfilesProvider)
      .singleWhere((item) => item.candidateName == candidateName);

  container
      .read(candidateDevelopmentCalibrationDraftProvider.notifier)
      .initializeFromProfile(profile);

  return container
      .read(candidateDevelopmentCalibrationReviewsProvider.notifier)
      .submitDraft(
        container.read(candidateDevelopmentCalibrationDraftProvider),
      );
}

CandidateDevelopmentCalibrationReview _submitBlockedCalibrationReview(
  ProviderContainer container,
  String candidateName,
) {
  final checkIn = _submitBlockedCheckIn(container, candidateName);
  _submitIntervention(container, checkIn);
  final profile = container
      .read(candidateDevelopmentCalibrationProfilesProvider)
      .singleWhere((item) => item.candidateName == candidateName);

  container
      .read(candidateDevelopmentCalibrationDraftProvider.notifier)
      .initializeFromProfile(profile);

  return container
      .read(candidateDevelopmentCalibrationReviewsProvider.notifier)
      .submitDraft(
        container.read(candidateDevelopmentCalibrationDraftProvider),
      );
}

CandidateDevelopmentCheckIn _submitReadyCheckIn(
  ProviderContainer container,
  String candidateName,
) {
  final objective = _submitObjective(container, candidateName);
  container
      .read(candidateDevelopmentObjectivesProvider.notifier)
      .activate(objective.id);

  final activeObjective = container
      .read(candidateDevelopmentObjectivesProvider)
      .singleWhere((item) => item.id == objective.id);

  container
      .read(candidateDevelopmentCheckInDraftProvider.notifier)
      .initializeFromObjective(activeObjective);
  container
      .read(candidateDevelopmentCheckInDraftProvider.notifier)
      .setConfidence('5');

  return container
      .read(candidateDevelopmentCheckInsProvider.notifier)
      .submitDraft(container.read(candidateDevelopmentCheckInDraftProvider));
}

CandidateDevelopmentCheckIn _submitBlockedCheckIn(
  ProviderContainer container,
  String candidateName,
) {
  final objective = _submitObjective(container, candidateName);

  container
      .read(candidateDevelopmentCheckInDraftProvider.notifier)
      .initializeFromObjective(objective);
  container
      .read(candidateDevelopmentCheckInDraftProvider.notifier)
      .setConfidence('2');
  container
      .read(candidateDevelopmentCheckInDraftProvider.notifier)
      .setBlockerNote('Mentor capacity is blocked this week.');

  return container
      .read(candidateDevelopmentCheckInsProvider.notifier)
      .submitDraft(container.read(candidateDevelopmentCheckInDraftProvider));
}

CandidateDevelopmentIntervention _submitIntervention(
  ProviderContainer container,
  CandidateDevelopmentCheckIn checkIn,
) {
  container
      .read(candidateDevelopmentInterventionDraftProvider.notifier)
      .initializeFromCheckIn(checkIn);

  return container
      .read(candidateDevelopmentInterventionsProvider.notifier)
      .submitDraft(
        container.read(candidateDevelopmentInterventionDraftProvider),
      );
}

CandidateDevelopmentObjective _submitObjective(
  ProviderContainer container,
  String candidateName,
) {
  final packet = container
      .read(candidateDecisionPacketsProvider)
      .singleWhere((item) => item.candidateName == candidateName);

  container
      .read(candidateDevelopmentObjectiveDraftProvider.notifier)
      .initializeFromPacket(packet);

  return container
      .read(candidateDevelopmentObjectivesProvider.notifier)
      .submitDraft(container.read(candidateDevelopmentObjectiveDraftProvider));
}
