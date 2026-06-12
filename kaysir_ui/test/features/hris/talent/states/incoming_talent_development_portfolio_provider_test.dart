import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_activation_outcome_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_portfolio_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_roadmap_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_portfolio_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_development_roadmap_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('IDP portfolio defaults from at-risk development roadmap', () {
    final asOfDate = DateTime(2026, 6, 7);
    final roadmap = _roadmap(
      asOfDate,
      status: IncomingTalentDevelopmentRoadmapStatus.atRisk,
      risk: IncomingTalentActivationRetentionRisk.high,
      readinessScore: 52,
    );

    final draft = IncomingTalentDevelopmentPortfolioDraft.fromRoadmap(
      roadmap: roadmap,
      asOfDate: asOfDate,
    );

    expect(draft.roadmapId, roadmap.id);
    expect(draft.stage, IncomingTalentDevelopmentPortfolioStage.watch);
    expect(draft.priority, IncomingTalentDevelopmentPortfolioPriority.recovery);
    expect(
      draft.reviewCadence,
      IncomingTalentDevelopmentPortfolioCadence.weekly,
    );
    expect(draft.nextReviewDate, asOfDate.add(const Duration(days: 7)));
    expect(draft.competencyFocus, roadmap.focusArea);
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('IDP portfolios submit from roadmap and summarize attention', () {
    final asOfDate = DateTime(2026, 6, 7);
    final roadmap = _roadmap(
      asOfDate,
      status: IncomingTalentDevelopmentRoadmapStatus.atRisk,
      risk: IncomingTalentActivationRetentionRisk.high,
      readinessScore: 52,
    );
    final container = _container(asOfDate, roadmaps: [roadmap]);
    addTearDown(container.dispose);

    final portfolio = _submitPortfolio(container, roadmap);

    expect(portfolio.id, 'talent-idp-001');
    expect(portfolio.stage, IncomingTalentDevelopmentPortfolioStage.watch);
    expect(portfolio.needsAttention, isTrue);
    expect(container.read(portfolioReadyDevelopmentRoadmapsProvider), isEmpty);

    expect(
      () => container
          .read(incomingTalentDevelopmentPortfoliosProvider.notifier)
          .submitDraft(
            container.read(incomingTalentDevelopmentPortfolioDraftProvider),
          ),
      throwsStateError,
    );

    final summary = container.read(
      incomingTalentDevelopmentPortfolioSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.watchCount, 1);
    expect(summary.recoveryPriorityCount, 1);
    expect(summary.nextAction, 'Stabilize 1 watch portfolios.');
  });

  test('IDP portfolio draft validates required fields', () {
    final asOfDate = DateTime(2026, 6, 7);
    final draft = IncomingTalentDevelopmentPortfolioDraft.empty(
      asOfDate,
    ).copyWith(
      competencyFocus: 'ab',
      growthGoal: 'short',
      learningPath: 'tiny',
      evidencePlan: 'mini',
      startDate: asOfDate.subtract(const Duration(days: 1)),
      nextReviewDate: asOfDate.subtract(const Duration(days: 1)),
      targetCompletionDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a development roadmap',
      'Please enter a portfolio owner',
      'Please enter a mentor',
      'Competency focus is too short',
      'Growth goal must be at least 12 characters',
      'Learning path must be at least 12 characters',
      'Evidence plan must be at least 12 characters',
      'Select portfolio stage',
      'Select portfolio priority',
      'Select review cadence',
      'Start date cannot be in the past',
      'Next review must be after the start date',
      'Target completion must be after the start date',
    ]);
  });

  test('IDP portfolios follow talent filters', () {
    final asOfDate = DateTime(2026, 6, 7);
    final engineeringRoadmap = _roadmap(
      asOfDate,
      id: 'roadmap-engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      role: 'Senior Flutter Engineer',
      status: IncomingTalentDevelopmentRoadmapStatus.active,
      risk: IncomingTalentActivationRetentionRisk.low,
      readinessScore: 91,
    );
    final financeRoadmap = _roadmap(
      asOfDate,
      id: 'roadmap-finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      role: 'Finance Operations Analyst',
      status: IncomingTalentDevelopmentRoadmapStatus.atRisk,
      risk: IncomingTalentActivationRetentionRisk.high,
      readinessScore: 48,
    );
    final container = _container(
      asOfDate,
      roadmaps: [engineeringRoadmap, financeRoadmap],
    );
    addTearDown(container.dispose);

    _submitPortfolio(container, engineeringRoadmap);
    _submitPortfolio(container, financeRoadmap);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentDevelopmentPortfoliosProvider,
    );
    final summary = container.read(
      incomingTalentDevelopmentPortfolioSummaryProvider,
    );

    expect(filtered.map((portfolio) => portfolio.candidateName), [
      'Mira Lestari',
    ]);
    expect(
      filtered.single.stage,
      IncomingTalentDevelopmentPortfolioStage.watch,
    );
    expect(summary.totalCount, 1);
    expect(summary.watchCount, 1);
    expect(summary.nextAction, 'Stabilize 1 watch portfolios.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentDevelopmentRoadmap> roadmaps,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentDevelopmentRoadmapsProvider.overrideWithValue(
        roadmaps,
      ),
    ],
  );
}

IncomingTalentDevelopmentPortfolio _submitPortfolio(
  ProviderContainer container,
  IncomingTalentDevelopmentRoadmap roadmap,
) {
  container
      .read(incomingTalentDevelopmentPortfolioDraftProvider.notifier)
      .initializeFromRoadmap(roadmap);
  return container
      .read(incomingTalentDevelopmentPortfoliosProvider.notifier)
      .submitDraft(
        container.read(incomingTalentDevelopmentPortfolioDraftProvider),
      );
}

IncomingTalentDevelopmentRoadmap _roadmap(
  DateTime asOfDate, {
  String id = 'roadmap-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String role = 'Senior Flutter Engineer',
  required IncomingTalentDevelopmentRoadmapStatus status,
  required IncomingTalentActivationRetentionRisk risk,
  required int readinessScore,
}) {
  return IncomingTalentDevelopmentRoadmap(
    id: id,
    outcomeReviewId: 'outcome-$id',
    activationPlanId: 'activation-$id',
    handoffId: 'handoff-$id',
    candidateId: 'candidate-${candidateName.toLowerCase().split(' ').first}',
    candidateName: candidateName,
    role: role,
    department: department,
    ownerName: '$department Manager',
    mentorName: '$department Mentor',
    focusArea: '$role competency growth',
    learningObjective: 'Build stronger $role delivery habits with evidence.',
    firstMilestone: 'Complete manager-reviewed $role milestone.',
    successMetric: 'Maintain readiness above target for the next cycle.',
    cadence: IncomingTalentDevelopmentRoadmapCadence.monthly,
    status: status,
    startDate: asOfDate,
    targetCompletionDate: asOfDate.add(const Duration(days: 60)),
    sourceDecision: IncomingTalentActivationOutcomeDecision.stabilized,
    retentionRisk: risk,
    readinessScore: readinessScore,
    createdAt: asOfDate,
  );
}
