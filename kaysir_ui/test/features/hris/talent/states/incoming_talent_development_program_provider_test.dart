import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_portfolio_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_program_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_portfolio_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_program_enrollment_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_program_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('development program draft validates required catalog fields', () {
    final asOfDate = DateTime(2026, 6, 7);
    final draft = IncomingTalentDevelopmentProgramDraft.empty(
      asOfDate,
    ).copyWith(
      skillFocus: 'short',
      expectedOutcome: 'tiny',
      capacity: 0,
      durationDays: 7,
      startDate: asOfDate.subtract(const Duration(days: 1)),
      endDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a title',
      'Please enter a department',
      'Please enter a program owner',
      'Select program track',
      'Skill focus must be at least 12 characters',
      'Expected outcome must be at least 12 characters',
      'Capacity must be at least 1',
      'Duration must be at least 14 days',
      'Start date cannot be in the past',
      'End date must be after the start date',
    ]);
  });

  test('development programs submit and summarize catalog readiness', () {
    final asOfDate = DateTime(2026, 6, 7);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final program = _submitProgram(container);

    expect(program.id, 'talent-program-001');
    expect(program.status, IncomingTalentDevelopmentProgramStatus.active);
    expect(program.acceptsEnrollment, isTrue);
    expect(program.availableSeats(3), 9);

    final summary = container.read(
      incomingTalentDevelopmentProgramSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.activeCount, 1);
    expect(summary.totalCapacity, 12);
    expect(summary.nextAction, 'Enroll talent into 1 programs.');

    expect(
      () => container
          .read(incomingTalentDevelopmentProgramsProvider.notifier)
          .submitDraft(_programDraft(asOfDate)),
      throwsStateError,
    );
  });

  test(
    'program enrollments default from IDP portfolio and summarize attention',
    () {
      final asOfDate = DateTime(2026, 6, 7);
      final portfolio = _portfolio(
        asOfDate,
        stage: IncomingTalentDevelopmentPortfolioStage.watch,
        priority: IncomingTalentDevelopmentPortfolioPriority.recovery,
        readinessScore: 52,
      );
      final container = _container(asOfDate, portfolios: [portfolio]);
      addTearDown(container.dispose);

      final program = _submitProgram(container);
      final draft =
          IncomingTalentDevelopmentProgramEnrollmentDraft.fromProgramPortfolio(
            program: program,
            portfolio: portfolio,
            asOfDate: asOfDate,
          );

      expect(
        draft.status,
        IncomingTalentDevelopmentProgramEnrollmentStatus.watch,
      );
      expect(draft.nextReviewDate, asOfDate.add(const Duration(days: 7)));
      expect(draft.isReadyToSubmit, isTrue);

      final enrollment = _submitEnrollment(container, program, portfolio);

      expect(enrollment.id, 'talent-program-enrollment-001');
      expect(enrollment.needsAttention, isTrue);
      expect(
        container.read(programReadyDevelopmentPortfoliosProvider),
        isEmpty,
      );

      final summary = container.read(
        incomingTalentDevelopmentProgramEnrollmentSummaryProvider,
      );
      expect(summary.totalCount, 1);
      expect(summary.watchCount, 1);
      expect(summary.dueSoonCount, 1);
      expect(summary.averageProgressScore, 52);
      expect(summary.nextAction, 'Stabilize 1 watch enrollments.');

      expect(
        () => container
            .read(incomingTalentDevelopmentProgramEnrollmentsProvider.notifier)
            .submitDraft(
              container.read(
                incomingTalentDevelopmentProgramEnrollmentDraftProvider,
              ),
            ),
        throwsStateError,
      );
    },
  );

  test('development program enrollments follow talent filters', () {
    final asOfDate = DateTime(2026, 6, 7);
    final engineeringPortfolio = _portfolio(
      asOfDate,
      id: 'idp-engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
      stage: IncomingTalentDevelopmentPortfolioStage.active,
      priority: IncomingTalentDevelopmentPortfolioPriority.accelerated,
      readinessScore: 88,
    );
    final financePortfolio = _portfolio(
      asOfDate,
      id: 'idp-finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
      stage: IncomingTalentDevelopmentPortfolioStage.watch,
      priority: IncomingTalentDevelopmentPortfolioPriority.recovery,
      readinessScore: 48,
    );
    final container = _container(
      asOfDate,
      portfolios: [engineeringPortfolio, financePortfolio],
    );
    addTearDown(container.dispose);

    final engineeringProgram = _submitProgram(
      container,
      title: 'Engineering mastery cohort',
      department: 'Engineering',
    );
    final financeProgram = _submitProgram(
      container,
      title: 'Finance recovery academy',
      department: 'Finance',
      track: IncomingTalentDevelopmentProgramTrack.recovery,
    );

    _submitEnrollment(container, engineeringProgram, engineeringPortfolio);
    _submitEnrollment(container, financeProgram, financePortfolio);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentDevelopmentProgramEnrollmentsProvider,
    );
    final summary = container.read(
      incomingTalentDevelopmentProgramEnrollmentSummaryProvider,
    );

    expect(filtered.map((enrollment) => enrollment.candidateName), [
      'Mira Lestari',
    ]);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.totalCount, 1);
    expect(summary.watchCount, 1);
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  List<IncomingTalentDevelopmentPortfolio> portfolios = const [],
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentDevelopmentPortfoliosProvider.overrideWithValue(
        portfolios,
      ),
    ],
  );
}

