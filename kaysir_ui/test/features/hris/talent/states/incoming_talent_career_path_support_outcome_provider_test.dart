import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_review_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_support_action_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_career_path_support_outcome_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_path_support_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_career_path_support_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('career path support outcome draft defaults from resolved action', () {
    final asOfDate = DateTime(2026, 6, 7);
    final action = _action(
      asOfDate,
      status: IncomingTalentCareerPathSupportActionStatus.resolved,
      priority: IncomingTalentCareerPathSupportActionPriority.critical,
      sourceDecision: IncomingTalentCareerPathReviewDecision.blocked,
      reviewedLevel: 1,
      targetLevel: 4,
    );

    final draft = IncomingTalentCareerPathSupportOutcomeDraft.fromAction(
      action: action,
      asOfDate: asOfDate,
    );

    expect(draft.actionId, action.id);
    expect(
      draft.decision,
      IncomingTalentCareerPathSupportOutcomeDecision.improved,
    );
    expect(
      draft.residualRisk,
      IncomingTalentCareerPathSupportOutcomeResidualRisk.high,
    );
    expect(draft.verifiedLevel, 2);
    expect(draft.nextReviewDate, asOfDate.add(const Duration(days: 30)));
    expect(draft.reviewerName, action.ownerName);
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('career path support outcomes submit, de-duplicate, and summarize', () {
    final asOfDate = DateTime(2026, 6, 7);
    final action = _action(
      asOfDate,
      status: IncomingTalentCareerPathSupportActionStatus.resolved,
      priority: IncomingTalentCareerPathSupportActionPriority.critical,
      sourceDecision: IncomingTalentCareerPathReviewDecision.blocked,
      reviewedLevel: 1,
      targetLevel: 4,
    );
    final container = _container(asOfDate, actions: [action]);
    addTearDown(container.dispose);

    expect(container.read(careerPathSupportOutcomeReadyActionsProvider), [
      action,
    ]);

    final draft = _initializeDraft(container, action);
    final outcome = container
        .read(incomingTalentCareerPathSupportOutcomesProvider.notifier)
        .submitDraft(draft);

    expect(outcome.id, 'talent-career-support-outcome-001');
    expect(outcome.actionId, action.id);
    expect(outcome.levelGain, 1);
    expect(outcome.needsAttention, isTrue);
    expect(
      container.read(careerPathSupportOutcomeReadyActionsProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(incomingTalentCareerPathSupportOutcomesProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );

    final summary = container.read(
      incomingTalentCareerPathSupportOutcomeSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.improvedCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.averageVerifiedLevel, 2);
    expect(summary.nextAction, 'Follow up 1 residual career risks.');
  });

  test('career path support outcome draft validates required fields', () {
    final asOfDate = DateTime(2026, 6, 7);
    final draft = IncomingTalentCareerPathSupportOutcomeDraft.empty(
      asOfDate,
    ).copyWith(
      actionStatus: IncomingTalentCareerPathSupportActionStatus.open,
      outcomeDate: asOfDate.subtract(const Duration(days: 1)),
      verifiedLevel: 0,
      evidenceSummary: 'tiny',
      managerNote: 'mini',
      nextReviewAction: 'short',
      nextReviewDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a resolved support action',
      'Please enter an outcome reviewer',
      'Action must be resolved before outcome',
      'Outcome date cannot be in the past',
      'Select outcome decision',
      'Select residual risk',
      'Verified level must be between 1 and 5',
      'Evidence summary must be at least 12 characters',
      'Manager note must be at least 12 characters',
      'Next review action must be at least 12 characters',
      'Next review date must be after outcome date',
    ]);
  });

  test('career path support outcomes follow talent filters', () {
    final asOfDate = DateTime(2026, 6, 7);
    final engineering = _action(
      asOfDate,
      id: 'engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      status: IncomingTalentCareerPathSupportActionStatus.resolved,
      priority: IncomingTalentCareerPathSupportActionPriority.medium,
      sourceDecision: IncomingTalentCareerPathReviewDecision.needsSupport,
      reviewedLevel: 4,
      targetLevel: 5,
    );
    final finance = _action(
      asOfDate,
      id: 'finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      status: IncomingTalentCareerPathSupportActionStatus.resolved,
      priority: IncomingTalentCareerPathSupportActionPriority.critical,
      sourceDecision: IncomingTalentCareerPathReviewDecision.blocked,
      reviewedLevel: 1,
      targetLevel: 4,
    );
    final container = _container(asOfDate, actions: [engineering, finance]);
    addTearDown(container.dispose);

    _submitOutcome(
      container,
      engineering,
      decision: IncomingTalentCareerPathSupportOutcomeDecision.resolved,
      residualRisk: IncomingTalentCareerPathSupportOutcomeResidualRisk.low,
      verifiedLevel: 5,
    );
    _submitOutcome(
      container,
      finance,
      decision: IncomingTalentCareerPathSupportOutcomeDecision.monitor,
      residualRisk: IncomingTalentCareerPathSupportOutcomeResidualRisk.high,
      verifiedLevel: 2,
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentCareerPathSupportOutcomesProvider,
    );
    final summary = container.read(
      incomingTalentCareerPathSupportOutcomeSummaryProvider,
    );

    expect(filtered.map((outcome) => outcome.candidateName), ['Mira Lestari']);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.totalCount, 1);
    expect(summary.monitorCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.averageVerifiedLevel, 2);
    expect(summary.nextAction, 'Monitor 1 career support outcomes.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentCareerPathSupportAction> actions,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentCareerPathSupportActionsProvider.overrideWithValue(
        actions,
      ),
    ],
  );
}

IncomingTalentCareerPathSupportOutcomeDraft _initializeDraft(
  ProviderContainer container,
  IncomingTalentCareerPathSupportAction action,
) {
  container
      .read(incomingTalentCareerPathSupportOutcomeDraftProvider.notifier)
      .initializeFromAction(action);
  return container.read(incomingTalentCareerPathSupportOutcomeDraftProvider);
}

IncomingTalentCareerPathSupportOutcome _submitOutcome(
  ProviderContainer container,
  IncomingTalentCareerPathSupportAction action, {
  IncomingTalentCareerPathSupportOutcomeDecision? decision,
  IncomingTalentCareerPathSupportOutcomeResidualRisk? residualRisk,
  int? verifiedLevel,
}) {
  final notifier = container.read(
    incomingTalentCareerPathSupportOutcomeDraftProvider.notifier,
  );
  notifier.initializeFromAction(action);
  if (decision != null) notifier.setDecision(decision);
  if (residualRisk != null) notifier.setResidualRisk(residualRisk);
  if (verifiedLevel != null) notifier.setVerifiedLevel(verifiedLevel);
  return container
      .read(incomingTalentCareerPathSupportOutcomesProvider.notifier)
      .submitDraft(
        container.read(incomingTalentCareerPathSupportOutcomeDraftProvider),
      );
}

IncomingTalentCareerPathSupportAction _action(
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  String department = 'Engineering',
  required IncomingTalentCareerPathSupportActionStatus status,
  required IncomingTalentCareerPathSupportActionPriority priority,
  required IncomingTalentCareerPathReviewDecision sourceDecision,
  required int reviewedLevel,
  required int targetLevel,
}) {
  return IncomingTalentCareerPathSupportAction(
    id: 'support-$id',
    reviewId: 'review-$id',
    careerPathId: 'career-$id',
    portfolioId: 'portfolio-$id',
    roadmapId: 'roadmap-$id',
    candidateId: 'candidate-$id',
    candidateName: candidateName,
    department: department,
    targetRole: '$department Lead',
    competencyName: '$department capability review',
    ownerName: '$department Manager',
    actionType: IncomingTalentCareerPathSupportActionType.managerUnblocker,
    priority: priority,
    status: status,
    dueDate: asOfDate,
    actionPlan: 'Complete manager-supported capability unblocker.',
    successCriteria: 'Lift capability to target level with signed evidence.',
    escalationNote: 'Escalate support ownership if progress stalls.',
    sourceDecision: sourceDecision,
    reviewedLevel: reviewedLevel,
    targetLevel: targetLevel,
    sourceLevelGap: targetLevel - reviewedLevel,
    createdAt: asOfDate,
  );
}
