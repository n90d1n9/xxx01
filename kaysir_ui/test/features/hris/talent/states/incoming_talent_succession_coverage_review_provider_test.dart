import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_dashboard_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('succession coverage reviews submit from dashboard snapshot', () {
    final asOfDate = DateTime(2026, 6, 5);
    final container = _container(
      asOfDate,
      _dashboard(
        health: IncomingTalentSuccessionCoverageHealth.strong,
        coverageScore: 84,
        totalCandidates: 3,
        readyCoverageCount: 3,
      ),
    );
    addTearDown(container.dispose);

    final draft = container.read(
      incomingTalentSuccessionCoverageReviewDraftProvider,
    );
    final review = container
        .read(incomingTalentSuccessionCoverageReviewsProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentSuccessionCoverageReviewSummaryProvider,
    );

    expect(draft.scopeLabel, 'All departments');
    expect(
      draft.decision,
      IncomingTalentSuccessionCoverageReviewDecision.endorsed,
    );
    expect(draft.nextReviewDate, asOfDate.add(const Duration(days: 90)));
    expect(review.id, 'talent-succession-coverage-review-001');
    expect(review.coverageScore, 84);
    expect(review.readyCoverageCount, 3);
    expect(review.needsAttention, isFalse);
    expect(summary.totalReviews, 1);
    expect(summary.endorsedCount, 1);
    expect(summary.nextAction, '1 coverage reviews endorsed.');

    expect(
      () => container
          .read(incomingTalentSuccessionCoverageReviewsProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('succession coverage review draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 5);
    final draft = IncomingTalentSuccessionCoverageReviewDraft.empty(
      asOfDate,
    ).copyWith(
      reviewDate: asOfDate,
      coverageScore: 101,
      reviewSummary: 'short',
      executiveCommitment: 'tiny',
      nextReviewDate: asOfDate,
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a review scope',
      'Please enter a reviewer',
      'Select coverage decision',
      'Refresh coverage snapshot',
      'Coverage score must be between 0 and 100',
      'Review summary must be at least 12 characters',
      'Executive commitment must be at least 12 characters',
      'Next review must be after review date',
    ]);
  });

  test('succession coverage reviews follow scope and attention filters', () {
    final asOfDate = DateTime(2026, 6, 5);
    final container = _container(
      asOfDate,
      _dashboard(
        health: IncomingTalentSuccessionCoverageHealth.critical,
        coverageScore: 42,
        totalCandidates: 2,
        readyCoverageCount: 0,
        attentionSignalCount: 4,
        openBenchActionCount: 1,
      ),
    );
    addTearDown(container.dispose);

    container
        .read(incomingTalentSuccessionCoverageReviewsProvider.notifier)
        .submitDraft(
          container.read(incomingTalentSuccessionCoverageReviewDraftProvider),
        );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.invalidate(incomingTalentSuccessionCoverageReviewDraftProvider);
    final financeDraft = container
        .read(incomingTalentSuccessionCoverageReviewDraftProvider)
        .copyWith(
          reviewDate: asOfDate.add(const Duration(days: 1)),
          nextReviewDate: asOfDate.add(const Duration(days: 15)),
        );
    container
        .read(incomingTalentSuccessionCoverageReviewsProvider.notifier)
        .submitDraft(financeDraft);

    container.read(talentNeedsAttentionProvider.notifier).state = true;
    final filtered = container.read(
      filteredIncomingTalentSuccessionCoverageReviewsProvider,
    );
    final summary = container.read(
      incomingTalentSuccessionCoverageReviewSummaryProvider,
    );

    expect(filtered.map((review) => review.scopeLabel), ['Finance']);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.reworkCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Rework 1 succession coverage reviews.');
  });
}

ProviderContainer _container(
  DateTime asOfDate,
  IncomingTalentSuccessionCoverageDashboard dashboard,
) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      incomingTalentSuccessionCoverageDashboardProvider.overrideWithValue(
        dashboard,
      ),
    ],
  );
}

IncomingTalentSuccessionCoverageDashboard _dashboard({
  required IncomingTalentSuccessionCoverageHealth health,
  required int coverageScore,
  required int totalCandidates,
  required int readyCoverageCount,
  int attentionSignalCount = 0,
  int openBenchActionCount = 0,
}) {
  final readyNowCount = readyCoverageCount.clamp(0, totalCandidates);
  final blockedCount = totalCandidates - readyNowCount;

  return IncomingTalentSuccessionCoverageDashboard(
    counts: IncomingTalentSuccessionCoverageCounts(
      totalCandidates: totalCandidates,
      readyNowCount: readyNowCount,
      readySoonCount: 0,
      blockedCandidateCount: blockedCount,
      highRiskCandidateCount: 0,
      activationPlanCount: 0,
      activationAtRiskCount: 0,
      transitionPulseCount: 0,
      transitionPulseAtRiskCount: 0,
      openTransitionInterventionCount: 0,
      transitionOutcomeRiskCount: 0,
      benchPlanCount: 0,
      criticalBenchPlanCount: 0,
      benchCheckInAttentionCount: attentionSignalCount,
      openBenchActionCount: openBenchActionCount,
    ),
    coverageScore: coverageScore,
    health: health,
    nextAction: 'Coverage dashboard fixture.',
  );
}
