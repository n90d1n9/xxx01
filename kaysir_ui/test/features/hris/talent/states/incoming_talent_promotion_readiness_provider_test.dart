import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_framework_level_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_portfolio_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_readiness_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_framework_level_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_path_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_readiness_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('promotion readiness draft defaults from matched source', () {
    final asOfDate = DateTime(2026, 6, 9);
    final source = _source(asOfDate);

    final draft = IncomingTalentPromotionReadinessDraft.fromSource(
      source: source,
      asOfDate: asOfDate,
    );

    expect(draft.careerPathId, source.careerPath.id);
    expect(draft.frameworkLevelId, source.frameworkLevel.id);
    expect(draft.candidateName, source.careerPath.candidateName);
    expect(draft.frameworkLevelCode, 'L5');
    expect(draft.rating, IncomingTalentPromotionReadinessRating.developing);
    expect(draft.status, IncomingTalentPromotionReadinessStatus.calibration);
    expect(draft.nextReviewDate, asOfDate.add(const Duration(days: 60)));
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('promotion readiness submits, de-duplicates, and summarizes', () {
    final asOfDate = DateTime(2026, 6, 9);
    final source = _source(asOfDate);
    final container = _container(asOfDate, source: source);
    addTearDown(container.dispose);
    final frameworkLevel = _submitFrameworkLevel(container, source.careerPath);
    final readySource = container.read(promotionReadinessSourceProvider).single;

    expect(readySource.id, '${source.careerPath.id}|${frameworkLevel.id}');

    final packet = _submitReadiness(container, readySource);

    expect(packet.id, 'talent-promotion-readiness-001');
    expect(packet.readinessScore, 0.45);
    expect(packet.needsAttention, isTrue);
    expect(container.read(promotionReadinessSourceProvider), isEmpty);
    expect(() => _submitReadiness(container, readySource), throwsStateError);

    final summary = container.read(
      incomingTalentPromotionReadinessSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.developingCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.averageReadinessScore, 0.45);
    expect(summary.nextAction, 'Coach 1 readiness packets needing support.');
  });

  test('promotion readiness draft validates required panel evidence', () {
    final asOfDate = DateTime(2026, 6, 9);
    final draft = IncomingTalentPromotionReadinessDraft.empty(
      asOfDate,
    ).copyWith(
      evidenceSummary: 'short',
      gapSummary: 'tiny',
      panelRecommendation: 'small',
      reviewDate: asOfDate.subtract(const Duration(days: 1)),
      nextReviewDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a career path',
      'Please enter a framework level',
      'Please enter an assessor',
      'Select readiness rating',
      'Evidence summary must be at least 12 characters',
      'Gap summary must be at least 12 characters',
      'Panel recommendation must be at least 12 characters',
      'Review date cannot be in the past',
      'Next review date must be after review date',
    ]);
  });

  test('promotion readiness follows department and attention filters', () {
    final asOfDate = DateTime(2026, 6, 9);
    final container = _container(asOfDate);
    addTearDown(container.dispose);
    final engineeringSource = _source(asOfDate);
    final financeSource = _source(
      asOfDate,
      id: 'finance',
      department: 'Finance',
      currentRole: 'Finance Analyst',
      targetRole: 'Finance Specialist',
      careerPathStatus: IncomingTalentCareerPathStatus.blocked,
      careerPathPriority: IncomingTalentCareerPathPriority.critical,
    );

    _submitReadiness(container, engineeringSource);
    _submitReadiness(container, financeSource);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentPromotionReadinessProvider,
    );
    final summary = container.read(
      incomingTalentPromotionReadinessSummaryProvider,
    );

    expect(filtered.map((packet) => packet.department), ['Finance']);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.blockedCount, 1);
    expect(summary.nextAction, 'Resolve 1 blocked readiness packets.');
  });
}

IncomingTalentPromotionReadinessSource _source(
  DateTime asOfDate, {
  String id = 'engineering',
  String department = 'Engineering',
  String currentRole = 'Backend Engineer',
  String targetRole = 'Lead Backend Engineer',
  IncomingTalentCareerPathStatus careerPathStatus =
      IncomingTalentCareerPathStatus.active,
  IncomingTalentCareerPathPriority careerPathPriority =
      IncomingTalentCareerPathPriority.accelerated,
}) {
  final careerPath = IncomingTalentCareerPath(
    id: 'career-path-$id',
    portfolioId: 'portfolio-$id',
    roadmapId: 'roadmap-$id',
    candidateId: 'candidate-$id',
    candidateName: '$department Talent',
    department: department,
    currentRole: currentRole,
    targetRole: targetRole,
    ownerName: '$department HRBP',
    mentorName: '$department Mentor',
    competencyName: '$department leadership',
    currentLevel: 3,
    targetLevel: 5,
    status: careerPathStatus,
    priority: careerPathPriority,
    developmentAction: 'Lead operating reviews and coach adjacent teams.',
    evidenceRequirement: 'Submit review outcomes and stakeholder feedback.',
    reviewDate: asOfDate.add(const Duration(days: 30)),
    sourcePortfolioPriority:
        IncomingTalentDevelopmentPortfolioPriority.accelerated,
    sourcePortfolioStage: IncomingTalentDevelopmentPortfolioStage.active,
    createdAt: asOfDate,
  );
  final frameworkLevel = IncomingTalentCareerFrameworkLevel(
    id: 'framework-$id',
    sourceCareerPathId: careerPath.id,
    department: department,
    familyName: '$currentRole family',
    levelCode: 'L5',
    roleTitle: targetRole,
    scope: IncomingTalentCareerFrameworkLevelScope.peopleLeadership,
    status: IncomingTalentCareerFrameworkLevelStatus.active,
    ownerName: '$department HRBP',
    competencyName: '$department leadership',
    successCriteria: 'Leads complex work with repeatable manager confidence.',
    evidenceRequirement: 'Provide calibrated stakeholder evidence.',
    reviewCadence: IncomingTalentCareerFrameworkReviewCadence.quarterly,
    createdAt: asOfDate,
  );

  return IncomingTalentPromotionReadinessSource(
    careerPath: careerPath,
    frameworkLevel: frameworkLevel,
  );
}

ProviderContainer _container(
  DateTime asOfDate, {
  IncomingTalentPromotionReadinessSource? source,
}) {
  final careerPaths =
      source == null ? const <IncomingTalentCareerPath>[] : [source.careerPath];

  final container = ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      if (source != null)
        filteredIncomingTalentCareerPathsProvider.overrideWithValue(
          careerPaths,
        ),
    ],
  );
  return container;
}

IncomingTalentCareerFrameworkLevel _submitFrameworkLevel(
  ProviderContainer container,
  IncomingTalentCareerPath careerPath,
) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft = IncomingTalentCareerFrameworkLevelDraft.fromCareerPath(
    careerPath: careerPath,
    asOfDate: asOfDate,
  );

  return container
      .read(incomingTalentCareerFrameworkLevelsProvider.notifier)
      .submitDraft(draft);
}

IncomingTalentPromotionReadiness _submitReadiness(
  ProviderContainer container,
  IncomingTalentPromotionReadinessSource source,
) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft = IncomingTalentPromotionReadinessDraft.fromSource(
    source: source,
    asOfDate: asOfDate,
  );

  return container
      .read(incomingTalentPromotionReadinessProvider.notifier)
      .submitDraft(draft);
}
