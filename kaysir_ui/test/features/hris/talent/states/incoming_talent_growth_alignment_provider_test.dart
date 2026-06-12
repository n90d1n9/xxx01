import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_portfolio_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_program_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_growth_alignment_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_growth_alignment_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('growth alignment highlights training and career path gaps', () {
    final asOfDate = DateTime(2026, 6, 9);
    final portfolio = _portfolio(
      asOfDate,
      stage: IncomingTalentDevelopmentPortfolioStage.active,
      priority: IncomingTalentDevelopmentPortfolioPriority.accelerated,
      readinessScore: 88,
    );
    final container = _container(
      asOfDate,
      portfolios: [portfolio],
      programs: [_program(asOfDate)],
    );
    addTearDown(container.dispose);

    final items = container.read(incomingTalentGrowthAlignmentItemsProvider);
    final summary = container.read(
      incomingTalentGrowthAlignmentSummaryProvider,
    );

    expect(items, hasLength(1));
    expect(
      items.single.status,
      IncomingTalentGrowthAlignmentStatus.needsTraining,
    );
    expect(items.single.hasTrainingEnrollment, isFalse);
    expect(items.single.hasCareerPath, isFalse);
    expect(items.single.trainingTitle, 'Engineering growth accelerator');
    expect(
      items.single.nextAction,
      'Enroll Fajar Nugroho into Engineering growth accelerator and create a career path.',
    );
    expect(summary.trainingGapCount, 1);
    expect(summary.careerGapCount, 1);
    expect(summary.nextAction, 'Assign training for 1 IDP portfolios.');
  });

  test(
    'growth alignment flags evidence risk across training and career path',
    () {
      final asOfDate = DateTime(2026, 6, 9);
      final portfolio = _portfolio(
        asOfDate,
        stage: IncomingTalentDevelopmentPortfolioStage.watch,
        priority: IncomingTalentDevelopmentPortfolioPriority.recovery,
        readinessScore: 52,
      );
      final container = _container(
        asOfDate,
        portfolios: [portfolio],
        programs: [
          _program(
            asOfDate,
            track: IncomingTalentDevelopmentProgramTrack.recovery,
          ),
        ],
        enrollments: [
          _enrollment(
            asOfDate,
            portfolio: portfolio,
            status: IncomingTalentDevelopmentProgramEnrollmentStatus.watch,
            progressScore: 52,
          ),
        ],
        careerPaths: [
          _careerPath(
            asOfDate,
            portfolio: portfolio,
            status: IncomingTalentCareerPathStatus.blocked,
            priority: IncomingTalentCareerPathPriority.critical,
          ),
        ],
      );
      addTearDown(container.dispose);

      final item =
          container.read(incomingTalentGrowthAlignmentItemsProvider).single;
      final summary = container.read(
        incomingTalentGrowthAlignmentSummaryProvider,
      );

      expect(item.status, IncomingTalentGrowthAlignmentStatus.atRisk);
      expect(item.focus, IncomingTalentGrowthAlignmentFocus.evidence);
      expect(item.needsAttention, isTrue);
      expect(item.hasTrainingEnrollment, isTrue);
      expect(item.hasCareerPath, isTrue);
      expect(summary.evidenceGapCount, 1);
      expect(summary.attentionCount, 1);
      expect(summary.nextAction, 'Collect evidence for 1 growth alignments.');
    },
  );

  test(
    'growth alignment filters attention after deriving missing coverage',
    () {
      final asOfDate = DateTime(2026, 6, 9);
      final engineeringPortfolio = _portfolio(
        asOfDate,
        id: 'idp-engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        role: 'Senior Flutter Engineer',
        stage: IncomingTalentDevelopmentPortfolioStage.active,
        priority: IncomingTalentDevelopmentPortfolioPriority.accelerated,
        readinessScore: 91,
      );
      final financePortfolio = _portfolio(
        asOfDate,
        id: 'idp-finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        role: 'Finance Operations Analyst',
        stage: IncomingTalentDevelopmentPortfolioStage.active,
        priority: IncomingTalentDevelopmentPortfolioPriority.focused,
        readinessScore: 82,
      );
      final container = _container(
        asOfDate,
        portfolios: [engineeringPortfolio, financePortfolio],
        programs: [
          _program(asOfDate),
          _program(
            asOfDate,
            id: 'program-finance',
            title: 'Finance growth academy',
            department: 'Finance',
          ),
        ],
        enrollments: [_enrollment(asOfDate, portfolio: engineeringPortfolio)],
        careerPaths: [_careerPath(asOfDate, portfolio: engineeringPortfolio)],
      );
      addTearDown(container.dispose);

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      final filtered = container.read(
        incomingTalentGrowthAlignmentItemsProvider,
      );

      expect(filtered.map((item) => item.candidateName), ['Mira Lestari']);
      expect(
        filtered.single.status,
        IncomingTalentGrowthAlignmentStatus.needsTraining,
      );
      expect(filtered.single.needsAttention, isTrue);
    },
  );
}

