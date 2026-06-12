import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_decision_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_implementation_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_readiness_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_stabilization_review_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_stabilization_follow_up_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_stabilization_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('promotion stabilization follow-up draft defaults from review', () {
    final asOfDate = DateTime(2026, 7, 9);
    final review = _review(asOfDate);

    final draft =
        IncomingTalentPromotionStabilizationFollowUpActionDraft.fromReview(
          review: review,
          asOfDate: asOfDate,
        );

    expect(draft.reviewId, review.id);
    expect(draft.candidateName, review.candidateName);
    expect(
      draft.actionType,
      IncomingTalentPromotionStabilizationFollowUpActionType.managerCoaching,
    );
    expect(
      draft.priority,
      IncomingTalentPromotionStabilizationFollowUpPriority.critical,
    );
    expect(
      draft.status,
      IncomingTalentPromotionStabilizationFollowUpStatus.open,
    );
    expect(draft.dueDate, asOfDate.add(const Duration(days: 7)));
    expect(draft.isReadyToSubmit, isTrue);
  });

  test(
    'promotion stabilization follow-ups submit, de-duplicate, and summarize',
    () {
      final asOfDate = DateTime(2026, 7, 9);
      final review = _review(asOfDate);
      final container = _container(asOfDate, reviews: [review]);
      addTearDown(container.dispose);

      expect(
        container.read(promotionStabilizationFollowUpReadyReviewsProvider),
        [review],
      );

      final action = _submitAction(container, review);

      expect(action.id, 'talent-promotion-stabilization-follow-up-001');
      expect(
        action.priority,
        IncomingTalentPromotionStabilizationFollowUpPriority.critical,
      );
      expect(action.needsAttention, isTrue);
      expect(action.progressRatio, 0.2);
      expect(
        container.read(promotionStabilizationFollowUpReadyReviewsProvider),
        isEmpty,
      );
      expect(() => _submitAction(container, review), throwsStateError);

      final summary = container.read(
        incomingTalentPromotionStabilizationFollowUpActionSummaryProvider,
      );
      expect(summary.totalCount, 1);
      expect(summary.openCount, 1);
      expect(summary.criticalCount, 1);
      expect(summary.dueSoonCount, 1);
      expect(summary.averageProgress, 0.2);
      expect(summary.nextAction, 'Complete 1 promotion follow-ups due soon.');
    },
  );

  test('promotion stabilization follow-up draft validates fields', () {
    final asOfDate = DateTime(2026, 7, 9);
    final draft = IncomingTalentPromotionStabilizationFollowUpActionDraft.empty(
      asOfDate,
    ).copyWith(
      status: IncomingTalentPromotionStabilizationFollowUpStatus.resolved,
      dueDate: asOfDate.subtract(const Duration(days: 1)),
      actionPlan: 'short',
      successCriteria: 'tiny',
      escalationNote: 'small',
      resolutionNote: 'brief',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a stabilization review',
      'Please enter an owner',
      'Select follow-up action type',
      'Select follow-up priority',
      'Due date cannot be in the past',
      'Action plan must be at least 12 characters',
      'Success criteria must be at least 12 characters',
      'Escalation note must be at least 12 characters',
      'Resolution note must be at least 12 characters',
    ]);
  });

  test(
    'promotion stabilization follow-ups follow department filters and status updates',
    () {
      final asOfDate = DateTime(2026, 7, 9);
      final container = _container(asOfDate);
      addTearDown(container.dispose);
      final engineeringReview = _review(asOfDate);
      final financeReview = _review(
        asOfDate,
        id: 'finance',
        department: 'Finance',
        currentRole: 'Finance Analyst',
        newRole: 'Finance Specialist',
        outcome: IncomingTalentPromotionStabilizationOutcome.roleReset,
        status: IncomingTalentPromotionStabilizationStatus.escalated,
        confidenceScore: 1,
      );

      _submitAction(container, engineeringReview);
      final financeAction = _submitAction(container, financeReview);

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      final filtered = container.read(
        filteredIncomingTalentPromotionStabilizationFollowUpActionsProvider,
      );

      expect(filtered.map((action) => action.department), ['Finance']);
      expect(filtered.single.needsAttention, isTrue);

      container
          .read(
            incomingTalentPromotionStabilizationFollowUpActionsProvider
                .notifier,
          )
          .updateStatus(
            id: financeAction.id,
            status: IncomingTalentPromotionStabilizationFollowUpStatus.resolved,
            resolutionNote:
                'Role reset action resolved with people panel confirmation.',
          );

      expect(
        container.read(
          filteredIncomingTalentPromotionStabilizationFollowUpActionsProvider,
        ),
        isEmpty,
      );
      container.read(talentNeedsAttentionProvider.notifier).state = false;

      final resolvedFiltered = container.read(
        filteredIncomingTalentPromotionStabilizationFollowUpActionsProvider,
      );
      final summary = container.read(
        incomingTalentPromotionStabilizationFollowUpActionSummaryProvider,
      );

      expect(
        resolvedFiltered.single.status,
        IncomingTalentPromotionStabilizationFollowUpStatus.resolved,
      );
      expect(resolvedFiltered.single.resolutionNote, contains('people panel'));
      expect(summary.resolvedCount, 1);
      expect(
        summary.nextAction,
        'Archive resolved promotion stabilization follow-ups.',
      );
    },
  );
}

