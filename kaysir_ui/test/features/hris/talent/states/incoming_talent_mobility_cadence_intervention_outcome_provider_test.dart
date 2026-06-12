import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_cadence_intervention_outcome_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_cadence_intervention_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('mobility intervention outcome submits from resolved intervention', () {
    final asOfDate = DateTime(2026, 6, 6);
    final intervention = _intervention(
      asOfDate,
      department: 'Engineering',
      priority: IncomingTalentMobilityCadenceInterventionPriority.standard,
      residualRisk: IncomingTalentMobilityStabilizationResidualRisk.low,
      confidence: 4,
    );
    final container = _container(asOfDate, interventions: [intervention]);
    addTearDown(container.dispose);

    expect(container.read(outcomeReadyMobilityCadenceInterventionsProvider), [
      intervention,
    ]);

    container
        .read(
          incomingTalentMobilityCadenceInterventionOutcomeDraftProvider
              .notifier,
        )
        .initializeFromIntervention(intervention);
    final draft = container.read(
      incomingTalentMobilityCadenceInterventionOutcomeDraftProvider,
    );
    final outcome = container
        .read(
          incomingTalentMobilityCadenceInterventionOutcomesProvider.notifier,
        )
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentMobilityCadenceInterventionOutcomeSummaryProvider,
    );

    expect(outcome.id, 'talent-mobility-intervention-outcome-001');
    expect(outcome.interventionId, intervention.id);
    expect(
      outcome.interventionStatus,
      IncomingTalentMobilityCadenceInterventionStatus.resolved,
    );
    expect(
      outcome.decision,
      IncomingTalentMobilityCadenceInterventionOutcomeDecision.recovered,
    );
    expect(outcome.confidenceRecovery, 1);
    expect(summary.totalCount, 1);
    expect(summary.recoveredCount, 1);
    expect(summary.nextAction, 'Archive 1 recovery wins.');
    expect(
      container.read(outcomeReadyMobilityCadenceInterventionsProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(
            incomingTalentMobilityCadenceInterventionOutcomesProvider.notifier,
          )
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('mobility intervention outcome draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 6);
    final draft = IncomingTalentMobilityCadenceInterventionOutcomeDraft.empty(
      asOfDate,
    ).copyWith(
      interventionStatus:
          IncomingTalentMobilityCadenceInterventionStatus.blocked,
      reviewDate: asOfDate.subtract(const Duration(days: 1)),
      hostConfidenceAfter: 6,
      evidenceSummary: 'tiny',
      learningSummary: 'mini',
      nextCadenceAction: 'short',
      nextReviewDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a resolved intervention',
      'Please enter an outcome reviewer',
      'Intervention must be resolved before outcome',
      'Review date cannot be in the past',
      'Select outcome decision',
      'Select sustainability',
      'Select residual risk',
      'Host confidence must be between 1 and 5',
      'Evidence summary must be at least 12 characters',
      'Learning summary must be at least 12 characters',
      'Next cadence action must be at least 12 characters',
      'Next review date must be after review date',
    ]);
  });

  test('mobility intervention outcomes filter by department and attention', () {
    final asOfDate = DateTime(2026, 6, 6);
    final engineering = _intervention(
      asOfDate,
      id: 'engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      priority: IncomingTalentMobilityCadenceInterventionPriority.standard,
      residualRisk: IncomingTalentMobilityStabilizationResidualRisk.low,
      confidence: 4,
    );
    final finance = _intervention(
      asOfDate,
      id: 'finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      priority: IncomingTalentMobilityCadenceInterventionPriority.urgent,
      residualRisk: IncomingTalentMobilityStabilizationResidualRisk.high,
      confidence: 2,
    );
    final container = _container(
      asOfDate,
      interventions: [engineering, finance],
    );
    addTearDown(container.dispose);

    _submitOutcome(container, engineering);
    _submitOutcome(
      container,
      finance,
      decision:
          IncomingTalentMobilityCadenceInterventionOutcomeDecision.escalate,
      sustainability:
          IncomingTalentMobilityCadenceInterventionSustainability.fragile,
      residualRisk: IncomingTalentMobilityStabilizationResidualRisk.high,
      confidence: 2,
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentMobilityCadenceInterventionOutcomesProvider,
    );
    final summary = container.read(
      incomingTalentMobilityCadenceInterventionOutcomeSummaryProvider,
    );

    expect(filtered.map((item) => item.candidateName), ['Mira Lestari']);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.totalCount, 1);
    expect(summary.escalateCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.averageHostConfidence, 2);
    expect(summary.nextAction, 'Escalate 1 intervention outcomes.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentMobilityCadenceIntervention> interventions,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentMobilityCadenceInterventionsProvider
          .overrideWithValue(interventions),
    ],
  );
}

IncomingTalentMobilityCadenceInterventionOutcome _submitOutcome(
  ProviderContainer container,
  IncomingTalentMobilityCadenceIntervention intervention, {
  IncomingTalentMobilityCadenceInterventionOutcomeDecision? decision,
  IncomingTalentMobilityCadenceInterventionSustainability? sustainability,
  IncomingTalentMobilityStabilizationResidualRisk? residualRisk,
  int? confidence,
}) {
  final draftNotifier = container.read(
    incomingTalentMobilityCadenceInterventionOutcomeDraftProvider.notifier,
  );
  draftNotifier.initializeFromIntervention(intervention);
  if (decision != null) draftNotifier.setDecision(decision);
  if (sustainability != null) {
    draftNotifier.setSustainability(sustainability);
  }
  if (residualRisk != null) {
    draftNotifier.setResidualRiskAfter(residualRisk);
  }
  if (confidence != null) {
    draftNotifier.setHostConfidenceAfter(confidence);
  }
  return container
      .read(incomingTalentMobilityCadenceInterventionOutcomesProvider.notifier)
      .submitDraft(
        container.read(
          incomingTalentMobilityCadenceInterventionOutcomeDraftProvider,
        ),
      );
}

IncomingTalentMobilityCadenceIntervention _intervention(
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  required String department,
  required IncomingTalentMobilityCadenceInterventionPriority priority,
  required IncomingTalentMobilityStabilizationResidualRisk residualRisk,
  required int confidence,
}) {
  return IncomingTalentMobilityCadenceIntervention(
    id: 'intervention-$id',
    checkInId: 'check-in-$id',
    outcomeId: 'outcome-$id',
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
    cadenceStatus: IncomingTalentMobilityCadenceStatus.watch,
    residualRisk: residualRisk,
    hostConfidenceScore: confidence,
    interventionType:
        IncomingTalentMobilityCadenceInterventionType.managerCoaching,
    priority: priority,
    status: IncomingTalentMobilityCadenceInterventionStatus.resolved,
    ownerName: '$department Mobility Owner',
    dueDate: asOfDate,
    interventionSummary: '$department mobility recovery action was completed.',
    successMeasure:
        '$department host confidence improved above risk threshold.',
    blockerNote: '',
    createdAt: asOfDate,
  );
}
