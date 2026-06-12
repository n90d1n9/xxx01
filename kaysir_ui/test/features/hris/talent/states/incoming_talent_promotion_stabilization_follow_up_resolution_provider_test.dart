import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_stabilization_follow_up_resolution_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_promotion_stabilization_review_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_stabilization_follow_up_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_promotion_stabilization_follow_up_resolution_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('promotion follow-up resolution draft defaults from resolved action', () {
    final asOfDate = DateTime(2026, 7, 28);
    final action = _action(
      asOfDate,
      status: IncomingTalentPromotionStabilizationFollowUpStatus.resolved,
      confidenceScore: 3,
    );

    final draft =
        IncomingTalentPromotionStabilizationFollowUpResolutionDraft.fromAction(
          action: action,
          asOfDate: asOfDate,
        );

    expect(draft.actionId, action.id);
    expect(draft.reviewerName, action.ownerName);
    expect(
      draft.outcome,
      IncomingTalentPromotionStabilizationFollowUpResolutionOutcome.stabilized,
    );
    expect(draft.confidenceBefore, 3);
    expect(draft.confidenceAfter, 4);
    expect(draft.residualRiskCount, 0);
    expect(draft.nextReviewDate, asOfDate.add(const Duration(days: 45)));
    expect(draft.isReadyToSubmit, isTrue);
  });

  test(
    'promotion follow-up resolutions submit, de-duplicate, and summarize',
    () {
      final asOfDate = DateTime(2026, 7, 28);
      final action = _action(asOfDate);
      final container = _container(asOfDate, actions: [action]);
      addTearDown(container.dispose);

      expect(
        container.read(
          resolutionReadyPromotionStabilizationFollowUpActionsProvider,
        ),
        [action],
      );

      final resolution = _submitResolution(container, action);

      expect(resolution.id, 'talent-promotion-follow-up-resolution-001');
      expect(
        resolution.outcome,
        IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
            .stabilized,
      );
      expect(resolution.needsAttention, isFalse);
      expect(
        container.read(
          resolutionReadyPromotionStabilizationFollowUpActionsProvider,
        ),
        isEmpty,
      );
      expect(() => _submitResolution(container, action), throwsStateError);

      final summary = container.read(
        incomingTalentPromotionStabilizationFollowUpResolutionSummaryProvider,
      );
      expect(summary.totalCount, 1);
      expect(summary.stabilizedCount, 1);
      expect(summary.averageConfidenceAfter, 4);
      expect(summary.averageConfidenceDelta, 1);
      expect(
        summary.nextAction,
        '1 promotion follow-up resolutions are stable.',
      );
    },
  );

  test('promotion follow-up resolution draft validates fields', () {
    final asOfDate = DateTime(2026, 7, 28);
    final draft =
        IncomingTalentPromotionStabilizationFollowUpResolutionDraft.empty(
          asOfDate,
        ).copyWith(
          actionStatus: IncomingTalentPromotionStabilizationFollowUpStatus.open,
          reviewDate: asOfDate.subtract(const Duration(days: 1)),
          confidenceAfter: 0,
          residualRiskCount: -1,
          evidenceSummary: 'short',
          managerNote: 'tiny',
          nextAction: 'brief',
        );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a resolved or escalated follow-up',
      'Please enter a reviewer',
      'Follow-up must be resolved or escalated before review',
      'Resolution review date cannot be in the past',
      'Select resolution outcome',
      'Confidence must be between 1 and 5',
      'Residual risk cannot be negative',
      'Evidence summary must be at least 12 characters',
      'Manager note must be at least 12 characters',
      'Next action must be at least 12 characters',
      'Select next review date',
    ]);
  });

  test(
    'promotion follow-up resolutions follow filters and escalated outcomes',
    () {
      final asOfDate = DateTime(2026, 7, 28);
      final container = _container(asOfDate);
      addTearDown(container.dispose);
      final engineeringAction = _action(asOfDate);
      final financeAction = _action(
        asOfDate,
        id: 'finance',
        department: 'Finance',
        currentRole: 'Finance Analyst',
        newRole: 'Finance Lead',
        status: IncomingTalentPromotionStabilizationFollowUpStatus.escalated,
        confidenceScore: 2,
      );

      _submitResolution(container, engineeringAction);
      final financeResolution = _submitResolution(container, financeAction);

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      final filtered = container.read(
        filteredIncomingTalentPromotionStabilizationFollowUpResolutionsProvider,
      );
      final summary = container.read(
        incomingTalentPromotionStabilizationFollowUpResolutionSummaryProvider,
      );

      expect(filtered, [financeResolution]);
      expect(filtered.single.needsAttention, isTrue);
      expect(
        filtered.single.outcome,
        IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
            .peoplePanelEscalation,
      );
      expect(summary.totalCount, 1);
      expect(summary.escalatedCount, 1);
      expect(summary.attentionCount, 1);
      expect(
        summary.nextAction,
        'Escalate 1 promotion resolutions to people panel.',
      );
    },
  );
}

ProviderContainer _container(
  DateTime asOfDate, {
  List<IncomingTalentPromotionStabilizationFollowUpAction> actions = const [],
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      if (actions.isNotEmpty)
        filteredIncomingTalentPromotionStabilizationFollowUpActionsProvider
            .overrideWithValue(actions),
    ],
  );
}

IncomingTalentPromotionStabilizationFollowUpResolution _submitResolution(
  ProviderContainer container,
  IncomingTalentPromotionStabilizationFollowUpAction action,
) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft =
      IncomingTalentPromotionStabilizationFollowUpResolutionDraft.fromAction(
        action: action,
        asOfDate: asOfDate,
      );

  return container
      .read(
        incomingTalentPromotionStabilizationFollowUpResolutionsProvider
            .notifier,
      )
      .submitDraft(draft);
}

IncomingTalentPromotionStabilizationFollowUpAction _action(
  DateTime asOfDate, {
  String id = 'engineering',
  String department = 'Engineering',
  String currentRole = 'Backend Engineer',
  String newRole = 'Lead Backend Engineer',
  IncomingTalentPromotionStabilizationFollowUpStatus status =
      IncomingTalentPromotionStabilizationFollowUpStatus.resolved,
  int confidenceScore = 3,
}) {
  return IncomingTalentPromotionStabilizationFollowUpAction(
    id: 'promotion-follow-up-$id',
    reviewId: 'promotion-review-$id',
    implementationId: 'promotion-implementation-$id',
    decisionId: 'promotion-decision-$id',
    candidateId: 'candidate-$id',
    candidateName: '$department Talent',
    department: department,
    currentRole: currentRole,
    newRole: newRole,
    frameworkLevelCode: 'L5',
    ownerName: '$department HRBP',
    actionType:
        IncomingTalentPromotionStabilizationFollowUpActionType.managerCoaching,
    priority: IncomingTalentPromotionStabilizationFollowUpPriority.critical,
    status: status,
    dueDate: asOfDate.subtract(const Duration(days: 7)),
    actionPlan:
        'Run manager coaching checkpoint and clarify promotion measures.',
    successCriteria:
        'Manager and employee confirm clear promotion support cadence.',
    escalationNote: 'Escalate if the promotion support cadence stalls.',
    resolutionNote:
        'Manager and employee confirmed the promotion support cadence.',
    sourceOutcome:
        IncomingTalentPromotionStabilizationOutcome.needsManagerSupport,
    sourceReviewStatus:
        IncomingTalentPromotionStabilizationStatus.followUpRequired,
    sourceConfidenceScore: confidenceScore,
    createdAt: asOfDate.subtract(const Duration(days: 14)),
  );
}