IncomingTalentPromotionStabilizationReview _review(
  DateTime asOfDate, {
  String id = 'engineering',
  String department = 'Engineering',
  String currentRole = 'Backend Engineer',
  String newRole = 'Lead Backend Engineer',
  IncomingTalentPromotionStabilizationOutcome outcome =
      IncomingTalentPromotionStabilizationOutcome.needsManagerSupport,
  IncomingTalentPromotionStabilizationStatus status =
      IncomingTalentPromotionStabilizationStatus.followUpRequired,
  int confidenceScore = 2,
}) {
  return IncomingTalentPromotionStabilizationReview(
    id: 'promotion-stabilization-review-$id',
    implementationId: 'promotion-implementation-$id',
    decisionId: 'promotion-decision-$id',
    readinessId: 'promotion-readiness-$id',
    candidateId: 'candidate-$id',
    candidateName: '$department Talent',
    department: department,
    currentRole: currentRole,
    newRole: newRole,
    frameworkLevelCode: 'L5',
    ownerName: '$department HRBP',
    reviewerName: '$department people panel',
    outcome: outcome,
    status: status,
    reviewDate: asOfDate.subtract(const Duration(days: 1)),
    followUpDate: asOfDate.add(const Duration(days: 14)),
    confidenceScore: confidenceScore,
    managerFeedback:
        'Manager needs clearer operating expectations after promotion.',
    employeeFeedback:
        'Employee needs clearer promotion goals and support cadence.',
    evidenceSummary:
        'Promotion letter, HRIS update, and manager feedback reviewed.',
    supportPlan:
        'Schedule manager support checkpoint and clarify success measures.',
    sourceAction: IncomingTalentPromotionImplementationAction.titleUpdate,
    sourceImplementationStatus:
        IncomingTalentPromotionImplementationStatus.completed,
    sourceOutcome: IncomingTalentPromotionDecisionOutcome.promoteNow,
    sourceReadinessRating: IncomingTalentPromotionReadinessRating.readyNow,
    createdAt: asOfDate.subtract(const Duration(days: 2)),
  );
}

ProviderContainer _container(
  DateTime asOfDate, {
  List<IncomingTalentPromotionStabilizationReview> reviews = const [],
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      if (reviews.isNotEmpty)
        filteredIncomingTalentPromotionStabilizationReviewsProvider
            .overrideWithValue(reviews),
    ],
  );
}

IncomingTalentPromotionStabilizationFollowUpAction _submitAction(
  ProviderContainer container,
  IncomingTalentPromotionStabilizationReview review,
) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft =
      IncomingTalentPromotionStabilizationFollowUpActionDraft.fromReview(
        review: review,
        asOfDate: asOfDate,
      );

  return container
      .read(
        incomingTalentPromotionStabilizationFollowUpActionsProvider.notifier,
      )
      .submitDraft(draft);
}