IncomingTalentDevelopmentProgram _submitProgram(
  ProviderContainer container, {
  String title = 'Leadership readiness cohort',
  String department = 'Engineering',
  IncomingTalentDevelopmentProgramTrack track =
      IncomingTalentDevelopmentProgramTrack.leadership,
}) {
  return container
      .read(incomingTalentDevelopmentProgramsProvider.notifier)
      .submitDraft(
        _programDraft(
          container.read(talentAsOfDateProvider),
          title: title,
          department: department,
          track: track,
        ),
      );
}

IncomingTalentDevelopmentProgramDraft _programDraft(
  DateTime asOfDate, {
  String title = 'Leadership readiness cohort',
  String department = 'Engineering',
  IncomingTalentDevelopmentProgramTrack track =
      IncomingTalentDevelopmentProgramTrack.leadership,
}) {
  return IncomingTalentDevelopmentProgramDraft.empty(asOfDate).copyWith(
    title: title,
    department: department,
    ownerName: '$department HRBP',
    track: track,
    skillFocus: '$department leadership decision-making',
    expectedOutcome: 'Ready talent can lead a scoped operating review.',
    startDate: asOfDate,
    endDate: asOfDate.add(const Duration(days: 60)),
  );
}

IncomingTalentDevelopmentProgramEnrollment _submitEnrollment(
  ProviderContainer container,
  IncomingTalentDevelopmentProgram program,
  IncomingTalentDevelopmentPortfolio portfolio,
) {
  container
      .read(incomingTalentDevelopmentProgramEnrollmentDraftProvider.notifier)
      .initializeFromProgramPortfolio(program: program, portfolio: portfolio);
  return container
      .read(incomingTalentDevelopmentProgramEnrollmentsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentDevelopmentProgramEnrollmentDraftProvider),
      );
}

IncomingTalentDevelopmentPortfolio _portfolio(
  DateTime asOfDate, {
  String id = 'idp-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentDevelopmentPortfolioStage stage,
  required IncomingTalentDevelopmentPortfolioPriority priority,
  required int readinessScore,
}) {
  return IncomingTalentDevelopmentPortfolio(
    id: id,
    roadmapId: 'roadmap-$id',
    outcomeReviewId: 'outcome-$id',
    candidateId: 'candidate-${candidateName.toLowerCase().split(' ').first}',
    candidateName: candidateName,
    role: role,
    department: department,
    portfolioOwnerName: '$department Manager',
    mentorName: '$department Mentor',
    competencyFocus: '$role competency growth',
    growthGoal: 'Build stronger $role delivery habits with evidence.',
    learningPath: 'Pair mentoring with a manager-reviewed delivery milestone.',
    evidencePlan: 'Track reviewed output and manager sign-off evidence.',
    stage: stage,
    priority: priority,
    reviewCadence: IncomingTalentDevelopmentPortfolioCadence.biweekly,
    startDate: asOfDate,
    nextReviewDate: asOfDate.add(const Duration(days: 14)),
    targetCompletionDate: asOfDate.add(const Duration(days: 60)),
    sourceRoadmapStatus: IncomingTalentDevelopmentRoadmapStatus.active,
    sourceRetentionRisk: IncomingTalentActivationRetentionRisk.medium,
    sourceReadinessScore: readinessScore,
    createdAt: asOfDate,
  );
}
