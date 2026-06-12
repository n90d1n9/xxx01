import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_portfolio_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_path_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_portfolio_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('career path draft defaults from recovery IDP portfolio', () {
    final asOfDate = DateTime(2026, 6, 7);
    final portfolio = _portfolio(
      asOfDate,
      priority: IncomingTalentDevelopmentPortfolioPriority.recovery,
      stage: IncomingTalentDevelopmentPortfolioStage.watch,
      readinessScore: 52,
    );

    final draft = IncomingTalentCareerPathDraft.fromPortfolio(
      portfolio: portfolio,
      asOfDate: asOfDate,
    );

    expect(draft.portfolioId, portfolio.id);
    expect(draft.targetRole, '${portfolio.role} - stabilized');
    expect(draft.currentLevel, 1);
    expect(draft.targetLevel, 4);
    expect(draft.status, IncomingTalentCareerPathStatus.blocked);
    expect(draft.priority, IncomingTalentCareerPathPriority.critical);
    expect(draft.reviewDate, asOfDate.add(const Duration(days: 14)));
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('career paths submit from portfolio and summarize critical gaps', () {
    final asOfDate = DateTime(2026, 6, 7);
    final portfolio = _portfolio(
      asOfDate,
      priority: IncomingTalentDevelopmentPortfolioPriority.recovery,
      stage: IncomingTalentDevelopmentPortfolioStage.watch,
      readinessScore: 52,
    );
    final container = _container(asOfDate, portfolios: [portfolio]);
    addTearDown(container.dispose);

    final careerPath = _submitCareerPath(container, portfolio);

    expect(careerPath.id, 'talent-career-path-001');
    expect(careerPath.levelGap, 3);
    expect(careerPath.needsAttention, isTrue);
    expect(
      container.read(careerPathReadyDevelopmentPortfoliosProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(incomingTalentCareerPathsProvider.notifier)
          .submitDraft(container.read(incomingTalentCareerPathDraftProvider)),
      throwsStateError,
    );

    final summary = container.read(incomingTalentCareerPathSummaryProvider);
    expect(summary.totalCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.criticalCount, 1);
    expect(summary.averageGap, 3);
    expect(summary.nextAction, 'Unblock 1 critical career paths.');
  });

  test('career path draft validates required fields and levels', () {
    final asOfDate = DateTime(2026, 6, 7);
    final draft = IncomingTalentCareerPathDraft.empty(asOfDate).copyWith(
      competencyName: 'ab',
      currentLevel: 0,
      targetLevel: 0,
      developmentAction: 'short',
      evidenceRequirement: 'tiny',
      reviewDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter an IDP portfolio',
      'Please enter a current role',
      'Please enter a target role',
      'Please enter an owner',
      'Please enter a mentor',
      'Competency is too short',
      'Development action must be at least 12 characters',
      'Evidence requirement must be at least 12 characters',
      'Select career path status',
      'Select career path priority',
      'Current level must be between 1 and 5',
      'Target level must be between 1 and 5',
      'Review date cannot be in the past',
    ]);
  });

  test('career paths follow talent filters', () {
    final asOfDate = DateTime(2026, 6, 7);
    final engineeringPortfolio = _portfolio(
      asOfDate,
      id: 'portfolio-engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
      priority: IncomingTalentDevelopmentPortfolioPriority.accelerated,
      stage: IncomingTalentDevelopmentPortfolioStage.active,
      readinessScore: 91,
    );
    final financePortfolio = _portfolio(
      asOfDate,
      id: 'portfolio-finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
      priority: IncomingTalentDevelopmentPortfolioPriority.recovery,
      stage: IncomingTalentDevelopmentPortfolioStage.watch,
      readinessScore: 48,
    );
    final container = _container(
      asOfDate,
      portfolios: [engineeringPortfolio, financePortfolio],
    );
    addTearDown(container.dispose);

    _submitCareerPath(container, engineeringPortfolio);
    _submitCareerPath(container, financePortfolio);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(filteredIncomingTalentCareerPathsProvider);
    final summary = container.read(incomingTalentCareerPathSummaryProvider);

    expect(filtered.map((careerPath) => careerPath.candidateName), [
      'Mira Lestari',
    ]);
    expect(filtered.single.status, IncomingTalentCareerPathStatus.blocked);
    expect(summary.totalCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.nextAction, 'Unblock 1 critical career paths.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentDevelopmentPortfolio> portfolios,
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

IncomingTalentCareerPath _submitCareerPath(
  ProviderContainer container,
  IncomingTalentDevelopmentPortfolio portfolio,
) {
  container
      .read(incomingTalentCareerPathDraftProvider.notifier)
      .initializeFromPortfolio(portfolio);
  return container
      .read(incomingTalentCareerPathsProvider.notifier)
      .submitDraft(container.read(incomingTalentCareerPathDraftProvider));
}

IncomingTalentDevelopmentPortfolio _portfolio(
  DateTime asOfDate, {
  String id = 'portfolio-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentDevelopmentPortfolioPriority priority,
  required IncomingTalentDevelopmentPortfolioStage stage,
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
    competencyFocus: '$role capability matrix',
    growthGoal: 'Build practical growth signals for $role performance.',
    learningPath: 'Complete manager-supported $role learning path.',
    evidencePlan: 'Provide signed evidence for the target competency.',
    stage: stage,
    priority: priority,
    reviewCadence: IncomingTalentDevelopmentPortfolioCadence.monthly,
    startDate: asOfDate,
    nextReviewDate: asOfDate.add(const Duration(days: 30)),
    targetCompletionDate: asOfDate.add(const Duration(days: 90)),
    sourceRoadmapStatus: IncomingTalentDevelopmentRoadmapStatus.active,
    sourceRetentionRisk: IncomingTalentActivationRetentionRisk.low,
    sourceReadinessScore: readinessScore,
    createdAt: asOfDate,
  );
}
