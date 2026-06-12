import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_succession_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_cadence_check_in_provider.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_mobility_cadence_intervention_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('mobility cadence intervention submits from risky check-in', () {
    final asOfDate = DateTime(2026, 6, 6);
    final checkIn = _checkIn(
      asOfDate,
      department: 'Engineering',
      status: IncomingTalentMobilityCadenceStatus.intervene,
      residualRisk: IncomingTalentMobilityStabilizationResidualRisk.high,
      confidence: 2,
    );
    final container = _container(asOfDate, checkIns: [checkIn]);
    addTearDown(container.dispose);

    expect(container.read(interventionReadyMobilityCadenceCheckInsProvider), [
      checkIn,
    ]);

    container
        .read(incomingTalentMobilityCadenceInterventionDraftProvider.notifier)
        .initializeFromCheckIn(checkIn);
    final draft = container.read(
      incomingTalentMobilityCadenceInterventionDraftProvider,
    );
    final intervention = container
        .read(incomingTalentMobilityCadenceInterventionsProvider.notifier)
        .submitDraft(draft);
    final summary = container.read(
      incomingTalentMobilityCadenceInterventionSummaryProvider,
    );

    expect(intervention.id, 'talent-mobility-cadence-intervention-001');
    expect(intervention.checkInId, checkIn.id);
    expect(
      intervention.interventionType,
      IncomingTalentMobilityCadenceInterventionType.sponsorEscalation,
    );
    expect(
      intervention.priority,
      IncomingTalentMobilityCadenceInterventionPriority.urgent,
    );
    expect(
      intervention.status,
      IncomingTalentMobilityCadenceInterventionStatus.inProgress,
    );
    expect(intervention.needsAttention, isTrue);
    expect(summary.totalCount, 1);
    expect(summary.inProgressCount, 1);
    expect(summary.urgentCount, 1);
    expect(summary.nextAction, 'Resolve 1 urgent mobility interventions.');
    expect(
      container.read(interventionReadyMobilityCadenceCheckInsProvider),
      isEmpty,
    );

    expect(
      () => container
          .read(incomingTalentMobilityCadenceInterventionsProvider.notifier)
          .submitDraft(draft),
      throwsStateError,
    );
  });

  test('mobility cadence intervention draft validates fields', () {
    final asOfDate = DateTime(2026, 6, 6);
    final draft = IncomingTalentMobilityCadenceInterventionDraft.empty(
      asOfDate,
    ).copyWith(
      status: IncomingTalentMobilityCadenceInterventionStatus.blocked,
      dueDate: asOfDate.subtract(const Duration(days: 1)),
      interventionSummary: 'tiny',
      successMeasure: 'short',
      blockerNote: 'mini',
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a mobility cadence check-in',
      'Please enter an intervention owner',
      'Select intervention type',
      'Select priority',
      'Due date cannot be in the past',
      'Intervention summary must be at least 12 characters',
      'Success measure must be at least 12 characters',
      'Blocker note must be at least 12 characters',
    ]);
  });

  test('mobility cadence interventions follow lifecycle and filters', () {
    final asOfDate = DateTime(2026, 6, 6);
    final engineering = _checkIn(
      asOfDate,
      id: 'engineering',
      candidateName: 'Fajar Nugroho',
      department: 'Engineering',
      status: IncomingTalentMobilityCadenceStatus.watch,
      residualRisk: IncomingTalentMobilityStabilizationResidualRisk.moderate,
      confidence: 3,
    );
    final finance = _checkIn(
      asOfDate,
      id: 'finance',
      candidateName: 'Mira Lestari',
      department: 'Finance',
      status: IncomingTalentMobilityCadenceStatus.intervene,
      residualRisk: IncomingTalentMobilityStabilizationResidualRisk.high,
      confidence: 2,
    );
    final container = _container(asOfDate, checkIns: [engineering, finance]);
    addTearDown(container.dispose);

    final engineeringIntervention = _submitIntervention(container, engineering);
    final notifier = container.read(
      incomingTalentMobilityCadenceInterventionsProvider.notifier,
    );
    notifier.resolve(engineeringIntervention.id);

    final financeIntervention = _submitIntervention(container, finance);
    notifier.block(financeIntervention.id);

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentMobilityCadenceInterventionsProvider,
    );
    final summary = container.read(
      incomingTalentMobilityCadenceInterventionSummaryProvider,
    );

    expect(filtered.map((item) => item.candidateName), ['Mira Lestari']);
    expect(
      filtered.single.status,
      IncomingTalentMobilityCadenceInterventionStatus.blocked,
    );
    expect(summary.totalCount, 1);
    expect(summary.blockedCount, 1);
    expect(summary.attentionCount, 1);
    expect(summary.nextAction, 'Unblock 1 mobility interventions.');
  });
}

ProviderContainer _container(
  DateTime asOfDate, {
  required List<IncomingTalentMobilityCadenceCheckIn> checkIns,
}) {
  return ProviderContainer(
    overrides: [
      talentAsOfDateProvider.overrideWithValue(asOfDate),
      filteredIncomingTalentMobilityCadenceCheckInsProvider.overrideWithValue(
        checkIns,
      ),
    ],
  );
}

IncomingTalentMobilityCadenceIntervention _submitIntervention(
  ProviderContainer container,
  IncomingTalentMobilityCadenceCheckIn checkIn,
) {
  container
      .read(incomingTalentMobilityCadenceInterventionDraftProvider.notifier)
      .initializeFromCheckIn(checkIn);
  return container
      .read(incomingTalentMobilityCadenceInterventionsProvider.notifier)
      .submitDraft(
        container.read(incomingTalentMobilityCadenceInterventionDraftProvider),
      );
}

IncomingTalentMobilityCadenceCheckIn _checkIn(
  DateTime asOfDate, {
  String id = 'engineering',
  String candidateName = 'Fajar Nugroho',
  required String department,
  required IncomingTalentMobilityCadenceStatus status,
  required IncomingTalentMobilityStabilizationResidualRisk residualRisk,
  required int confidence,
}) {
  return IncomingTalentMobilityCadenceCheckIn(
    id: 'check-in-$id',
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
    outcomeDecision: IncomingTalentMobilityStabilizationOutcomeDecision.monitor,
    previousResidualRisk: residualRisk,
    previousHostConfidence: confidence + 1,
    reviewerName: '$department Mobility Reviewer',
    checkInDate: asOfDate,
    status: status,
    residualRisk: residualRisk,
    hostConfidenceScore: confidence,
    pulseSummary: '$department mobility pulse needs targeted support.',
    supportPlan: '$department support plan needs owner follow-up.',
    nextReviewDate: asOfDate.add(const Duration(days: 14)),
    createdAt: asOfDate,
  );
}
