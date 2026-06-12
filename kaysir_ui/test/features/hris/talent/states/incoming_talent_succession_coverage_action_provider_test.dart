import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_succession_coverage_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('succession coverage actions submit from risky coverage review', () {
    final asOfDate = DateTime(2026, 6, 5);
    final review = _review(
      decision: IncomingTalentSuccessionCoverageReviewDecision.rework,
      health: IncomingTalentSuccessionCoverageHealth.critical,
      attentionSignalCount: 3,
      openBenchActionCount: 1,
    );
    final container = _container(asOfDate, readyReviews: [review]);
    addTearDown(container.dispose);

    expect(container.read(actionReadySuccessionCoverageReviewsProvider), [
      review,
    ]);

    container
        .read(incomingTalentSuccessionCoverageActionDraftProvider.notifier)
        .initializeFromReview(review);
    final draft = container.read(
      incomingTalentSuccessionCoverageActionDraftProvider,
    );
    final action = container
        .read(incomingTalentSuccessionCoverageActionsProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentSuccessionCoverageActionSummaryProvider,
    );

    expect(action.id, 'talent-succession-coverage-action-001');
    expect(action.coverageReviewId, review.id);
    expect(
      action.actionType,
      IncomingTalentSuccessionCoverageActionType.slateRework,
    );
    expect(action.status, IncomingTalentSuccessionCoverageActionStatus.planned);
    expect(action.dueDate, asOfDate.add(const Duration(days: 7)));
    expect(summary.totalActions, 1);
    expect(summary.plannedCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.nextAction, 'Complete 1 coverage actions due soon.');
    expect(
      container.read(actionReadySuccessionCoverageReviewsProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(incomingTalentSuccessionCoverageActionsProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('succession coverage action draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 5);
    final draft = IncomingTalentSuccessionCoverageActionDraft.empty(
      asOfDate,
    ).copyWith(
      dueDate: asOfDate.subtract(const Duration(days: 1)),
      actionPlan: 'short',
      escalationPath: 'tiny',
      resolutionEvidence: 'mini',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a coverage review',
      'Please enter an action owner',
      'Select coverage review decision',
      'Refresh coverage review snapshot',
      'Select action type',
      'Select action status',
      'Due date cannot be in the past',
      'Action plan must be at least 12 characters',
      'Escalation path must be at least 12 characters',
      'Resolution evidence must be at least 12 characters',
    ]);
  });

  test('succession coverage actions follow filters and statuses', () {
    final asOfDate = DateTime(2026, 6, 5);
    final container = _container(asOfDate);
    addTearDown(container.dispose);

    final engineeringAction = _submitAction(
      container,
      _review(
        id: 'engineering',
        scopeLabel: 'Engineering',
        departmentScope: 'Engineering',
        decision: IncomingTalentSuccessionCoverageReviewDecision.watch,
        health: IncomingTalentSuccessionCoverageHealth.watch,
        attentionSignalCount: 1,
      ),
    );
    container
        .read(incomingTalentSuccessionCoverageActionsProvider.notifier)
        .resolve(engineeringAction.id);

    final financeAction = _submitAction(
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
    container
        .read(incomingTalentSuccessionCoverageActionsProvider.notifier)
        .block(financeAction.id);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    var filtered = container.read(
      filteredIncomingTalentSuccessionCoverageActionsProvider,
    );
    var summary = container.read(
      incomingTalentSuccessionCoverageActionSummaryProvider,
    );

    expect(filtered.map((action) => action.scopeLabel), ['Finance']);
    expect(
      filtered.single.status,
      IncomingTalentSuccessionCoverageActionStatus.blocked,
    );
    expect(summary.blockedCount, 1);
    expect(summary.nextAction, 'Unblock 1 coverage actions.');

    container
        .read(incomingTalentSuccessionCoverageActionsProvider.notifier)
        .resolve(filtered.single.id);
    filtered = container.read(
      filteredIncomingTalentSuccessionCoverageActionsProvider,
    );
    expect(filtered, isEmpty);

    container.read(talentNeedsAttentionProvider.notifier).state = false;
    filtered = container.read(
      filteredIncomingTalentSuccessionCoverageActionsProvider,
    );
    summary = container.read(
      incomingTalentSuccessionCoverageActionSummaryProvider,
    );

    expect(
      filtered.single.status,
      IncomingTalentSuccessionCoverageActionStatus.resolved,
    );
    expect(summary.resolvedCount, 1);
    expect(summary.nextAction, '1 coverage actions resolved.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  List<IncomingTalentSuccessionCoverageReview> readyReviews = const [],
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentSuccessionCoverageReviewsProvider.overrideWithValue(
        readyReviews,
      ),
    ],
  );
}

IncomingTalentSuccessionCoverageAction _submitAction(
  ProviderContainer container,
  IncomingTalentSuccessionCoverageReview review,
) {
  final draft = IncomingTalentSuccessionCoverageActionDraft.fromReview(
    review: review,
    asOfDate: DateTime(2026, 6, 5),
  );
  return container
      .read(incomingTalentSuccessionCoverageActionsProvider.notifier)
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