ProviderContainer _container(
  DateTime asOfDate, {
  List<IncomingTalentDevelopmentPortfolio> portfolios = const [],
  List<IncomingTalentDevelopmentProgram> programs = const [],
  List<IncomingTalentDevelopmentProgramEnrollment> enrollments = const [],
  List<IncomingTalentCareerPath> careerPaths = const [],
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      incomingTalentGrowthAlignmentSourcePortfoliosProvider.overrideWithValue(
        portfolios,
      ),
      incomingTalentGrowthAlignmentSourceProgramsProvider.overrideWithValue(
        programs,
      ),
      incomingTalentGrowthAlignmentSourceEnrollmentsProvider.overrideWithValue(
        enrollments,
      ),
      incomingTalentGrowthAlignmentSourceCareerPathsProvider.overrideWithValue(
        careerPaths,
      ),
    ],
  );
}

IncomingTalentDevelopmentPortfolio _portfolio(
  DateTime asOfDate, {
  String id = 'idp-engineering',
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
    portfolioOwnerName: '$department HRBP',
    mentorName: '$department Mentor',
    competencyFocus: '$role platform growth',
    growthGoal: 'Build stronger $role delivery habits with evidence.',
    learningPath: 'Complete manager-supported $role learning path.',
    evidencePlan: 'Submit reviewed work evidence and mentor feedback.',
    stage: stage,
    priority: priority,
    reviewCadence: IncomingTalentDevelopmentPortfolioCadence.biweekly,
    startDate: asOfDate,
    nextReviewDate: asOfDate.add(const Duration(days: 14)),
    targetCompletionDate: asOfDate.add(const Duration(days: 90)),
    sourceRoadmapStatus: IncomingTalentDevelopmentRoadmapStatus.active,
    sourceRetentionRisk: IncomingTalentActivationRetentionRisk.low,
    sourceReadinessScore: readinessScore,
    createdAt: asOfDate,
  );
}

IncomingTalentDevelopmentProgram _program(
  DateTime asOfDate, {
  String id = 'program-engineering',
  String title = 'Engineering growth accelerator',
  String department = 'Engineering',
  IncomingTalentDevelopmentProgramTrack track =
      IncomingTalentDevelopmentProgramTrack.leadership,
}) {
  return IncomingTalentDevelopmentProgram(
    id: id,
    title: title,
    department: department,
    ownerName: '$department HRBP',
    track: track,
    status: IncomingTalentDevelopmentProgramStatus.active,
    intensity: IncomingTalentDevelopmentProgramIntensity.standard,
    skillFocus: '$department platform leadership growth',
    expectedOutcome: 'Ready talent can lead a scoped operating review.',
    capacity: 12,
    durationDays: 60,
    startDate: asOfDate,
    endDate: asOfDate.add(const Duration(days: 60)),
    createdAt: asOfDate,
  );
}

IncomingTalentDevelopmentProgramEnrollment _enrollment(
  DateTime asOfDate, {
  required IncomingTalentDevelopmentPortfolio portfolio,
  IncomingTalentDevelopmentProgramEnrollmentStatus status =
      IncomingTalentDevelopmentProgramEnrollmentStatus.active,
  int progressScore = 82,
}) {
  return IncomingTalentDevelopmentProgramEnrollment(
    id: 'enrollment-${portfolio.id}',
    programId: 'program-${portfolio.department.toLowerCase()}',
    programTitle: '${portfolio.department} growth accelerator',
    portfolioId: portfolio.id,
    candidateId: portfolio.candidateId,
    candidateName: portfolio.candidateName,
    role: portfolio.role,
    department: portfolio.department,
    mentorName: portfolio.mentorName,
    milestone: 'Complete manager-reviewed growth milestone.',
    evidencePlan: 'Submit mentor notes and reviewed output evidence.',
    status: status,
    progressScore: progressScore,
    enrolledAt: asOfDate,
    nextReviewDate: asOfDate.add(const Duration(days: 7)),
    targetCompletionDate: asOfDate.add(const Duration(days: 60)),
    sourcePortfolioStage: portfolio.stage,
    sourcePortfolioPriority: portfolio.priority,
    createdAt: asOfDate,
  );
}

IncomingTalentCareerPath _careerPath(
  DateTime asOfDate, {
  required IncomingTalentDevelopmentPortfolio portfolio,
  IncomingTalentCareerPathStatus status = IncomingTalentCareerPathStatus.active,
  IncomingTalentCareerPathPriority priority =
      IncomingTalentCareerPathPriority.standard,
}) {
  return IncomingTalentCareerPath(
    id: 'career-${portfolio.id}',
    portfolioId: portfolio.id,
    roadmapId: portfolio.roadmapId,
    candidateId: portfolio.candidateId,
    candidateName: portfolio.candidateName,
    department: portfolio.department,
    currentRole: portfolio.role,
    targetRole: '${portfolio.role} Lead',
    ownerName: portfolio.portfolioOwnerName,
    mentorName: portfolio.mentorName,
    competencyName: portfolio.competencyFocus,
    currentLevel: 3,
    targetLevel: 4,
    status: status,
    priority: priority,
    developmentAction: 'Lead a scoped delivery review with manager feedback.',
    evidenceRequirement: 'Submit reviewed delivery plan and mentor feedback.',
    reviewDate: asOfDate.add(const Duration(days: 14)),
    sourcePortfolioPriority: portfolio.priority,
    sourcePortfolioStage: portfolio.stage,
    createdAt: asOfDate,
  );
}
