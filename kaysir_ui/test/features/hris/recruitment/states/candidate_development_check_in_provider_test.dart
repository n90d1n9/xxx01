import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_development_check_in_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_development_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_decision_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_development_check_in_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_development_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('candidate development check-in draft initializes from objective', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    final objective = _submitObjective(container, 'Fajar Nugroho');

    container
        .read(candidateDevelopmentCheckInDraftProvider.notifier)
        .initializeFromObjective(objective);

    final draft = container.read(candidateDevelopmentCheckInDraftProvider);

    expect(draft.objectiveId, 'development-objective-001');
    expect(draft.candidateName, 'Fajar Nugroho');
    expect(draft.ownerName, 'Talent Partner');
    expect(draft.mentorName, 'Alya Saputra');
    expect(draft.confidenceText, '3');
    expect(draft.nextReviewDate, asOfDate.add(const Duration(days: 14)));
    expect(draft.status, CandidateDevelopmentCheckInStatus.watch);
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('candidate development check-in draft validates required fields', () {
    final asOfDate = DateTime(2026, 5, 30);
    final draft = CandidateDevelopmentCheckInDraft.empty(asOfDate).copyWith(
      confidenceText: '7',
      progressNote: 'short',
      nextReviewDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter an objective',
      'Please enter an owner',
      'Please enter a mentor',
      'Select confidence from 1 to 5',
      'Progress note must be at least 12 characters',
      'Next review date cannot be in the past',
    ]);
  });

  test('candidate development check-ins submit and summarize confidence', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    final objective = _submitObjective(container, 'Mira Lestari');
    final draftNotifier = container.read(
      candidateDevelopmentCheckInDraftProvider.notifier,
    );

    draftNotifier.initializeFromObjective(objective);
    draftNotifier.setConfidence('2');
    draftNotifier.setBlockerNote('Payroll mentor is unavailable this week.');

    final checkIn = container
        .read(candidateDevelopmentCheckInsProvider.notifier)
        .submitDraft(container.read(candidateDevelopmentCheckInDraftProvider));

    expect(checkIn.id, 'development-check-in-001');
    expect(checkIn.candidateName, 'Mira Lestari');
    expect(checkIn.confidenceLevel, 2);
    expect(checkIn.status, CandidateDevelopmentCheckInStatus.blocked);
    expect(checkIn.daysUntilReview(asOfDate), 14);

    final summary = container.read(candidateDevelopmentCheckInSummaryProvider);
    expect(summary.totalCount, 1);
    expect(summary.onTrackCount, 0);
    expect(summary.watchCount, 0);
    expect(summary.blockedCount, 1);
    expect(summary.reviewDueSoonCount, 0);
    expect(summary.nextAction, 'Resolve 1 blocked check-ins.');
  });

  test('candidate development check-in summary detects review due soon', () {
    final asOfDate = DateTime(2026, 5, 30);
    final checkIn = CandidateDevelopmentCheckIn(
      id: 'development-check-in-001',
      objectiveId: 'development-objective-001',
      candidateName: 'Fajar Nugroho',
      role: 'Senior Flutter Engineer',
      department: 'Engineering',
      objectiveTitle: 'Close Flutter architecture readiness gap',
      ownerName: 'Talent Partner',
      mentorName: 'Alya Saputra',
      confidenceLevel: 5,
      progressNote: 'Architecture pairing is progressing smoothly.',
      blockerNote: '',
      nextReviewDate: asOfDate.add(const Duration(days: 5)),
      status: CandidateDevelopmentCheckInStatus.onTrack,
      createdAt: asOfDate,
    );

    final summary = CandidateDevelopmentCheckInSummary.fromCheckIns(
      checkIns: [checkIn],
      asOfDate: asOfDate,
    );

    expect(checkIn.isReviewDueSoon(asOfDate), isTrue);
    expect(summary.onTrackCount, 1);
    expect(summary.reviewDueSoonCount, 1);
    expect(summary.nextAction, 'Prepare 1 upcoming development reviews.');
  });
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
