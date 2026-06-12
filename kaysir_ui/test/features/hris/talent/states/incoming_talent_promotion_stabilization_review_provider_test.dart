import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_decision_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_implementation_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_readiness_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_stabilization_review_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_implementation_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_stabilization_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('promotion stabilization review draft defaults from implementation', () {
    final asOfDate = DateTime(2026, 7, 9);
    final implementation = _implementation(asOfDate);

    final draft =
        IncomingTalentPromotionStabilizationReviewDraft.fromImplementation(
          implementation: implementation,
          asOfDate: asOfDate,
        );

    expect(draft.implementationId, implementation.id);
    expect(draft.candidateName, implementation.candidateName);
    expect(
      draft.outcome,
      IncomingTalentPromotionStabilizationOutcome.stableInRole,
    );
    expect(draft.status, IncomingTalentPromotionStabilizationStatus.reviewed);
    expect(draft.confidenceScore, 4);
    expect(draft.reviewDate, implementation.completedDate);
    expect(draft.isReadyToSubmit, isTrue);
  });

  test(
    'promotion stabilization reviews submit, de-duplicate, and summarize',
    () {
      final asOfDate = DateTime(2026, 7, 9);
      final implementation = _implementation(asOfDate);
      final container = _container(asOfDate, implementations: [implementation]);
      addTearDown(container.dispose);

      expect(
        container.read(
          promotionStabilizationReviewReadyImplementationsProvider,
        ),
        [implementation],
      );

      final review = _submitReview(container, implementation);

      expect(review.id, 'talent-promotion-stabilization-review-001');
      expect(
        review.outcome,
        IncomingTalentPromotionStabilizationOutcome.stableInRole,
      );
      expect(review.needsAttention, isFalse);
      expect(review.confidenceRatio, 0.8);
      expect(
        container.read(
          promotionStabilizationReviewReadyImplementationsProvider,
        ),
        isEmpty,
      );
      expect(() => _submitReview(container, implementation), throwsStateError);

      final summary = container.read(
        incomingTalentPromotionStabilizationReviewSummaryProvider,
      );
      expect(summary.totalCount, 1);
      expect(summary.stableCount, 1);
      expect(summary.attentionCount, 0);
      expect(summary.averageConfidence, 4);
      expect(summary.averageProgress, 0.65);
      expect(
        summary.nextAction,
        'Close evidence for 1 stable promotion reviews.',
      );
    },
  );

  test('promotion stabilization review draft validates required fields', () {
    final asOfDate = DateTime(2026, 7, 9);
    final draft = IncomingTalentPromotionStabilizationReviewDraft(
      implementationId: '',
      decisionId: '',
      readinessId: '',
      candidateId: '',
      candidateName: '',
      department: '',
      currentRole: '',
      newRole: '',
      frameworkLevelCode: '',
      ownerName: '',
      reviewerName: '',
      outcome: null,
      status: IncomingTalentPromotionStabilizationStatus.followUpRequired,
      reviewDate: asOfDate,
      followUpDate: asOfDate.subtract(const Duration(days: 1)),
      confidenceScore: 0,
      managerFeedback: 'short',
      employeeFeedback: 'tiny',
      evidenceSummary: 'small',
      supportPlan: 'brief',
      sourceAction: null,
      sourceImplementationStatus: null,
      sourceOutcome: null,
      sourceReadinessRating: null,
      asOfDate: asOfDate,
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a promotion implementation',
      'Please enter an owner',
      'Please enter a reviewer',
      'Select stabilization outcome',
      'Select confidence score',
      'Manager feedback must be at least 12 characters',
      'Employee feedback must be at least 12 characters',
      'Evidence summary must be at least 12 characters',
      'Support plan must be at least 12 characters',
      'Follow-up date cannot be before review date',
    ]);
  });

  test(
    'promotion stabilization reviews follow department and attention filters',
    () {
      final asOfDate = DateTime(2026, 7, 9);
      final container = _container(asOfDate);
      addTearDown(container.dispose);
      final engineeringImplementation = _implementation(asOfDate);
      final financeImplementation = _implementation(
        asOfDate,
        id: 'finance',
        department: 'Finance',
        currentRole: 'Finance Analyst',
        newRole: 'Finance Specialist',
        action: IncomingTalentPromotionImplementationAction.compensationRoute,
        sourceOutcome:
            IncomingTalentPromotionDecisionOutcome.compensationReview,
      );

      _submitReview(container, engineeringImplementation);
      _submitReview(container, financeImplementation);

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      final filtered = container.read(
        filteredIncomingTalentPromotionStabilizationReviewsProvider,
      );
      final summary = container.read(
        incomingTalentPromotionStabilizationReviewSummaryProvider,
      );

      expect(filtered.map((review) => review.department), ['Finance']);
      expect(filtered.single.needsAttention, isTrue);
      expect(
        filtered.single.outcome,
        IncomingTalentPromotionStabilizationOutcome.compensationFollowUp,
      );
      expect(summary.attentionCount, 1);
      expect(summary.followUpRequiredCount, 1);
      expect(summary.nextAction, 'Track 1 promotion stabilization follow-ups.');
    },
  );
}

IncomingTalentPromotionImplementation _implementation(
  DateTime asOfDate, {
  String id = 'engineering',
  String department = 'Engineering',
  String currentRole = 'Backend Engineer',
  String newRole = 'Lead Backend Engineer',
  IncomingTalentPromotionImplementationAction action =
      IncomingTalentPromotionImplementationAction.titleUpdate,
  IncomingTalentPromotionDecisionOutcome sourceOutcome =
      IncomingTalentPromotionDecisionOutcome.promoteNow,
}) {
  return IncomingTalentPromotionImplementation(
    id: 'promotion-implementation-$id',
    decisionId: 'promotion-decision-$id',
    readinessId: 'promotion-readiness-$id',
    candidateId: 'candidate-$id',
    candidateName: '$department Talent',
    department: department,
    currentRole: currentRole,
    newRole: newRole,
    frameworkLevelCode: 'L5',
    ownerName: '$department HRBP',
    approverName: '$department people panel',
    action: action,
    status: IncomingTalentPromotionImplementationStatus.completed,
    systemOfRecord: 'HRIS employee profile',
    implementationStep: 'Prepare promotion letter and HRIS title update.',
    evidenceNote: 'Signed letter and HRIS update confirmation captured.',
    blockerNote: 'No open blockers after manager transition.',
    dueDate: asOfDate.subtract(const Duration(days: 2)),
    completedDate: asOfDate.subtract(const Duration(days: 1)),
    sourceOutcome: sourceOutcome,
    sourceDecisionStatus: IncomingTalentPromotionDecisionStatus.approved,
    sourceReadinessRating: IncomingTalentPromotionReadinessRating.readyNow,
    createdAt: asOfDate.subtract(const Duration(days: 14)),
  );
}

ProviderContainer _container(
  DateTime asOfDate, {
  List<IncomingTalentPromotionImplementation> implementations = const [],
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      if (implementations.isNotEmpty)
        filteredIncomingTalentPromotionImplementationsProvider
            .overrideWithValue(implementations),
    ],
  );
}

IncomingTalentPromotionStabilizationReview _submitReview(
  ProviderContainer container,
  IncomingTalentPromotionImplementation implementation,
) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft =
      IncomingTalentPromotionStabilizationReviewDraft.fromImplementation(
        implementation: implementation,
        asOfDate: asOfDate,
      );

  return container
      .read(incomingTalentPromotionStabilizationReviewsProvider.notifier)
      .submitDraft(draft);
}
