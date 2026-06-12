import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_talent_handoff_checklist_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_talent_handoff_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_talent_handoff_checklist_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('candidate talent handoff checklist draft initializes from handoff', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    final handoff = _readyHandoff(asOfDate);

    container
        .read(candidateTalentHandoffChecklistDraftProvider.notifier)
        .initializeFromHandoff(handoff);

    final draft = container.read(candidateTalentHandoffChecklistDraftProvider);

    expect(draft.handoffId, 'talent-handoff-001');
    expect(draft.candidateId, 'candidate-fajar');
    expect(draft.candidateName, 'Fajar Nugroho');
    expect(draft.category, CandidateTalentHandoffChecklistCategory.paperwork);
    expect(draft.title, 'Complete offer and contract handoff');
    expect(draft.ownerName, 'Talent Partner');
    expect(draft.dueDate, asOfDate.add(const Duration(days: 5)));
    expect(draft.requiredBeforeStart, isTrue);
    expect(draft.detail, 'Confirm readiness for Fajar Nugroho.');
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('candidate talent handoff checklist draft validates fields', () {
    final asOfDate = DateTime(2026, 5, 30);
    final draft = CandidateTalentHandoffChecklistDraft.empty(asOfDate).copyWith(
      title: 'short',
      dueDate: asOfDate.subtract(const Duration(days: 1)),
      detail: 'tiny',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a talent handoff',
      'Select a checklist category',
      'Checklist title must be at least 8 characters',
      'Please enter an owner',
      'Due date cannot be in the past',
      'Checklist detail must be at least 12 characters',
    ]);
  });

  test('candidate talent handoff checklist templates generate task packs', () {
    final asOfDate = DateTime(2026, 5, 30);
    final container = ProviderContainer(
      overrides: [
        recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
        talentAsOfDateProvider.overrideWithValue(asOfDate),
      ],
    );
    addTearDown(container.dispose);

    final handoff = _readyHandoff(asOfDate);
    var coverage = CandidateTalentHandoffChecklistCoverage.fromHandoff(
      handoff: handoff,
      items: const [],
    );

    expect(coverage.templateLabel, 'Offer transition checklist');
    expect(coverage.coverageRatio, 0);
    expect(coverage.missingCategories, [
      CandidateTalentHandoffChecklistCategory.paperwork,
      CandidateTalentHandoffChecklistCategory.payroll,
      CandidateTalentHandoffChecklistCategory.access,
      CandidateTalentHandoffChecklistCategory.managerKickoff,
      CandidateTalentHandoffChecklistCategory.mentor,
    ]);
    expect(coverage.nextAction, 'Generate 5 missing checklist tasks.');

    final generated = container
        .read(candidateTalentHandoffChecklistItemsProvider.notifier)
        .generateForHandoff(handoff: handoff, asOfDate: asOfDate);

    expect(generated.length, 5);
    expect(generated.first.id, 'handoff-checklist-001');
    expect(generated.last.id, 'handoff-checklist-005');
    expect(generated.map((item) => item.category), [
      CandidateTalentHandoffChecklistCategory.paperwork,
      CandidateTalentHandoffChecklistCategory.payroll,
      CandidateTalentHandoffChecklistCategory.access,
      CandidateTalentHandoffChecklistCategory.managerKickoff,
      CandidateTalentHandoffChecklistCategory.mentor,
    ]);
    expect(generated.first.ownerName, 'Talent Partner');
    expect(generated.last.ownerName, 'Engineering Manager');

    coverage = CandidateTalentHandoffChecklistCoverage.fromHandoff(
      handoff: handoff,
      items: generated,
    );
    expect(coverage.isComplete, isTrue);
    expect(coverage.coverageRatio, 1);
    expect(coverage.missingCategories, isEmpty);
    expect(coverage.nextAction, 'Checklist coverage complete.');

    final duplicateAttempt = container
        .read(candidateTalentHandoffChecklistItemsProvider.notifier)
        .generateForHandoff(handoff: handoff, asOfDate: asOfDate);

    expect(duplicateAttempt, isEmpty);
    expect(
      container.read(candidateTalentHandoffChecklistItemsProvider).length,
      5,
    );
  });

  test(
    'candidate talent handoff checklist submits and tracks status summary',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = ProviderContainer(
        overrides: [
          recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
          talentAsOfDateProvider.overrideWithValue(asOfDate),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(candidateTalentHandoffChecklistDraftProvider.notifier)
          .initializeFromHandoff(_readyHandoff(asOfDate));

      final item = container
          .read(candidateTalentHandoffChecklistItemsProvider.notifier)
          .submitDraft(
            container.read(candidateTalentHandoffChecklistDraftProvider),
          );

      expect(item.id, 'handoff-checklist-001');
      expect(item.status, CandidateTalentHandoffChecklistStatus.open);
      expect(item.isDueSoon(asOfDate), isTrue);
      expect(item.daysUntilDue(asOfDate), 5);

      var summary = container.read(
        candidateTalentHandoffChecklistSummaryProvider,
      );
      expect(summary.totalCount, 1);
      expect(summary.openCount, 1);
      expect(summary.inProgressCount, 0);
      expect(summary.completedCount, 0);
      expect(summary.blockedCount, 0);
      expect(summary.dueSoonCount, 1);
      expect(summary.overdueCount, 0);
      expect(summary.nextAction, 'Complete 1 checklist tasks due soon.');

      container
          .read(candidateTalentHandoffChecklistItemsProvider.notifier)
          .block(item.id);

      summary = container.read(candidateTalentHandoffChecklistSummaryProvider);
      expect(summary.blockedCount, 1);
      expect(summary.nextAction, 'Unblock 1 handoff checklist tasks.');

      container
          .read(candidateTalentHandoffChecklistItemsProvider.notifier)
          .start(item.id);

      summary = container.read(candidateTalentHandoffChecklistSummaryProvider);
      expect(summary.inProgressCount, 1);
      expect(summary.nextAction, 'Complete 1 checklist tasks due soon.');

      container
          .read(candidateTalentHandoffChecklistItemsProvider.notifier)
          .complete(item.id);

      summary = container.read(candidateTalentHandoffChecklistSummaryProvider);
      expect(summary.completedCount, 1);
      expect(summary.dueSoonCount, 0);
      expect(summary.nextAction, 'Handoff checklist is complete.');
    },
  );
}

CandidateTalentHandoff _readyHandoff(DateTime asOfDate) {
  return CandidateTalentHandoff(
    id: 'talent-handoff-001',
    calibrationReviewId: 'development-calibration-001',
    objectiveId: 'development-objective-001',
    candidateId: 'candidate-fajar',
    candidateName: 'Fajar Nugroho',
    role: 'Senior Flutter Engineer',
    department: 'Engineering',
    type: CandidateTalentHandoffType.offerTransition,
    status: CandidateTalentHandoffStatus.ready,
    readinessScore: 86,
    ownerName: 'Talent Partner',
    receivingManagerName: 'Engineering Manager',
    targetStartDate: asOfDate.add(const Duration(days: 7)),
    firstCheckpointDate: asOfDate.add(const Duration(days: 21)),
    talentFocus: 'Confirm readiness for Fajar Nugroho.',
    handoffNote: 'Confirm readiness for Fajar Nugroho.',
    createdAt: asOfDate,
  );
}
