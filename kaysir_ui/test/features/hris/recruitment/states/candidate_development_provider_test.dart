import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_development_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_decision_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_development_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('candidate development draft initializes from a decision packet', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    final packet = container
        .read(candidateDecisionPacketsProvider)
        .singleWhere((item) => item.candidateName == 'Mira Lestari');

    container
        .read(candidateDevelopmentObjectiveDraftProvider.notifier)
        .initializeFromPacket(packet);

    final draft = container.read(candidateDevelopmentObjectiveDraftProvider);

    expect(draft.candidateId, 'cand-002');
    expect(draft.objectiveTitle, 'Close Payroll reconciliation readiness gap');
    expect(draft.skillFocus, 'Payroll reconciliation');
    expect(draft.mentorName, 'Emma Rodriguez');
    expect(draft.startDate, asOfDate.add(const Duration(days: 4)));
    expect(draft.dueDate, asOfDate.add(const Duration(days: 49)));
    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.completionRatio, 1);
  });

  test('candidate development draft validates required objective fields', () {
    final asOfDate = DateTime(2026, 5, 30);
    final draft = CandidateDevelopmentObjectiveDraft.empty(asOfDate).copyWith(
      objectiveTitle: 'Fit',
      startDate: asOfDate.subtract(const Duration(days: 1)),
      dueDate: asOfDate,
      successMeasure: 'short',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a candidate',
      'Objective title is too short',
      'Please enter a skill focus',
      'Please enter an owner',
      'Please enter a mentor',
      'Start date cannot be in the past',
      'Success measure must be at least 12 characters',
    ]);
    expect(
      CandidateDevelopmentObjectiveDraft.validateDueDate(asOfDate, asOfDate),
      'Due date must be after start date',
    );
  });

  test('candidate development objectives submit and track status summary', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    final packet = container
        .read(candidateDecisionPacketsProvider)
        .singleWhere((item) => item.candidateName == 'Fajar Nugroho');
    final draftNotifier = container.read(
      candidateDevelopmentObjectiveDraftProvider.notifier,
    );

    draftNotifier.initializeFromPacket(packet);

    final objective = container
        .read(candidateDevelopmentObjectivesProvider.notifier)
        .submitDraft(
          container.read(candidateDevelopmentObjectiveDraftProvider),
        );

    expect(objective.id, 'development-objective-001');
    expect(objective.candidateName, 'Fajar Nugroho');
    expect(objective.status, CandidateDevelopmentObjectiveStatus.planned);
    expect(objective.daysUntilDue(asOfDate), 44);

    var summary = container.read(candidateDevelopmentObjectiveSummaryProvider);
    expect(summary.totalCount, 1);
    expect(summary.plannedCount, 1);
    expect(summary.activeCount, 0);
    expect(summary.completedCount, 0);
    expect(summary.dueSoonCount, 0);
    expect(summary.nextAction, 'Activate 1 planned development objectives.');

    container
        .read(candidateDevelopmentObjectivesProvider.notifier)
        .activate(objective.id);

    summary = container.read(candidateDevelopmentObjectiveSummaryProvider);
    expect(summary.plannedCount, 0);
    expect(summary.activeCount, 1);
    expect(summary.nextAction, 'Track active candidate development progress.');

    container
        .read(candidateDevelopmentObjectivesProvider.notifier)
        .complete(objective.id);

    summary = container.read(candidateDevelopmentObjectiveSummaryProvider);
    expect(summary.activeCount, 0);
    expect(summary.completedCount, 1);
    expect(
      summary.nextAction,
      'Candidate development objectives are complete.',
    );
  });

  test('candidate development summary detects objectives due soon', () {
    final asOfDate = DateTime(2026, 5, 30);
    final objective = CandidateDevelopmentObjective(
      id: 'development-objective-001',
      candidateId: 'cand-001',
      candidateName: 'Fajar Nugroho',
      role: 'Senior Flutter Engineer',
      department: 'Engineering',
      objectiveTitle: 'Close Flutter architecture readiness gap',
      skillFocus: 'Flutter architecture',
      ownerName: 'Talent Partner',
      mentorName: 'Alya Saputra',
      successMeasure: 'First sprint architecture review completed.',
      startDate: asOfDate,
      dueDate: asOfDate.add(const Duration(days: 10)),
      status: CandidateDevelopmentObjectiveStatus.active,
      createdAt: asOfDate,
    );

    final summary = CandidateDevelopmentObjectiveSummary.fromObjectives(
      objectives: [objective],
      asOfDate: asOfDate,
    );

    expect(objective.isDueSoon(asOfDate), isTrue);
    expect(summary.dueSoonCount, 1);
    expect(summary.nextAction, 'Review 1 development objectives due soon.');
  });
}
