import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_framework_level_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_portfolio_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_framework_level_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_path_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('career framework draft defaults from career path', () {
    final asOfDate = DateTime(2026, 6, 9);
    final careerPath = _careerPath(asOfDate);

    final draft = IncomingTalentCareerFrameworkLevelDraft.fromCareerPath(
      careerPath: careerPath,
      asOfDate: asOfDate,
    );

    expect(draft.sourceCareerPathId, careerPath.id);
    expect(draft.department, careerPath.department);
    expect(draft.levelCode, 'L5');
    expect(draft.roleTitle, careerPath.targetRole);
    expect(
      draft.scope,
      IncomingTalentCareerFrameworkLevelScope.peopleLeadership,
    );
    expect(draft.status, IncomingTalentCareerFrameworkLevelStatus.active);
    expect(
      draft.reviewCadence,
      IncomingTalentCareerFrameworkReviewCadence.quarterly,
    );
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('career framework levels submit, prevent duplicates, and map paths', () {
    final asOfDate = DateTime(2026, 6, 9);
    final careerPath = _careerPath(asOfDate);
    final container = _container(asOfDate, careerPaths: [careerPath]);
    addTearDown(container.dispose);

    expect(container.read(careerFrameworkReadyCareerPathsProvider), [
      careerPath,
    ]);

    final level = _submitLevel(container, careerPath);

    expect(level.id, 'talent-career-framework-level-001');
    expect(level.matchesCareerPath(careerPath), isTrue);
    expect(level.needsAttention, isFalse);
    expect(container.read(careerFrameworkReadyCareerPathsProvider), isEmpty);
    expect(() => _submitLevel(container, careerPath), throwsStateError);

    final summary = container.read(
      incomingTalentCareerFrameworkLevelSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.familyCount, 1);
    expect(summary.mappedCareerPathCount, 1);
    expect(summary.unmappedCareerPathCount, 0);
    expect(summary.mappingRatio, 1);
    expect(summary.nextAction, 'Keep role ladders aligned to career paths.');
  });

  test('career framework draft validates required criteria', () {
    final asOfDate = DateTime(2026, 6, 9);
    final draft = IncomingTalentCareerFrameworkLevelDraft.empty(
      asOfDate,
    ).copyWith(
      levelCode: 'L',
      competencyName: 'AI',
      successCriteria: 'short',
      evidenceRequirement: 'tiny',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a department',
      'Please enter a role family',
      'Level code must be at least 2 characters',
      'Please enter a role title',
      'Please enter an owner',
      'Competency is too short',
      'Success criteria must be at least 12 characters',
      'Evidence requirement must be at least 12 characters',
    ]);
  });

  test('career framework levels follow department and attention filters', () {
    final asOfDate = DateTime(2026, 6, 9);
    final container = _container(asOfDate);
    addTearDown(container.dispose);
    final engineeringPath = _careerPath(asOfDate);
    final financePath = _careerPath(
      asOfDate,
      id: 'career-path-finance',
      department: 'Finance',
      currentRole: 'Finance Analyst',
      targetRole: 'Finance Specialist',
      status: IncomingTalentCareerPathStatus.blocked,
      priority: IncomingTalentCareerPathPriority.critical,
    );

    _submitLevel(container, engineeringPath);
    _submitLevel(container, financePath);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentCareerFrameworkLevelsProvider,
    );
    final summary = container.read(
      incomingTalentCareerFrameworkLevelSummaryProvider,
    );

    expect(filtered.map((level) => level.department), ['Finance']);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.attentionCount, 1);
    expect(
      summary.nextAction,
      'Review 1 framework levels needing calibration.',
    );
  });
}

IncomingTalentCareerPath _careerPath(
  DateTime asOfDate, {
  String id = 'career-path-engineering',
  String department = 'Engineering',
  String currentRole = 'Backend Engineer',
  String targetRole = 'Lead Backend Engineer',
  IncomingTalentCareerPathStatus status = IncomingTalentCareerPathStatus.active,
  IncomingTalentCareerPathPriority priority =
      IncomingTalentCareerPathPriority.accelerated,
}) {
  return IncomingTalentCareerPath(
    id: id,
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
    status: status,
    priority: priority,
    developmentAction: 'Lead operating reviews and coach adjacent teams.',
    evidenceRequirement: 'Submit review outcomes and stakeholder feedback.',
    reviewDate: asOfDate.add(const Duration(days: 30)),
    sourcePortfolioPriority:
        IncomingTalentDevelopmentPortfolioPriority.accelerated,
    sourcePortfolioStage: IncomingTalentDevelopmentPortfolioStage.active,
    createdAt: asOfDate,
  );
}

ProviderContainer _container(
  DateTime asOfDate, {
  List<IncomingTalentCareerPath> careerPaths = const [],
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      if (careerPaths.isNotEmpty)
        filteredIncomingTalentCareerPathsProvider.overrideWithValue(
          careerPaths,
        ),
    ],
  );
}

IncomingTalentCareerFrameworkLevel _submitLevel(
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
