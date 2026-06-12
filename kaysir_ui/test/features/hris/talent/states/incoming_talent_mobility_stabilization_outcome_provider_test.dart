import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_stabilization_action_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_stabilization_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('mobility stabilization outcome submits from completed action', () {
    final asOfDate = DateTime(2026, 6, 6);
    final action = _action(asOfDate, department: 'Engineering');
    final container = _container(asOfDate, actions: [action]);
    addTearDown(container.dispose);

    expect(container.read(outcomeReadyMobilityStabilizationActionsProvider), [
      action,
    ]);

    container
        .read(incomingTalentMobilityStabilizationOutcomeDraftProvider.notifier)
        .initializeFromAction(action);
    final draft = container.read(
      incomingTalentMobilityStabilizationOutcomeDraftProvider,
    );
    final outcome = container
        .read(incomingTalentMobilityStabilizationOutcomesProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentMobilityStabilizationOutcomeSummaryProvider,
    );

    expect(outcome.id, 'talent-mobility-stabilization-outcome-001');
    expect(outcome.actionId, action.id);
    expect(
      outcome.actionStatus,
      IncomingTalentMobilityStabilizationStatus.completed,
    );
    expect(
      outcome.decision,
      IncomingTalentMobilityStabilizationOutcomeDecision.resolved,
    );
    expect(outcome.confidenceImprovement, 1);
    expect(summary.totalCount, 1);
    expect(summary.resolvedCount, 1);
    expect(summary.nextAction, 'Keep 1 moves on cadence.');
    expect(
      container.read(outcomeReadyMobilityStabilizationActionsProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(incomingTalentMobilityStabilizationOutcomesProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('mobility stabilization outcome draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 6);
    final draft = IncomingTalentMobilityStabilizationOutcomeDraft.empty(
      asOfDate,
    ).copyWith(
      actionStatus: IncomingTalentMobilityStabilizationStatus.blocked,
      outcomeDate: asOfDate.subtract(const Duration(days: 1)),
      hostConfidenceAfter: 6,
      evidenceSummary: 'tiny',
      learningSummary: 'mini',
      nextCadenceAction: 'short',
      nextReviewDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a completed stabilization action',
      'Please enter an outcome reviewer',
      'Action must be completed before outcome',
      'Outcome date cannot be in the past',
      'Select outcome decision',
      'Select residual risk',
      'Host confidence must be between 1 and 5',
      'Evidence summary must be at least 12 characters',
      'Learning summary must be at least 12 characters',
      'Next cadence action must be at least 12 characters',
      'Next review date must be after outcome date',
    ]);
  });

  test(
    'mobility stabilization outcomes filter by department and attention',
    () {
      final asOfDate = DateTime(2026, 6, 6);
      final engineering = _action(
        asOfDate,
        id: 'engineering',
        candidateName: 'Fajar Nugroho',
        department: 'Engineering',
        confidence: 4,
      );
      final finance = _action(
        asOfDate,
        id: 'finance',
        candidateName: 'Mira Lestari',
        department: 'Finance',
        retentionRisk: IncomingTalentMobilityFirstReviewRetentionRisk.high,
        confidence: 2,
      );
      final container = _container(asOfDate, actions: [engineering, finance]);
      addTearDown(container.dispose);

      _submitOutcome(container, engineering);
      _submitOutcome(
        container,
        finance,
        decision: IncomingTalentMobilityStabilizationOutcomeDecision.monitor,
        residualRisk: IncomingTalentMobilityStabilizationResidualRisk.high,
        confidenceAfter: 3,
      );

      container.read(talentDepartmentProvider.notifier).state = 'Finance';
      container.read(talentNeedsAttentionProvider.notifier).state = true;

      final filtered = container.read(
        filteredIncomingTalentMobilityStabilizationOutcomesProvider,
      );
      final summary = container.read(
        incomingTalentMobilityStabilizationOutcomeSummaryProvider,
      );

      expect(filtered.map((outcome) => outcome.candidateName), [
        'Mira Lestari',
      ]);
      expect(filtered.single.needsAttention, isTrue);
      expect(summary.totalCount, 1);
      expect(summary.monitorCount, 1);
      expect(summary.attentionCount, 1);
      expect(summary.averageConfidenceAfter, 3);
      expect(summary.nextAction, 'Monitor 1 mobility outcomes.');
    },
  );
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentMobilityStabilizationAction> actions,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentMobilityStabilizationActionsProvider
          .overrideWithValue(actions),
    ],
  );
}

IncomingTalentMobilityStabilizationOutcome _submitOutcome(
  ProviderContainer container,
  IncomingTalentMobilityStabilizationAction action, {
  IncomingTalentMobilityStabilizationOutcomeDecision? decision,
  IncomingTalentMobilityStabilizationResidualRisk? residualRisk,
  int? confidenceAfter,
}) {
  final draftNotifier = container.read(
    incomingTalentMobilityStabilizationOutcomeDraftProvider.notifier,
  );
  draftNotifier.initializeFromAction(action);
  if (decision != null) draftNotifier.setDecision(decision);
  if (residualRisk != null) draftNotifier.setResidualRisk(residualRisk);
  if (confidenceAfter != null) {
    draftNotifier.setHostConfidenceAfter(confidenceAfter);
  }
  return container
      .read(incomingTalentMobilityStabilizationOutcomesProvider.notifier)
      .submitDraft(
        container.read(incomingTalentMobilityStabilizationOutcomeDraftProvider),
      );
}

IncomingTalentMobilityStabilizationAction _action(
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  required String department,
  IncomingTalentMobilityFirstReviewOutcome reviewOutcome =
      IncomingTalentMobilityFirstReviewOutcome.watch,
  IncomingTalentMobilityFirstReviewRetentionRisk retentionRisk =
      IncomingTalentMobilityFirstReviewRetentionRisk.low,
  int confidence = 3,
}) {
  return IncomingTalentMobilityStabilizationAction(
    id: 'action-$id',
    reviewId: 'review-$id',
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
    reviewOutcome: reviewOutcome,
    retentionRisk: retentionRisk,
    hostConfidenceScore: confidence,
    actionType:
        IncomingTalentMobilityStabilizationActionType.hostManagerCoaching,
    status: IncomingTalentMobilityStabilizationStatus.completed,
    ownerName: '$department Mobility Owner',
    dueDate: asOfDate,
    actionSummary: '$department host manager coaching was completed.',
    successMeasure: '$department host confidence improved by one point.',
    blockerNote: '',
    createdAt: asOfDate,
  );
}
