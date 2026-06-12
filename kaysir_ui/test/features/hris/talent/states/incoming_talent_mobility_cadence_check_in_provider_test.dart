import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_cadence_check_in_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_stabilization_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('mobility cadence check-in submits from due outcome', () {
    final asOfDate = DateTime(2026, 6, 6);
    final outcome = _outcome(
      asOfDate,
      department: 'Engineering',
      decision: IncomingTalentMobilityStabilizationOutcomeDecision.monitor,
      residualRisk: IncomingTalentMobilityStabilizationResidualRisk.moderate,
      confidence: 3,
    );
    final container = _container(asOfDate, outcomes: [outcome]);
    addTearDown(container.dispose);

    expect(container.read(cadenceReadyMobilityStabilizationOutcomesProvider), [
      outcome,
    ]);

    container
        .read(incomingTalentMobilityCadenceCheckInDraftProvider.notifier)
        .initializeFromOutcome(outcome);
    final draft = container.read(
      incomingTalentMobilityCadenceCheckInDraftProvider,
    );
    final checkIn = container
        .read(incomingTalentMobilityCadenceCheckInsProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentMobilityCadenceCheckInSummaryProvider,
    );

    expect(checkIn.id, 'talent-mobility-cadence-check-in-001');
    expect(checkIn.outcomeId, outcome.id);
    expect(checkIn.status, IncomingTalentMobilityCadenceStatus.watch);
    expect(checkIn.residualRisk, outcome.residualRisk);
    expect(checkIn.confidenceDelta, 0);
    expect(summary.totalCount, 1);
    expect(summary.watchCount, 1);
    expect(summary.nextAction, 'Review 1 mobility cadence watches.');
    expect(
      container.read(cadenceReadyMobilityStabilizationOutcomesProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(incomingTalentMobilityCadenceCheckInsProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('mobility cadence check-in draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 6);
    final draft = IncomingTalentMobilityCadenceCheckInDraft.empty(
      asOfDate,
    ).copyWith(
      checkInDate: asOfDate.subtract(const Duration(days: 1)),
      hostConfidenceScore: 6,
      pulseSummary: 'tiny',
      supportPlan: 'short',
      nextReviewDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a mobility outcome',
      'Please enter a cadence reviewer',
      'Check-in date cannot be in the past',
      'Select cadence status',
      'Select residual risk',
      'Host confidence must be between 1 and 5',
      'Pulse summary must be at least 12 characters',
      'Support plan must be at least 12 characters',
      'Next review date must be after check-in date',
    ]);
  });

  test('mobility cadence check-ins filter by department and attention', () {
    final asOfDate = DateTime(2026, 6, 6);
    final engineering = _outcome(
      asOfDate,
      id: 'engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      decision: IncomingTalentMobilityStabilizationOutcomeDecision.resolved,
      residualRisk: IncomingTalentMobilityStabilizationResidualRisk.low,
      confidence: 5,
    );
    final finance = _outcome(
      asOfDate,
      id: 'finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      decision: IncomingTalentMobilityStabilizationOutcomeDecision.monitor,
      residualRisk: IncomingTalentMobilityStabilizationResidualRisk.high,
      confidence: 2,
    );
    final container = _container(asOfDate, outcomes: [engineering, finance]);
    addTearDown(container.dispose);

    _submitCheckIn(
      container,
      engineering,
      status: IncomingTalentMobilityCadenceStatus.onTrack,
      residualRisk: IncomingTalentMobilityStabilizationResidualRisk.low,
      confidence: 5,
    );
    _submitCheckIn(
      container,
      finance,
      status: IncomingTalentMobilityCadenceStatus.intervene,
      residualRisk: IncomingTalentMobilityStabilizationResidualRisk.high,
      confidence: 2,
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentMobilityCadenceCheckInsProvider,
    );
    final summary = container.read(
      incomingTalentMobilityCadenceCheckInSummaryProvider,
    );

    expect(filtered.map((item) => item.candidateName), ['Mira Lestari']);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.totalCount, 1);
    expect(summary.interventionCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.averageHostConfidence, 2);
    expect(summary.nextAction, 'Intervene on 1 mobility cadence risks.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentMobilityStabilizationOutcome> outcomes,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentMobilityStabilizationOutcomesProvider
          .overrideWithValue(outcomes),
    ],
  );
}

IncomingTalentMobilityCadenceCheckIn _submitCheckIn(
  ProviderContainer container,
  IncomingTalentMobilityStabilizationOutcome outcome, {
  IncomingTalentMobilityCadenceStatus? status,
  IncomingTalentMobilityStabilizationResidualRisk? residualRisk,
  int? confidence,
}) {
  final draftNotifier = container.read(
    incomingTalentMobilityCadenceCheckInDraftProvider.notifier,
  );
  draftNotifier.initializeFromOutcome(outcome);
  if (status != null) draftNotifier.setStatus(status);
  if (residualRisk != null) draftNotifier.setResidualRisk(residualRisk);
  if (confidence != null) draftNotifier.setHostConfidenceScore(confidence);
  return container
      .read(incomingTalentMobilityCadenceCheckInsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentMobilityCadenceCheckInDraftProvider),
      );
}

IncomingTalentMobilityStabilizationOutcome _outcome(
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  required String department,
  required IncomingTalentMobilityStabilizationOutcomeDecision decision,
  required IncomingTalentMobilityStabilizationResidualRisk residualRisk,
  required int confidence,
}) {
  return IncomingTalentMobilityStabilizationOutcome(
    id: 'outcome-$id',
    actionId: 'action-$id',
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
    actionType:
        IncomingTalentMobilityStabilizationActionType.hostManagerCoaching,
    actionStatus: IncomingTalentMobilityStabilizationStatus.completed,
    actionOwnerName: '$department Mobility Owner',
    actionSummary: '$department stabilization action was completed.',
    reviewOutcomeBefore: IncomingTalentMobilityFirstReviewOutcome.watch,
    retentionRiskBefore:
        IncomingTalentMobilityFirstReviewRetentionRisk.moderate,
    hostConfidenceBefore: confidence - 1,
    reviewerName: '$department Mobility Reviewer',
    outcomeDate: asOfDate,
    decision: decision,
    residualRisk: residualRisk,
    hostConfidenceAfter: confidence,
    evidenceSummary: '$department evidence confirms mobility stabilization.',
    learningSummary: '$department learning was added to mobility playbooks.',
    nextCadenceAction: '$department cadence needs host manager follow-up.',
    nextReviewDate: asOfDate,
    createdAt: asOfDate,
  );
}
