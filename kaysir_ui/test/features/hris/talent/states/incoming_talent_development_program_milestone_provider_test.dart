import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_portfolio_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_program_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_program_enrollment_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_program_milestone_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('program milestone draft validates required review fields', () {
    final asOfDate = DateTime(2026, 6, 7);
    final draft = IncomingTalentDevelopmentProgramMilestoneDraft.empty(
      asOfDate,
    ).copyWith(
      title: 'short',
      evidenceSummary: 'tiny',
      reviewNotes: 'mini',
      score: -1,
      dueDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a program enrollment',
      'Please enter a reviewer',
      'Title must be at least 12 characters',
      'Evidence summary must be at least 12 characters',
      'Review notes must be at least 12 characters',
      'Select milestone type',
      'Select milestone status',
      'Score cannot be below 0',
      'Due date cannot be in the past',
      'Select source enrollment status',
    ]);
  });

  test(
    'program milestones default from watch enrollment and summarize review',
    () {
      final asOfDate = DateTime(2026, 6, 7);
      final enrollment = _enrollment(
        asOfDate,
        status: IncomingTalentDevelopmentProgramEnrollmentStatus.watch,
        progressScore: 48,
        sourceStage: IncomingTalentDevelopmentPortfolioStage.watch,
        sourcePriority: IncomingTalentDevelopmentPortfolioPriority.recovery,
      );
      final container = _container(asOfDate, enrollments: [enrollment]);
      addTearDown(container.dispose);

      final draft =
          IncomingTalentDevelopmentProgramMilestoneDraft.fromEnrollment(
            enrollment: enrollment,
            asOfDate: asOfDate,
          );

      expect(
        draft.status,
        IncomingTalentDevelopmentProgramMilestoneStatus.needsRevision,
      );
      expect(draft.score, 48);
      expect(draft.submittedAt, isNull);
      expect(draft.dueDate, enrollment.nextReviewDate);
      expect(draft.isReadyToSubmit, isTrue);

      final milestone = _submitMilestone(container, enrollment);

      expect(milestone.id, 'talent-program-milestone-001');
      expect(milestone.needsAttention, isTrue);
      expect(container.read(milestoneReadyProgramEnrollmentsProvider), isEmpty);

      final summary = container.read(
        incomingTalentDevelopmentProgramMilestoneSummaryProvider,
      );
      expect(summary.totalCount, 1);
      expect(summary.revisionCount, 1);
      expect(summary.dueSoonCount, 1);
      expect(summary.averageScore, 48);
      expect(summary.nextAction, 'Resolve 1 milestone revisions.');

      expect(
        () => container
            .read(incomingTalentDevelopmentProgramMilestonesProvider.notifier)
            .submitDraft(
              container.read(
                incomingTalentDevelopmentProgramMilestoneDraftProvider,
              ),
            ),
        throwsStateError,
      );
    },
  );

  test('program milestones follow talent filters', () {
    final asOfDate = DateTime(2026, 6, 7);
    final engineeringEnrollment = _enrollment(
      asOfDate,
      id: 'enrollment-engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
      status: IncomingTalentDevelopmentProgramEnrollmentStatus.active,
      progressScore: 88,
      sourceStage: IncomingTalentDevelopmentPortfolioStage.active,
      sourcePriority: IncomingTalentDevelopmentPortfolioPriority.accelerated,
    );
    final financeEnrollment = _enrollment(
      asOfDate,
      id: 'enrollment-finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
      status: IncomingTalentDevelopmentProgramEnrollmentStatus.watch,
      progressScore: 48,
      sourceStage: IncomingTalentDevelopmentPortfolioStage.watch,
      sourcePriority: IncomingTalentDevelopmentPortfolioPriority.recovery,
    );
    final container = _container(
      asOfDate,
      enrollments: [engineeringEnrollment, financeEnrollment],
    );
    addTearDown(container.dispose);

    _submitMilestone(container, engineeringEnrollment);
    _submitMilestone(container, financeEnrollment);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentDevelopmentProgramMilestonesProvider,
    );
    final summary = container.read(
      incomingTalentDevelopmentProgramMilestoneSummaryProvider,
    );

    expect(filtered.map((milestone) => milestone.candidateName), [
      'Mira Lestari',
    ]);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.totalCount, 1);
    expect(summary.revisionCount, 1);
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentDevelopmentProgramEnrollment> enrollments,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentDevelopmentProgramEnrollmentsProvider
          .overrideWithValue(enrollments),
    ],
  );
}

IncomingTalentDevelopmentProgramMilestone _submitMilestone(
  ProviderContainer container,
  IncomingTalentDevelopmentProgramEnrollment enrollment,
) {
  container
      .read(incomingTalentDevelopmentProgramMilestoneDraftProvider.notifier)
      .initializeFromEnrollment(enrollment);
  return container
      .read(incomingTalentDevelopmentProgramMilestonesProvider.notifier)
      .submitDraft(
        container.read(incomingTalentDevelopmentProgramMilestoneDraftProvider),
      );
}

IncomingTalentDevelopmentProgramEnrollment _enrollment(
  DateTime asOfDate, {
  String id = 'enrollment-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentDevelopmentProgramEnrollmentStatus status,
  required int progressScore,
  required IncomingTalentDevelopmentPortfolioStage sourceStage,
  required IncomingTalentDevelopmentPortfolioPriority sourcePriority,
}) {
  return IncomingTalentDevelopmentProgramEnrollment(
    id: id,
    programId: 'program-$department',
    programTitle: '$department readiness cohort',
    portfolioId: 'portfolio-$id',
    candidateId: 'candidate-${candidateName.toLowerCase().split(' ').first}',
    candidateName: candidateName,
    role: role,
    department: department,
    mentorName: '$department Mentor',
    milestone: 'Complete $role readiness milestone with reviewed evidence.',
    evidencePlan: 'Submit manager-reviewed evidence for $role readiness.',
    status: status,
    progressScore: progressScore,
    enrolledAt: asOfDate,
    nextReviewDate: asOfDate.add(const Duration(days: 7)),
    targetCompletionDate: asOfDate.add(const Duration(days: 60)),
    sourcePortfolioStage: sourceStage,
    sourcePortfolioPriority: sourcePriority,
    createdAt: asOfDate,
  );
}
