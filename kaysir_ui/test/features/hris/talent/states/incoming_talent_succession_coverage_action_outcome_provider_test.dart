import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_action_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('succession coverage outcomes submit from resolved action', () {
    final asOfDate = DateTime(2026, 6, 5);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    _submitResolvedAction(
      container,
      _review(
        decision: IncomingTalentSuccessionCoverageReviewDecision.rework,
        health: IncomingTalentSuccessionCoverageHealth.critical,
        attentionSignalCount: 3,
        openBenchActionCount: 1,
      ),
    );
    final readyAction =
        container.read(outcomeReadySuccessionCoverageActionsProvider).single;

    container
        .read(
          incomingTalentSuccessionCoverageActionOutcomeDraftProvider.notifier,
        )
        .initializeFromAction(readyAction);
    final draft = container.read(
      incomingTalentSuccessionCoverageActionOutcomeDraftProvider,
    );
    final outcome = container
        .read(incomingTalentSuccessionCoverageActionOutcomesProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentSuccessionCoverageActionOutcomeSummaryProvider,
    );

    expect(outcome.id, 'talent-succession-coverage-outcome-001');
    expect(outcome.actionId, readyAction.id);
    expect(
      outcome.decision,
      IncomingTalentSuccessionCoverageActionOutcomeDecision.monitor,
    );
    expect(
      outcome.residualRisk,
      IncomingTalentSuccessionCoverageActionResidualRisk.high,
    );
    expect(outcome.coverageScoreAfter, 60);
    expect(outcome.coverageImprovement, 18);
    expect(summary.totalOutcomes, 1);
    expect(summary.monitorCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.averageCoverageAfter, 60);
    expect(summary.averageCoverageImprovement, 18);
    expect(summary.nextAction, 'Keep 1 coverage outcomes on watch.');
    expect(
      container.read(outcomeReadySuccessionCoverageActionsProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(incomingTalentSuccessionCoverageActionOutcomesProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('succession coverage outcome draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 5);
    final draft = IncomingTalentSuccessionCoverageActionOutcomeDraft.empty(
      asOfDate,
    ).copyWith(
      actionStatus: IncomingTalentSuccessionCoverageActionStatus.planned,
      reviewDate: asOfDate,
      coverageScoreAfter: 120,
      evidenceSummary: 'tiny',
      learningSummary: 'mini',
      nextCoverageAction: 'small',
      nextReviewDate: asOfDate,
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please select a resolved coverage action',
      'Please enter an outcome reviewer',
      'Coverage action must be resolved before outcome review',
      'Select outcome decision',
      'Select residual risk',
      'Coverage score must be between 0 and 100',
      'Evidence summary must be at least 12 characters',
      'Learning summary must be at least 12 characters',
      'Next coverage action must be at least 12 characters',
      'Next review must be after review date',
    ]);
  });

  test('succession coverage outcomes follow filters and attention summary', () {
    final asOfDate = DateTime(2026, 6, 5);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final engineeringAction = _submitResolvedAction(
      container,
      _review(
        id: 'engineering',
        scopeLabel: 'Engineering',
        departmentScope: 'Engineering',
        decision: IncomingTalentSuccessionCoverageReviewDecision.watch,
        health: IncomingTalentSuccessionCoverageHealth.strong,
      ),
    );
    _submitOutcome(
      container,
      engineeringAction,
      decision: IncomingTalentSuccessionCoverageActionOutcomeDecision.validated,
      residualRisk: IncomingTalentSuccessionCoverageActionResidualRisk.low,
      coverageScoreAfter: 90,
    );

    final financeAction = _submitResolvedAction(
      container,
      _review(
        id: 'finance',
        scopeLabel: 'Finance',
        departmentScope: 'Finance',
        decision:
            IncomingTalentSuccessionCoverageReviewDecision.executiveEscalation,
        health: IncomingTalentSuccessionCoverageHealth.critical,
        attentionSignalCount: 4,
        openBenchActionCount: 1,
      ),
    );
    _submitOutcome(
      container,
      financeAction,
      decision:
          IncomingTalentSuccessionCoverageActionOutcomeDecision.executiveReview,
      residualRisk: IncomingTalentSuccessionCoverageActionResidualRisk.high,
      coverageScoreAfter: 55,
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentSuccessionCoverageActionOutcomesProvider,
    );
    final summary = container.read(
      incomingTalentSuccessionCoverageActionOutcomeSummaryProvider,
    );

    expect(filtered.map((outcome) => outcome.scopeLabel), ['Finance']);
    expect(
      filtered.single.decision,
      IncomingTalentSuccessionCoverageActionOutcomeDecision.executiveReview,
    );
    expect(summary.executiveReviewCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Route 1 coverage outcomes to executives.');
  });
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentSuccessionCoverageAction _submitResolvedAction(
  ProviderContainer container,
  IncomingTalentSuccessionCoverageReview review,
) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft = IncomingTalentSuccessionCoverageActionDraft.fromReview(
    review: review,
    asOfDate: asOfDate,
  );
  final action = container
      .read(incomingTalentSuccessionCoverageActionsProvider.notifier)
      .submitDraft(draft);
  container
      .read(incomingTalentSuccessionCoverageActionsProvider.notifier)
      .resolve(action.id);

  return container
      .read(incomingTalentSuccessionCoverageActionsProvider)
      .firstWhere((item) => item.id == action.id);
}

IncomingTalentSuccessionCoverageActionOutcome _submitOutcome(
  ProviderContainer container,
  IncomingTalentSuccessionCoverageAction action, {
  required IncomingTalentSuccessionCoverageActionOutcomeDecision decision,
  required IncomingTalentSuccessionCoverageActionResidualRisk residualRisk,
  required int coverageScoreAfter,
}) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft = IncomingTalentSuccessionCoverageActionOutcomeDraft.fromAction(
    action: action,
    asOfDate: asOfDate,
  ).copyWith(
    decision: decision,
    residualRisk: residualRisk,
    coverageScoreAfter: coverageScoreAfter,
    nextReviewDate: asOfDate.add(const Duration(days: 30)),
  );
  return container
      .read(incomingTalentSuccessionCoverageActionOutcomesProvider.notifier)
      .submitDraft(draft);
}

IncomingTalentSuccessionCoverageReview _review({
  String id = 'coverage-review-001',
  String scopeLabel = 'All departments',
  String departmentScope = 'All departments',
  required IncomingTalentSuccessionCoverageReviewDecision decision,
  required IncomingTalentSuccessionCoverageHealth health,
  int attentionSignalCount = 0,
  int openBenchActionCount = 0,
}) {
  return IncomingTalentSuccessionCoverageReview(
    id: 'review-$id',
    scopeLabel: scopeLabel,
    departmentScope: departmentScope,
    attentionOnly: false,
    reviewerName: '$scopeLabel Talent Council',
    reviewDate: DateTime(2026, 6, 5),
    decision: decision,
    coverageHealth: health,
    coverageScore:
        health == IncomingTalentSuccessionCoverageHealth.critical ? 42 : 72,
    totalCandidates: 3,
    readyCoverageCount: 1,
    attentionSignalCount: attentionSignalCount,
    openBenchActionCount: openBenchActionCount,
    reviewSummary: 'Coverage review summary captures readiness gaps.',
    executiveCommitment:
        'Assign accountable owners to close succession coverage risks.',
    nextReviewDate: DateTime(2026, 6, 19),
    createdAt: DateTime(2026, 6, 5),
  );
}
