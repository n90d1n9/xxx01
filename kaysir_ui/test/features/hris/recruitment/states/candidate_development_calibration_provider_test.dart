import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_development_calibration_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_development_check_in_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_development_intervention_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_development_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_decision_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_development_calibration_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_development_check_in_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_development_intervention_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_development_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('candidate development calibration summarizes readiness signals', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    _submitReadyCheckIn(container, 'Fajar Nugroho');
    final blockedCheckIn = _submitBlockedCheckIn(container, 'Mira Lestari');
    _submitIntervention(container, blockedCheckIn);

    final profiles = container.read(
      candidateDevelopmentCalibrationProfilesProvider,
    );
    final readyProfile = profiles.singleWhere(
      (item) => item.candidateName == 'Fajar Nugroho',
    );
    final blockedProfile = profiles.singleWhere(
      (item) => item.candidateName == 'Mira Lestari',
    );

    expect(readyProfile.status, CandidateDevelopmentCalibrationStatus.ready);
    expect(readyProfile.readinessScore, 86);
    expect(readyProfile.latestConfidence, 5);
    expect(readyProfile.openInterventionCount, 0);
    expect(readyProfile.escalationRequired, isFalse);
    expect(readyProfile.nextAction, 'Confirm readiness for Fajar Nugroho.');

    expect(
      blockedProfile.status,
      CandidateDevelopmentCalibrationStatus.blocked,
    );
    expect(blockedProfile.readinessScore, 0);
    expect(blockedProfile.latestConfidence, 2);
    expect(blockedProfile.openInterventionCount, 1);
    expect(blockedProfile.escalationRequired, isTrue);
    expect(
      blockedProfile.nextAction,
      'Escalate unresolved development blocker.',
    );

    final summary = container.read(
      candidateDevelopmentCalibrationSummaryProvider,
    );
    expect(summary.totalCount, 2);
    expect(summary.readyCount, 1);
    expect(summary.monitorCount, 0);
    expect(summary.blockedCount, 1);
    expect(summary.averageReadinessScore, 43);
    expect(summary.nextAction, 'Escalate 1 blocked development calibrations.');
  });

  test('candidate development calibration draft initializes from profile', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    _submitReadyCheckIn(container, 'Fajar Nugroho');
    final profile = container
        .read(candidateDevelopmentCalibrationProfilesProvider)
        .singleWhere((item) => item.candidateName == 'Fajar Nugroho');

    container
        .read(candidateDevelopmentCalibrationDraftProvider.notifier)
        .initializeFromProfile(profile);

    final draft = container.read(candidateDevelopmentCalibrationDraftProvider);

    expect(draft.objectiveId, 'development-objective-001');
    expect(draft.candidateName, 'Fajar Nugroho');
    expect(draft.status, CandidateDevelopmentCalibrationStatus.ready);
    expect(draft.outcome, CandidateDevelopmentCalibrationOutcome.confirmReady);
    expect(draft.readinessScore, 86);
    expect(draft.ownerName, 'Talent Partner');
    expect(draft.reviewDate, asOfDate.add(const Duration(days: 7)));
    expect(draft.note, 'Confirm readiness for Fajar Nugroho.');
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('candidate development calibration draft validates required fields', () {
    final asOfDate = DateTime(2026, 5, 30);
    final draft = CandidateDevelopmentCalibrationDraft.empty(asOfDate).copyWith(
      note: 'short',
      nextAction: 'do',
      reviewDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a calibration profile',
      'Select a calibration status',
      'Select a calibration outcome',
      'Please enter an owner',
      'Review date cannot be in the past',
      'Calibration notes must be at least 12 characters',
      'Next action must be at least 8 characters',
    ]);
  });

  test('candidate development calibration reviews submit from ready draft', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    _submitReadyCheckIn(container, 'Fajar Nugroho');
    final profile = container
        .read(candidateDevelopmentCalibrationProfilesProvider)
        .singleWhere((item) => item.candidateName == 'Fajar Nugroho');

    container
        .read(candidateDevelopmentCalibrationDraftProvider.notifier)
        .initializeFromProfile(profile);

    final review = container
        .read(candidateDevelopmentCalibrationReviewsProvider.notifier)
        .submitDraft(
          container.read(candidateDevelopmentCalibrationDraftProvider),
        );

    expect(review.id, 'development-calibration-001');
    expect(review.candidateName, 'Fajar Nugroho');
    expect(review.status, CandidateDevelopmentCalibrationStatus.ready);
    expect(review.outcome, CandidateDevelopmentCalibrationOutcome.confirmReady);
    expect(review.readinessScore, 86);
    expect(review.reviewDate, asOfDate.add(const Duration(days: 7)));
    expect(review.nextAction, 'Confirm readiness for Fajar Nugroho.');
    expect(container.read(candidateDevelopmentCalibrationReviewsProvider), [
      review,
    ]);
  });
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
  final draftNotifier = container.read(
    candidateDevelopmentCheckInDraftProvider.notifier,
  );

  draftNotifier.initializeFromObjective(activeObjective);
  draftNotifier.setConfidence('5');

  return container
      .read(candidateDevelopmentCheckInsProvider.notifier)
      .submitDraft(container.read(candidateDevelopmentCheckInDraftProvider));
}

CandidateDevelopmentCheckIn _submitBlockedCheckIn(
  ProviderContainer container,
  String candidateName,
) {
  final objective = _submitObjective(container, candidateName);
  final draftNotifier = container.read(
    candidateDevelopmentCheckInDraftProvider.notifier,
  );

  draftNotifier.initializeFromObjective(objective);
  draftNotifier.setConfidence('2');
  draftNotifier.setBlockerNote('Mentor capacity is blocked this week.');

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
