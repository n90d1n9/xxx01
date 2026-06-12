import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_review_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_portfolio_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_path_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_path_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('career path review draft defaults from blocked path', () {
    final asOfDate = DateTime(2026, 6, 7);
    final careerPath = _careerPath(
      asOfDate,
      status: IncomingTalentCareerPathStatus.blocked,
      priority: IncomingTalentCareerPathPriority.critical,
      currentLevel: 1,
      targetLevel: 4,
    );

    final draft = IncomingTalentCareerPathReviewDraft.fromCareerPath(
      careerPath: careerPath,
      asOfDate: asOfDate,
    );

    expect(draft.careerPathId, careerPath.id);
    expect(draft.decision, IncomingTalentCareerPathReviewDecision.blocked);
    expect(draft.reviewedLevel, 1);
    expect(draft.nextReviewDate, asOfDate.add(const Duration(days: 14)));
    expect(draft.blockerNote, contains(careerPath.competencyName));
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('career path reviews submit and summarize blocked progress', () {
    final asOfDate = DateTime(2026, 6, 7);
    final careerPath = _careerPath(
      asOfDate,
      status: IncomingTalentCareerPathStatus.blocked,
      priority: IncomingTalentCareerPathPriority.critical,
      currentLevel: 1,
      targetLevel: 4,
    );
    final container = _container(asOfDate, careerPaths: [careerPath]);
    addTearDown(container.dispose);

    final review = _submitReview(container, careerPath);

    expect(review.id, 'talent-career-review-001');
    expect(review.levelGap, 3);
    expect(review.needsAttention, isTrue);
    expect(container.read(careerPathReviewReadyProvider), [careerPath]);

    expect(
      () => container
          .read(incomingTalentCareerPathReviewsProvider.notifier)
          .submitDraft(
            container.read(incomingTalentCareerPathReviewDraftProvider),
          ),
      throwsStateError,
    );

    final summary = container.read(
      incomingTalentCareerPathReviewSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.nextAction, 'Unblock 1 career path reviews.');
  });

  test('career path review draft validates required fields', () {
    final asOfDate = DateTime(2026, 6, 7);
    final draft = IncomingTalentCareerPathReviewDraft.empty(asOfDate).copyWith(
      reviewDate: asOfDate.subtract(const Duration(days: 1)),
      reviewedLevel: 0,
      targetLevel: 4,
      evidenceNote: 'short',
      blockerNote: 'tiny',
      nextAction: 'mini',
      nextReviewDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a career path',
      'Please enter a reviewer',
      'Review date cannot be in the past',
      'Select review decision',
      'Reviewed level must be between 1 and 5',
      'Evidence note must be at least 12 characters',
      'Blocker note must be at least 12 characters',
      'Next action must be at least 12 characters',
      'Next review date cannot be in the past',
    ]);
  });

  test('career path reviews follow talent filters', () {
    final asOfDate = DateTime(2026, 6, 7);
    final engineeringPath = _careerPath(
      asOfDate,
      id: 'career-engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      currentRole: 'Senior Flutter Engineer',
      targetRole: 'Lead Senior Flutter Engineer',
      status: IncomingTalentCareerPathStatus.active,
      priority: IncomingTalentCareerPathPriority.accelerated,
      currentLevel: 4,
      targetLevel: 5,
    );
    final financePath = _careerPath(
      asOfDate,
      id: 'career-finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      currentRole: 'Finance Operations Analyst',
      targetRole: 'Finance Operations Analyst - stabilized',
      status: IncomingTalentCareerPathStatus.blocked,
      priority: IncomingTalentCareerPathPriority.critical,
      currentLevel: 1,
      targetLevel: 4,
    );
    final container = _container(
      asOfDate,
      careerPaths: [engineeringPath, financePath],
    );
    addTearDown(container.dispose);

    _submitReview(container, engineeringPath);
    _submitReview(container, financePath);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentCareerPathReviewsProvider,
    );
    final summary = container.read(
      incomingTalentCareerPathReviewSummaryProvider,
    );

    expect(filtered.map((review) => review.candidateName), ['Mira Lestari']);
    expect(
      filtered.single.decision,
      IncomingTalentCareerPathReviewDecision.blocked,
    );
    expect(summary.totalCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.nextAction, 'Unblock 1 career path reviews.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentCareerPath> careerPaths,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentCareerPathsProvider.overrideWithValue(careerPaths),
    ],
  );
}

IncomingTalentCareerPathReview _submitReview(
  ProviderContainer container,
  IncomingTalentCareerPath careerPath,
) {
  container
      .read(incomingTalentCareerPathReviewDraftProvider.notifier)
      .initializeFromCareerPath(careerPath);
  return container
      .read(incomingTalentCareerPathReviewsProvider.notifier)
      .submitDraft(container.read(incomingTalentCareerPathReviewDraftProvider));
}

IncomingTalentCareerPath _careerPath(
  DateTime asOfDate, {
  String id = 'career-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  String currentRole = 'Senior Flutter Engineer',
  String targetRole = 'Lead Senior Flutter Engineer',
  required IncomingTalentCareerPathStatus status,
  required IncomingTalentCareerPathPriority priority,
  required int currentLevel,
  required int targetLevel,
}) {
  return IncomingTalentCareerPath(
    id: id,
    portfolioId: 'portfolio-$id',
    roadmapId: 'roadmap-$id',
    candidateId: 'candidate-${candidateName.toLowerCase().split(' ').first}',
    candidateName: candidateName,
    department: department,
    currentRole: currentRole,
    targetRole: targetRole,
    ownerName: '$department Manager',
    mentorName: '$department Mentor',
    competencyName: '$currentRole capability review',
    currentLevel: currentLevel,
    targetLevel: targetLevel,
    status: status,
    priority: priority,
    developmentAction: 'Complete manager-supported capability exercises.',
    evidenceRequirement: 'Provide signed evidence for the target competency.',
    reviewDate: asOfDate,
    sourcePortfolioPriority:
        IncomingTalentDevelopmentPortfolioPriority.recovery,
    sourcePortfolioStage: IncomingTalentDevelopmentPortfolioStage.watch,
    createdAt: asOfDate,
  );
}
