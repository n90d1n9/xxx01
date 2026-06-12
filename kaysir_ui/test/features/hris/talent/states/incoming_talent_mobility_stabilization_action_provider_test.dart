import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_first_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_stabilization_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('mobility stabilization action submits from risky first review', () {
    final asOfDate = DateTime(2026, 6, 6);
    final review = _review(
      asOfDate,
      department: 'Engineering',
      outcome: IncomingTalentMobilityFirstReviewOutcome.watch,
      retentionRisk: IncomingTalentMobilityFirstReviewRetentionRisk.high,
      confidence: 2,
    );
    final container = _container(asOfDate, reviews: [review]);
    addTearDown(container.dispose);

    expect(container.read(stabilizationReadyMobilityFirstReviewsProvider), [
      review,
    ]);

    container
        .read(incomingTalentMobilityStabilizationActionDraftProvider.notifier)
        .initializeFromReview(review);
    final draft = container.read(
      incomingTalentMobilityStabilizationActionDraftProvider,
    );
    final action = container
        .read(incomingTalentMobilityStabilizationActionsProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentMobilityStabilizationActionSummaryProvider,
    );

    expect(action.id, 'talent-mobility-stabilization-001');
    expect(action.reviewId, review.id);
    expect(
      action.actionType,
      IncomingTalentMobilityStabilizationActionType.retentionSave,
    );
    expect(action.status, IncomingTalentMobilityStabilizationStatus.planned);
    expect(action.needsAttention, isTrue);
    expect(summary.totalCount, 1);
    expect(summary.plannedCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Follow up 1 mobility risks.');
    expect(
      container.read(stabilizationReadyMobilityFirstReviewsProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(incomingTalentMobilityStabilizationActionsProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('mobility stabilization action draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 6);
    final draft = IncomingTalentMobilityStabilizationActionDraft.empty(
      asOfDate,
    ).copyWith(
      status: IncomingTalentMobilityStabilizationStatus.blocked,
      dueDate: asOfDate.subtract(const Duration(days: 1)),
      actionSummary: 'tiny',
      successMeasure: 'short',
      blockerNote: 'mini',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a mobility first review',
      'Please enter an action owner',
      'Select action type',
      'Due date cannot be in the past',
      'Action summary must be at least 12 characters',
      'Success measure must be at least 12 characters',
      'Blocker note must be at least 12 characters',
    ]);
  });

  test('mobility stabilization actions follow lifecycle and filters', () {
    final asOfDate = DateTime(2026, 6, 6);
    final engineering = _review(
      asOfDate,
      id: 'engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      outcome: IncomingTalentMobilityFirstReviewOutcome.watch,
      retentionRisk: IncomingTalentMobilityFirstReviewRetentionRisk.moderate,
      confidence: 3,
    );
    final finance = _review(
      asOfDate,
      id: 'finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      outcome: IncomingTalentMobilityFirstReviewOutcome.blocked,
      retentionRisk: IncomingTalentMobilityFirstReviewRetentionRisk.high,
      confidence: 2,
    );
    final container = _container(asOfDate, reviews: [engineering, finance]);
    addTearDown(container.dispose);

    final engineeringAction = _submitAction(container, engineering);
    final notifier = container.read(
      incomingTalentMobilityStabilizationActionsProvider.notifier,
    );
    notifier.start(engineeringAction.id);
    notifier.complete(engineeringAction.id);

    final financeAction = _submitAction(container, finance);
    notifier.block(financeAction.id);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentMobilityStabilizationActionsProvider,
    );
    final summary = container.read(
      incomingTalentMobilityStabilizationActionSummaryProvider,
    );

    expect(filtered.map((action) => action.candidateName), ['Mira Lestari']);
    expect(
      filtered.single.status,
      IncomingTalentMobilityStabilizationStatus.blocked,
    );
    expect(summary.totalCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Unblock 1 mobility actions.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentMobilityFirstReview> reviews,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentMobilityFirstReviewsProvider.overrideWithValue(
        reviews,
      ),
    ],
  );
}

IncomingTalentMobilityStabilizationAction _submitAction(
  ProviderContainer container,
  IncomingTalentMobilityFirstReview review,
) {
  container
      .read(incomingTalentMobilityStabilizationActionDraftProvider.notifier)
      .initializeFromReview(review);
  return container
      .read(incomingTalentMobilityStabilizationActionsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentMobilityStabilizationActionDraftProvider),
      );
}

IncomingTalentMobilityFirstReview _review(
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  required String department,
  required IncomingTalentMobilityFirstReviewOutcome outcome,
  required IncomingTalentMobilityFirstReviewRetentionRisk retentionRisk,
  required int confidence,
}) {
  return IncomingTalentMobilityFirstReview(
    id: 'review-$id',
    checklistId: 'launch-$id',
    matchId: 'match-$id',
    decisionId: 'decision-$id',
    candidateId: 'candidate-$id',
    candidateName: candidateName,
    currentRole: '$department Specialist',
    department: department,
    targetRole: '$department Lead',
    opportunityTitle: '$department mobility launch',
    hostDepartment: department,
    reviewerName: '$department Mobility Owner',
    reviewDate: asOfDate,
    outcome: outcome,
    hostConfidenceScore: confidence,
    deliverySignal: '$department delivery signal needs targeted support.',
    blockerNote: '$department blocker requires sponsor and host alignment.',
    retentionRisk: retentionRisk,
    nextAction: '$department stabilization action needs owner follow-up.',
    followUpDate: asOfDate.add(const Duration(days: 10)),
    launchStatus: IncomingTalentMobilityLaunchStatus.launched,
    createdAt: asOfDate,
  );
}
