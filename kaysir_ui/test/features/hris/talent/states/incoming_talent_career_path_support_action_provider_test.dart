import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_review_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_support_action_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_path_review_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_path_support_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('career path support action draft defaults from blocked review', () {
    final asOfDate = DateTime(2026, 6, 7);
    final review = _review(
      asOfDate,
      decision: IncomingTalentCareerPathReviewDecision.blocked,
      reviewedLevel: 1,
      targetLevel: 4,
    );

    final draft = IncomingTalentCareerPathSupportActionDraft.fromReview(
      review: review,
      asOfDate: asOfDate,
    );

    expect(draft.reviewId, review.id);
    expect(
      draft.actionType,
      IncomingTalentCareerPathSupportActionType.managerUnblocker,
    );
    expect(
      draft.priority,
      IncomingTalentCareerPathSupportActionPriority.critical,
    );
    expect(draft.status, IncomingTalentCareerPathSupportActionStatus.open);
    expect(draft.dueDate, asOfDate.add(const Duration(days: 7)));
    expect(draft.ownerName, review.reviewerName);
    expect(draft.sourceLevelGap, 3);
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('career path support actions submit, de-duplicate, and summarize', () {
    final asOfDate = DateTime(2026, 6, 7);
    final review = _review(
      asOfDate,
      decision: IncomingTalentCareerPathReviewDecision.blocked,
      reviewedLevel: 1,
      targetLevel: 4,
    );
    final container = _container(asOfDate, reviews: [review]);
    addTearDown(container.dispose);

    final draft = _initializeDraft(container, review);
    final action = container
        .read(incomingTalentCareerPathSupportActionsProvider.notifier)
        .submitDraft(draft);

    expect(action.id, 'talent-career-support-001');
    expect(action.needsAttention, isTrue);
    expect(
      container.read(careerPathSupportActionReadyReviewsProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(incomingTalentCareerPathSupportActionsProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );

    final summary = container.read(
      incomingTalentCareerPathSupportActionSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.criticalCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Resolve 1 critical career support actions.');
  });

  test('career path support action draft validates required fields', () {
    final asOfDate = DateTime(2026, 6, 7);
    final draft = IncomingTalentCareerPathSupportActionDraft.empty(
      asOfDate,
    ).copyWith(
      dueDate: asOfDate.subtract(const Duration(days: 1)),
      actionPlan: 'short',
      successCriteria: 'tiny',
      escalationNote: 'mini',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a career path review',
      'Please enter an owner',
      'Select action type',
      'Select priority',
      'Select action status',
      'Due date cannot be in the past',
      'Action plan must be at least 12 characters',
      'Success criteria must be at least 12 characters',
      'Escalation note must be at least 12 characters',
    ]);
  });

  test('career path support actions follow talent filters', () {
    final asOfDate = DateTime(2026, 6, 7);
    final engineeringReview = _review(
      asOfDate,
      id: 'career-review-engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      decision: IncomingTalentCareerPathReviewDecision.needsSupport,
      reviewedLevel: 3,
      targetLevel: 4,
    );
    final financeReview = _review(
      asOfDate,
      id: 'career-review-finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      decision: IncomingTalentCareerPathReviewDecision.blocked,
      reviewedLevel: 1,
      targetLevel: 4,
    );
    final container = _container(
      asOfDate,
      reviews: [engineeringReview, financeReview],
    );
    addTearDown(container.dispose);

    _submitAction(container, engineeringReview);
    _submitAction(container, financeReview);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentCareerPathSupportActionsProvider,
    );
    final summary = container.read(
      incomingTalentCareerPathSupportActionSummaryProvider,
    );

    expect(filtered.map((action) => action.candidateName), ['Mira Lestari']);
    expect(
      filtered.single.priority,
      IncomingTalentCareerPathSupportActionPriority.critical,
    );
    expect(summary.totalCount, 1);
    expect(summary.openCount, 1);
    expect(summary.nextAction, 'Resolve 1 critical career support actions.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentCareerPathReview> reviews,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentCareerPathReviewsProvider.overrideWithValue(
        reviews,
      ),
    ],
  );
}

IncomingTalentCareerPathSupportActionDraft _initializeDraft(
  ProviderContainer container,
  IncomingTalentCareerPathReview review,
) {
  container
      .read(incomingTalentCareerPathSupportActionDraftProvider.notifier)
      .initializeFromReview(review);
  return container.read(incomingTalentCareerPathSupportActionDraftProvider);
}

IncomingTalentCareerPathSupportAction _submitAction(
  ProviderContainer container,
  IncomingTalentCareerPathReview review,
) {
  final draft = _initializeDraft(container, review);
  return container
      .read(incomingTalentCareerPathSupportActionsProvider.notifier)
      .submitDraft(draft);
}

IncomingTalentCareerPathReview _review(
  DateTime asOfDate, {
  String id = 'career-review-001',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  required IncomingTalentCareerPathReviewDecision decision,
  required int reviewedLevel,
  required int targetLevel,
}) {
  return IncomingTalentCareerPathReview(
    id: id,
    careerPathId: 'career-$id',
    portfolioId: 'portfolio-$id',
    roadmapId: 'roadmap-$id',
    candidateId: 'candidate-${candidateName.toLowerCase().split(' ').first}',
    candidateName: candidateName,
    department: department,
    currentRole: '$department Specialist',
    targetRole: '$department Lead',
    competencyName: '$department capability review',
    reviewerName: '$department Manager',
    reviewDate: asOfDate,
    decision: decision,
    previousLevel: 1,
    reviewedLevel: reviewedLevel,
    targetLevel: targetLevel,
    evidenceNote: 'Manager reviewed signed growth evidence.',
    blockerNote: 'Manager documented support blockers for follow up.',
    nextAction: 'Create focused support action with owner.',
    nextReviewDate: asOfDate.add(const Duration(days: 14)),
    sourceStatus:
        decision == IncomingTalentCareerPathReviewDecision.blocked
            ? IncomingTalentCareerPathStatus.blocked
            : IncomingTalentCareerPathStatus.active,
    sourcePriority:
        decision == IncomingTalentCareerPathReviewDecision.blocked
            ? IncomingTalentCareerPathPriority.critical
            : IncomingTalentCareerPathPriority.standard,
    createdAt: asOfDate,
  );
}
