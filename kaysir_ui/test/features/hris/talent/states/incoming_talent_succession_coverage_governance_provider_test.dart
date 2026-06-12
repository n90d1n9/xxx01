import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_action_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_governance_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('coverage governance starts risky reviews as action required', () {
    final asOfDate = DateTime(2026, 6, 5);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final review = _submitReview(
      container,
      scopeLabel: 'Finance',
      departmentScope: 'Finance',
      decision:
          IncomingTalentSuccessionCoverageReviewDecision.executiveEscalation,
      health: IncomingTalentSuccessionCoverageHealth.critical,
      coverageScore: 42,
      nextReviewDate: asOfDate.add(const Duration(days: 7)),
    );

    final record =
        container
            .read(incomingTalentSuccessionCoverageGovernanceRecordsProvider)
            .single;
    final summary = container.read(
      incomingTalentSuccessionCoverageGovernanceSummaryProvider,
    );

    expect(record.reviewId, review.id);
    expect(
      record.stage,
      IncomingTalentSuccessionCoverageGovernanceStage.actionRequired,
    );
    expect(
      record.riskLevel,
      IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical,
    );
    expect(record.ownerName, 'Finance Talent Council');
    expect(record.nextAction, 'Create coverage action for Finance.');
    expect(summary.totalRecords, 1);
    expect(summary.openRecords, 1);
    expect(summary.actionRequiredCount, 1);
    expect(summary.criticalCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(
      summary.nextAction,
      'Resolve 1 critical coverage governance records.',
    );
  });

  test('coverage governance follows action and outcome lifecycle', () {
    final asOfDate = DateTime(2026, 6, 5);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final review = _submitReview(
      container,
      decision: IncomingTalentSuccessionCoverageReviewDecision.rework,
      health: IncomingTalentSuccessionCoverageHealth.critical,
      coverageScore: 42,
      nextReviewDate: asOfDate.add(const Duration(days: 14)),
    );
    final action = _submitAction(container, review);

    var record =
        container
            .read(incomingTalentSuccessionCoverageGovernanceRecordsProvider)
            .single;
    expect(
      record.stage,
      IncomingTalentSuccessionCoverageGovernanceStage.actionOpen,
    );
    expect(
      record.riskLevel,
      IncomingTalentSuccessionCoverageGovernanceRiskLevel.high,
    );
    expect(record.actionId, action.id);
    expect(record.dueDate, asOfDate.add(const Duration(days: 7)));

    container
        .read(incomingTalentSuccessionCoverageActionsProvider.notifier)
        .resolve(action.id);

    final resolvedAction = _actionById(container, action.id);
    record =
        container
            .read(incomingTalentSuccessionCoverageGovernanceRecordsProvider)
            .single;
    expect(
      record.stage,
      IncomingTalentSuccessionCoverageGovernanceStage.outcomeReview,
    );
    expect(record.nextAction, 'Review resolved coverage action evidence.');

    _submitOutcome(
      container,
      resolvedAction,
      decision: IncomingTalentSuccessionCoverageActionOutcomeDecision.validated,
      residualRisk: IncomingTalentSuccessionCoverageActionResidualRisk.low,
      coverageScoreAfter: 86,
    );

    record =
        container
            .read(incomingTalentSuccessionCoverageGovernanceRecordsProvider)
            .single;
    final summary = container.read(
      incomingTalentSuccessionCoverageGovernanceSummaryProvider,
    );

    expect(
      record.stage,
      IncomingTalentSuccessionCoverageGovernanceStage.closed,
    );
    expect(
      record.riskLevel,
      IncomingTalentSuccessionCoverageGovernanceRiskLevel.low,
    );
    expect(record.needsAttention, isFalse);
    expect(record.coverageScore, 86);
    expect(summary.closedCount, 1);
    expect(summary.openRecords, 0);
    expect(summary.nextAction, '1 coverage governance records closed.');
  });

  test('coverage governance follows department and attention filters', () {
    final asOfDate = DateTime(2026, 6, 5);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final engineeringReview = _submitReview(
      container,
      scopeLabel: 'Engineering',
      departmentScope: 'Engineering',
      decision: IncomingTalentSuccessionCoverageReviewDecision.watch,
      health: IncomingTalentSuccessionCoverageHealth.watch,
      coverageScore: 68,
      nextReviewDate: asOfDate.add(const Duration(days: 30)),
    );
    final engineeringAction = _submitAction(container, engineeringReview);
    container
        .read(incomingTalentSuccessionCoverageActionsProvider.notifier)
        .resolve(engineeringAction.id);
    _submitOutcome(
      container,
      _actionById(container, engineeringAction.id),
      decision: IncomingTalentSuccessionCoverageActionOutcomeDecision.validated,
      residualRisk: IncomingTalentSuccessionCoverageActionResidualRisk.low,
      coverageScoreAfter: 90,
    );

    _submitReview(
      container,
      scopeLabel: 'Finance',
      departmentScope: 'Finance',
      decision:
          IncomingTalentSuccessionCoverageReviewDecision.executiveEscalation,
      health: IncomingTalentSuccessionCoverageHealth.critical,
      coverageScore: 38,
      nextReviewDate: asOfDate.add(const Duration(days: 7)),
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final records = container.read(
      filteredIncomingTalentSuccessionCoverageGovernanceRecordsProvider,
    );
    final summary = container.read(
      incomingTalentSuccessionCoverageGovernanceSummaryProvider,
    );

    expect(records.map((record) => record.scopeLabel), ['Finance']);
    expect(
      records.single.stage,
      IncomingTalentSuccessionCoverageGovernanceStage.actionRequired,
    );
    expect(summary.totalRecords, 1);
    expect(summary.criticalCount, 1);
    expect(summary.closedCount, 0);
  });
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentSuccessionCoverageReview _submitReview(
  ProviderContainer container, {
  String scopeLabel = 'All departments',
  String departmentScope = 'All departments',
  required IncomingTalentSuccessionCoverageReviewDecision decision,
  required IncomingTalentSuccessionCoverageHealth health,
  required int coverageScore,
  required DateTime nextReviewDate,
}) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft = IncomingTalentSuccessionCoverageReviewDraft(
    scopeLabel: scopeLabel,
    departmentScope: departmentScope,
    attentionOnly: false,
    reviewerName: '$scopeLabel Talent Council',
    reviewDate: asOfDate,
    decision: decision,
    coverageHealth: health,
    coverageScore: coverageScore,
    totalCandidates: 4,
    readyCoverageCount: 1,
    attentionSignalCount:
        health == IncomingTalentSuccessionCoverageHealth.critical ? 3 : 1,
    openBenchActionCount:
        health == IncomingTalentSuccessionCoverageHealth.critical ? 1 : 0,
    reviewSummary: 'Coverage governance review captures successor risk.',
    executiveCommitment:
        'Assign accountable owners to close succession coverage risk.',
    nextReviewDate: nextReviewDate,
    asOfDate: asOfDate,
  );
  return container
      .read(incomingTalentSuccessionCoverageReviewsProvider.notifier)
      .submitDraft(draft);
}

IncomingTalentSuccessionCoverageAction _submitAction(
  ProviderContainer container,
  IncomingTalentSuccessionCoverageReview review,
) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft = IncomingTalentSuccessionCoverageActionDraft.fromReview(
    review: review,
    asOfDate: asOfDate,
  );
  return container
      .read(incomingTalentSuccessionCoverageActionsProvider.notifier)
      .submitDraft(draft);
}

IncomingTalentSuccessionCoverageAction _actionById(
  ProviderContainer container,
  String actionId,
) {
  return container
      .read(incomingTalentSuccessionCoverageActionsProvider)
      .firstWhere((action) => action.id == actionId);
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
    nextReviewDate: asOfDate.add(const Duration(days: 60)),
  );

  return container
      .read(incomingTalentSuccessionCoverageActionOutcomesProvider.notifier)
      .submitDraft(draft);
}
